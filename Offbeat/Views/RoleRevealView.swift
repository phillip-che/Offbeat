import SwiftUI

struct RoleRevealView: View {
    @EnvironmentObject var vm: GameViewModel
    @State private var revealed: Bool = false
    @State private var hintPulse: Bool = false

    var body: some View {
        ZStack {
            OB.Color.bg.ignoresSafeArea()

            VStack(spacing: 0) {
                topBar
                    .padding(.top, 4)
                    .padding(.horizontal, 24)

                Spacer()

                Group {
                    if revealed {
                        revealedContent
                            .transition(.opacity)
                    } else {
                        coveredContent
                            .transition(.opacity)
                    }
                }
                .padding(.horizontal, 24)
                .frame(maxWidth: .infinity)
                .contentShape(Rectangle())

                Spacer()

                PrimaryButton(title: "Next", trailingChevron: true) {
                    UIImpactFeedbackGenerator(style: .light).impactOccurred()
                    revealed = false
                    vm.advanceReveal()
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 12)
            }
        }
        .contentShape(Rectangle())
        .onTapGesture {
            // Only the central body should toggle, but a single full-screen
            // tap matches the design's "tap anywhere" promise. The Next button
            // intercepts its own taps.
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
            withAnimation(.easeInOut(duration: 0.28)) {
                revealed.toggle()
            }
        }
        .onAppear { startHintPulse() }
        .onChange(of: vm.revealIndex) { _, _ in
            // Always reset to covered when the player rotates.
            revealed = false
        }
        .navigationBarBackButtonHidden()
    }

    private var topBar: some View {
        HStack {
            // Back pill — visible only on the covered (name) state.
            // Goes to the previous player; from the first player it returns to Setup.
            Button {
                UIImpactFeedbackGenerator(style: .light).impactOccurred()
                if vm.revealIndex > 0 {
                    vm.revealIndex -= 1
                } else {
                    vm.path.removeLast()
                }
            } label: {
                HStack(spacing: 4) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 12, weight: .semibold))
                    Text("Back")
                        .font(.system(size: 14, weight: .medium))
                }
                .foregroundStyle(OB.Color.muted)
                .padding(.vertical, 7)
                .padding(.horizontal, 12)
                .background(Capsule().stroke(OB.Color.border, lineWidth: 1))
            }
            .buttonStyle(.plain)
            .opacity(revealed ? 0 : 1)
            .allowsHitTesting(!revealed)

            Spacer()

            ProgressDots(
                total: vm.session?.revealOrder.count ?? 0,
                current: vm.revealIndex
            )

            Spacer()

            Text("\(vm.revealIndex + 1) / \(vm.session?.revealOrder.count ?? 0)")
                .font(.system(size: 14, weight: .medium))
                .foregroundStyle(OB.Color.muted)
        }
    }

    // MARK: - Covered

    private var coveredContent: some View {
        VStack(spacing: 28) {
            Text("PASS THE PHONE TO")
                .font(.system(size: 14, weight: .semibold))
                .tracking(2.5)
                .foregroundStyle(OB.Color.muted)

            Text(vm.currentRevealPlayer?.name ?? "")
                .font(.system(size: 56, weight: .bold))
                .tracking(-1)
                .foregroundStyle(vm.currentRevealPlayer?.color.color ?? OB.Color.text)

            HStack(spacing: 10) {
                Circle()
                    .fill(OB.Color.accent)
                    .frame(width: 8, height: 8)
                    .opacity(hintPulse ? 1 : 0.35)
                    .animation(.easeInOut(duration: 1.6).repeatForever(autoreverses: true), value: hintPulse)
                Text("Tap to reveal your role")
                    .font(.system(size: 15, weight: .medium))
                    .foregroundStyle(OB.Color.muted)
            }
            .padding(.vertical, 11)
            .padding(.horizontal, 18)
            .background(Capsule().stroke(OB.Color.border, lineWidth: 1))
        }
    }

    private func startHintPulse() {
        hintPulse = true
    }

    // MARK: - Revealed

    @ViewBuilder
    private var revealedContent: some View {
        if let player = vm.currentRevealPlayer, let session = vm.session {
            if vm.isImpostor(player) {
                impostorView
            } else {
                themeView(theme: session.theme)
            }
        }
    }

    private func themeView(theme: String) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            // Music-note icon
            ZStack {
                Image(systemName: "music.note")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundStyle(OB.Color.accent)
            }
            .frame(width: 36, height: 36, alignment: .leading)

            Text("YOUR THEME")
                .font(.system(size: 13, weight: .semibold))
                .tracking(2.5)
                .foregroundStyle(OB.Color.muted)

            Text(theme)
                .font(.system(size: 36, weight: .bold))
                .tracking(-0.5)
                .foregroundStyle(OB.Color.text)
                .lineSpacing(2)
                .fixedSize(horizontal: false, vertical: true)

            Text("Pick a song that fits the theme. Don't give it away.")
                .font(.system(size: 16))
                .foregroundStyle(OB.Color.muted)
                .padding(.top, 4)

            Text("TAP TO HIDE")
                .font(.system(size: 12, weight: .semibold))
                .tracking(2.5)
                .foregroundStyle(OB.Color.faint)
                .padding(.top, 12)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var impostorView: some View {
        VStack(alignment: .leading, spacing: 16) {
            Image(systemName: "theatermasks")
                .font(.system(size: 26, weight: .bold))
                .foregroundStyle(OB.Color.accent)

            Text("YOUR ROLE")
                .font(.system(size: 13, weight: .semibold))
                .tracking(2.5)
                .foregroundStyle(OB.Color.accent)

            VStack(alignment: .leading, spacing: 0) {
                Text("You are the")
                    .font(.system(size: 40, weight: .bold))
                    .foregroundStyle(OB.Color.text)
                Text("Impostor.")
                    .font(.system(size: 40, weight: .bold))
                    .foregroundStyle(OB.Color.accent)
            }
            .tracking(-0.5)

            Text("You don't know the theme. Pick any song and try to blend in.")
                .font(.system(size: 16))
                .foregroundStyle(OB.Color.muted)
                .padding(.top, 4)

            Text("TAP TO HIDE")
                .font(.system(size: 12, weight: .semibold))
                .tracking(2.5)
                .foregroundStyle(OB.Color.faint)
                .padding(.top, 12)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}
