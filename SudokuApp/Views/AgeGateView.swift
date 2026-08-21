import SwiftUI

/// One-time 14+ confirmation. A single self-declaration tap — no ID, no verification,
/// nothing collected. The choice is stored on-device.
struct AgeGateView: View {
    @EnvironmentObject private var viewModel: GameViewModel

    var body: some View {
        VStack(spacing: 28) {
            Spacer()

            CatAgeBadge()
                .accessibilityHidden(true)

            VStack(spacing: 10) {
                Text("PochiDoku")
                    .font(.largeTitle.bold())
                Text("This app is intended for players aged 14 and over.")
                    .font(.body)
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.secondary)
                    .padding(.horizontal, 32)
            }

            Spacer()

            VStack(spacing: 12) {
                Button {
                    viewModel.isAgeConfirmed = true
                } label: {
                    Text("I am 14 or older")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                }
                .buttonStyle(.borderedProminent)

                Text("A quick confirmation is all that's needed — no ID and no verification.")
                    .font(.caption)
                    .foregroundStyle(.tertiary)
                    .multilineTextAlignment(.center)
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 24)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemGroupedBackground))
    }
}

/// A quiet cat treatment for the age badge: the number stays dominant while the
/// ears, eyes, whiskers, and tiny mouth give PochiDoku a little personality.
private struct CatAgeBadge: View {
    private let badgeColor = Color.accentColor

    var body: some View {
        ZStack {
            CatEar()
                .fill(badgeColor)
                .frame(width: 30, height: 31)
                .rotationEffect(.degrees(-8))
                .offset(x: -27, y: -34)

            CatEar()
                .fill(badgeColor)
                .frame(width: 30, height: 31)
                .rotationEffect(.degrees(8))
                .offset(x: 27, y: -34)

            CatEar()
                .fill(.white.opacity(0.2))
                .frame(width: 13, height: 15)
                .rotationEffect(.degrees(-8))
                .offset(x: -27, y: -33)

            CatEar()
                .fill(.white.opacity(0.2))
                .frame(width: 13, height: 15)
                .rotationEffect(.degrees(8))
                .offset(x: 27, y: -33)

            Circle()
                .fill(badgeColor)
                .frame(width: 88, height: 88)
                .offset(y: 4)

            HStack(spacing: 31) {
                Capsule()
                    .frame(width: 4, height: 8)
                Capsule()
                    .frame(width: 4, height: 8)
            }
            .foregroundStyle(.white.opacity(0.82))
            .offset(y: -20)

            Text("14")
                .font(.system(size: 32, weight: .bold, design: .rounded))
                .monospacedDigit()
                .foregroundStyle(.white)
                .offset(y: 3)

            Circle()
                .fill(.white.opacity(0.78))
                .frame(width: 3, height: 3)
                .offset(y: 26)

            CatMouth()
                .stroke(.white.opacity(0.72), style: StrokeStyle(lineWidth: 1.5, lineCap: .round))
                .frame(width: 15, height: 7)
                .offset(y: 31)

            whisker(x: -33, y: 24, rotation: -8)
            whisker(x: -33, y: 29, rotation: 8)
            whisker(x: 33, y: 24, rotation: 8)
            whisker(x: 33, y: 29, rotation: -8)
        }
        .frame(width: 108, height: 100)
    }

    private func whisker(x: CGFloat, y: CGFloat, rotation: Double) -> some View {
        Capsule()
            .fill(.white.opacity(0.58))
            .frame(width: 15, height: 1.4)
            .rotationEffect(.degrees(rotation))
            .offset(x: x, y: y)
    }
}

private struct CatEar: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.midX, y: rect.minY))
        path.addQuadCurve(
            to: CGPoint(x: rect.maxX, y: rect.maxY),
            control: CGPoint(x: rect.maxX * 0.92, y: rect.height * 0.45)
        )
        path.addQuadCurve(
            to: CGPoint(x: rect.minX, y: rect.maxY),
            control: CGPoint(x: rect.midX, y: rect.height * 0.88)
        )
        path.addQuadCurve(
            to: CGPoint(x: rect.midX, y: rect.minY),
            control: CGPoint(x: rect.width * 0.08, y: rect.height * 0.45)
        )
        path.closeSubpath()
        return path
    }
}

private struct CatMouth: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.midX, y: rect.minY))
        path.addQuadCurve(
            to: CGPoint(x: rect.minX, y: rect.midY),
            control: CGPoint(x: rect.midX * 0.55, y: rect.maxY)
        )
        path.move(to: CGPoint(x: rect.midX, y: rect.minY))
        path.addQuadCurve(
            to: CGPoint(x: rect.maxX, y: rect.midY),
            control: CGPoint(x: rect.midX * 1.45, y: rect.maxY)
        )
        return path
    }
}
