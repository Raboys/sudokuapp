import SwiftUI

/// About tab: what the app is, who makes it, the age guidance, and the version.
struct AboutView: View {
    private let projectURL = URL(string: "https://github.com/Raboys/sudokuapp")!

    private var versionString: String {
        let info = Bundle.main.infoDictionary
        let version = info?["CFBundleShortVersionString"] as? String ?? "1.0"
        let build = info?["CFBundleVersion"] as? String ?? "1"
        return "\(version) (\(build))"
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    // App card
                    VStack(alignment: .leading, spacing: 10) {
                        HStack(spacing: 12) {
                            PochiGlyph(kind: .brand, color: .accentColor)
                                .frame(width: 38, height: 38)
                            Text("PochiDoku")
                                .font(.title3.bold())
                        }
                        Text("A clean, classic Sudoku for iPhone. Every puzzle is generated on your device with a guaranteed unique solution, including a new daily challenge. Live scores, streaks, times, and history stay only on this iPhone and never leave it.")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    .padding(18)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color(.secondarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: 18, style: .continuous))

                    // Developer card
                    VStack(alignment: .leading, spacing: 8) {
                        Text("DEVELOPER")
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(.secondary)
                        VStack(alignment: .leading, spacing: 0) {
                            Label("Raboys", systemImage: "building.2.fill")
                                .padding(.vertical, 14)
                            Divider()
                            Link(destination: projectURL) {
                                Label("Open-source project", systemImage: "chevron.left.forwardslash.chevron.right")
                            }
                            .padding(.vertical, 14)
                        }
                        .padding(.horizontal, 18)
                        .background(Color(.secondarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: 18, style: .continuous))
                    }

                    // Age + version card
                    VStack(alignment: .leading, spacing: 0) {
                        HStack {
                            Text("Age guidance")
                            Spacer()
                            Text("14+").foregroundStyle(.secondary)
                        }
                        .padding(.vertical, 14)
                        Divider()
                        HStack {
                            Text("Version")
                            Spacer()
                            Text(versionString).foregroundStyle(.secondary)
                        }
                        .padding(.vertical, 14)
                    }
                    .padding(.horizontal, 18)
                    .background(Color(.secondarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: 18, style: .continuous))
                }
                .padding(20)
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("About")
        }
    }
}
