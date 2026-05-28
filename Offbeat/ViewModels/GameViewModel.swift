import SwiftUI
import Combine

enum Route: Hashable {
    case setup
    case roleReveal
    case playOrder
    case reveal
}

@MainActor
final class GameViewModel: ObservableObject {
    @Published var path: [Route] = []
    @Published var players: [Player] = []
    @Published var session: GameSession?
    @Published var revealIndex: Int = 0

    // Theme rotation — exhaust the pool before reshuffling.
    private var themeQueue: [String] = []

    // Source of truth for the theme pool + custom hints.
    let themeStore: ThemeStore

    init(themeStore: ThemeStore) {
        self.themeStore = themeStore
    }

    // Hint level persisted across launches.
    @AppStorage("hintLevel") private var storedHintLevel: String = HintLevel.off.rawValue
    var hintLevel: HintLevel {
        get { HintLevel(rawValue: storedHintLevel) ?? .off }
        set {
            storedHintLevel = newValue.rawValue
            objectWillChange.send()
        }
    }

    /// The hint string for the current session's theme, if hints are enabled.
    /// Resolves customs first (via `ThemeStore`), then built-in defaults.
    var impostorHint: String? {
        guard hintLevel != .off, let theme = session?.theme else { return nil }
        return themeStore.hint(for: theme)?.string(for: hintLevel)
    }

    var isReadyToStart: Bool { players.count >= 3 }
    var canAddMore: Bool { players.count < 10 }

    func addPlayer(name: String) {
        let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty, canAddMore else { return }
        let color = nextPlayerColor()
        players.append(Player(name: trimmed, color: color))
    }

    func removePlayer(_ player: Player) {
        players.removeAll { $0.id == player.id }
    }

    /// Cycle through palette in declaration order; wrap when exhausted.
    private func nextPlayerColor() -> PlayerColor {
        let palette = PlayerColor.allCases
        return palette[players.count % palette.count]
    }

    /// Build a new round: shuffled reveal order, separately shuffled play order,
    /// random impostor, and a non-repeating random theme.
    func startNewRound() {
        guard players.count >= 3 else { return }

        let reveal = players.shuffled()
        var play = players.shuffled()
        // Make play order visibly distinct from reveal order when possible.
        if play == reveal, play.count > 1 {
            play.swapAt(0, play.count - 1)
        }

        let impostorIndex = Int.random(in: 0..<players.count)
        let impostor = players[impostorIndex]

        session = GameSession(
            theme: pullNextTheme(),
            impostorID: impostor.id,
            revealOrder: reveal,
            playOrder: play
        )
        revealIndex = 0
    }

    /// Pull from the user's active pool (defaults minus disabled + customs).
    /// Falls back to a placeholder if the user disabled every theme.
    private func pullNextTheme() -> String {
        let pool = themeStore.activePool
        guard !pool.isEmpty else { return "Pick any song" }
        if themeQueue.isEmpty {
            themeQueue = pool.shuffled()
        }
        return themeQueue.removeFirst()
    }

    /// Called when the underlying theme pool changes mid-session, so the
    /// next round picks from the freshest list.
    func invalidateThemeQueue() {
        themeQueue.removeAll()
    }

    // MARK: - Navigation helpers

    func goToSetup() { path = [.setup] }

    func startGame() {
        startNewRound()
        path = [.setup, .roleReveal]
    }

    func advanceReveal() {
        guard let session else { return }
        if revealIndex + 1 >= session.revealOrder.count {
            path.append(.playOrder)
        } else {
            revealIndex += 1
        }
    }

    func goToReveal() { path.append(.reveal) }

    func playAgain() {
        startNewRound()
        path = [.setup, .roleReveal]
    }

    var currentRevealPlayer: Player? {
        guard let session, revealIndex < session.revealOrder.count else { return nil }
        return session.revealOrder[revealIndex]
    }

    var impostor: Player? {
        guard let session else { return nil }
        return players.first { $0.id == session.impostorID }
    }

    func isImpostor(_ player: Player) -> Bool {
        session?.impostorID == player.id
    }
}
