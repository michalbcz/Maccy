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

  // Unicode Tag Characters (ASCII Smuggler attacks)
  func testDetectsUnicodeTagCharacters() {
    // U+E0041 = TAG LATIN CAPITAL LETTER A
    let text = "Hello\u{E0041}World"
    XCTAssertTrue(text.containsHiddenCharacters)
  }

  func testDetectsMultipleTagCharacters() {
    // Encoding "hi" using tag characters: U+E0068 (h), U+E0069 (i)
    let text = "Normal\u{E0068}\u{E0069}Text"
    XCTAssertTrue(text.containsHiddenCharacters)
  }

  func testDetectsTagCharacterBoundaries() {
    // Test both start (U+E0000) and end (U+E007F) of tag range
    let textStart = "Start\u{E0000}Text"
    let textEnd = "End\u{E007F}Text"
    XCTAssertTrue(textStart.containsHiddenCharacters)
    XCTAssertTrue(textEnd.containsHiddenCharacters)
  }

  // Variation Selectors
  func testDetectsVariationSelectors() {
    let text = "Hello\u{FE00}World"
    XCTAssertTrue(text.containsHiddenCharacters)
  }

  func testDetectsVariationSelectorsSupplement() {
    let text = "Test\u{E0100}Text"
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

  func testRemovesTagCharacters() {
    let text = "Hello\u{E0041}\u{E0042}World"
    let cleaned = text.removingHiddenCharacters
    XCTAssertEqual(cleaned, "HelloWorld")
  }

  func testRemovesVariationSelectors() {
    let text = "Test\u{FE00}\u{E0100}Text"
    let cleaned = text.removingHiddenCharacters
    XCTAssertEqual(cleaned, "TestText")
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

  func testHighlightsTagCharacters() {
    let text = "Hello\u{E0041}World"
    let attributed = text.highlightingHiddenCharacters()
    XCTAssertTrue(attributed.string.contains("<TAG:A>"))
  }

  func testHighlightsVariationSelectors() {
    let text = "Test\u{FE00}Text"
    let attributed = text.highlightingHiddenCharacters()
    XCTAssertTrue(attributed.string.contains("<VS1>"))
  }

  func testHighlightingPreservesNormalText() {
    let text = "Hello\u{200B}World"
    let attributed = text.highlightingHiddenCharacters()
    XCTAssertTrue(attributed.string.contains("Hello"))
    XCTAssertTrue(attributed.string.contains("World"))
  }
}
