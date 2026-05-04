import UnspoolCore
import XCTest

final class StreakCalculatorTests: XCTestCase {
    func testNoEntriesIsZero() {
        XCTAssertEqual(StreakCalculator.currentStreak(entries: [], today: fixedDate("2026-05-02")), 0)
    }

    func testOneCompletedTodayIsOne() {
        let today = fixedDate("2026-05-02")
        XCTAssertEqual(StreakCalculator.currentStreak(entries: [completed(today)], today: today), 1)
    }

    func testCompletedYesterdayAndTodayIsTwo() {
        let today = fixedDate("2026-05-02")
        let yesterday = fixedDate("2026-05-01")

        XCTAssertEqual(
            StreakCalculator.currentStreak(entries: [completed(yesterday), completed(today)], today: today),
            2
        )
    }

    func testMultipleEntriesOnSameCompletedDayCountAsOneStreakDay() {
        let today = fixedDate("2026-05-02")
        let firstToday = completed(today, id: "2026-05-02-080000")
        let secondToday = completed(today, id: "2026-05-02-090000")

        XCTAssertEqual(
            StreakCalculator.currentStreak(entries: [firstToday, secondToday], today: today),
            1
        )
    }

    func testBestStreakUsesCompletedDays() {
        let dayOne = fixedDate("2026-04-29")
        let dayTwo = fixedDate("2026-04-30")
        let dayFour = fixedDate("2026-05-02")

        XCTAssertEqual(
            StreakCalculator.bestStreak(entries: [completed(dayOne), completed(dayTwo), completed(dayFour)]),
            2
        )
    }

    func testGapBreaksStreak() {
        let today = fixedDate("2026-05-02")
        let twoDaysAgo = fixedDate("2026-04-30")

        XCTAssertEqual(
            StreakCalculator.currentStreak(entries: [completed(today), completed(twoDaysAgo)], today: today),
            1
        )
    }

    func testYesterdayCompleteButTodayIncompleteShowsExistingStreak() {
        let today = fixedDate("2026-05-02")
        let yesterday = fixedDate("2026-05-01")
        let twoDaysAgo = fixedDate("2026-04-30")
        let incompleteToday = DailyEntry(date: today, body: "not enough yet")

        XCTAssertEqual(
            StreakCalculator.currentStreak(
                entries: [completed(twoDaysAgo), completed(yesterday), incompleteToday],
                today: today
            ),
            2
        )
    }

    private func completed(_ date: Date, id: String? = nil) -> DailyEntry {
        DailyEntry(id: id, date: date, body: Array(repeating: "word", count: 750).joined(separator: " "))
    }
}
