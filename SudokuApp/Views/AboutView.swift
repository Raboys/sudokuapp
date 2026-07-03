import SwiftUI

/// About tab: what the app is, who makes it, the age guidance, and the version.
struct AboutView: View {
    private let developerURL = URL(string: "https://www.tertiaryinfotech.com")!

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
                            Image(systemName: "square.grid.3x3.fill")
                                .font(.system(size: 34))
                                .foregroundStyle(.tint)
                            Text("Sudoku")
                                .font(.title3.bold())
                        }
                        Text("A clean, classic Sudoku for iPhone. Every puzzle is generated on your device with a guaranteed unique solution, across four difficulty levels with smart hints, pencil notes, and scoring. Your scores, times, and history are stored only on this iPhone and never leave it.")
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
                            Label("Tertiary Infotech Academy Pte Ltd", systemImage: "building.2.fill")
                                .padding(.vertical, 14)
                            Divider()
                            Link(destination: developerURL) {
                                Label("tertiaryinfotech.com", systemImage: "globe")
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
