import UnspoolCore
import XCTest

final class MarkdownCompostSerializerTests: XCTestCase {
    func testCompostReviewRoundTripPreservesMarkdown() throws {
        let directory = try temporaryDirectory()
        let fileURL = directory.appendingPathComponent("2026-05-02-compost.md")
        let body = """
        ## Red Bars Review

        ### Bottleneck
        - Build a small thing.

        ### Green Bar Signal
        - One useful reply.
        """
        let review = CompostReview(
            entryDate: fixedDate("2026-05-02"),
            sourceWordCount: 812,
            generationMode: .heuristic,
            userEditedMarkdown: body
        )

        try MarkdownCompostSerializer.save(review, to: fileURL)
        let loaded = try MarkdownCompostSerializer.load(from: fileURL)

        XCTAssertEqual(loaded.dayString, "2026-05-02")
        XCTAssertEqual(loaded.sourceWordCount, 812)
        XCTAssertEqual(loaded.generationMode, .heuristic)
        XCTAssertEqual(loaded.markdownBody, body)
    }
}
