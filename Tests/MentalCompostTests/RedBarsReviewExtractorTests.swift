import MentalCompostCore
import XCTest

final class RedBarsReviewExtractorTests: XCTestCase {
    func testExtractsInsightSummaryFromReviewMarkdown() {
        let review = CompostReview(
            entryDate: fixedDate("2026-05-02"),
            sourceWordCount: 812,
            generationMode: .localAI,
            userEditedMarkdown: """
            ## Red Bars Review

            ### Bottleneck
            - Unclear demo.

            ### Next Red Bar
            - Show the rough version.

            ### Green Bar Signal
            - One useful reply.
            """
        )
        let reviewedAt = Date(timeIntervalSince1970: 500)

        let summary = RedBarsReviewExtractor.insightSummary(from: review, reviewedAt: reviewedAt)

        XCTAssertEqual(summary.reviewedAt, reviewedAt)
        XCTAssertEqual(summary.bottleneck, "Unclear demo.")
        XCTAssertEqual(summary.nextRedBar, "Show the rough version.")
        XCTAssertEqual(summary.greenBarSignal, "One useful reply.")
    }
}
