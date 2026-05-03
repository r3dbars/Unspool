import SwiftUI

public struct PreviousEntryDetailView: View {
    public var entry: DailyEntry
    @ObservedObject public var entryStore: EntryStore
    @ObservedObject public var compostStore: CompostReviewStore
    @State private var showingCompost = false

    public init(entry: DailyEntry, entryStore: EntryStore, compostStore: CompostReviewStore) {
        self.entry = entry
        self.entryStore = entryStore
        self.compostStore = compostStore
    }

    public var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                HStack(alignment: .firstTextBaseline) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(entry.dayString)
                            .font(.largeTitle.bold())
                        Text("\(entry.wordCount) words")
                            .foregroundStyle(.secondary)
                    }

                    Spacer()

                    if entry.reachedGoal {
                        Label("Goal reached", systemImage: "checkmark.circle.fill")
                            .foregroundStyle(.green)
                    }

                    Button(compostStore.hasReview(for: entry.date) ? "Open Review" : "AI Insights") {
                        showingCompost = true
                    }
                    .disabled(!entry.reachedGoal)
                    .help(entry.reachedGoal ? "Open or create a Red Bars Review for this day" : "Insights unlock after 750 words")
                }

                Text(entry.body.isEmpty ? "No writing saved for this day." : entry.body)
                    .font(.system(size: 17, design: .serif))
                    .lineSpacing(5)
                    .textSelection(.enabled)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding(28)
            .frame(maxWidth: 840)
        }
        .frame(minWidth: 640, minHeight: 520)
        .sheet(isPresented: $showingCompost) {
            CompostReviewView(
                entry: entry,
                compostStore: compostStore,
                onSave: { review in
                    entryStore.markComposted(for: review.entryDate, at: review.generatedAt)
                },
                onApplyToEntry: { review in
                    entryStore.applyInsights(from: review)
                }
            )
        }
    }
}
