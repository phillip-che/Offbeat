import Foundation

/// A user-authored theme with its own Impostor hint.
struct CustomTheme: Identifiable, Codable, Hashable {
    var id: UUID = UUID()
    var text: String
    /// Stored as the raw value of `HintDimension` for forward-compat.
    var dimensionRaw: String
    var descriptor: String

    var dimension: HintDimension {
        HintDimension(rawValue: dimensionRaw) ?? .mood
    }

    var hint: ThemeHint {
        ThemeHint(dimension: dimension, descriptor: descriptor)
    }
}
