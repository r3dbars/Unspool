import Foundation

public struct EntryStatsSummary: Equatable, Sendable {
    public var totalWords: Int
    public var totalEntries: Int
    public var writingDays: Int
    public var completedDays: Int
    public var currentStreak: Int
    public var bestStreak: Int
    public var averageWordsPerWritingDay: Int

    public init(entries: [DailyEntry], today: Date = Date()) {
        let writtenEntries = entries.filter { $0.wordCount > 0 }
        let wordsByDay = Dictionary(grouping: writtenEntries, by: \.dayString)
            .mapValues { $0.reduce(0) { $0 + $1.wordCount } }
        let completedDays = Dictionary(grouping: entries.filter(\.reachedGoal), by: \.dayString)

        totalWords = writtenEntries.reduce(0) { $0 + $1.wordCount }
        totalEntries = writtenEntries.count
        writingDays = wordsByDay.count
        self.completedDays = completedDays.count
        currentStreak = StreakCalculator.currentStreak(entries: entries, today: today)
        bestStreak = StreakCalculator.bestStreak(entries: entries)
        averageWordsPerWritingDay = wordsByDay.isEmpty ? 0 : totalWords / wordsByDay.count
    }
}
