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

                    dailyChallengeCard

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
            .navigationTitle("PochiDoku")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button { showSettings = true } label: {
                        Image(systemName: "gearshape.fill")
                    }
                    .accessibilityLabel("Settings")
                }
            }
            .sheet(isPresented: $showSettings) { SettingsView() }
            .onAppear { viewModel.refreshDailyProgress() }
        }
    }

    private var dailyChallengeCard: some View {
        Button { viewModel.startDailyChallenge() } label: {
            HStack(spacing: 14) {
                Image(systemName: viewModel.isTodayChallengeCompleted ? "checkmark.seal.fill" : "calendar")
                    .font(.system(size: 28, weight: .semibold))
                    .foregroundStyle(.white)
                    .frame(width: 52, height: 52)
                    .background(Color.accentColor, in: RoundedRectangle(cornerRadius: 14))

                VStack(alignment: .leading, spacing: 3) {
                    Text("Daily Challenge")
                        .font(.headline)
                        .foregroundStyle(.primary)
                    Text(dailyChallengeSubtitle)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                VStack(alignment: .trailing, spacing: 4) {
                    Label("\(viewModel.dailyStreak)", systemImage: "pawprint.fill")
                        .font(.headline.monospacedDigit())
                        .foregroundStyle(.tint)
                    Text("streak")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
            }
            .padding(16)
            .background(Color.accentColor.opacity(0.09), in: RoundedRectangle(cornerRadius: 18))
            .overlay {
                RoundedRectangle(cornerRadius: 18)
                    .stroke(Color.accentColor.opacity(0.18), lineWidth: 1)
            }
        }
        .buttonStyle(.plain)
        .accessibilityHint("Starts today's shared Medium puzzle")
    }

    private var dailyChallengeSubtitle: String {
        if viewModel.isTodayChallengeCompleted { return L10n.text("Completed today · Play again") }
        return L10n.text("Medium · One shared puzzle")
    }

    private var header: some View {
        VStack(spacing: 6) {
            PochiGlyph(kind: .brand, color: .accentColor)
                .frame(width: 62, height: 62)
            Text("Nine lives. Nine numbers. One Pochi.")
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
            let kind = saved.isDaily ? L10n.text("Daily") : saved.difficulty.title
            return L10n.format("%@ · %@", kind, saved.elapsed)
        }
        return L10n.text("Resume your game in progress")
    }
}

/// Small, code-native illustrations drawn on a shared 24×24 grid.
struct PochiGlyph: View {
    enum Kind {
        case brand
        case yarn
        case curious
        case claws
        case royal
    }

    let kind: Kind
    let color: Color

    var body: some View {
        Canvas { context, size in
            let scale = min(size.width, size.height) / 24
            context.translateBy(
                x: (size.width - 24 * scale) / 2,
                y: (size.height - 24 * scale) / 2
            )
            context.scaleBy(x: scale, y: scale)

            switch kind {
            case .brand:   drawBrand(in: &context)
            case .yarn:    drawYarn(in: &context)
            case .curious: drawCat(in: &context)
            case .claws:   drawClaws(in: &context)
            case .royal:   drawCat(in: &context, crowned: true)
            }
        }
        .accessibilityHidden(true)
    }

    private var strokeStyle: StrokeStyle {
        StrokeStyle(lineWidth: 1.7, lineCap: .round, lineJoin: .round)
    }

    private func stroke(_ path: Path, in context: inout GraphicsContext, opacity: Double = 1) {
        context.stroke(path, with: .color(color.opacity(opacity)), style: strokeStyle)
    }

    private func fill(_ path: Path, in context: inout GraphicsContext) {
        context.fill(path, with: .color(color))
    }

    private func drawBrand(in context: inout GraphicsContext) {
        let head = catHead(offsetY: 0)
        stroke(head, in: &context)

        var grid = Path()
        for coordinate: CGFloat in [9.4, 14.6] {
            grid.move(to: CGPoint(x: coordinate, y: 7.5))
            grid.addLine(to: CGPoint(x: coordinate, y: 17.2))
            grid.move(to: CGPoint(x: 6.8, y: coordinate + 0.2))
            grid.addLine(to: CGPoint(x: 17.2, y: coordinate + 0.2))
        }
        stroke(grid, in: &context, opacity: 0.38)

        fill(Path(ellipseIn: CGRect(x: 7.5, y: 10.2, width: 1.8, height: 2.2)), in: &context)
        fill(Path(ellipseIn: CGRect(x: 14.7, y: 10.2, width: 1.8, height: 2.2)), in: &context)

        var smile = Path()
        smile.move(to: CGPoint(x: 10.1, y: 15.1))
        smile.addQuadCurve(to: CGPoint(x: 12, y: 16.3), control: CGPoint(x: 10.8, y: 16.3))
        smile.addQuadCurve(to: CGPoint(x: 13.9, y: 15.1), control: CGPoint(x: 13.2, y: 16.3))
        stroke(smile, in: &context)
    }

    private func drawYarn(in context: inout GraphicsContext) {
        var ball = Path()
        ball.addEllipse(in: CGRect(x: 4.5, y: 4.2, width: 14, height: 14))
        stroke(ball, in: &context)

        var strands = Path()
        strands.move(to: CGPoint(x: 7, y: 6.8))
        strands.addCurve(
            to: CGPoint(x: 16.5, y: 14.9),
            control1: CGPoint(x: 11.8, y: 7),
            control2: CGPoint(x: 13, y: 13.5)
        )
        strands.move(to: CGPoint(x: 15.8, y: 6.6))
        strands.addCurve(
            to: CGPoint(x: 6.7, y: 14.6),
            control1: CGPoint(x: 11.7, y: 8),
            control2: CGPoint(x: 10.2, y: 13.4)
        )
        strands.move(to: CGPoint(x: 5.4, y: 11.2))
        strands.addCurve(
            to: CGPoint(x: 17.5, y: 10.2),
            control1: CGPoint(x: 8.7, y: 13.2),
            control2: CGPoint(x: 14.3, y: 7.9)
        )
        strands.move(to: CGPoint(x: 15.8, y: 16.6))
        strands.addCurve(
            to: CGPoint(x: 21, y: 19.2),
            control1: CGPoint(x: 18.5, y: 17),
            control2: CGPoint(x: 18.8, y: 20.2)
        )
        stroke(strands, in: &context)
    }

    private func drawCat(in context: inout GraphicsContext, crowned: Bool = false) {
        let offset = crowned ? 2.2 : 0
        stroke(catHead(offsetY: offset), in: &context)

        fill(Path(ellipseIn: CGRect(x: 7.4, y: 10.2 + offset, width: 1.7, height: 2.1)), in: &context)
        fill(Path(ellipseIn: CGRect(x: 14.9, y: 10.2 + offset, width: 1.7, height: 2.1)), in: &context)

        var face = Path()
        face.move(to: CGPoint(x: 11, y: 14 + offset))
        face.addLine(to: CGPoint(x: 13, y: 14 + offset))
        face.addLine(to: CGPoint(x: 12, y: 15 + offset))
        face.closeSubpath()
        fill(face, in: &context)

        var whiskers = Path()
        for y: CGFloat in [14.3, 16.1] {
            whiskers.move(to: CGPoint(x: 9.3, y: y + offset))
            whiskers.addLine(to: CGPoint(x: 4.6, y: y - 0.7 + offset))
            whiskers.move(to: CGPoint(x: 14.7, y: y + offset))
            whiskers.addLine(to: CGPoint(x: 19.4, y: y - 0.7 + offset))
        }
        stroke(whiskers, in: &context)

        if crowned {
            var crown = Path()
            crown.move(to: CGPoint(x: 8, y: 6.7))
            crown.addLine(to: CGPoint(x: 7.3, y: 2.7))
            crown.addLine(to: CGPoint(x: 10.5, y: 4.8))
            crown.addLine(to: CGPoint(x: 12, y: 1.8))
            crown.addLine(to: CGPoint(x: 13.5, y: 4.8))
            crown.addLine(to: CGPoint(x: 16.7, y: 2.7))
            crown.addLine(to: CGPoint(x: 16, y: 6.7))
            crown.closeSubpath()
            stroke(crown, in: &context)
        }
    }

    private func catHead(offsetY: CGFloat) -> Path {
        var head = Path()
        head.move(to: CGPoint(x: 5, y: 8 + offsetY))
        head.addLine(to: CGPoint(x: 5, y: 3.5 + offsetY))
        head.addLine(to: CGPoint(x: 9.2, y: 6.2 + offsetY))
        head.addCurve(
            to: CGPoint(x: 14.8, y: 6.2 + offsetY),
            control1: CGPoint(x: 10.8, y: 5.6 + offsetY),
            control2: CGPoint(x: 13.2, y: 5.6 + offsetY)
        )
        head.addLine(to: CGPoint(x: 19, y: 3.5 + offsetY))
        head.addLine(to: CGPoint(x: 19, y: 13.4 + offsetY))
        head.addCurve(
            to: CGPoint(x: 12, y: 20 + offsetY),
            control1: CGPoint(x: 19, y: 17.8 + offsetY),
            control2: CGPoint(x: 16.2, y: 20 + offsetY)
        )
        head.addCurve(
            to: CGPoint(x: 5, y: 13.4 + offsetY),
            control1: CGPoint(x: 7.8, y: 20 + offsetY),
            control2: CGPoint(x: 5, y: 17.8 + offsetY)
        )
        head.closeSubpath()
        return head
    }

    private func drawClaws(in context: inout GraphicsContext) {
        for offset: CGFloat in [0, 5.1, 10.2] {
            var claw = Path()
            claw.move(to: CGPoint(x: 5.2 + offset, y: 18.8))
            claw.addCurve(
                to: CGPoint(x: 8.9 + offset, y: 4.3),
                control1: CGPoint(x: 6.1 + offset, y: 13.3),
                control2: CGPoint(x: 6.8 + offset, y: 7.4)
            )
            claw.addCurve(
                to: CGPoint(x: 7.7 + offset, y: 13.2),
                control1: CGPoint(x: 9.2 + offset, y: 8.3),
                control2: CGPoint(x: 8.8 + offset, y: 11.2)
            )
            claw.addCurve(
                to: CGPoint(x: 5.2 + offset, y: 18.8),
                control1: CGPoint(x: 6.9 + offset, y: 15.5),
                control2: CGPoint(x: 6 + offset, y: 17.4)
            )
            fill(claw, in: &context)
        }
    }
}

extension Difficulty {
    var glyphKind: PochiGlyph.Kind {
        switch self {
        case .easy:   return .yarn
        case .medium: return .curious
        case .hard:   return .claws
        case .expert: return .royal
        }
    }
}

/// A tappable difficulty card on the home screen.
private struct DifficultyRow: View {
    let level: Difficulty
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 14) {
                PochiGlyph(kind: level.glyphKind, color: .white)
                    .frame(width: 27, height: 27)
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
