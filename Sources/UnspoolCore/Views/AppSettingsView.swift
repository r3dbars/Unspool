import AppKit
import SwiftUI

public struct AppSettingsView: View {
    @AppStorage(EntryDirectoryPreference.userDefaultsKey) private var customEntriesDirectoryPath = ""

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
}
