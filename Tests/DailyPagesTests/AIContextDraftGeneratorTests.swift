import DailyPagesCore
import XCTest

final class AIContextDraftGeneratorTests: XCTestCase {
    func testExtractsParagraphsWithKeywords() {
        let text = """
        This is a private warmup paragraph.

        Project idea: make the writing flow calmer.

        Another private paragraph without a signal.

        Remember to follow up with a customer bug.
        """

        let paragraphs = AIContextDraftGenerator.usefulParagraphs(from: text)

        XCTAssertEqual(paragraphs.count, 2)
        XCTAssertTrue(paragraphs[0].contains("Project idea"))
        XCTAssertTrue(paragraphs[1].contains("customer bug"))
    }

    func testDraftDoesNotExportEntireEntryAutomatically() {
        let privateParagraph = "This private paragraph has no keyword."
        let usefulParagraph = "Decision: promote only this part."
        let entry = DailyEntry(date: fixedDate("2026-05-02"), body: "\(privateParagraph)\n\n\(usefulParagraph)")

        let draft = AIContextDraftGenerator.draft(for: entry)

        XCTAssertFalse(draft.contains(privateParagraph))
        XCTAssertTrue(draft.contains(usefulParagraph))
    }

    func testFallbackTemplateWhenNothingRelevantIsFound() {
        let entry = DailyEntry(date: fixedDate("2026-05-02"), body: "Just ordinary morning pages.")

        let draft = AIContextDraftGenerator.draft(for: entry)

        XCTAssertTrue(draft.contains("No obvious AI-context paragraphs were found."))
        XCTAssertTrue(draft.contains("Add only the ideas"))
    }
}
