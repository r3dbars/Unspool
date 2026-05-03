import DailyPagesCore
import XCTest

final class WordCounterTests: XCTestCase {
    func testEmptyStringIsZero() {
        XCTAssertEqual(WordCounter.count(""), 0)
    }

    func testMultipleSpacesAndNewlinesAreHandled() {
        XCTAssertEqual(WordCounter.count("  one   two\n\nthree\tfour  "), 4)
    }

    func testPunctuationDoesNotBreakCounting() {
        XCTAssertEqual(WordCounter.count("Hello, world! This works."), 4)
    }
}
