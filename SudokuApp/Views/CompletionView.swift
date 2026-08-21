import SwiftUI

/// Shown after a puzzle is solved: the score, the breakdown, and the next actions.
struct CompletionView: View {
    @EnvironmentObject private var viewModel: GameViewModel

    var body: some View {
        let session = viewModel.lastSession
        VStack(spacing: 28) {
            Spacer()

            VStack(spacing: 12) {
                Image(systemName: "pawprint.fill")
                    .font(.system(size: 42))
                    .foregroundStyle(.white)
                    .frame(width: 82, height: 82)
                    .background(Color.accentColor, in: Circle())
                Text(L10n.text(session?.isDailyChallenge == true ? "Daily complete!" : "Purr-fect!"))
                    .font(.largeTitle.bold())
                if let session {
                    Text(L10n.format("%@ puzzle", session.difficulty.title))
                        .font(.headline)
                        .foregroundStyle(session.difficulty.tint)
                }
            }

            if let session {
                VStack(spacing: 0) {
                    ScoreBig(score: session.score)
                    achievementSummary(session)
                    Divider().padding(.vertical, 4)
                    StatRow(label: L10n.text("Time"), value: session.formattedDuration, symbol: "clock")
                    StatRow(label: L10n.text("Hints used"), value: "\(session.hintsUsed)", symbol: "pawprint.fill")
                    StatRow(label: L10n.text("Mistakes"), value: "\(session.mistakes)", symbol: "xmark.circle")
                }
                .padding(20)
                .background(Color(.secondarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: 18))
                .padding(.horizontal, 24)
            }

            Spacer()

            VStack(spacing: 12) {
                if let session {
                    Button {
                        if session.isDailyChallenge {
                            viewModel.startDailyChallenge()
                        } else {
                            viewModel.startNewGame(session.difficulty)
                        }
                    } label: {
                        Text(session.isDailyChallenge
                             ? L10n.text("Replay today's challenge")
                             : L10n.format("Play again (%@)", session.difficulty.title))
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                    }
                    .buttonStyle(.borderedProminent)
                }
                Button {
                    viewModel.screen = .home
                } label: {
                    Text("Home")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                }
                .buttonStyle(.bordered)
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 24)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemGroupedBackground))
    }

    @ViewBuilder
    private func achievementSummary(_ session: GameSession) -> some View {
        VStack(spacing: 8) {
            if session.isDailyChallenge {
                Label(L10n.format("%d-day streak", viewModel.dailyStreak), systemImage: "calendar.badge.checkmark")
            }
            if viewModel.lastWasPersonalBest {
                Label("New personal best", systemImage: "star.fill")
            }
            if let percentile = viewModel.lastPersonalPercentile {
                Text(L10n.format(
                    "Better than %d%% of your %@ games",
                    percentile,
                    session.difficulty.title.lowercased()
                ))
                    .multilineTextAlignment(.center)
            }
        }
        .font(.subheadline.weight(.semibold))
        .foregroundStyle(.tint)
        .padding(.bottom, 8)
    }
}

private struct ScoreBig: View {
    let score: Int
    var body: some View {
        VStack(spacing: 2) {
            Text("\(score)")
                .font(.system(size: 52, weight: .bold, design: .rounded))
                .foregroundStyle(.tint)
            Text("POINTS")
                .font(.caption.weight(.semibold))
                .foregroundStyle(.secondary)
                .tracking(2)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 8)
    }
}

private struct StatRow: View {
    let label: String
    let value: String
    let symbol: String
    var body: some View {
        HStack {
            Label(label, systemImage: symbol)
                .foregroundStyle(.secondary)
            Spacer()
            Text(value).font(.body.monospacedDigit().weight(.semibold))
        }
        .padding(.vertical, 8)
    }
}
