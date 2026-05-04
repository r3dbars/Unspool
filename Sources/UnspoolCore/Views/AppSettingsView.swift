import AppKit
import SwiftUI

public struct AppSettingsView: View {
    @AppStorage(EntryDirectoryPreference.userDefaultsKey) private var customEntriesDirectoryPath = ""
    @AppStorage("customExportDirectoryPath") private var customExportDirectoryPath = ""
    @AppStorage("localAIEnabled") private var localAIEnabled = false
    @AppStorage("localAIEndpointURL") private var localAIEndpointURL = LocalModelDefaults.endpointURLString
    @AppStorage("localAIModelName") private var localAIModelName = LocalModelDefaults.modelName
    @State private var localAITestMessage: String?

    public init() {}

    public var body: some View {
        Form {
            Section("Storage") {
                pathRow("Entries", url: effectiveEntriesDirectory)

                HStack {
                    Button("Choose Entries Folder...") {
                        chooseEntriesFolder()
                    }

                    Button("Reveal Entries Folder") {
                        reveal(effectiveEntriesDirectory)
                    }

                    Button("Use Default Entries Folder") {
                        setEntriesDirectory(nil)
                    }
                    .disabled(customEntriesDirectoryPath.isEmpty)
                }
            }

            Section("Experimental") {
                Text("These are optional tools from an earlier reflection prototype. They are not needed for daily writing.")
                    .font(.caption)
                    .foregroundStyle(.secondary)

                DisclosureGroup("AI context export") {
                    pathRow("Exports", url: effectiveExportDirectory)

                    HStack {
                        Button("Choose Export Folder...") {
                            chooseExportFolder()
                        }

                        Button("Reveal Exports Folder") {
                            reveal(effectiveExportDirectory)
                        }

                        Button("Use Default Export Folder") {
                            customExportDirectoryPath = ""
                        }
                        .disabled(customExportDirectoryPath.isEmpty)
                    }
                }

                DisclosureGroup("Local model") {
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
            }

            Section("Privacy") {
                PrivacyAboutView()
            }
        }
        .formStyle(.grouped)
        .padding(20)
        .frame(width: 720)
    }

    private var effectiveEntriesDirectory: URL {
        EntryDirectoryPreference.preferredDirectory()
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

    private func chooseEntriesFolder() {
        chooseFolder(prompt: "Choose") { url in
            setEntriesDirectory(url)
        }
    }

    private func chooseExportFolder() {
        chooseFolder(prompt: "Choose") { url in
            customExportDirectoryPath = url.path
        }
    }

    private func chooseFolder(prompt: String, onChoose: (URL) -> Void) {
        let panel = NSOpenPanel()
        panel.canChooseDirectories = true
        panel.canChooseFiles = false
        panel.allowsMultipleSelection = false
        panel.prompt = prompt

        if panel.runModal() == .OK, let url = panel.url {
            onChoose(url)
        }
    }

    private func setEntriesDirectory(_ url: URL?) {
        EntryDirectoryPreference.setPreferredDirectory(url)
        customEntriesDirectoryPath = url?.standardizedFileURL.path ?? ""
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
