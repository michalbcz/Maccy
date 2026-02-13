import XCTest
@testable import Maccy

// swiftlint:disable force_try
class StringHiddenCharactersTests: XCTestCase {
  func testDetectsZeroWidthSpace() {
    let text = "Hello\u{200B}World"
    XCTAssertTrue(text.containsHiddenCharacters)
  }

  func testDetectsZeroWidthNonJoiner() {
    let text = "Hello\u{200C}World"
    XCTAssertTrue(text.containsHiddenCharacters)
  }

  func testDetectsZeroWidthJoiner() {
    let text = "Hello\u{200D}World"
    XCTAssertTrue(text.containsHiddenCharacters)
  }

  func testDetectsLeftToRightMark() {
    let text = "Hello\u{200E}World"
    XCTAssertTrue(text.containsHiddenCharacters)
  }

  func testDetectsRightToLeftMark() {
    let text = "Hello\u{200F}World"
    XCTAssertTrue(text.containsHiddenCharacters)
  }

  func testDetectsBOM() {
    let text = "\u{FEFF}Hello World"
    XCTAssertTrue(text.containsHiddenCharacters)
  }

  func testDetectsDirectionalFormatting() {
    let text = "Hello\u{202A}World"
    XCTAssertTrue(text.containsHiddenCharacters)
  }

  func testDoesNotDetectNormalText() {
    let text = "Hello World"
    XCTAssertFalse(text.containsHiddenCharacters)
  }

  func testDoesNotDetectTabsAndNewlines() {
    let text = "Hello\nWorld\t!"
    XCTAssertFalse(text.containsHiddenCharacters)
  }

  func testRemovesHiddenCharacters() {
    let text = "Hello\u{200B}World\u{200C}Test"
    let cleaned = text.removingHiddenCharacters
    XCTAssertEqual(cleaned, "HelloWorldTest")
  }

  func testKeepsNormalCharactersWhenRemoving() {
    let text = "Hello\u{200B}World\nTest\t!"
    let cleaned = text.removingHiddenCharacters
    XCTAssertEqual(cleaned, "HelloWorld\nTest\t!")
  }

  func testHighlightsHiddenCharacters() {
    let text = "Hello\u{200B}World"
    let attributed = text.highlightingHiddenCharacters()
    XCTAssertTrue(attributed.string.contains("<ZWSP>"))
  }

  func testHighlightingPreservesNormalText() {
    let text = "Hello\u{200B}World"
    let attributed = text.highlightingHiddenCharacters()
    XCTAssertTrue(attributed.string.contains("Hello"))
    XCTAssertTrue(attributed.string.contains("World"))
  }
}
