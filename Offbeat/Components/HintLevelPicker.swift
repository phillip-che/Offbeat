import SwiftUI

/// A segmented pill selector matching the Offbeat design language.
/// Used on the Player Setup screen for choosing the hint level.
struct HintLevelPicker: View {
    @Binding var selection: HintLevel

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 8) {
                Text("HINTS")
                    .font(.system(size: 12, weight: .semibold))
                    .tracking(2.5)
                    .foregroundStyle(OB.Color.muted)

                Text(captionText)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(OB.Color.faint)
                    .lineLimit(1)
                    .truncationMode(.tail)
            }

            HStack(spacing: 4) {
                ForEach(HintLevel.allCases) { level in
                    segment(for: level)
                }
            }
            .padding(4)
            .background(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(OB.Color.surface)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .stroke(OB.Color.border, lineWidth: 1)
            )
        }
    }

    private func segment(for level: HintLevel) -> some View {
        let isSelected = selection == level
        return Button {
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
            withAnimation(.spring(response: 0.32, dampingFraction: 0.78)) {
                selection = level
            }
        } label: {
            Text(level.label)
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(isSelected ? OB.Color.bg : OB.Color.muted)
                .frame(maxWidth: .infinity)
                .frame(height: 36)
                .background(
                    ZStack {
                        if isSelected {
                            RoundedRectangle(cornerRadius: 10, style: .continuous)
                                .fill(OB.Color.accent)
                                .matchedGeometryEffect(id: "hintPickerSelection", in: ns)
                        }
                    }
                )
        }
        .buttonStyle(.plain)
    }

    @Namespace private var ns

    private var captionText: String {
        switch selection {
        case .off:      return "· Impostor gets nothing"
        case .subtle:   return "· just the dimension"
        case .standard: return "· one vague word"
        case .generous: return "· labelled clue"
        }
    }
}
