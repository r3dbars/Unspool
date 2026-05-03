import MentalCompostCore
import XCTest

final class WordCounterTests: XCTestCase {
    func testEmptyStringIsZero() {
        XCTAssertEqual(WordCounter.count(""), 0)
    }

    func testWhitespaceOnlyIsZero() {
        XCTAssertEqual(WordCounter.count(" \n\t "), 0)
    }

    func testSimpleSentence() {
        XCTAssertEqual(WordCounter.count("Start with the mess."), 4)
    }

    func testMultipleSpacesAndNewlinesAreHandled() {
        XCTAssertEqual(WordCounter.count("  one   two\n\nthree\tfour  "), 4)
    }

    func testPunctuationDoesNotBreakCounting() {
        XCTAssertEqual(WordCounter.count("Hello, world! This works."), 4)
    }

    func testMarkdownAndContractionsCountReasonably() {
        XCTAssertEqual(WordCounter.count("## Title\n- I'm trying **this** today."), 5)
    }

    func testLongBody() {
        let body = Array(repeating: "compost", count: 1_000).joined(separator: " ")
        XCTAssertEqual(WordCounter.count(body), 1_000)
    }
}
