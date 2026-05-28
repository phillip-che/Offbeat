import Foundation

/// The dimension a hint speaks to. Used to build the "Subtle" hint ("Think about mood.")
/// and the "Generous" hint ("Mood: warm").
enum HintDimension: String, CaseIterable, Identifiable, Codable {
    case mood    = "Mood"
    case energy  = "Energy"
    case setting = "Setting"
    case era     = "Era"
    case vibe    = "Vibe"

    var id: String { rawValue }
    var lowered: String { rawValue.lowercased() }
}

/// Level of help shown to the Impostor on the role reveal screen.
/// Persisted via @AppStorage.
enum HintLevel: String, CaseIterable, Identifiable {
    case off, subtle, standard, generous

    var id: String { rawValue }

    var label: String {
        switch self {
        case .off:      return "Off"
        case .subtle:   return "Subtle"
        case .standard: return "Standard"
        case .generous: return "Generous"
        }
    }
}

/// One hint = a (dimension, descriptor) pair. The descriptor is intentionally
/// vague — many themes share the same descriptor so the Impostor cannot
/// reverse-engineer the theme from the hint alone.
struct ThemeHint {
    let dimension: HintDimension
    let descriptor: String

    func string(for level: HintLevel) -> String? {
        switch level {
        case .off:
            return nil
        case .subtle:
            return "Think about \(dimension.lowered)."
        case .standard:
            return descriptor
        case .generous:
            return "\(dimension.rawValue): \(descriptor)"
        }
    }
}

enum Hints {
    /// Every theme in `Themes.pool` has a vague hint here. The keys are
    /// matched verbatim against the theme string.
    static let map: [String: ThemeHint] = [
        "Songs you'd hear at a wedding reception":            .init(dimension: .setting, descriptor: "a celebration"),
        "Songs to cry to at 2am":                              .init(dimension: .mood,    descriptor: "heavy"),
        "Songs for a road trip with friends":                  .init(dimension: .energy,  descriptor: "open"),
        "Songs your mum would love":                           .init(dimension: .vibe,    descriptor: "nostalgic"),
        "Songs that feel like summer":                         .init(dimension: .mood,    descriptor: "warm"),
        "Songs for a gym workout":                             .init(dimension: .energy,  descriptor: "loud"),
        "Songs for a villain's entrance":                      .init(dimension: .mood,    descriptor: "menacing"),
        "Songs to play at a funeral (respectfully)":           .init(dimension: .mood,    descriptor: "solemn"),
        "Songs that slap at a house party":                    .init(dimension: .setting, descriptor: "a party"),
        "Songs for falling in love":                           .init(dimension: .mood,    descriptor: "tender"),
        "Songs for a breakup montage":                         .init(dimension: .mood,    descriptor: "heartbroken"),
        "Songs that feel nostalgic for childhood":             .init(dimension: .vibe,    descriptor: "nostalgic"),
        "Songs for a boss battle in a video game":             .init(dimension: .energy,  descriptor: "intense"),
        "Songs for cooking dinner on a Friday night":          .init(dimension: .setting, descriptor: "a quiet evening"),
        "Songs for a slow dance":                              .init(dimension: .energy,  descriptor: "soft"),
        "Songs that make you feel invincible":                 .init(dimension: .mood,    descriptor: "triumphant"),
        "Songs for a movie chase scene":                       .init(dimension: .energy,  descriptor: "frantic"),
        "Songs you'd sing drunk at karaoke":                   .init(dimension: .setting, descriptor: "a party"),
        "Songs for a lazy Sunday morning":                     .init(dimension: .energy,  descriptor: "soft"),
        "Songs that make you want to drive fast":              .init(dimension: .energy,  descriptor: "intense"),
        "Songs that feel cinematic":                           .init(dimension: .vibe,    descriptor: "cinematic"),
        "Songs for getting ready to go out":                   .init(dimension: .energy,  descriptor: "rising"),
        "Songs for a rainy afternoon indoors":                 .init(dimension: .mood,    descriptor: "wistful"),
        "Songs that feel rebellious":                          .init(dimension: .mood,    descriptor: "defiant"),
        "Songs to blast at the beach":                         .init(dimension: .mood,    descriptor: "warm"),
        "Songs for meditating or winding down":                .init(dimension: .energy,  descriptor: "soft"),
        "Songs for a birthday party":                          .init(dimension: .setting, descriptor: "a celebration"),
        "Songs for studying or deep focus":                    .init(dimension: .energy,  descriptor: "still"),
        "Songs for a late night city drive":                   .init(dimension: .vibe,    descriptor: "nocturnal"),
        "Songs that feel like the 80s":                        .init(dimension: .era,     descriptor: "a specific decade"),
        "Songs for dancing alone in your room":                .init(dimension: .mood,    descriptor: "private"),
        "Songs that feel dangerous":                           .init(dimension: .mood,    descriptor: "menacing"),
        "Songs for a horror movie scene":                      .init(dimension: .mood,    descriptor: "unsettling"),
        "Songs to play at a BBQ":                              .init(dimension: .setting, descriptor: "a celebration"),
        "Songs that feel euphoric":                            .init(dimension: .mood,    descriptor: "euphoric"),
        "Songs for a sports highlight reel":                   .init(dimension: .mood,    descriptor: "triumphant"),
        "Songs that make you emotional at the end of a film":  .init(dimension: .mood,    descriptor: "wistful"),
        "Songs for a heist scene":                             .init(dimension: .mood,    descriptor: "sly"),
        "Songs that feel like being young and free":           .init(dimension: .vibe,    descriptor: "carefree"),
        "Songs a DJ would play to close out a festival":       .init(dimension: .setting, descriptor: "a party"),
        "Songs for a first kiss scene":                        .init(dimension: .mood,    descriptor: "tender"),
        "Songs that feel like Sunday melancholy":              .init(dimension: .mood,    descriptor: "wistful"),
        "Songs to clean the house to":                         .init(dimension: .energy,  descriptor: "upbeat"),
        "Songs that make a stadium go wild":                   .init(dimension: .mood,    descriptor: "triumphant"),
    ]

    /// Returns the hint string for the given theme + level, or nil if hints
    /// are off or the theme has no mapping (defensive — should never happen).
    static func text(for theme: String, level: HintLevel) -> String? {
        guard level != .off, let hint = map[theme] else { return nil }
        return hint.string(for: level)
    }
}
