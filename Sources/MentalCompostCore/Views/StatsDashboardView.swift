import SwiftUI

public struct StatsDashboardView: View {
    public var summary: EntryStatsSummary

    public init(summary: EntryStatsSummary) {
        self.summary = summary
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            VStack(alignment: .leading, spacing: 3) {
                Text("Writing Stats")
                    .font(.headline)
                Text("A quiet look at the pages you have kept.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            HStack(spacing: 10) {
                statTile(value: "\(summary.currentStreak)", label: "Current streak")
                statTile(value: "\(summary.bestStreak)", label: "Best streak")
            }

            Divider()

            VStack(spacing: 9) {
                statRow("Total words", value: formatted(summary.totalWords))
                statRow("Writing days", value: "\(summary.writingDays)")
                statRow("Completed days", value: "\(summary.completedDays)")
                statRow("Pages written", value: "\(summary.totalEntries)")
                statRow("Avg words/day", value: formatted(summary.averageWordsPerWritingDay))
            }
        }
        .padding(16)
        .frame(width: 280)
    }

    private func statTile(value: String, label: String) -> some View {
        VStack(alignment: .leading, spacing: 3) {
            Text(value)
                .font(.system(size: 28, weight: .semibold, design: .rounded))
                .monospacedDigit()
                .foregroundStyle(MentalCompostColor.sproutGreen)

            Text(label)
                .font(.caption2.weight(.medium))
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(10)
        .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 8))
    }

    private func statRow(_ title: String, value: String) -> some View {
        HStack {
            Text(title)
                .foregroundStyle(.secondary)
            Spacer()
            Text(value)
                .font(.caption.monospacedDigit().weight(.semibold))
                .foregroundStyle(.primary)
        }
        .font(.caption)
    }

    private func formatted(_ value: Int) -> String {
        value.formatted(.number)
    }
}
