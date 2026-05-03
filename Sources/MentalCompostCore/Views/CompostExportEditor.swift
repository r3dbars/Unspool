import SwiftUI

public struct CompostExportEditor: View {
    public var review: CompostReview
    public var exporter: AIContextExporter
    public var onExport: (CompostReview) -> Void

    @Environment(\.dismiss) private var dismiss
    @State private var selectedContext: String
    @State private var exportMessage: String?
    @State private var exportError: String?

    public init(review: CompostReview, exporter: AIContextExporter, onExport: @escaping (CompostReview) -> Void) {
        self.review = review
        self.exporter = exporter
        self.onExport = onExport
        _selectedContext = State(initialValue: review.markdownBody)
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(alignment: .firstTextBaseline) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Export Selected Review")
                        .font(.title.bold())
                    Text("Only export what you want your AI tools to remember.")
                        .foregroundStyle(.secondary)
                }

                Spacer()

                Button("Cancel") {
                    dismiss()
                }
            }

            TextEditor(text: $selectedContext)
                .font(.system(size: 15, design: .serif))
                .lineSpacing(5)
                .scrollContentBackground(.hidden)
                .padding(12)
                .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 8))

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
                Spacer()

                Button("Export to AI Context") {
                    export()
                }
                .buttonStyle(.borderedProminent)
                .tint(MentalCompostColor.mossGreen)
                .disabled(selectedContext.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            }
        }
        .padding(22)
        .frame(minWidth: 720, minHeight: 560)
    }

    private func export() {
        do {
            let exportedURL = try exporter.export(selectedContext: selectedContext, for: review)
            let exportedReview = review.withEditedMarkdown(selectedContext).markedExported()
            exportMessage = "Exported to \(exportedURL.path)"
            exportError = nil
            onExport(exportedReview)
        } catch {
            exportError = "Could not export: \(error.localizedDescription)"
        }
    }
}
