import SwiftUI

/// Landing screen: continue a saved game, pick a difficulty for a new game, and
/// reach the settings screen. Stats live in their own tab.
struct HomeView: View {
    @EnvironmentObject private var viewModel: GameViewModel
    @State private var showSettings = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    header

                    if viewModel.hasResumableGame {
                        continueCard
                    }

                    VStack(alignment: .leading, spacing: 12) {
                        Text("New Game")
                            .font(.title3.bold())
                            .frame(maxWidth: .infinity, alignment: .leading)
                        ForEach(Difficulty.allCases) { level in
                            DifficultyRow(level: level) {
                                viewModel.startNewGame(level)
                            }
                        }
                    }
                }
                .padding(20)
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Sudoku")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button { showSettings = true } label: {
                        Image(systemName: "gearshape.fill")
                    }
                    .accessibilityLabel("Settings")
                }
            }
            .sheet(isPresented: $showSettings) { SettingsView() }
        }
    }

    private var header: some View {
        VStack(spacing: 6) {
            Image(systemName: "square.grid.3x3.fill")
                .font(.system(size: 52))
                .foregroundStyle(.tint)
            Text("Train your brain, one grid at a time.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 8)
    }

    private var continueCard: some View {
        Button {
            viewModel.resumeSavedGame()
        } label: {
            HStack(spacing: 14) {
                Image(systemName: "play.circle.fill")
                    .font(.system(size: 34))
                    .foregroundStyle(.tint)
                VStack(alignment: .leading, spacing: 2) {
                    Text("Continue")
                        .font(.headline)
                        .foregroundStyle(.primary)
                    Text(continueSubtitle)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                Spacer()
                Image(systemName: "chevron.right").foregroundStyle(.tertiary)
            }
            .padding(16)
            .background(Color(.secondarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: 16))
        }
        .buttonStyle(.plain)
    }

    /// e.g. "Medium · 03:42" for the saved game, so the player knows what they
    /// are coming back to before tapping.
    private var continueSubtitle: String {
        if let saved = viewModel.savedGameSummary {
            return "\(saved.difficulty.title) · \(saved.elapsed)"
        }
        return "Resume your game in progress"
    }
}

/// A tappable difficulty card on the home screen.
private struct DifficultyRow: View {
    let level: Difficulty
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 14) {
                Image(systemName: level.symbol)
                    .font(.title3)
                    .foregroundStyle(.white)
                    .frame(width: 44, height: 44)
                    .background(level.tint, in: RoundedRectangle(cornerRadius: 12))
                VStack(alignment: .leading, spacing: 2) {
                    Text(level.title).font(.headline).foregroundStyle(.primary)
                    Text(level.subtitle).font(.subheadline).foregroundStyle(.secondary)
                }
                Spacer()
                Image(systemName: "chevron.right").foregroundStyle(.tertiary)
            }
            .padding(14)
            .background(Color(.secondarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: 16))
        }
        .buttonStyle(.plain)
    }
}
