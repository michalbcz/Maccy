import Foundation

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
        let replacement: String
        switch char.unicodeScalars.first?.value {
        case 0x200B:
          replacement = "<ZWSP>"
        case 0x200C:
          replacement = "<ZWNJ>"
        case 0x200D:
          replacement = "<ZWJ>"
        case 0x200E:
          replacement = "<LRM>"
        case 0x200F:
          replacement = "<RLM>"
        case 0x202A:
          replacement = "<LRE>"
        case 0x202B:
          replacement = "<RLE>"
        case 0x202C:
          replacement = "<PDF>"
        case 0x202D:
          replacement = "<LRO>"
        case 0x202E:
          replacement = "<RLO>"
        case 0x2060:
          replacement = "<WJ>"
        case 0x2061:
          replacement = "<FA>"
        case 0x2062:
          replacement = "<IT>"
        case 0x2063:
          replacement = "<IS>"
        case 0x2064:
          replacement = "<IP>"
        case 0xFEFF:
          replacement = "<BOM>"
        default:
          if char.unicodeScalars.first?.properties.isNoncharacterCodePoint == true {
            replacement = "<NC>"
          } else {
            replacement = String(format: "<U+%04X>", char.unicodeScalars.first?.value ?? 0)
          }
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

    // Zero-width characters
    if value >= 0x200B && value <= 0x200F {
      return true
    }

    // Zero-width joiner and non-joiner
    if value == 0x200C || value == 0x200D {
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
