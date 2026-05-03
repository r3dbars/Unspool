import AppKit
import SwiftUI

public struct AppSettingsView: View {
    @AppStorage("customExportDirectoryPath") private var customExportDirectoryPath = ""

    public init() {}

    public var body: some View {
        Form {
            Section("Storage") {
                LabeledContent("Entries") {
                    Text(EntryStore.defaultEntriesDirectory().path)
                        .textSelection(.enabled)
                        .foregroundStyle(.secondary)
                }
            }

            Section("AI Context") {
                LabeledContent("Export folder") {
                    Text(effectiveExportDirectory.path)
                        .textSelection(.enabled)
                        .foregroundStyle(.secondary)
                }

                HStack {
                    Button("Choose Folder...") {
                        chooseExportFolder()
                    }

                    Button("Use Default") {
                        customExportDirectoryPath = ""
                    }
                    .disabled(customExportDirectoryPath.isEmpty)
                }
            }
        }
        .formStyle(.grouped)
        .padding(20)
        .frame(width: 620)
    }

    private var effectiveExportDirectory: URL {
        ContextExportStore(customExportDirectory: customExportDirectory).exportDirectory
    }

    private var customExportDirectory: URL? {
        guard !customExportDirectoryPath.isEmpty else { return nil }
        return URL(fileURLWithPath: customExportDirectoryPath)
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
}
