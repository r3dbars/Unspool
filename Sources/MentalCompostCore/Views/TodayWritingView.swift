import AppKit
import SwiftUI

public struct TodayWritingView: View {
    @ObservedObject public var entryStore: EntryStore
    public var onToggleHistory: () -> Void
    @Environment(\.colorScheme) private var colorScheme
    @FocusState private var editorFocused: Bool
    @State private var bottomBarHovered = false
    @State private var backspaceDisabled = false
    @State private var isFullscreen = false

    @AppStorage("writingFontStyle") private var writingFontStyle = "Serif"
    @AppStorage("writingFontSize") private var writingFontSize = 19.0
    @AppStorage("ritualColorScheme") private var ritualColorScheme = "system"
    private let editorHorizontalInset = 18.0
    private let editorTopInset = 64.0
    private let editorBottomInset = 44.0
    private let placeholderCaretGap = 7.0
    private let fadeEdgeHeight = 42.0

    public init(entryStore: EntryStore, onToggleHistory: @escaping () -> Void = {}) {
        self.entryStore = entryStore
        self.onToggleHistory = onToggleHistory
    }

    public var body: some View {
        ZStack(alignment: .bottom) {
            ritualBackground.ignoresSafeArea()

            editorSurface
                .padding(.horizontal, 34)
                .padding(.top, 14)
                .padding(.bottom, 58)

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
            .padding(.top, editorTopInset)
            .padding(.bottom, editorBottomInset)
            .padding(.horizontal, editorHorizontalInset)
            .frame(maxWidth: 720, maxHeight: .infinity)
            .mask(editorFadeMask)
            .focused($editorFocused)
            .accessibilityLabel("Today's daily page")

            if entryStore.todayEntry.body.isEmpty {
                Text("Unspool the noise")
                    .font(editorFont)
                    .lineSpacing(7)
                    .foregroundStyle(placeholderColor)
                    .padding(.leading, editorHorizontalInset + placeholderCaretGap)
                    .padding(.trailing, editorHorizontalInset)
                    .padding(.top, editorTopInset)
                    .allowsHitTesting(false)
            }
        }
        .frame(maxWidth: 720, maxHeight: .infinity)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
    }

    private var bottomBar: some View {
        HStack(spacing: 6) {
            compactProgress

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
                onToggleHistory()
            }
            .help("Show previous days")
        }
        .font(.system(size: 12, weight: .medium))
        .padding(.horizontal, 10)
        .padding(.vertical, 8)
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 8))
    }

    private var compactProgress: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack(spacing: 6) {
                Text("\(entryStore.todayEntry.wordCount) / 750")
                    .font(.caption.monospacedDigit())
                    .foregroundStyle(entryStore.todayEntry.reachedGoal ? MentalCompostColor.sproutGreen : .secondary)

                Text("·")
                    .foregroundStyle(.tertiary)

                Text("Streak \(entryStore.currentStreak)")
                    .font(.caption.monospacedDigit())
                    .foregroundStyle(.secondary)
            }

            HStack(spacing: 8) {
                ProgressView(value: min(Double(entryStore.todayEntry.wordCount) / 750.0, 1.0))
                    .controlSize(.mini)
                    .tint(entryStore.todayEntry.reachedGoal ? MentalCompostColor.sproutGreen : MentalCompostColor.mossGreen)
                    .frame(width: 116)

                Text(entryStore.saveErrorMessage ?? statusMessage(for: entryStore.todayEntry.wordCount))
                    .font(.caption2)
                    .foregroundStyle(entryStore.saveErrorMessage == nil ? Color.secondary.opacity(0.65) : Color.red)
                    .lineLimit(1)
            }
        }
        .frame(width: 260, alignment: .leading)
    }

    private func bottomButton(_ title: String, systemImage: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Label(title, systemImage: systemImage)
                .labelStyle(.titleAndIcon)
                .padding(.horizontal, 8)
                .frame(height: 28)
                .contentShape(RoundedRectangle(cornerRadius: 6))
        }
        .buttonStyle(.plain)
        .foregroundStyle(.secondary)
        .background(Color.primary.opacity(0.001), in: RoundedRectangle(cornerRadius: 6))
    }

    private var editorFadeMask: some View {
        VStack(spacing: 0) {
            LinearGradient(
                colors: [.clear, .black],
                startPoint: .top,
                endPoint: .bottom
            )
            .frame(height: fadeEdgeHeight)

            Rectangle()
                .fill(.black)

            LinearGradient(
                colors: [.black, .clear],
                startPoint: .top,
                endPoint: .bottom
            )
            .frame(height: fadeEdgeHeight)
        }
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

    private var placeholderColor: Color {
        colorScheme == .dark ? Color.white.opacity(0.24) : Color.black.opacity(0.28)
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
            "Start anywhere. This stays private."
        case 1...249:
            "Keep going."
        case 250...499:
            "The page is opening up."
        case 500...749:
            "A little more out of your head."
        default:
            "Page saved."
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
