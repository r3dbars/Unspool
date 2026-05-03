import AppKit
import SwiftUI

public struct TodayWritingView: View {
    @ObservedObject public var entryStore: EntryStore
    @ObservedObject public var compostStore: CompostReviewStore
    public var onToggleHistory: () -> Void
    @Environment(\.colorScheme) private var colorScheme
    @FocusState private var editorFocused: Bool
    @State private var showingCompost = false
    @State private var bottomBarHovered = false
    @State private var backspaceDisabled = false
    @State private var placeholder = TodayWritingView.placeholders.randomElement() ?? "Start anywhere."
    @State private var isFullscreen = false

    @AppStorage("writingFontStyle") private var writingFontStyle = "Serif"
    @AppStorage("writingFontSize") private var writingFontSize = 19.0
    @AppStorage("ritualColorScheme") private var ritualColorScheme = "system"

    private static let placeholders = [
        "Start with the mess.",
        "What keeps circling?",
        "One honest sentence.",
        "Dump the noise.",
        "Write the thing under the thing.",
        "Let it decompose."
    ]

    public init(entryStore: EntryStore, compostStore: CompostReviewStore, onToggleHistory: @escaping () -> Void = {}) {
        self.entryStore = entryStore
        self.compostStore = compostStore
        self.onToggleHistory = onToggleHistory
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
                .opacity(bottomBarHovered ? 1 : 0)
                .animation(.easeInOut(duration: 0.22), value: bottomBarHovered)
                .contentShape(Rectangle())
                .onHover { bottomBarHovered = $0 }
        }
        .frame(minWidth: 720, minHeight: 560)
        .background(BackspaceGuardView(isEnabled: backspaceDisabled).frame(width: 0, height: 0))
        .sheet(isPresented: $showingCompost) {
            CompostReviewView(entry: entryStore.todayEntry, compostStore: compostStore) { review in
                entryStore.markComposted(for: review.entryDate, at: review.generatedAt)
            }
        }
        .onAppear {
            editorFocused = true
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
                    Text("Today’s Pile")
                        .font(.system(size: 32, weight: .semibold, design: .serif))
                    Text("750 words / 3 pages · dump the noise")
                        .font(.callout)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                HStack(spacing: 18) {
                    statusMetric(title: "Words", value: "\(entryStore.todayEntry.wordCount)")
                    statusMetric(title: "Streak", value: "\(entryStore.currentStreak)")
                }
            }

            ProgressView(value: min(Double(entryStore.todayEntry.wordCount) / 750.0, 1.0))
                .tint(entryStore.todayEntry.reachedGoal ? MentalCompostColor.sproutGreen : MentalCompostColor.mossGreen)

            HStack {
                Text(statusMessage(for: entryStore.todayEntry.wordCount))
                    .font(.callout)
                    .foregroundStyle(entryStore.todayEntry.reachedGoal ? MentalCompostColor.sproutGreen : .secondary)

                Spacer()

                if let error = entryStore.saveErrorMessage {
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
                get: { entryStore.todayEntry.body },
                set: { entryStore.updateTodayBody($0) }
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

            if entryStore.todayEntry.body.isEmpty {
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
                onToggleHistory()
            }
            .help("Show previous days")

            Button {
                showingCompost = true
            } label: {
                Label("Compost Today’s Page", systemImage: "leaf")
            }
            .buttonStyle(.borderedProminent)
            .tint(MentalCompostColor.mossGreen)
            .controlSize(.small)
            .disabled(!entryStore.todayEntry.reachedGoal)
            .help(entryStore.todayEntry.reachedGoal ? "Turn today’s page into editable compost" : "Compost unlocks after 750 words")
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
        colorScheme == .dark ? MentalCompostColor.charcoalSoil : MentalCompostColor.warmPaper
    }

    private var fontSizeTitle: String {
        "\(Int(writingFontSize))px"
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
            "Start with the mess. This stays private."
        case 1...249:
            "The pile is warming up."
        case 250...499:
            "Something useful is forming."
        case 500...749:
            "Let it decompose a little longer."
        default:
            "Fruit found. You showed up."
        }
    }
}

public enum MentalCompostColor {
    public static let warmPaper = Color(red: 0.96, green: 0.92, blue: 0.84)
    public static let mossGreen = Color(red: 0.31, green: 0.43, blue: 0.25)
    public static let sproutGreen = Color(red: 0.34, green: 0.58, blue: 0.28)
    public static let clay = Color(red: 0.67, green: 0.38, blue: 0.27)
    public static let charcoalSoil = Color(red: 0.12, green: 0.11, blue: 0.09)
}
