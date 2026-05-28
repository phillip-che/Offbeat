import SwiftUI

/// Modal sheet for managing the theme pool.
/// - Defaults (built-in) can be toggled on/off but not edited.
/// - Customs can be added, edited and deleted.
/// - Reset re-enables every default and removes every custom.
struct ThemeEditorView: View {
    @EnvironmentObject var store: ThemeStore
    @EnvironmentObject var vm: GameViewModel
    @Environment(\.dismiss) private var dismiss

    @State private var editing: CustomTheme?
    @State private var showingAdd = false
    @State private var showingResetConfirm = false

    var body: some View {
        ZStack {
            OB.Color.bg.ignoresSafeArea()

            VStack(spacing: 0) {
                header

                ScrollView {
                    VStack(alignment: .leading, spacing: 28) {
                        customsSection
                        defaultsSection
                        resetButton
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 8)
                    .padding(.bottom, 32)
                }
            }
        }
        .sheet(isPresented: $showingAdd) {
            ThemeFormView(mode: .add)
                .environmentObject(store)
                .presentationDetents([.large])
                .presentationDragIndicator(.visible)
        }
        .sheet(item: $editing) { theme in
            ThemeFormView(mode: .edit(theme))
                .environmentObject(store)
                .presentationDetents([.large])
                .presentationDragIndicator(.visible)
        }
        .alert("Reset to defaults?", isPresented: $showingResetConfirm) {
            Button("Cancel", role: .cancel) {}
            Button("Reset", role: .destructive) {
                withAnimation(.easeInOut(duration: 0.25)) {
                    store.reset()
                }
                vm.invalidateThemeQueue()
            }
        } message: {
            Text("Re-enables every built-in theme and removes every custom one.")
        }
        .onChange(of: store.activePool) { _, _ in
            vm.invalidateThemeQueue()
        }
    }

    // MARK: - Header

    private var header: some View {
        HStack {
            Text("Themes")
                .font(.system(size: 28, weight: .bold))
                .tracking(-0.5)
                .foregroundStyle(OB.Color.text)
            Spacer()
            Button {
                dismiss()
            } label: {
                Image(systemName: "xmark")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundStyle(OB.Color.muted)
                    .frame(width: 32, height: 32)
                    .background(Circle().fill(OB.Color.surface))
                    .overlay(Circle().stroke(OB.Color.border, lineWidth: 1))
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 20)
        .padding(.top, 16)
        .padding(.bottom, 12)
    }

    // MARK: - Sections

    private var customsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionHeader(
                title: "YOURS",
                trailing: "\(store.customs.count)"
            )

            if store.customs.isEmpty {
                Text("Add themes that fit your group. Each one needs a vague hint for the Impostor.")
                    .font(.system(size: 14))
                    .foregroundStyle(OB.Color.faint)
                    .multilineTextAlignment(.leading)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(16)
                    .background(
                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                            .stroke(style: StrokeStyle(lineWidth: 1, dash: [5, 5]))
                            .foregroundStyle(OB.Color.border)
                    )
            } else {
                VStack(spacing: 8) {
                    ForEach(store.customs) { custom in
                        customRow(custom)
                    }
                }
            }

            addRow
        }
    }

    private var defaultsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionHeader(
                title: "BUILT-IN",
                trailing: "\(store.activeDefaults.count)/\(Themes.pool.count)"
            )

            VStack(spacing: 8) {
                ForEach(Themes.pool, id: \.self) { theme in
                    defaultRow(theme)
                }
            }
        }
    }

    private func sectionHeader(title: String, trailing: String) -> some View {
        HStack {
            Text(title)
                .font(.system(size: 12, weight: .semibold))
                .tracking(2.5)
                .foregroundStyle(OB.Color.muted)
            Spacer()
            Text(trailing)
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(OB.Color.faint)
        }
    }

    // MARK: - Rows

    private func customRow(_ theme: CustomTheme) -> some View {
        Button { editing = theme } label: {
            HStack(alignment: .center, spacing: 12) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(theme.text)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(OB.Color.text)
                        .multilineTextAlignment(.leading)
                    Text("\(theme.dimension.rawValue) · \(theme.descriptor)")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundStyle(OB.Color.muted)
                }
                Spacer(minLength: 8)
                Image(systemName: "chevron.right")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(OB.Color.faint)
            }
            .padding(.vertical, 14)
            .padding(.horizontal, 16)
            .background(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(OB.Color.surface)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .stroke(OB.Color.border, lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
        .swipeActions(edge: .trailing, allowsFullSwipe: false) {
            Button(role: .destructive) {
                withAnimation { store.delete(theme) }
            } label: {
                Label("Delete", systemImage: "trash")
            }
        }
    }

    private var addRow: some View {
        Button { showingAdd = true } label: {
            HStack(spacing: 10) {
                Image(systemName: "plus.circle.fill")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundStyle(OB.Color.accent)
                Text("Add a theme")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(OB.Color.text)
                Spacer()
            }
            .padding(.vertical, 14)
            .padding(.horizontal, 16)
            .background(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(OB.Color.accent.opacity(0.06))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .stroke(OB.Color.accent.opacity(0.35), lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }

    private func defaultRow(_ theme: String) -> some View {
        let enabled = store.isDefaultEnabled(theme)
        return HStack(spacing: 12) {
            Text(theme)
                .font(.system(size: 15, weight: .medium))
                .foregroundStyle(enabled ? OB.Color.text : OB.Color.muted)
                .strikethrough(!enabled, color: OB.Color.faint)
                .multilineTextAlignment(.leading)
            Spacer(minLength: 8)
            Toggle(
                "",
                isOn: Binding(
                    get: { enabled },
                    set: { store.setDefault(theme, enabled: $0) }
                )
            )
            .labelsHidden()
            .tint(OB.Color.accent)
        }
        .padding(.vertical, 12)
        .padding(.horizontal, 16)
        .background(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(OB.Color.surface)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .stroke(OB.Color.border, lineWidth: 1)
        )
    }

    private var resetButton: some View {
        Button {
            showingResetConfirm = true
        } label: {
            Text("Reset to defaults")
                .font(.system(size: 15, weight: .semibold))
                .foregroundStyle(OB.Color.muted)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .stroke(OB.Color.border, lineWidth: 1)
                )
        }
        .buttonStyle(.plain)
        .padding(.top, 8)
    }
}
