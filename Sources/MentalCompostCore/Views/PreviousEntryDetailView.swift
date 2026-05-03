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

                    Button(compostStore.hasReview(for: entry.date) ? "Open Compost" : "Compost This Day") {
                        showingCompost = true
                    }
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
            CompostReviewView(entry: entry, compostStore: compostStore) { review in
                entryStore.markComposted(for: review.entryDate, at: review.generatedAt)
            }
        }
    }
}
