import SwiftUI

public struct EntryListView: View {
    public var todayEntry: DailyEntry
    public var previousEntries: [DailyEntry]
    @Binding public var selectedEntryID: String

    public init(todayEntry: DailyEntry, previousEntries: [DailyEntry], selectedEntryID: Binding<String>) {
        self.todayEntry = todayEntry
        self.previousEntries = previousEntries
        _selectedEntryID = selectedEntryID
    }

    public var body: some View {
        List(selection: $selectedEntryID) {
            Section {
                entryRow(title: "Today", detail: "\(todayEntry.wordCount) words", reachedGoal: todayEntry.reachedGoal)
                    .tag("today")
            }

            if !previousEntries.isEmpty {
                Section("Previous") {
                    ForEach(previousEntries) { entry in
                        entryRow(
                            title: entry.dayString,
                            detail: "\(entry.wordCount) words",
                            reachedGoal: entry.reachedGoal
                        )
                        .tag(entry.id)
                    }
                }
            }
        }
        .listStyle(.sidebar)
        .frame(minWidth: 220)
    }

    private func entryRow(title: String, detail: String, reachedGoal: Bool) -> some View {
        HStack(spacing: 10) {
            Image(systemName: reachedGoal ? "checkmark.circle.fill" : "doc.text")
                .foregroundStyle(reachedGoal ? .green : .secondary)
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
}
