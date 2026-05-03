import MentalCompostCore
import XCTest

final class HeuristicCompostGeneratorTests: XCTestCase {
    func testExtractsSeedsFromIdeaAndProjectLanguage() {
        let entry = DailyEntry(date: fixedDate("2026-05-02"), body: "Project idea: build a calmer app someday.")

        let review = HeuristicCompostGenerator.generate(for: entry)

        XCTAssertEqual(review.generationMode, .heuristic)
        XCTAssertTrue(review.seeds.first?.contains("Project idea") == true)
    }

    func testExtractsWeedsFromWorryLanguage() {
        let entry = DailyEntry(date: fixedDate("2026-05-02"), body: "I feel anxious and stuck under too much pressure.")

        let review = HeuristicCompostGenerator.generate(for: entry)

        XCTAssertTrue(review.weeds.first?.contains("anxious") == true)
    }

    func testExtractsFruitFromActionAndDecisionLanguage() {
        let entry = DailyEntry(date: fixedDate("2026-05-02"), body: "I decided the next action is to ship the tiny version.")

        let review = HeuristicCompostGenerator.generate(for: entry)

        XCTAssertTrue(review.fruit.first?.contains("decided") == true)
    }

    func testProducesFallbackTemplateWhenNothingMatches() {
        let entry = DailyEntry(date: fixedDate("2026-05-02"), body: "Plain ordinary sentence.")

        let review = HeuristicCompostGenerator.generate(for: entry)

        XCTAssertEqual(review.generationMode, .manual)
        XCTAssertTrue(review.markdownBody.contains("Today felt..."))
    }
}
