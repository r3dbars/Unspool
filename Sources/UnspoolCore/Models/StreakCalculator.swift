import Foundation

public enum StreakCalculator {
    public static func currentStreak(entries: [DailyEntry], today: Date = Date()) -> Int {
        let completedDays = completedDayStrings(from: entries)
        let todayStart = DateSupport.startOfDay(for: today)
        let todayKey = DateSupport.dayString(for: todayStart)
        let yesterday = DateSupport.addingDays(-1, to: todayStart)

        let anchor: Date
        if completedDays.contains(todayKey) {
            anchor = todayStart
        } else if completedDays.contains(DateSupport.dayString(for: yesterday)) {
            anchor = yesterday
        } else {
            return 0
        }

        var count = 0
        var cursor = anchor
        while completedDays.contains(DateSupport.dayString(for: cursor)) {
            count += 1
            cursor = DateSupport.addingDays(-1, to: cursor)
        }
        return count
    }

    public static func bestStreak(entries: [DailyEntry]) -> Int {
        let completedDays = completedDayStrings(from: entries)
        let dates = completedDays
            .compactMap(DateSupport.date(fromDayString:))
            .sorted()
        guard !dates.isEmpty else { return 0 }

        var best = 1
        var current = 1

        for index in dates.indices.dropFirst() {
            let previous = dates[dates.index(before: index)]
            let expected = DateSupport.addingDays(1, to: previous)
            if DateSupport.dayString(for: dates[index]) == DateSupport.dayString(for: expected) {
                current += 1
            } else {
                current = 1
            }
            best = max(best, current)
        }

        return best
    }

    private static func completedDayStrings(from entries: [DailyEntry]) -> Set<String> {
        Set(entries.filter(\.reachedGoal).map(\.dayString))
    }
}
