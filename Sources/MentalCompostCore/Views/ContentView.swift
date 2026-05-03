import SwiftUI

public struct ContentView: View {
    @StateObject private var entryStore: EntryStore
    @SceneStorage("selectedEntryID") private var selectedEntryID = "today"
    @State private var columnVisibility: NavigationSplitViewVisibility = .detailOnly
    @Environment(\.scenePhase) private var scenePhase
    @AppStorage("ritualColorScheme") private var ritualColorScheme = "system"

    public init(entryStore: EntryStore = EntryStore()) {
        _entryStore = StateObject(wrappedValue: entryStore)
    }

    public var body: some View {
        NavigationSplitView(columnVisibility: $columnVisibility) {
            EntryListView(
                todayEntry: entryStore.todayEntry,
                previousEntries: entryStore.previousEntries,
                selectedEntryID: $selectedEntryID
            )
        } detail: {
            if selectedEntryID == "today" {
                TodayWritingView(
                    entryStore: entryStore,
                    onToggleHistory: toggleHistory
                )
            } else if let entry = entryStore.visibleEntries.first(where: { $0.id == selectedEntryID }) {
                PreviousEntryDetailView(entry: entry)
            } else {
                TodayWritingView(
                    entryStore: entryStore,
                    onToggleHistory: toggleHistory
                )
            }
        }
        .navigationTitle("Unspool")
        .preferredColorScheme(preferredColorScheme)
        .onChange(of: scenePhase) { _, newPhase in
            if newPhase != .active {
                entryStore.saveTodayNow()
            }
        }
    }

    private var preferredColorScheme: ColorScheme? {
        switch ritualColorScheme {
        case "light": .light
        case "dark": .dark
        default: nil
        }
    }

    private func toggleHistory() {
        withAnimation(.easeInOut(duration: 0.18)) {
            columnVisibility = columnVisibility == .detailOnly ? .all : .detailOnly
        }
    }
}
