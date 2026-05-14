import SwiftUI

struct PlayerChip: View {
    let player: Player
    let onRemove: () -> Void

    var body: some View {
        HStack(spacing: 8) {
            Circle()
                .fill(player.color.color)
                .frame(width: 8, height: 8)
            Text(player.name)
                .font(.system(size: 15, weight: .semibold))
                .foregroundStyle(OB.Color.text)
            Button(action: onRemove) {
                Image(systemName: "xmark")
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundStyle(OB.Color.muted)
                    .padding(.leading, 2)
            }
            .buttonStyle(.plain)
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 12)
        .background(
            Capsule().fill(OB.Color.surface)
        )
        .overlay(
            Capsule().stroke(OB.Color.border, lineWidth: 1)
        )
    }
}
