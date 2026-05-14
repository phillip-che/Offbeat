import SwiftUI

struct PrimaryButton: View {
    let title: String
    var trailingChevron: Bool = false
    var enabled: Bool = true
    let action: () -> Void

    @State private var pressed = false

    var body: some View {
        Button {
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
            action()
        } label: {
            HStack(spacing: 8) {
                Text(title)
                    .font(.system(size: 17, weight: .semibold))
                if trailingChevron {
                    Image(systemName: "chevron.right")
                        .font(.system(size: 15, weight: .semibold))
                }
            }
            .foregroundStyle(OB.Color.bg)
            .frame(maxWidth: .infinity)
            .frame(height: 60)
            .background(
                RoundedRectangle(cornerRadius: OB.Radius.button, style: .continuous)
                    .fill(enabled ? OB.Color.accent : OB.Color.accent.opacity(0.18))
            )
            .foregroundStyle(enabled ? OB.Color.bg : OB.Color.muted)
            .scaleEffect(pressed ? 0.97 : 1)
            .animation(.spring(response: 0.12, dampingFraction: 0.7), value: pressed)
        }
        .buttonStyle(.plain)
        .disabled(!enabled)
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in pressed = true }
                .onEnded { _ in pressed = false }
        )
    }
}

struct OutlineButton: View {
    let title: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 17, weight: .semibold))
                .foregroundStyle(OB.Color.text)
                .frame(maxWidth: .infinity)
                .frame(height: 60)
                .background(
                    RoundedRectangle(cornerRadius: OB.Radius.button, style: .continuous)
                        .stroke(OB.Color.border, lineWidth: 1)
                )
        }
        .buttonStyle(.plain)
    }
}
