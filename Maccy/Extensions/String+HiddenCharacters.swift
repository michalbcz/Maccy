import Foundation

private let hiddenCharacterLabels: [UInt32: String] = [
  0x200B: "<ZWSP>",
  0x200C: "<ZWNJ>",
  0x200D: "<ZWJ>",
  0x200E: "<LRM>",
  0x200F: "<RLM>",
  0x202A: "<LRE>",
  0x202B: "<RLE>",
  0x202C: "<PDF>",
  0x202D: "<LRO>",
  0x202E: "<RLO>",
  0x2060: "<WJ>",
  0x2061: "<FA>",
  0x2062: "<IT>",
  0x2063: "<IS>",
  0x2064: "<IP>",
  0xFEFF: "<BOM>",
  // Variation Selectors
  0xFE00: "<VS1>",
  0xFE01: "<VS2>",
  0xFE02: "<VS3>",
  0xFE03: "<VS4>",
  0xFE04: "<VS5>",
  0xFE05: "<VS6>",
  0xFE06: "<VS7>",
  0xFE07: "<VS8>",
  0xFE08: "<VS9>",
  0xFE09: "<VS10>",
  0xFE0A: "<VS11>",
  0xFE0B: "<VS12>",
  0xFE0C: "<VS13>",
  0xFE0D: "<VS14>",
  0xFE0E: "<VS15>",
  0xFE0F: "<VS16>"
]

extension String {
  /// Checks if the string contains hidden or invisible characters
  var containsHiddenCharacters: Bool {
    return contains { char in
      char.isHiddenCharacter
    }
  }

  /// Returns a copy of the string with all hidden characters removed
  var removingHiddenCharacters: String {
    return filter { !$0.isHiddenCharacter }
  }

  /// Returns an attributed string with hidden characters highlighted
  func highlightingHiddenCharacters() -> NSAttributedString {
    let attributedString = NSMutableAttributedString()

    // Set default attributes
    let defaultAttributes: [NSAttributedString.Key: Any] = [
      .font: NSFont.monospacedSystemFont(ofSize: 12, weight: .regular)
    ]

    for char in self {
      if char.isHiddenCharacter {
        // Replace with visible representation
        let value = char.unicodeScalars.first?.value ?? 0
        let replacement: String
        
        // Check if it's a Unicode Tag Character (U+E0000–U+E007F)
        if value >= 0xE0000 && value <= 0xE007F {
          // Tag characters encode ASCII values
          let asciiValue = value - 0xE0000
          if asciiValue >= 0x20 && asciiValue <= 0x7E {
            // Printable ASCII
            let asciiChar = Character(UnicodeScalar(UInt8(asciiValue)))
            replacement = "<TAG:\(asciiChar)>"
          } else {
            replacement = String(format: "<TAG:%02X>", asciiValue)
          }
        } else if value >= 0xE0100 && value <= 0xE01EF {
          // Variation Selectors Supplement
          let vsNum = value - 0xE0100 + 17
          replacement = "<VS\(vsNum)>"
        } else if let label = hiddenCharacterLabels[value] {
          replacement = label
        } else if char.unicodeScalars.first?.properties.isNoncharacterCodePoint == true {
          replacement = "<NC>"
        } else {
          replacement = String(format: "<U+%04X>", value)
        }

        let replacementString = NSAttributedString(
          string: replacement,
          attributes: [
            .backgroundColor: NSColor.red,
            .foregroundColor: NSColor.white,
            .font: NSFont.monospacedSystemFont(ofSize: 12, weight: .bold)
          ]
        )
        attributedString.append(replacementString)
      } else {
        let charString = NSAttributedString(string: String(char), attributes: defaultAttributes)
        attributedString.append(charString)
      }
    }

    return attributedString
  }
}

extension Character {
  /// Checks if the character is considered hidden or invisible
  var isHiddenCharacter: Bool {
    guard let scalar = unicodeScalars.first else {
      return false
    }

    let value = scalar.value

    // Zero-width characters (includes ZWNJ and ZWJ)
    if value >= 0x200B && value <= 0x200F {
      return true
    }

    // Directional formatting characters
    if value >= 0x202A && value <= 0x202E {
      return true
    }

    // Word joiner and invisible function application
    if value >= 0x2060 && value <= 0x2064 {
      return true
    }

    // Byte Order Mark (BOM)
    if value == 0xFEFF {
      return true
    }

    // Unicode Tag Characters (U+E0000–U+E007F)
    // Used for steganography and data smuggling (ASCII Smuggler attacks)
    if value >= 0xE0000 && value <= 0xE007F {
      return true
    }

    // Variation Selectors (U+FE00-FE0F, U+E0100-E01EF)
    // Can be abused for steganography
    if (value >= 0xFE00 && value <= 0xFE0F) || (value >= 0xE0100 && value <= 0xE01EF) {
      return true
    }

    // Noncharacter code points
    if scalar.properties.isNoncharacterCodePoint {
      return true
    }

    // Control characters (except common whitespace)
    if scalar.properties.generalCategory == .control {
      // Allow common control characters: tab, newline, carriage return
      return ![0x09, 0x0A, 0x0D].contains(value)
    }

    return false
  }
}
