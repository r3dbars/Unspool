import MentalCompostCore
import XCTest

@MainActor
final class EntryStoreTests: XCTestCase {
    func testLaunchResumesLatestCompletedTodayEntry() throws {
        let directory = try temporaryDirectory()
        let today = fixedDate("2026-05-02")
        let completedEntry = DailyEntry(
            id: "2026-05-02-080000",
            date: today,
            body: Array(repeating: "word", count: 750).joined(separator: " "),
            createdAt: Date(timeIntervalSince1970: 100)
        )
        try MarkdownEntrySerializer.save(
            completedEntry,
            to: directory.appendingPathComponent("\(completedEntry.id).md")
        )

        let store = EntryStore(entriesDirectory: directory, today: today)

        XCTAssertEqual(store.todayEntry.id, completedEntry.id)
        XCTAssertEqual(store.todayEntry.body, completedEntry.body)
        XCTAssertEqual(store.previousEntries.map(\.id), [])
    }

    func testLaunchResumesLatestIncompleteTodayEntry() throws {
        let directory = try temporaryDirectory()
        let today = fixedDate("2026-05-02")
        let incompleteEntry = DailyEntry(
            id: "2026-05-02-080000",
            date: today,
            body: "still writing",
            createdAt: Date(timeIntervalSince1970: 100)
        )
        try MarkdownEntrySerializer.save(
            incompleteEntry,
            to: directory.appendingPathComponent("\(incompleteEntry.id).md")
        )

        let store = EntryStore(entriesDirectory: directory, today: today)

        XCTAssertEqual(store.todayEntry.id, incompleteEntry.id)
        XCTAssertEqual(store.todayEntry.body, "still writing")
    }

    func testLaunchCreatesFreshSessionOnNewDay() throws {
        let directory = try temporaryDirectory()
        let yesterday = fixedDate("2026-05-01")
        let today = fixedDate("2026-05-02")
        let completedEntry = DailyEntry(
            id: "2026-05-01-080000",
            date: yesterday,
            body: Array(repeating: "word", count: 750).joined(separator: " "),
            createdAt: Date(timeIntervalSince1970: 100)
        )
        try MarkdownEntrySerializer.save(
            completedEntry,
            to: directory.appendingPathComponent("\(completedEntry.id).md")
        )

        let store = EntryStore(entriesDirectory: directory, today: today)

        XCTAssertTrue(store.todayEntry.body.isEmpty)
        XCTAssertEqual(store.todayEntry.dayString, "2026-05-02")
        XCTAssertEqual(store.previousEntries.map(\.id), [completedEntry.id])
    }
}
