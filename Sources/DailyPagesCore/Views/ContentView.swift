import SwiftUI

public struct ContentView: View {
    @StateObject private var store: EntryStore
    @SceneStorage("selectedEntryID") private var selectedEntryID = "today"
    @Environment(\.scenePhase) private var scenePhase

    public init(store: EntryStore = EntryStore()) {
        _store = StateObject(wrappedValue: store)
    }

    public var body: some View {
        NavigationSplitView {
            EntryListView(
                todayEntry: store.todayEntry,
                previousEntries: store.previousEntries,
                selectedEntryID: $selectedEntryID
            )
        } detail: {
            if selectedEntryID == "today" {
                TodayWritingView(store: store)
            } else if let entry = store.visibleEntries.first(where: { $0.id == selectedEntryID }) {
                PreviousEntryDetailView(entry: entry)
            } else {
                TodayWritingView(store: store)
            }
        }
        .navigationTitle("Daily Pages")
        .onChange(of: scenePhase) { _, newPhase in
            if newPhase != .active {
                store.saveTodayNow()
            }
        }
    }
}
