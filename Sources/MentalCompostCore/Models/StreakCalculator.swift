import Foundation

public enum StreakCalculator {
    public static func currentStreak(entries: [DailyEntry], today: Date = Date()) -> Int {
        let entriesByDay = Dictionary(uniqueKeysWithValues: entries.map { ($0.dayString, $0) })
        let todayStart = DateSupport.startOfDay(for: today)
        let todayKey = DateSupport.dayString(for: todayStart)
        let yesterday = DateSupport.addingDays(-1, to: todayStart)

        let anchor: Date
        if entriesByDay[todayKey]?.reachedGoal == true {
            anchor = todayStart
        } else if entriesByDay[DateSupport.dayString(for: yesterday)]?.reachedGoal == true {
            anchor = yesterday
        } else {
            return 0
        }

        var count = 0
        var cursor = anchor
        while entriesByDay[DateSupport.dayString(for: cursor)]?.reachedGoal == true {
            count += 1
            cursor = DateSupport.addingDays(-1, to: cursor)
        }
        return count
    }
}
