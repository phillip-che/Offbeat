import SwiftUI

struct PlayerSetupView: View {
    @EnvironmentObject var vm: GameViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var draft = ""
    @FocusState private var fieldFocused: Bool

    var body: some View {
        ZStack {
            OB.Color.bg.ignoresSafeArea()

            VStack(alignment: .leading, spacing: 0) {
                // Top bar
                HStack {
                    Button {
                        if vm.path.count > 1 { vm.path.removeLast() } else { vm.path = [] }
                    } label: {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundStyle(OB.Color.muted)
                            .frame(width: 36, height: 36)
                    }
                    .buttonStyle(.plain)
                    Spacer()
                    Text("\(vm.players.count) players")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundStyle(OB.Color.muted)
                }
                .padding(.top, 4)

                Text("Who's\nplaying?")
                    .font(.system(size: 48, weight: .bold))
                    .tracking(-1)
                    .foregroundStyle(OB.Color.text)
                    .lineSpacing(-4)
                    .padding(.top, 16)

                Text("Add 3–10 people in the room. We'll randomise the order.")
                    .font(.system(size: 16, weight: .regular))
                    .foregroundStyle(OB.Color.muted)
                    .padding(.top, 12)
                    .lineSpacing(2)

                // Input row
                HStack(spacing: 0) {
                    TextField("", text: $draft, prompt: Text("Add a name").foregroundColor(OB.Color.muted))
                        .focused($fieldFocused)
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundStyle(OB.Color.text)
                        .tint(OB.Color.accent)
                        .submitLabel(.done)
                        .onSubmit(submit)
                        .autocorrectionDisabled()

                    Button(action: submit) {
                        Text("Add")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundStyle(canAdd ? OB.Color.accent : OB.Color.muted)
                    }
                    .buttonStyle(.plain)
                    .disabled(!canAdd)
                }
                .padding(.horizontal, 18)
                .frame(height: 56)
                .background(RoundedRectangle(cornerRadius: 14, style: .continuous).fill(OB.Color.surface))
                .overlay(RoundedRectangle(cornerRadius: 14, style: .continuous).stroke(OB.Color.border, lineWidth: 1))
                .padding(.top, 28)

                // Chips area
                Group {
                    if vm.players.isEmpty {
                        VStack {
                            Text("Names you add appear here as chips. Tap × to remove.")
                                .font(.system(size: 15))
                                .foregroundStyle(OB.Color.faint)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 24)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 32)
                        .background(
                            RoundedRectangle(cornerRadius: 14, style: .continuous)
                                .stroke(style: StrokeStyle(lineWidth: 1, dash: [5, 5]))
                                .foregroundStyle(OB.Color.border)
                        )
                    } else {
                        FlowLayout(spacing: 8, lineSpacing: 8) {
                            ForEach(vm.players) { p in
                                PlayerChip(player: p) {
                                    withAnimation(.timingCurve(0.2, 1.4, 0.3, 1, duration: 0.28)) {
                                        vm.removePlayer(p)
                                    }
                                }
                                .transition(.scale.combined(with: .opacity))
                            }
                        }
                    }
                }
                .padding(.top, 16)
                .animation(.timingCurve(0.2, 1.4, 0.3, 1, duration: 0.28), value: vm.players)

                Spacer()

                if !vm.isReadyToStart {
                    Text(hintText)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundStyle(OB.Color.muted)
                        .frame(maxWidth: .infinity)
                        .padding(.bottom, 10)
                }

                PrimaryButton(
                    title: "Let's Play",
                    trailingChevron: true,
                    enabled: vm.isReadyToStart
                ) {
                    vm.startGame()
                }
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 12)
        }
        .navigationBarBackButtonHidden()
    }

    private var canAdd: Bool {
        !draft.trimmingCharacters(in: .whitespaces).isEmpty && vm.canAddMore
    }

    private var hintText: String {
        let needed = 3 - vm.players.count
        if needed == 1 { return "Add at least 1 more player" }
        return "Add at least \(needed) more players"
    }

    private func submit() {
        guard canAdd else { return }
        withAnimation(.timingCurve(0.2, 1.4, 0.3, 1, duration: 0.28)) {
            vm.addPlayer(name: draft)
        }
        draft = ""
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
    }
}

// Simple flow layout for chips
struct FlowLayout: Layout {
    var spacing: CGFloat = 8
    var lineSpacing: CGFloat = 8

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let width = proposal.width ?? .infinity
        return layout(subviews: subviews, in: width).size
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let result = layout(subviews: subviews, in: bounds.width)
        for (i, frame) in result.frames.enumerated() {
            let pos = CGPoint(x: bounds.minX + frame.minX, y: bounds.minY + frame.minY)
            subviews[i].place(at: pos, proposal: ProposedViewSize(frame.size))
        }
    }

    private func layout(subviews: Subviews, in width: CGFloat) -> (size: CGSize, frames: [CGRect]) {
        var frames: [CGRect] = []
        var x: CGFloat = 0
        var y: CGFloat = 0
        var lineHeight: CGFloat = 0
        for sv in subviews {
            let size = sv.sizeThatFits(.unspecified)
            if x + size.width > width && x > 0 {
                x = 0
                y += lineHeight + lineSpacing
                lineHeight = 0
            }
            frames.append(CGRect(x: x, y: y, width: size.width, height: size.height))
            x += size.width + spacing
            lineHeight = max(lineHeight, size.height)
        }
        return (CGSize(width: width, height: y + lineHeight), frames)
    }
}
