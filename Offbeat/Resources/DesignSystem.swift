import SwiftUI

enum OB {
    enum Color {
        static let bg = SwiftUI.Color(hex: 0x0D0D0D)
        static let surface = SwiftUI.Color(hex: 0x1A1A1A)
        static let border = SwiftUI.Color(hex: 0x2A2A2A)
        static let accent = SwiftUI.Color(hex: 0xE8F455)
        static let text = SwiftUI.Color(hex: 0xFFFFFF)
        static let muted = SwiftUI.Color(hex: 0x888888)
        static let faint = SwiftUI.Color(hex: 0x5A5A5A)
        static let overlay = SwiftUI.Color(hex: 0x000000)
    }

    enum Radius {
        static let button: CGFloat = 14
        static let card: CGFloat = 16
        static let pill: CGFloat = 999
    }
}

extension Color {
    init(hex: UInt32, alpha: Double = 1) {
        let r = Double((hex >> 16) & 0xFF) / 255
        let g = Double((hex >> 8) & 0xFF) / 255
        let b = Double(hex & 0xFF) / 255
        self.init(.sRGB, red: r, green: g, blue: b, opacity: alpha)
    }
}

enum PlayerColor: String, CaseIterable, Codable {
    case coral, sky, mint, lavender, pink, amber

    var color: Color {
        switch self {
        case .coral:    return Color(hex: 0xFF8A75)
        case .sky:      return Color(hex: 0x6DCBFF)
        case .mint:     return Color(hex: 0x7EE8B0)
        case .lavender: return Color(hex: 0xB69CFF)
        case .pink:     return Color(hex: 0xFF8FB8)
        case .amber:    return Color(hex: 0xFFC773)
        }
    }
}
