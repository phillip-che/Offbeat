import SwiftUI

struct RevealView: View {
    @EnvironmentObject var vm: GameViewModel
    @State private var revealed = false
    @State private var nameVisible = false
    @State private var pulse = false

    var body: some View {
        ZStack {
            OB.Color.bg.ignoresSafeArea()

            if revealed {
                postReveal
                    .transition(.opacity)
            } else {
                preReveal
                    .transition(.opacity)
            }

            // Faint accent pulse around frame on reveal
            if revealed {
                RoundedRectangle(cornerRadius: 32, style: .continuous)
                    .stroke(OB.Color.accent.opacity(pulse ? 0 : 0.5), lineWidth: 2)
                    .padding(8)
                    .ignoresSafeArea()
                    .allowsHitTesting(false)
                    .onAppear {
                        withAnimation(.easeOut(duration: 1.2)) { pulse = true }
                    }
            }
        }
        .navigationBarBackButtonHidden()
    }

    private var preReveal: some View {
        VStack(alignment: .leading, spacing: 0) {
            Spacer()

            Text("THE VOTE")
                .font(.system(size: 13, weight: .semibold))
                .tracking(2.5)
                .foregroundStyle(OB.Color.faint)

            Text("Made your\ndecision?")
                .font(.system(size: 48, weight: .bold))
                .tracking(-1)
                .foregroundStyle(OB.Color.text)
                .padding(.top, 14)

            Text("Discuss as a group. When you've all agreed on who you think the impostor is, reveal it.")
                .font(.system(size: 16))
                .foregroundStyle(OB.Color.muted)
                .padding(.top, 14)
                .lineSpacing(3)

            Spacer()
            Spacer()

            PrimaryButton(title: "Reveal the Impostor") {
                UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                withAnimation(.easeInOut(duration: 0.3)) { revealed = true }
                // Deliberate name entrance after short delay
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    withAnimation(.easeOut(duration: 1.2)) { nameVisible = true }
                }
            }
        }
        .padding(.horizontal, 24)
        .padding(.bottom, 12)
    }

    private var postReveal: some View {
        VStack(alignment: .leading, spacing: 0) {
            Spacer()

            Text("THE IMPOSTOR WAS")
                .font(.system(size: 13, weight: .semibold))
                .tracking(2.5)
                .foregroundStyle(OB.Color.muted)

            HStack(alignment: .firstTextBaseline, spacing: 0) {
                Text(vm.impostor?.name ?? "")
                    .font(.system(size: 64, weight: .bold))
                    .tracking(-2)
                    .foregroundStyle(vm.impostor?.color.color ?? OB.Color.text)
                Text(".")
                    .font(.system(size: 64, weight: .bold))
                    .foregroundStyle(vm.impostor?.color.color ?? OB.Color.text)
            }
            .opacity(nameVisible ? 1 : 0)
            .blur(radius: nameVisible ? 0 : 18)
            .offset(y: nameVisible ? 0 : 6)
            .padding(.top, 10)

            VStack(alignment: .leading, spacing: 6) {
                Text("THE THEME WAS")
                    .font(.system(size: 12, weight: .semibold))
                    .tracking(2.5)
                    .foregroundStyle(OB.Color.muted)
                Text(vm.session?.theme ?? "")
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundStyle(OB.Color.text)
            }
            .padding(.vertical, 14)
            .padding(.horizontal, 16)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(RoundedRectangle(cornerRadius: 14, style: .continuous).fill(OB.Color.surface))
            .overlay(RoundedRectangle(cornerRadius: 14, style: .continuous).stroke(OB.Color.border, lineWidth: 1))
            .padding(.top, 28)
            .opacity(nameVisible ? 1 : 0)
            .animation(.easeOut(duration: 0.6).delay(0.4), value: nameVisible)

            Text("Did they fool you? Roast accordingly.")
                .font(.system(size: 15))
                .foregroundStyle(OB.Color.muted)
                .padding(.top, 16)
                .opacity(nameVisible ? 1 : 0)
                .animation(.easeOut(duration: 0.6).delay(0.5), value: nameVisible)

            Spacer()
            Spacer()

            PrimaryButton(title: "Play Again", trailingChevron: true) {
                vm.playAgain()
            }
        }
        .padding(.horizontal, 24)
        .padding(.bottom, 12)
    }
}
