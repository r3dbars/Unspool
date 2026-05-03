import SwiftUI

public struct EntryListView: View {
    public var todayEntry: DailyEntry
    public var previousEntries: [DailyEntry]
    @Binding public var selectedEntryID: String

    public init(
        todayEntry: DailyEntry,
        previousEntries: [DailyEntry],
        selectedEntryID: Binding<String>
    ) {
        self.todayEntry = todayEntry
        self.previousEntries = previousEntries
        _selectedEntryID = selectedEntryID
    }

    public var body: some View {
        List(selection: $selectedEntryID) {
            Section {
                entryRow(
                    title: "Today",
                    detail: detail(for: todayEntry),
                    reachedGoal: todayEntry.reachedGoal
                )
                    .tag("today")
            }

            if !previousEntries.isEmpty {
                Section("Previous") {
                    ForEach(previousEntries) { entry in
                        entryRow(
                            title: entry.dayString,
                            detail: detail(for: entry),
                            reachedGoal: entry.reachedGoal
                        )
                        .tag(entry.id)
                    }
                }
            }
        }
        .listStyle(.sidebar)
        .safeAreaInset(edge: .bottom) {
            Text("Local pages. No sync.")
                .font(.caption2)
                .foregroundStyle(.tertiary)
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
        }
        .frame(minWidth: 230)
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

    private func detail(for entry: DailyEntry) -> String {
        "\(entry.wordCount) words"
    }
}
