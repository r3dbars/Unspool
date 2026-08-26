import UnspoolCore
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

    func testSwitchEntriesDirectoryCarriesExistingMarkdown() throws {
        let originalDirectory = try temporaryDirectory()
        let newDirectory = try temporaryDirectory()
        let today = fixedDate("2026-05-02")
        let entry = DailyEntry(
            id: "2026-05-02-080000",
            date: today,
            body: "this should follow the folder",
            createdAt: Date(timeIntervalSince1970: 100)
        )
        try MarkdownEntrySerializer.save(
            entry,
            to: originalDirectory.appendingPathComponent("\(entry.id).md")
        )

        let store = EntryStore(entriesDirectory: originalDirectory, today: today)
        try store.switchEntriesDirectory(to: newDirectory, today: today)

        XCTAssertEqual(store.entriesDirectory.standardizedFileURL, newDirectory.standardizedFileURL)
        XCTAssertEqual(store.todayEntry.id, entry.id)
        XCTAssertEqual(store.todayEntry.body, entry.body)
        XCTAssertTrue(FileManager.default.fileExists(atPath: newDirectory.appendingPathComponent("\(entry.id).md").path))
    }

    func testDuplicateEntryIDsDoNotCrashVisibleEntries() throws {
        let directory = try temporaryDirectory()
        let today = fixedDate("2026-05-02")
        let first = DailyEntry(
            id: "2026-05-02-080000",
            date: today,
            body: "first copy",
            createdAt: Date(timeIntervalSince1970: 100)
        )
        let second = DailyEntry(
            id: "2026-05-02-080000",
            date: today,
            body: "second copy",
            createdAt: Date(timeIntervalSince1970: 200)
        )
        try MarkdownEntrySerializer.save(first, to: directory.appendingPathComponent("2026-05-02-080000.md"))
        try MarkdownEntrySerializer.save(second, to: directory.appendingPathComponent("2026-05-02-080000-copy.md"))

        let store = EntryStore(entriesDirectory: directory, today: today)
        XCTAssertEqual(Set(store.visibleEntries.map(\.id)).count, store.visibleEntries.count)
    }

    func testPastDayDuplicateIDsKeepNewestAndDoNotCrashPreviousEntries() throws {
        let directory = try temporaryDirectory()
        let today = fixedDate("2026-05-02")
        let yesterday = fixedDate("2026-05-01")
        let older = DailyEntry(
            id: "2026-05-01-080000",
            date: yesterday,
            body: Array(repeating: "word", count: 750).joined(separator: " "),
            createdAt: Date(timeIntervalSince1970: 100)
        )
        let newer = DailyEntry(
            id: "2026-05-01-080000",
            date: yesterday,
            body: Array(repeating: "later", count: 750).joined(separator: " "),
            createdAt: Date(timeIntervalSince1970: 200)
        )
        try MarkdownEntrySerializer.save(older, to: directory.appendingPathComponent("2026-05-01-080000.md"))
        try MarkdownEntrySerializer.save(newer, to: directory.appendingPathComponent("2026-05-01-080000-copy.md"))

        let store = EntryStore(entriesDirectory: directory, today: today)
        XCTAssertEqual(store.previousEntries.map(\.id), [newer.id])
        XCTAssertEqual(store.previousEntries.first?.body, newer.body)
    }
}
