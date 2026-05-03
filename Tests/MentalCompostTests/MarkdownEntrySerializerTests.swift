import MentalCompostCore
import XCTest

final class MarkdownEntrySerializerTests: XCTestCase {
    func testEntrySerializesWithMetadataAndBody() throws {
        let entry = DailyEntry(
            date: fixedDate("2026-05-02"),
            body: "I wrote a lot today.\n\nThis line should stay.",
            createdAt: Date(timeIntervalSince1970: 100),
            updatedAt: Date(timeIntervalSince1970: 200)
        )

        let markdown = MarkdownEntrySerializer.markdown(for: entry)

        XCTAssertTrue(markdown.contains("date: 2026-05-02"))
        XCTAssertTrue(markdown.contains("app: Mental Compost"))
        XCTAssertTrue(markdown.contains("type: daily-entry"))
        XCTAssertTrue(markdown.contains("wordCount: 9"))
        XCTAssertTrue(markdown.contains("reachedGoal: false"))
        XCTAssertTrue(markdown.contains("# Mental Compost — 2026-05-02"))
        XCTAssertTrue(markdown.hasSuffix(entry.body))
    }

    func testEntryCanBeSavedAndLoadedWithoutLosingBodyText() throws {
        let directory = try temporaryDirectory()
        let fileURL = directory.appendingPathComponent("2026-05-02.md")
        let body = "First paragraph.\n\n- markdown list\n- with symbols: --- and #"
        let entry = DailyEntry(date: fixedDate("2026-05-02"), body: body)

        try MarkdownEntrySerializer.save(entry, to: fileURL)
        let loaded = try MarkdownEntrySerializer.load(from: fileURL)

        XCTAssertEqual(loaded.dayString, "2026-05-02")
        XCTAssertEqual(loaded.body, body)
        XCTAssertEqual(loaded.wordCount, WordCounter.count(body))
    }

    func testEntrySerializesAndLoadsInsightFrontmatter() throws {
        let reviewedAt = Date(timeIntervalSince1970: 300)
        let entry = DailyEntry(
            date: fixedDate("2026-05-02"),
            body: "Some body",
            insightSummary: EntryInsightSummary(
                reviewedAt: reviewedAt,
                bottleneck: "Unclear demo",
                nextRedBar: "Show the rough version",
                greenBarSignal: "One user asks for it again"
            )
        )

        let markdown = MarkdownEntrySerializer.markdown(for: entry)
        let loaded = try MarkdownEntrySerializer.entry(from: markdown)

        XCTAssertTrue(markdown.contains("insightBottleneck: \"Unclear demo\""))
        XCTAssertEqual(loaded.insightSummary?.reviewedAt, reviewedAt)
        XCTAssertEqual(loaded.insightSummary?.bottleneck, "Unclear demo")
        XCTAssertEqual(loaded.insightSummary?.nextRedBar, "Show the rough version")
        XCTAssertEqual(loaded.insightSummary?.greenBarSignal, "One user asks for it again")
    }
}
