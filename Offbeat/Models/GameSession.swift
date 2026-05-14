import Foundation

struct GameSession {
    var theme: String
    var impostorID: UUID
    var revealOrder: [Player]
    var playOrder: [Player]
}
