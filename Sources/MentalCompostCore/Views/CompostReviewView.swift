import AppKit
import SwiftUI

public struct CompostReviewView: View {
    public var entry: DailyEntry
    @ObservedObject public var compostStore: CompostReviewStore
    public var onSave: (CompostReview) -> Void

    @Environment(\.dismiss) private var dismiss
    @State private var draftMarkdown = CompostReview.manualTemplateMarkdown
    @State private var activeReview: CompostReview?
    @State private var statusMessage: String?
    @State private var errorMessage: String?
    @State private var isGenerating = false
    @State private var showingExportEditor = false

    @AppStorage("customExportDirectoryPath") private var customExportDirectoryPath = ""
    @AppStorage("localAIEnabled") private var localAIEnabled = false
    @AppStorage("localAIEndpointURL") private var localAIEndpointURL = "http://localhost:8080/v1/chat/completions"
    @AppStorage("localAIModelName") private var localAIModelName = "local-model"

    public init(entry: DailyEntry, compostStore: CompostReviewStore, onSave: @escaping (CompostReview) -> Void) {
        self.entry = entry
        self.compostStore = compostStore
        self.onSave = onSave
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            header

            if localAIUnavailableMessageIsUseful {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Local AI isn’t running, but the pile is still yours.")
                    Text("You can manually compost today’s page or use the simple offline heuristic.")
                }
                .font(.callout)
                .foregroundStyle(.secondary)
                .padding(10)
                .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 8))
            }

            TextEditor(text: $draftMarkdown)
                .font(.system(size: 15, design: .serif))
                .lineSpacing(5)
                .scrollContentBackground(.hidden)
                .padding(12)
                .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 8))
                .accessibilityLabel("Editable compost review")

            if let statusMessage {
                Text(statusMessage)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .textSelection(.enabled)
            }

            if let errorMessage {
                Text(errorMessage)
                    .font(.caption)
                    .foregroundStyle(.red)
            }

            actions
        }
        .padding(22)
        .frame(minWidth: 780, minHeight: 620)
        .sheet(isPresented: $showingExportEditor) {
            CompostExportEditor(
                review: currentReview().withEditedMarkdown(draftMarkdown),
                exporter: AIContextExporter(resolver: ExportPathResolver(customExportDirectory: customExportDirectory))
            ) { exportedReview in
                activeReview = exportedReview
                draftMarkdown = exportedReview.markdownBody
                compostStore.save(exportedReview)
                onSave(exportedReview)
            }
        }
        .onAppear {
            if let existing = compostStore.review(for: entry.date) {
                activeReview = existing
                draftMarkdown = existing.markdownBody
            } else {
                activeReview = CompostReview.manualTemplate(for: entry)
                draftMarkdown = CompostReview.manualTemplateMarkdown
            }
        }
        .onDisappear {
            saveCurrentReview()
        }
    }

    private var header: some View {
        HStack(alignment: .firstTextBaseline) {
            VStack(alignment: .leading, spacing: 4) {
                Text("Compost Review")
                    .font(.title.bold())
                Text("Possible seeds. Possible weeds. Nothing leaves your Mac unless you choose.")
                    .foregroundStyle(.secondary)
            }

            Spacer()

            Button("Cancel") {
                dismiss()
            }
        }
    }

    private var actions: some View {
        HStack {
            Button("Regenerate with Local AI") {
                generateWithLocalAI()
            }
            .disabled(isGenerating)

            Button("Use Simple Local Heuristic") {
                useHeuristic()
            }

            Button("Copy as Markdown") {
                copyMarkdown()
            }

            Spacer()

            Button("Save Review") {
                saveCurrentReview()
            }

            Button("Export Selected Compost") {
                saveCurrentReview()
                showingExportEditor = true
            }
            .buttonStyle(.borderedProminent)
            .tint(MentalCompostColor.mossGreen)
            .disabled(draftMarkdown.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
        }
    }

    private var localAIUnavailableMessageIsUseful: Bool {
        !localAIEnabled || errorMessage != nil
    }

    private var customExportDirectory: URL? {
        guard !customExportDirectoryPath.isEmpty else { return nil }
        return URL(fileURLWithPath: customExportDirectoryPath)
    }

    private func generateWithLocalAI() {
        guard localAIEnabled else {
            errorMessage = "Local AI is off. Turn it on in Settings or use the simple offline heuristic."
            return
        }

        guard let endpoint = URL(string: localAIEndpointURL) else {
            errorMessage = "The local AI endpoint URL is invalid."
            return
        }

        isGenerating = true
        errorMessage = nil
        statusMessage = "Composting locally..."

        Task {
            do {
                let generator = CompostGenerator(
                    localAIClient: OpenAICompatibleLocalAIClient(endpointURL: endpoint, allowNonLocalEndpoint: true)
                )
                let review = try await generator.generateWithLocalAI(for: entry, model: localAIModelName)
                await MainActor.run {
                    activeReview = review
                    draftMarkdown = review.markdownBody
                    compostStore.save(review)
                    onSave(review)
                    statusMessage = "Local AI composted the pile. Edit anything before export."
                    isGenerating = false
                }
            } catch {
                await MainActor.run {
                    errorMessage = "Local AI isn’t running, but the pile is still yours."
                    statusMessage = "Use the simple offline heuristic or edit the template by hand."
                    isGenerating = false
                }
            }
        }
    }

    private func useHeuristic() {
        let review = CompostGenerator.generateHeuristic(for: entry)
        activeReview = review
        draftMarkdown = review.markdownBody
        compostStore.save(review)
        onSave(review)
        errorMessage = nil
        statusMessage = "Simple local heuristic created a draft. Edit freely."
    }

    private func saveCurrentReview() {
        let review = currentReview().withEditedMarkdown(draftMarkdown)
        activeReview = review
        compostStore.save(review)
        onSave(review)
        statusMessage = "Compost review saved locally."
    }

    private func currentReview() -> CompostReview {
        activeReview ?? CompostReview.manualTemplate(for: entry)
    }

    private func copyMarkdown() {
        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString(draftMarkdown, forType: .string)
        statusMessage = "Copied compost Markdown."
    }
}

