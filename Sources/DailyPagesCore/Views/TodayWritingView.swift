import SwiftUI

public struct TodayWritingView: View {
    @ObservedObject public var store: EntryStore
    @FocusState private var editorFocused: Bool
    @State private var showingAIContext = false
    @AppStorage("customExportDirectoryPath") private var customExportDirectoryPath = ""

    public init(store: EntryStore) {
        self.store = store
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            header

            TextEditor(text: Binding(
                get: { store.todayEntry.body },
                set: { store.updateTodayBody($0) }
            ))
            .font(.system(size: 17, design: .serif))
            .lineSpacing(5)
            .scrollContentBackground(.hidden)
            .padding(14)
            .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 8))
            .focused($editorFocused)
            .accessibilityLabel("Today's daily page")

            if let error = store.saveErrorMessage {
                Text(error)
                    .font(.caption)
                    .foregroundStyle(.red)
            }
        }
        .padding(24)
        .frame(minWidth: 640, minHeight: 520)
        .toolbar {
            ToolbarItemGroup {
                Button("Previous Days") {
                    NSApp.sendAction(#selector(NSSplitViewController.toggleSidebar(_:)), to: nil, from: nil)
                }

                Button("Prepare AI Context") {
                    showingAIContext = true
                }
                .disabled(store.todayEntry.body.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            }
        }
        .sheet(isPresented: $showingAIContext) {
            AIContextExportView(
                entry: store.todayEntry,
                exportStore: ContextExportStore(customExportDirectory: customExportDirectory)
            ) { _ in
                store.markTodayExported()
            }
        }
        .onAppear {
            editorFocused = true
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(alignment: .firstTextBaseline) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Today's Page")
                        .font(.largeTitle.bold())
                    Text("750 words / 3 pages")
                        .foregroundStyle(.secondary)
                }

                Spacer()

                VStack(alignment: .trailing, spacing: 4) {
                    Text("\(store.todayEntry.wordCount) words")
                        .font(.title3.monospacedDigit())
                    Text("Streak \(store.currentStreak)")
                        .font(.callout)
                        .foregroundStyle(.secondary)
                }
            }

            ProgressView(value: min(Double(store.todayEntry.wordCount) / 750.0, 1.0))
                .tint(store.todayEntry.reachedGoal ? .green : .accentColor)

            Text(statusMessage(for: store.todayEntry.wordCount))
                .font(.callout)
                .foregroundStyle(store.todayEntry.reachedGoal ? .green : .secondary)
        }
    }

    private var customExportDirectory: URL? {
        guard !customExportDirectoryPath.isEmpty else { return nil }
        return URL(fileURLWithPath: customExportDirectoryPath)
    }

    private func statusMessage(for wordCount: Int) -> String {
        switch wordCount {
        case 0:
            "Start anywhere. This stays private."
        case 1...249:
            "Keep unloading."
        case 250...499:
            "You're clearing space."
        case 500...749:
            "Almost at three pages."
        default:
            "Green bar. You showed up."
        }
    }
}
