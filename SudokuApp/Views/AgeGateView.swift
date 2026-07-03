import SwiftUI

/// One-time 14+ confirmation. A single self-declaration tap — no ID, no verification,
/// nothing collected. The choice is stored on-device.
struct AgeGateView: View {
    @EnvironmentObject private var viewModel: GameViewModel

    var body: some View {
        VStack(spacing: 28) {
            Spacer()

            Image(systemName: "14.circle.fill")
                .font(.system(size: 84, weight: .bold))
                .foregroundStyle(.tint)
                .accessibilityHidden(true)

            VStack(spacing: 10) {
                Text("Sudoku")
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
