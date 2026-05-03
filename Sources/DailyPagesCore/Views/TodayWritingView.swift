import AppKit
import SwiftUI

public struct TodayWritingView: View {
    @ObservedObject public var store: EntryStore
    @FocusState private var editorFocused: Bool
    @State private var showingAIContext = false
    @State private var timerRemaining = 15 * 60
    @State private var timerIsRunning = false
    @State private var bottomBarHovered = false
    @State private var backspaceDisabled = false
    @State private var placeholder = TodayWritingView.placeholders.randomElement() ?? "Start anywhere."
    @State private var isFullscreen = false

    @AppStorage("customExportDirectoryPath") private var customExportDirectoryPath = ""
    @AppStorage("writingFontStyle") private var writingFontStyle = "Serif"
    @AppStorage("writingFontSize") private var writingFontSize = 19.0
    @AppStorage("ritualColorScheme") private var ritualColorScheme = "system"

    private let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    private static let placeholders = [
        "Start anywhere.",
        "What keeps circling?",
        "One honest sentence.",
        "Clear the deck.",
        "Write the thing under the thing.",
        "Begin before it makes sense."
    ]

    public init(store: EntryStore) {
        self.store = store
    }

    public var body: some View {
        ZStack(alignment: .bottom) {
            ritualBackground.ignoresSafeArea()

            VStack(spacing: 0) {
                topStatus
                    .padding(.horizontal, 34)
                    .padding(.top, 28)
                    .padding(.bottom, 10)

                editorSurface
                    .padding(.horizontal, 34)
                    .padding(.bottom, 74)
            }

            bottomBar
                .padding(.horizontal, 22)
                .padding(.bottom, 16)
                .opacity(timerIsRunning && !bottomBarHovered ? 0.18 : 1)
                .animation(.easeInOut(duration: 0.2), value: timerIsRunning && !bottomBarHovered)
                .onHover { bottomBarHovered = $0 }
        }
        .frame(minWidth: 720, minHeight: 560)
        .background(BackspaceGuardView(isEnabled: backspaceDisabled).frame(width: 0, height: 0))
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
        .onReceive(timer) { _ in
            guard timerIsRunning else { return }
            if timerRemaining > 0 {
                timerRemaining -= 1
            } else {
                timerIsRunning = false
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: NSWindow.willEnterFullScreenNotification)) { _ in
            isFullscreen = true
        }
        .onReceive(NotificationCenter.default.publisher(for: NSWindow.willExitFullScreenNotification)) { _ in
            isFullscreen = false
        }
    }

    private var topStatus: some View {
        VStack(spacing: 12) {
            HStack(alignment: .firstTextBaseline) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Today's Page")
                        .font(.system(size: 32, weight: .semibold, design: .serif))
                    Text("750 words / 3 pages")
                        .font(.callout)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                HStack(spacing: 18) {
                    statusMetric(title: "Words", value: "\(store.todayEntry.wordCount)")
                    statusMetric(title: "Streak", value: "\(store.currentStreak)")
                }
            }

            ProgressView(value: min(Double(store.todayEntry.wordCount) / 750.0, 1.0))
                .tint(store.todayEntry.reachedGoal ? .green : .accentColor)

            HStack {
                Text(statusMessage(for: store.todayEntry.wordCount))
                    .font(.callout)
                    .foregroundStyle(store.todayEntry.reachedGoal ? .green : .secondary)

                Spacer()

                if let error = store.saveErrorMessage {
                    Text(error)
                        .font(.caption)
                        .foregroundStyle(.red)
                } else {
                    Text("Saved locally")
                        .font(.caption)
                        .foregroundStyle(.tertiary)
                }
            }
        }
    }

    private var editorSurface: some View {
        ZStack(alignment: .topLeading) {
            TextEditor(text: Binding(
                get: { store.todayEntry.body },
                set: { store.updateTodayBody($0) }
            ))
            .font(editorFont)
            .lineSpacing(7)
            .foregroundStyle(editorTextColor)
            .scrollContentBackground(.hidden)
            .scrollIndicators(.never)
            .padding(.horizontal, 18)
            .padding(.vertical, 20)
            .frame(maxWidth: 720)
            .focused($editorFocused)
            .accessibilityLabel("Today's daily page")

            if store.todayEntry.body.isEmpty {
                Text(placeholder)
                    .font(editorFont)
                    .foregroundStyle(.tertiary)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 28)
                    .allowsHitTesting(false)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private var bottomBar: some View {
        HStack(spacing: 10) {
            bottomButton(timerTitle, systemImage: timerIsRunning ? "pause.fill" : "play.fill") {
                timerIsRunning.toggle()
            }
            .help("Start or pause a 15 minute writing timer")

            bottomButton("Reset", systemImage: "arrow.counterclockwise") {
                timerRemaining = 15 * 60
                timerIsRunning = false
            }
            .help("Reset timer")

            Divider().frame(height: 18)

            bottomButton(fontSizeTitle, systemImage: "textformat.size") {
                cycleFontSize()
            }
            .help("Change writing size")

            bottomButton(writingFontStyle, systemImage: "textformat") {
                cycleFontStyle()
            }
            .help("Change writing font")

            bottomButton(backspaceDisabled ? "No Delete" : "Delete On", systemImage: backspaceDisabled ? "delete.left.fill" : "delete.left") {
                backspaceDisabled.toggle()
            }
            .help("Toggle backspace/delete during a freewrite")

            Spacer()

            bottomButton("Folder", systemImage: "folder") {
                NSWorkspace.shared.selectFile(nil, inFileViewerRootedAtPath: EntryStore.defaultEntriesDirectory().path)
            }
            .help("Show local entry folder")

            bottomButton(isFullscreen ? "Window" : "Focus", systemImage: isFullscreen ? "arrow.down.right.and.arrow.up.left" : "arrow.up.left.and.arrow.down.right") {
                NSApp.keyWindow?.toggleFullScreen(nil)
            }
            .help("Toggle fullscreen")

            bottomButton(ritualColorScheme == "dark" ? "Light" : "Dark", systemImage: ritualColorScheme == "dark" ? "sun.max.fill" : "moon.fill") {
                toggleTheme()
            }
            .help("Toggle light or dark writing mode")

            bottomButton("History", systemImage: "clock.arrow.circlepath") {
                NSApp.sendAction(#selector(NSSplitViewController.toggleSidebar(_:)), to: nil, from: nil)
            }
            .help("Show previous days")

            Button {
                showingAIContext = true
            } label: {
                Label("Prepare AI Context", systemImage: "sparkles")
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.small)
            .disabled(store.todayEntry.body.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            .help("Choose what, if anything, AI tools may remember")
        }
        .font(.system(size: 12))
        .padding(.horizontal, 12)
        .padding(.vertical, 9)
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 8))
    }

    private func statusMetric(title: String, value: String) -> some View {
        VStack(alignment: .trailing, spacing: 2) {
            Text(value)
                .font(.title3.monospacedDigit())
            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }

    private func bottomButton(_ title: String, systemImage: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Label(title, systemImage: systemImage)
        }
        .buttonStyle(.plain)
        .foregroundStyle(.secondary)
        .labelStyle(.titleAndIcon)
    }

    private var editorFont: Font {
        switch writingFontStyle {
        case "System":
            .system(size: writingFontSize)
        case "Mono":
            .system(size: writingFontSize, design: .monospaced)
        default:
            .system(size: writingFontSize, design: .serif)
        }
    }

    private var editorTextColor: Color {
        Color(nsColor: .labelColor).opacity(0.9)
    }

    private var ritualBackground: Color {
        Color(nsColor: .textBackgroundColor)
    }

    private var fontSizeTitle: String {
        "\(Int(writingFontSize))px"
    }

    private var timerTitle: String {
        let minutes = timerRemaining / 60
        let seconds = timerRemaining % 60
        return String(format: "%d:%02d", minutes, seconds)
    }

    private var customExportDirectory: URL? {
        guard !customExportDirectoryPath.isEmpty else { return nil }
        return URL(fileURLWithPath: customExportDirectoryPath)
    }

    private func cycleFontStyle() {
        let styles = ["Serif", "System", "Mono"]
        guard let index = styles.firstIndex(of: writingFontStyle) else {
            writingFontStyle = "Serif"
            return
        }
        writingFontStyle = styles[(index + 1) % styles.count]
    }

    private func cycleFontSize() {
        let sizes = [17.0, 19.0, 21.0, 23.0, 26.0]
        guard let index = sizes.firstIndex(of: writingFontSize) else {
            writingFontSize = 19.0
            return
        }
        writingFontSize = sizes[(index + 1) % sizes.count]
    }

    private func toggleTheme() {
        ritualColorScheme = ritualColorScheme == "dark" ? "light" : "dark"
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
