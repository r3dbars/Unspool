import UnspoolCore
import XCTest

final class LocalAIClientTests: XCTestCase {
    func testMockClientSuccessGeneratesLocalAIReview() async throws {
        let markdown = """
        ## Red Bars Review

        ### Bottleneck
        - The unclear demo.
        """
        let client = MockLocalAIClient(result: .success(markdown))
        let generator = CompostGenerator(localAIClient: client)
        let entry = DailyEntry(date: fixedDate("2026-05-02"), body: "idea for an app")

        let review = try await generator.generateWithLocalAI(for: entry, model: "test-model")

        XCTAssertEqual(review.generationMode, .localAI)
        XCTAssertTrue(review.markdownBody.contains("The unclear demo"))
    }

    func testMockClientFailureIsHandledWithoutRealNetwork() async {
        let client = MockLocalAIClient(result: .failure(LocalAIClientError.unavailable))
        let generator = CompostGenerator(localAIClient: client)
        let entry = DailyEntry(date: fixedDate("2026-05-02"), body: "idea for an app")

        do {
            _ = try await generator.generateWithLocalAI(for: entry, model: "test-model")
            XCTFail("Expected local model failure")
        } catch {
            XCTAssertEqual(error as? LocalAIClientError, .unavailable)
        }
    }
}
