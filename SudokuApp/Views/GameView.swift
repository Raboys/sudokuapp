import SwiftUI

/// The playing screen: status bar, the board, the number pad, and the action row
/// (undo, erase, notes, hint).
struct GameView: View {
    @EnvironmentObject private var viewModel: GameViewModel
    @State private var showQuitConfirm = false

    var body: some View {
        VStack(spacing: 12) {
            topBar
                .padding(.horizontal, 16)
            metricsBar
                .padding(.horizontal, 16)
            boardArea
                .padding(.horizontal, 2)
            Spacer(minLength: 0)
            actionRow
                .padding(.horizontal, 8)
            NumberPad { viewModel.enter($0) }
                .padding(.horizontal, 4)
        }
        .padding(.top, 8)
        .padding(.bottom, 12)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemGroupedBackground))
        .toolbar(.hidden, for: .navigationBar)
        .confirmationDialog("Leave this game?", isPresented: $showQuitConfirm, titleVisibility: .visible) {
            Button("Save & Quit") { viewModel.quitToHome() }
            Button("Keep Playing", role: .cancel) {}
        } message: {
            Text("Your progress is saved so you can continue later.")
        }
    }

    // MARK: Progress header

    private var topBar: some View {
        HStack {
            Button { showQuitConfirm = true } label: {
                Image(systemName: "chevron.left").font(.headline)
            }
            .accessibilityLabel("Back")

            Label(L10n.format("Streak %d", viewModel.dailyStreak), systemImage: "pawprint.fill")
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(.tint)

            Spacer()

            if viewModel.isDailyChallenge {
                Label("Daily", systemImage: "calendar")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.secondary)
            }
        }
    }

    private var metricsBar: some View {
        HStack(alignment: .bottom, spacing: 8) {
            metric(title: L10n.text("Mistakes"), value: "\(viewModel.mistakes)/\(viewModel.mistakeLimit)", color: .red)
                .frame(maxWidth: .infinity, alignment: .leading)

            VStack(spacing: 2) {
                Text(L10n.format("Score: %d", viewModel.liveScore))
                    .font(.headline.monospacedDigit())
                    .foregroundStyle(.tint)
                HStack(spacing: 4) {
                    MiniCatMark(color: viewModel.difficulty.tint)
                        .scaleEffect(0.68)
                        .frame(width: 18, height: 17)
                    Text(viewModel.difficulty.title)
                        .font(.caption)
                }
                .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity)
            .accessibilityElement(children: .combine)

            Button { viewModel.togglePause() } label: {
                VStack(alignment: .trailing, spacing: 2) {
                    Text("Time")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Label(viewModel.formattedElapsed,
                          systemImage: viewModel.isPaused ? "play.fill" : "pause.fill")
                        .font(.subheadline.monospacedDigit())
                        .foregroundStyle(.primary)
                }
            }
            .frame(maxWidth: .infinity, alignment: .trailing)
        }
    }

    private func metric(title: String, value: String, color: Color) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(title).font(.caption).foregroundStyle(.secondary)
            Text(value).font(.subheadline.monospacedDigit()).foregroundStyle(color)
        }
    }

    // MARK: Board

    private var boardArea: some View {
        ZStack {
            BoardView()
                .padding(1)
                .background(Color(.systemBackground), in: RoundedRectangle(cornerRadius: 4))
                .blur(radius: viewModel.isPaused ? 14 : 0)

            if viewModel.isPaused {
                VStack(spacing: 12) {
                    Image(systemName: "pause.circle.fill").font(.system(size: 50))
                    Text("Paused").font(.title2.bold())
                    Button("Resume") { viewModel.togglePause() }
                        .buttonStyle(.borderedProminent)
                }
                .foregroundStyle(.primary)
            }
        }
    }

    // MARK: Actions

    private var actionRow: some View {
        HStack(spacing: 0) {
            ActionButton(title: L10n.text("Undo"), symbol: "arrow.uturn.backward") { viewModel.undo() }
            ActionButton(title: L10n.text("Erase"), symbol: "eraser") { viewModel.erase() }
            ActionButton(title: L10n.text("Notes"),
                         symbol: viewModel.isNotesMode ? "pencil.circle.fill" : "pencil.circle",
                         highlighted: viewModel.isNotesMode) { viewModel.toggleNotesMode() }
            ActionButton(title: L10n.text("Hint"), symbol: "pawprint.fill",
                         highlighted: true,
                         badge: viewModel.hintsUsed > 0 ? "\(viewModel.hintsUsed)" : nil) {
                viewModel.useHint()
            }
        }
    }
}

/// A tiny echo of the 14+ cat badge that keeps the game screen branded without
/// competing with the board.
private struct MiniCatMark: View {
    let color: Color

    var body: some View {
        ZStack {
            MiniCatEar()
                .fill(color)
                .frame(width: 9, height: 9)
                .rotationEffect(.degrees(-9))
                .offset(x: -7, y: -7)

            MiniCatEar()
                .fill(color)
                .frame(width: 9, height: 9)
                .rotationEffect(.degrees(9))
                .offset(x: 7, y: -7)

            Circle()
                .fill(color)
                .frame(width: 22, height: 22)

            HStack(spacing: 6) {
                Capsule().frame(width: 2, height: 4)
                Capsule().frame(width: 2, height: 4)
            }
            .foregroundStyle(.white.opacity(0.88))
            .offset(y: -2)

            CatSmile()
                .stroke(.white.opacity(0.82), style: StrokeStyle(lineWidth: 1, lineCap: .round))
                .frame(width: 8, height: 4)
                .offset(y: 5)
        }
        .frame(width: 26, height: 24)
        .accessibilityHidden(true)
    }
}

private struct MiniCatEar: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.midX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
        path.closeSubpath()
        return path
    }
}

private struct CatSmile: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.midX, y: rect.minY))
        path.addQuadCurve(
            to: CGPoint(x: rect.minX, y: rect.midY),
            control: CGPoint(x: rect.width * 0.35, y: rect.maxY)
        )
        path.move(to: CGPoint(x: rect.midX, y: rect.minY))
        path.addQuadCurve(
            to: CGPoint(x: rect.maxX, y: rect.midY),
            control: CGPoint(x: rect.width * 0.65, y: rect.maxY)
        )
        return path
    }
}

/// One labelled icon button in the action row.
private struct ActionButton: View {
    let title: String
    let symbol: String
    var highlighted: Bool = false
    var badge: String? = nil
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 6) {
                ZStack(alignment: .topTrailing) {
                    Image(systemName: symbol)
                        .font(.system(size: 24))
                        .frame(width: 30, height: 30)
                    if let badge {
                        Text(badge)
                            .font(.system(size: 11, weight: .bold))
                            .foregroundStyle(.white)
                            .padding(4)
                            .background(Circle().fill(.red))
                            .offset(x: 10, y: -8)
                    }
                }
                Text(title).font(.caption)
            }
            .foregroundStyle(highlighted ? Color.accentColor : Color.primary)
            .frame(maxWidth: .infinity)
        }
        .buttonStyle(.plain)
    }
}

/// The 1–9 number pad. Each key shows how many of that digit remain to be placed
/// and disables itself once all nine are on the board.
private struct NumberPad: View {
    @EnvironmentObject private var viewModel: GameViewModel
    let onTap: (Int) -> Void

    var body: some View {
        HStack(spacing: 8) {
            ForEach(1...9, id: \.self) { digit in
                let remaining = viewModel.remaining(for: digit)
                Button { onTap(digit) } label: {
                    VStack(spacing: 2) {
                        Text("\(digit)")
                            .font(.system(size: 28, weight: .semibold, design: .rounded))
                        Text(remaining > 0 ? "\(remaining)" : " ")
                            .font(.system(size: 11))
                            .foregroundStyle(.secondary)
                    }
                    .frame(maxWidth: .infinity, minHeight: 56)
                    .padding(.vertical, 6)
                    .background(Color(.secondarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: 10))
                }
                .buttonStyle(.plain)
                .disabled(remaining == 0)
                .opacity(remaining == 0 ? 0.35 : 1)
            }
        }
    }
}
