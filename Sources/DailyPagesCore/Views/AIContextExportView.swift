import SwiftUI

public struct AIContextExportView: View {
    public var entry: DailyEntry
    public var exportStore: ContextExportStore
    public var onExport: (URL) -> Void

    @Environment(\.dismiss) private var dismiss
    @State private var selectedContext = ""
    @State private var exportMessage: String?
    @State private var exportError: String?

    public init(entry: DailyEntry, exportStore: ContextExportStore, onExport: @escaping (URL) -> Void) {
        self.entry = entry
        self.exportStore = exportStore
        self.onExport = onExport
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(alignment: .firstTextBaseline) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Prepare AI Context")
                        .font(.title.bold())
                    Text("Only export what you want your AI tools to remember.")
                        .foregroundStyle(.secondary)
                }

                Spacer()

                Button("Cancel") {
                    dismiss()
                }
            }

            HSplitView {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Full private entry")
                        .font(.headline)
                    TextEditor(text: .constant(entry.body))
                        .font(.system(size: 14, design: .serif))
                        .disabled(true)
                        .scrollContentBackground(.hidden)
                        .padding(10)
                        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 8))
                }
                .frame(minWidth: 320)

                VStack(alignment: .leading, spacing: 8) {
                    Text("Selected Context")
                        .font(.headline)
                    TextEditor(text: $selectedContext)
                        .font(.system(size: 14, design: .serif))
                        .scrollContentBackground(.hidden)
                        .padding(10)
                        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 8))
                }
                .frame(minWidth: 320)
            }

            if let exportMessage {
                Text(exportMessage)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .textSelection(.enabled)
            }

            if let exportError {
                Text(exportError)
                    .font(.caption)
                    .foregroundStyle(.red)
            }

            HStack {
                Button("Generate Simple Context Draft") {
                    selectedContext = AIContextDraftGenerator.draft(for: entry)
                }

                Spacer()

                Button("Export Context Markdown") {
                    exportContext()
                }
                .buttonStyle(.borderedProminent)
                .disabled(selectedContext.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            }
        }
        .padding(22)
        .frame(minWidth: 820, minHeight: 560)
    }

    private func exportContext() {
        do {
            let url = try exportStore.export(context: selectedContext, for: entry)
            exportMessage = "Exported to \(url.path)"
            exportError = nil
            onExport(url)
        } catch {
            exportError = "Could not export: \(error.localizedDescription)"
        }
    }
}
