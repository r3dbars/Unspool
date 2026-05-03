import SwiftUI

public struct EntryListView: View {
    public var todayEntry: DailyEntry
    public var previousEntries: [DailyEntry]
    @ObservedObject public var compostStore: CompostReviewStore
    @Binding public var selectedEntryID: String

    public init(
        todayEntry: DailyEntry,
        previousEntries: [DailyEntry],
        compostStore: CompostReviewStore,
        selectedEntryID: Binding<String>
    ) {
        self.todayEntry = todayEntry
        self.previousEntries = previousEntries
        self.compostStore = compostStore
        _selectedEntryID = selectedEntryID
    }

    public var body: some View {
        List(selection: $selectedEntryID) {
            Section {
                entryRow(
                    title: "Today",
                    detail: detail(for: todayEntry),
                    reachedGoal: todayEntry.reachedGoal,
                    composted: compostStore.hasReview(for: todayEntry.date)
                )
                    .tag("today")
            }

            if !previousEntries.isEmpty {
                Section("Previous") {
                    ForEach(previousEntries) { entry in
                        entryRow(
                            title: entry.dayString,
                            detail: detail(for: entry),
                            reachedGoal: entry.reachedGoal,
                            composted: compostStore.hasReview(for: entry.date)
                        )
                        .tag(entry.id)
                    }
                }
            }
        }
        .listStyle(.sidebar)
        .safeAreaInset(edge: .bottom) {
            Text("Local pages. Local compost. No sync.")
                .font(.caption2)
                .foregroundStyle(.tertiary)
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
        }
        .frame(minWidth: 230)
    }

    private func entryRow(title: String, detail: String, reachedGoal: Bool, composted: Bool) -> some View {
        HStack(spacing: 10) {
            Image(systemName: composted ? "leaf.fill" : (reachedGoal ? "checkmark.circle.fill" : "doc.text"))
                .foregroundStyle(composted ? .green : (reachedGoal ? .green : .secondary))
                .frame(width: 16)

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .lineLimit(1)
                Text(detail)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
            }
        }
    }

    private func detail(for entry: DailyEntry) -> String {
        let compost = compostStore.hasReview(for: entry.date) ? " · composted" : ""
        return "\(entry.wordCount) words\(compost)"
    }
}
