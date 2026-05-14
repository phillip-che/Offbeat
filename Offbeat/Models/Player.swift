import Foundation

struct Player: Identifiable, Hashable {
    let id = UUID()
    var name: String
    var color: PlayerColor
}
