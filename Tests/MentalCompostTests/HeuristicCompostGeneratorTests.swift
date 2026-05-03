import MentalCompostCore
import XCTest

final class HeuristicCompostGeneratorTests: XCTestCase {
    func testExtractsBottleneckFromConstraintLanguage() {
        let entry = DailyEntry(date: fixedDate("2026-05-02"), body: "The bottleneck is that I am stuck on the hard part.")

        let review = HeuristicCompostGenerator.generate(for: entry)

        XCTAssertEqual(review.generationMode, .heuristic)
        XCTAssertTrue(review.bottleneck.first?.contains("bottleneck") == true)
    }

    func testExtractsOpenLoopsFromWorryLanguage() {
        let entry = DailyEntry(date: fixedDate("2026-05-02"), body: "I feel anxious under too much pressure and this keeps coming back.")

        let review = HeuristicCompostGenerator.generate(for: entry)

        XCTAssertTrue(review.openLoops.first?.contains("anxious") == true)
    }

    func testExtractsDecisionsAndReversibleMoveLanguage() {
        let entry = DailyEntry(date: fixedDate("2026-05-02"), body: "I decided the next action is to try the tiny version.")

        let review = HeuristicCompostGenerator.generate(for: entry)

        XCTAssertTrue(review.decisions.first?.contains("decided") == true)
        XCTAssertTrue(review.smallestReversibleMove.first?.contains("next action") == true)
    }

    func testExtractsRedBarAndGreenBarSignalLanguage() {
        let entry = DailyEntry(date: fixedDate("2026-05-02"), body: "The next red bar is the uncomfortable demo. The green bar signal is one customer saying it works.")

        let review = HeuristicCompostGenerator.generate(for: entry)

        XCTAssertTrue(review.nextRedBar.first?.contains("red bar") == true)
        XCTAssertTrue(review.greenBarSignal.first?.contains("green bar") == true)
    }

    func testProducesFallbackTemplateWhenNothingMatches() {
        let entry = DailyEntry(date: fixedDate("2026-05-02"), body: "Plain ordinary sentence.")

        let review = HeuristicCompostGenerator.generate(for: entry)

        XCTAssertEqual(review.generationMode, .manual)
        XCTAssertTrue(review.markdownBody.contains("## Red Bars Review"))
        XCTAssertTrue(review.markdownBody.contains("### Green Bar Signal"))
    }
}
