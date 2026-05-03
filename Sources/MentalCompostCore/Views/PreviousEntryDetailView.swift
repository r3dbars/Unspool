import SwiftUI

public struct PreviousEntryDetailView: View {
    public var entry: DailyEntry

    public init(entry: DailyEntry) {
        self.entry = entry
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
    }
}
