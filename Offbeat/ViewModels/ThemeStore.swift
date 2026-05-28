import SwiftUI
import Combine

/// Persistent store for the theme pool. Built-in defaults are read-only but
/// can be individually disabled. Users can also add their own themes with a
/// custom Impostor hint.
@MainActor
final class ThemeStore: ObservableObject {
    @Published private(set) var customs: [CustomTheme] = []
    @Published private(set) var disabledDefaults: Set<String> = []

    private let customsKey = "themeStore.customs.v1"
    private let disabledKey = "themeStore.disabledDefaults.v1"

    init() {
        load()
    }

    // MARK: - Derived

    /// Default themes still enabled by the user, in original order.
    var activeDefaults: [String] {
        Themes.pool.filter { !disabledDefaults.contains($0) }
    }

    /// Defaults (in original order) followed by customs (in insertion order).
    /// This is the live pool the game pulls from.
    var activePool: [String] {
        activeDefaults + customs.map { $0.text }
    }

    var canStartGame: Bool { !activePool.isEmpty }

    /// Resolve a hint for a theme — checks customs first, then the built-in map.
    func hint(for theme: String) -> ThemeHint? {
        if let custom = customs.first(where: { $0.text == theme }) {
            return custom.hint
        }
        return Hints.map[theme]
    }

    // MARK: - Mutations — defaults

    func isDefaultEnabled(_ theme: String) -> Bool {
        !disabledDefaults.contains(theme)
    }

    func setDefault(_ theme: String, enabled: Bool) {
        if enabled {
            disabledDefaults.remove(theme)
        } else {
            disabledDefaults.insert(theme)
        }
        save()
    }

    // MARK: - Mutations — customs

    func addCustom(text: String, dimension: HintDimension, descriptor: String) {
        let trimmedText = text.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedDesc = descriptor.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedText.isEmpty, !trimmedDesc.isEmpty else { return }
        customs.append(
            CustomTheme(
                text: trimmedText,
                dimensionRaw: dimension.rawValue,
                descriptor: trimmedDesc
            )
        )
        save()
    }

    func update(_ theme: CustomTheme) {
        guard let idx = customs.firstIndex(where: { $0.id == theme.id }) else { return }
        let trimmedText = theme.text.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedDesc = theme.descriptor.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedText.isEmpty, !trimmedDesc.isEmpty else { return }
        var copy = theme
        copy.text = trimmedText
        copy.descriptor = trimmedDesc
        customs[idx] = copy
        save()
    }

    func delete(_ theme: CustomTheme) {
        customs.removeAll { $0.id == theme.id }
        save()
    }

    /// Restore: re-enable every default and remove every custom theme.
    func reset() {
        customs = []
        disabledDefaults = []
        save()
    }

    // MARK: - Persistence

    private func load() {
        let defaults = UserDefaults.standard
        if let data = defaults.data(forKey: customsKey),
           let decoded = try? JSONDecoder().decode([CustomTheme].self, from: data) {
            customs = decoded
        }
        if let data = defaults.data(forKey: disabledKey),
           let decoded = try? JSONDecoder().decode([String].self, from: data) {
            disabledDefaults = Set(decoded)
        }
    }

    private func save() {
        let defaults = UserDefaults.standard
        if let data = try? JSONEncoder().encode(customs) {
            defaults.set(data, forKey: customsKey)
        }
        if let data = try? JSONEncoder().encode(Array(disabledDefaults)) {
            defaults.set(data, forKey: disabledKey)
        }
    }
}
