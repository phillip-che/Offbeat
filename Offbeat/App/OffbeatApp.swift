import SwiftUI

@main
struct OffbeatApp: App {
    @StateObject private var themeStore: ThemeStore
    @StateObject private var vm: GameViewModel

    init() {
        let store = ThemeStore()
        _themeStore = StateObject(wrappedValue: store)
        _vm = StateObject(wrappedValue: GameViewModel(themeStore: store))
    }

    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(vm)
                .environmentObject(themeStore)
                .preferredColorScheme(.dark)
                .tint(OB.Color.accent)
        }
    }
}

struct RootView: View {
    @EnvironmentObject var vm: GameViewModel

    var body: some View {
        NavigationStack(path: $vm.path) {
            HomeView()
                .navigationDestination(for: Route.self) { route in
                    switch route {
                    case .setup:      PlayerSetupView()
                    case .roleReveal: RoleRevealView()
                    case .playOrder:  PlayOrderView()
                    case .reveal:     RevealView()
                    }
                }
        }
    }
}
