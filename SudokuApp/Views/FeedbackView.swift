import SwiftUI

/// Feedback tab: a title and message that open in WhatsApp, pre-filled, so the
/// player can send feedback directly. Nothing is sent or stored by the app itself.
struct FeedbackView: View {
    private let whatsAppNumber = "6588666375"   // +65 8866 6375, country code, no "+"/spaces

    @State private var title = ""
    @State private var message = ""

    private var canSend: Bool {
        !title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            || !message.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    Text("Found a bug, or have an idea for the game? We'd love to hear it.")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)

                    TextField("Title", text: $title)
                        .padding(14)
                        .background(Color(.secondarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: 12))

                    ZStack(alignment: .topLeading) {
                        if message.isEmpty {
                            Text("Your message…")
                                .foregroundStyle(.secondary)
                                .padding(.top, 22)
                                .padding(.leading, 18)
                        }
                        TextEditor(text: $message)
                            .scrollContentBackground(.hidden)
                            .frame(minHeight: 180)
                            .padding(10)
                            .background(Color(.secondarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: 12))
                    }

                    Button(action: send) {
                        Label("Send via WhatsApp", systemImage: "paperplane.fill")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                    }
                    .buttonStyle(.borderedProminent)
                    .disabled(!canSend)
                }
                .padding(20)
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Feedback")
        }
    }

    private func send() {
        var body = ""
        let t = title.trimmingCharacters(in: .whitespacesAndNewlines)
        let m = message.trimmingCharacters(in: .whitespacesAndNewlines)
        if !t.isEmpty { body += "*\(t)*\n" }
        body += m

        var comps = URLComponents()
        comps.scheme = "https"
        comps.host = "wa.me"
        comps.path = "/\(whatsAppNumber)"
        comps.queryItems = [URLQueryItem(name: "text", value: body)]
        if let url = comps.url {
            UIApplication.shared.open(url)
        }
    }
}
