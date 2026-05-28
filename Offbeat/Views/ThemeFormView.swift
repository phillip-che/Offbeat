import SwiftUI

/// Add / edit form for a single custom theme. Captures both the prompt text
/// and the (vague) Impostor hint that pairs with it.
struct ThemeFormView: View {
    enum Mode: Equatable {
        case add
        case edit(CustomTheme)
    }

    @EnvironmentObject var store: ThemeStore
    @Environment(\.dismiss) private var dismiss

    let mode: Mode

    @State private var text: String = ""
    @State private var dimension: HintDimension = .mood
    @State private var descriptor: String = ""
    @State private var showingDeleteConfirm = false
    @FocusState private var focused: Field?

    enum Field { case theme, descriptor }

    init(mode: Mode) {
        self.mode = mode
        if case let .edit(theme) = mode {
            _text = State(initialValue: theme.text)
            _dimension = State(initialValue: theme.dimension)
            _descriptor = State(initialValue: theme.descriptor)
        }
    }

    var body: some View {
        ZStack {
            OB.Color.bg.ignoresSafeArea()

            VStack(spacing: 0) {
                header
                ScrollView {
                    VStack(alignment: .leading, spacing: 28) {
                        themeField
                        hintBlock
                        livePreview
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 8)
                }

                Spacer(minLength: 0)

                bottomBar
                    .padding(.horizontal, 20)
                    .padding(.bottom, 16)
            }
        }
        .alert("Delete this theme?", isPresented: $showingDeleteConfirm) {
            Button("Cancel", role: .cancel) {}
            Button("Delete", role: .destructive) {
                if case let .edit(theme) = mode {
                    store.delete(theme)
                    dismiss()
                }
            }
        }
    }

    // MARK: - Header

    private var header: some View {
        HStack {
            Text(title)
                .font(.system(size: 22, weight: .bold))
                .foregroundStyle(OB.Color.text)
            Spacer()
            Button {
                dismiss()
            } label: {
                Image(systemName: "xmark")
                    .font(.system(size: 13, weight: .bold))
                    .foregroundStyle(OB.Color.muted)
                    .frame(width: 30, height: 30)
                    .background(Circle().fill(OB.Color.surface))
                    .overlay(Circle().stroke(OB.Color.border, lineWidth: 1))
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 20)
        .padding(.top, 16)
        .padding(.bottom, 8)
    }

    private var title: String {
        switch mode {
        case .add:  return "New theme"
        case .edit: return "Edit theme"
        }
    }

    // MARK: - Theme text

    private var themeField: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("THEME")
                .font(.system(size: 12, weight: .semibold))
                .tracking(2.5)
                .foregroundStyle(OB.Color.muted)
            TextField(
                "",
                text: $text,
                prompt: Text("e.g. Songs for a midnight road trip").foregroundColor(OB.Color.faint),
                axis: .vertical
            )
            .focused($focused, equals: .theme)
            .font(.system(size: 17, weight: .semibold))
            .foregroundStyle(OB.Color.text)
            .tint(OB.Color.accent)
            .lineLimit(1...3)
            .padding(14)
            .background(RoundedRectangle(cornerRadius: 14, style: .continuous).fill(OB.Color.surface))
            .overlay(RoundedRectangle(cornerRadius: 14, style: .continuous).stroke(OB.Color.border, lineWidth: 1))
        }
    }

    // MARK: - Hint

    private var hintBlock: some View {
        VStack(alignment: .leading, spacing: 14) {
            VStack(alignment: .leading, spacing: 4) {
                Text("HINT FOR THE IMPOSTOR")
                    .font(.system(size: 12, weight: .semibold))
                    .tracking(2.5)
                    .foregroundStyle(OB.Color.muted)
                Text("Keep it vague — the Impostor shouldn't be able to guess the theme from it.")
                    .font(.system(size: 13))
                    .foregroundStyle(OB.Color.faint)
                    .lineSpacing(2)
            }

            // Dimension picker
            VStack(alignment: .leading, spacing: 6) {
                Text("DIMENSION")
                    .font(.system(size: 11, weight: .semibold))
                    .tracking(2)
                    .foregroundStyle(OB.Color.faint)
                dimensionPicker
            }

            // Descriptor field
            VStack(alignment: .leading, spacing: 6) {
                Text("DESCRIPTOR")
                    .font(.system(size: 11, weight: .semibold))
                    .tracking(2)
                    .foregroundStyle(OB.Color.faint)
                TextField(
                    "",
                    text: $descriptor,
                    prompt: Text("e.g. nocturnal").foregroundColor(OB.Color.faint)
                )
                .focused($focused, equals: .descriptor)
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(OB.Color.text)
                .tint(OB.Color.accent)
                .submitLabel(.done)
                .padding(14)
                .background(RoundedRectangle(cornerRadius: 14, style: .continuous).fill(OB.Color.surface))
                .overlay(RoundedRectangle(cornerRadius: 14, style: .continuous).stroke(OB.Color.border, lineWidth: 1))
            }
        }
    }

    private var dimensionPicker: some View {
        // Two-row wrap so all five always fit on iPhone widths.
        FlowLayout(spacing: 6, lineSpacing: 6) {
            ForEach(HintDimension.allCases) { dim in
                let selected = dim == dimension
                Button {
                    UIImpactFeedbackGenerator(style: .light).impactOccurred()
                    withAnimation(.spring(response: 0.28, dampingFraction: 0.78)) {
                        dimension = dim
                    }
                } label: {
                    Text(dim.rawValue)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(selected ? OB.Color.bg : OB.Color.muted)
                        .padding(.vertical, 9)
                        .padding(.horizontal, 14)
                        .background(
                            Capsule().fill(selected ? OB.Color.accent : OB.Color.surface)
                        )
                        .overlay(
                            Capsule().stroke(selected ? OB.Color.accent : OB.Color.border, lineWidth: 1)
                        )
                }
                .buttonStyle(.plain)
            }
        }
    }

    // MARK: - Preview

    private var livePreview: some View {
        let trimmed = descriptor.trimmingCharacters(in: .whitespaces)
        return VStack(alignment: .leading, spacing: 10) {
            Text("PREVIEW · GENEROUS")
                .font(.system(size: 11, weight: .semibold))
                .tracking(2)
                .foregroundStyle(OB.Color.faint)
            HStack(spacing: 8) {
                Image(systemName: "sparkles")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundStyle(OB.Color.accent)
                Text("HINT")
                    .font(.system(size: 11, weight: .semibold))
                    .tracking(2)
                    .foregroundStyle(OB.Color.accent)
                Text("\(dimension.rawValue): \(trimmed.isEmpty ? "…" : trimmed)")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(OB.Color.text)
            }
            .padding(.vertical, 9)
            .padding(.horizontal, 14)
            .background(Capsule().fill(OB.Color.accent.opacity(0.08)))
            .overlay(Capsule().stroke(OB.Color.accent.opacity(0.45), lineWidth: 1))
        }
    }

    // MARK: - Bottom bar

    private var bottomBar: some View {
        HStack(spacing: 12) {
            if case .edit = mode {
                Button {
                    showingDeleteConfirm = true
                } label: {
                    Image(systemName: "trash")
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundStyle(OB.Color.muted)
                        .frame(width: 60, height: 60)
                        .background(
                            RoundedRectangle(cornerRadius: 14, style: .continuous)
                                .stroke(OB.Color.border, lineWidth: 1)
                        )
                }
                .buttonStyle(.plain)
            }

            PrimaryButton(title: saveTitle, enabled: canSave) {
                save()
            }
        }
    }

    private var saveTitle: String {
        switch mode {
        case .add:  return "Add theme"
        case .edit: return "Save"
        }
    }

    private var canSave: Bool {
        !text.trimmingCharacters(in: .whitespaces).isEmpty &&
        !descriptor.trimmingCharacters(in: .whitespaces).isEmpty
    }

    private func save() {
        switch mode {
        case .add:
            store.addCustom(text: text, dimension: dimension, descriptor: descriptor)
        case .edit(let theme):
            var updated = theme
            updated.text = text
            updated.dimensionRaw = dimension.rawValue
            updated.descriptor = descriptor
            store.update(updated)
        }
        dismiss()
    }
}
