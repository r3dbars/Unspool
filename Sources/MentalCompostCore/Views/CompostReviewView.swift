import AppKit
import SwiftUI

public struct CompostReviewView: View {
    public var entry: DailyEntry
    @ObservedObject public var compostStore: CompostReviewStore
    public var onSave: (CompostReview) -> Void
    public var onApplyToEntry: (CompostReview) -> Void

    @Environment(\.dismiss) private var dismiss
    @State private var draftMarkdown = CompostReview.manualTemplateMarkdown
    @State private var activeReview: CompostReview?
    @State private var statusMessage: String?
    @State private var errorMessage: String?
    @State private var isGenerating = false
    @State private var showingExportEditor = false

    @AppStorage("customExportDirectoryPath") private var customExportDirectoryPath = ""
    @AppStorage("localAIEnabled") private var localAIEnabled = false
    @AppStorage("localAIEndpointURL") private var localAIEndpointURL = LocalModelDefaults.endpointURLString
    @AppStorage("localAIModelName") private var localAIModelName = LocalModelDefaults.modelName

    public init(
        entry: DailyEntry,
        compostStore: CompostReviewStore,
        onSave: @escaping (CompostReview) -> Void,
        onApplyToEntry: @escaping (CompostReview) -> Void = { _ in }
    ) {
        self.entry = entry
        self.compostStore = compostStore
        self.onSave = onSave
        self.onApplyToEntry = onApplyToEntry
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            header

            if localAIUnavailableMessageIsUseful {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Local model isn’t running, but the page is already saved.")
                    Text("You can write the Red Bars Review yourself or use the simple offline draft.")
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
                Text("Red Bars Review")
                    .font(.title.bold())
                Text("Find the bottleneck, choose the next red bar, and name the green-bar signal.")
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
            Button("Use Local Model") {
                generateWithLocalAI()
            }
            .disabled(isGenerating)

            Button("Use Simple Offline Draft") {
                useHeuristic()
            }

            Button("Copy as Markdown") {
                copyMarkdown()
            }

            Spacer()

            Button("Save Review") {
                saveCurrentReview()
            }

            Button("Apply to Page") {
                applyToEntry()
            }
            .help("Write bottleneck, next red bar, and green-bar signal into this page’s Markdown frontmatter")

            Button("Export Selected Review") {
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
            errorMessage = "Local model is off. Turn it on in Settings or use the simple offline draft."
            return
        }

        guard let endpoint = URL(string: localAIEndpointURL) else {
            errorMessage = "The local model endpoint URL is invalid."
            return
        }

        isGenerating = true
        errorMessage = nil
        statusMessage = "Reviewing locally..."

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
                    statusMessage = "Local model drafted a Red Bars Review. Edit anything before export."
                    isGenerating = false
                }
            } catch {
                await MainActor.run {
                    errorMessage = "Local model isn’t running, but the page is already saved."
                    statusMessage = "Use the simple offline draft or edit the template by hand."
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
        statusMessage = "Simple offline draft created. Edit freely."
    }

    private func saveCurrentReview() {
        let review = currentReview().withEditedMarkdown(draftMarkdown)
        activeReview = review
        compostStore.save(review)
        onSave(review)
        statusMessage = "Red Bars Review saved locally."
    }

    private func applyToEntry() {
        let review = currentReview().withEditedMarkdown(draftMarkdown)
        activeReview = review
        compostStore.save(review)
        onSave(review)
        onApplyToEntry(review)
        statusMessage = "Insights added to this page’s Markdown frontmatter."
    }

    private func currentReview() -> CompostReview {
        activeReview ?? CompostReview.manualTemplate(for: entry)
    }

    private func copyMarkdown() {
        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString(draftMarkdown, forType: .string)
        statusMessage = "Copied review Markdown."
    }
}
