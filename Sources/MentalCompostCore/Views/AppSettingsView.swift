import AppKit
import SwiftUI

public struct AppSettingsView: View {
    @AppStorage("customExportDirectoryPath") private var customExportDirectoryPath = ""
    @AppStorage("localAIEnabled") private var localAIEnabled = false
    @AppStorage("localAIEndpointURL") private var localAIEndpointURL = LocalModelDefaults.endpointURLString
    @AppStorage("localAIModelName") private var localAIModelName = LocalModelDefaults.modelName
    @State private var localAITestMessage: String?

    public init() {}

    public var body: some View {
        Form {
            Section("Storage") {
                pathRow("Entries", url: EntryStore.defaultEntriesDirectory())
                pathRow("AI context exports", url: effectiveExportDirectory)

                HStack {
                    Button("Reveal Entries Folder in Finder") {
                        reveal(EntryStore.defaultEntriesDirectory())
                    }

                    Button("Reveal Exports Folder in Finder") {
                        reveal(effectiveExportDirectory)
                    }
                }
            }

            Section("AI Context Export") {
                HStack {
                    Button("Choose Export Folder...") {
                        chooseExportFolder()
                    }

                    Button("Use Default") {
                        customExportDirectoryPath = ""
                    }
                    .disabled(customExportDirectoryPath.isEmpty)
                }
            }

            Section("Local Model") {
                Toggle("Use local model for future reviews", isOn: $localAIEnabled)

                Text("Recommended: \(LocalModelDefaults.displayName)")
                    .font(.caption)
                    .foregroundStyle(.secondary)

                TextField("Endpoint URL", text: $localAIEndpointURL)
                    .textFieldStyle(.roundedBorder)

                TextField("Model name", text: $localAIModelName)
                    .textFieldStyle(.roundedBorder)

                if !isEndpointLocalhost {
                    Text("Privacy note: this endpoint is not localhost. Only use it if you trust where your writing is going.")
                        .font(.caption)
                        .foregroundStyle(.orange)
                }

                HStack {
                    Button("Use Recommended MLX Model") {
                        localAIEndpointURL = LocalModelDefaults.endpointURLString
                        localAIModelName = LocalModelDefaults.modelName
                    }

                    Button("Test Local Model") {
                        testLocalAI()
                    }

                    if let localAITestMessage {
                        Text(localAITestMessage)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
            }

            Section("Privacy") {
                PrivacyAboutView()
            }
        }
        .formStyle(.grouped)
        .padding(20)
        .frame(width: 720)
    }

    private var effectiveExportDirectory: URL {
        ExportPathResolver(customExportDirectory: customExportDirectory).exportDirectory
    }

    private var customExportDirectory: URL? {
        guard !customExportDirectoryPath.isEmpty else { return nil }
        return URL(fileURLWithPath: customExportDirectoryPath)
    }

    private var isEndpointLocalhost: Bool {
        guard let url = URL(string: localAIEndpointURL),
              let host = url.host()?.lowercased() else {
            return true
        }
        return host == "localhost" || host == "127.0.0.1" || host == "::1"
    }

    private func pathRow(_ title: String, url: URL) -> some View {
        LabeledContent(title) {
            Text(url.path)
                .textSelection(.enabled)
                .foregroundStyle(.secondary)
        }
    }

    private func chooseExportFolder() {
        let panel = NSOpenPanel()
        panel.canChooseDirectories = true
        panel.canChooseFiles = false
        panel.allowsMultipleSelection = false
        panel.prompt = "Choose"

        if panel.runModal() == .OK, let url = panel.url {
            customExportDirectoryPath = url.path
        }
    }

    private func reveal(_ url: URL) {
        try? FileManager.default.createDirectory(at: url, withIntermediateDirectories: true)
        NSWorkspace.shared.selectFile(nil, inFileViewerRootedAtPath: url.path)
    }

    private func testLocalAI() {
        guard let endpoint = URL(string: localAIEndpointURL) else {
            localAITestMessage = "Endpoint URL is invalid."
            return
        }

        localAITestMessage = "Testing..."
        Task {
            do {
                let client = OpenAICompatibleLocalAIClient(endpointURL: endpoint, timeout: 10, allowNonLocalEndpoint: true)
                _ = try await client.chatCompletion(
                    model: localAIModelName,
                    messages: [
                        LocalAIMessage(role: "system", content: "Reply with OK."),
                        LocalAIMessage(role: "user", content: "OK?")
                    ],
                    temperature: 0
                )
                await MainActor.run {
                    localAITestMessage = "Local model responded."
                }
            } catch {
                await MainActor.run {
                    localAITestMessage = "Local model unavailable."
                }
            }
        }
    }
}
