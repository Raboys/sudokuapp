import SwiftUI

/// Top-level router. Shows the 14+ age gate until confirmed, then switches between
/// the tabbed home experience, the game, and the completion screen. The game and
/// completion screens are full-screen (no tab bar) so the board gets all the space.
struct RootView: View {
    @EnvironmentObject private var viewModel: GameViewModel

    var body: some View {
        Group {
            if !viewModel.isAgeConfirmed {
                AgeGateView()
            } else {
                switch viewModel.screen {
                case .home:       MainTabView()
                case .game:       GameView()
                case .completion: CompletionView()
                }
            }
        }
        .animation(.easeInOut(duration: 0.25), value: viewModel.screen)
        .animation(.easeInOut(duration: 0.25), value: viewModel.isAgeConfirmed)
        .alert(item: $viewModel.activeAlert) { alert in
            Alert(title: Text(alert.title),
                  message: Text(alert.message),
                  dismissButton: .default(Text("OK")))
        }
    }
}
