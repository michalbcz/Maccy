# Hidden Characters Detection Feature - Integration Notes

## Overview
This feature adds detection and warnings for hidden/invisible characters in clipboard text to protect users from potential security issues.

## What Was Implemented

### 1. Core Detection Logic
- **File**: `Maccy/Extensions/String+HiddenCharacters.swift`
- Detects zero-width characters, directional formatting, control characters, etc.
- Provides methods:
  - `containsHiddenCharacters` - checks if string has hidden chars
  - `removingHiddenCharacters` - removes all hidden chars
  - `highlightingHiddenCharacters()` - creates attributed string with visual markers

### 2. Data Model Updates
- **File**: `Maccy/Models/HistoryItem.swift`
- Added `hasHiddenCharacters: Bool` property
- Detection happens in `generateTitle()` method

### 3. UI Warning Display
- **File**: `Maccy/Views/ListItemView.swift`
- Shows warning icon (⚠️) for items with hidden characters
- Adds reddish background (10% opacity) to dangerous items
- **File**: `Maccy/Views/HistoryItemView.swift`
- Passes `hasHiddenCharacters` flag to ListItemView

### 4. Confirmation Dialog
- **File**: `Maccy/Views/ContentView.swift`
- Displays confirmation dialog when user tries to paste text with hidden chars
- Options: "Paste Anyway", "Strip Hidden Characters", "Inspect", "Cancel"

### 5. Inspect View
- **File**: `Maccy/Views/InspectHiddenCharactersView.swift`
- Shows text with hidden characters rendered visibly with red background
- Allows copying cleaned version

### 6. History Integration
- **File**: `Maccy/Observables/History.swift`
- Modified `select()` to intercept paste when hidden chars detected
- Added `performSelection()` with `removeHiddenChars` parameter
- Added `createCleanedItem()` to generate stripped versions

### 7. State Management
- **File**: `Maccy/Observables/AppState.swift`
- Added `showHiddenCharConfirmation: Bool`
- Added `pendingPasteItem: HistoryItemDecorator?`

### 8. Tests
- **File**: `MaccyTests/StringHiddenCharactersTests.swift`
- Tests for detection, removal, and highlighting

## Integration Steps Required

### 1. Add New Files to Xcode Project
The following files need to be manually added to the Xcode project:
- `Maccy/Extensions/String+HiddenCharacters.swift`
- `Maccy/Views/HiddenCharactersConfirmationView.swift` (optional, can be removed if not used)
- `Maccy/Views/InspectHiddenCharactersView.swift`
- `MaccyTests/StringHiddenCharactersTests.swift`

**Steps**:
1. Open `Maccy.xcodeproj` in Xcode
2. Right-click on the `Extensions` folder → "Add Files to Maccy..."
3. Select `String+HiddenCharacters.swift`
4. Repeat for Views folder with the two view files
5. Repeat for MaccyTests folder with test file

### 2. Build and Test
```bash
xcodebuild -scheme Maccy -configuration Debug build
xcodebuild -scheme Maccy -configuration Debug test
```

### 3. Known Issues to Address

#### SwiftData Migration
The `hasHiddenCharacters` property was added to the `HistoryItem` model. This requires a CoreData/SwiftData migration:
- Need to update the data model version
- Add migration code or mark as optional with default value

#### Potential Fix
In `HistoryItem.swift`, the property could be made optional:
```swift
var hasHiddenCharacters: Bool = false  // Already has default value
```

This should work, but test thoroughly.

## Testing the Feature

### Manual Testing Steps
1. Copy text containing hidden characters (e.g., from a malicious source)
2. Open Maccy popup
3. Verify item shows ⚠️ icon and reddish background
4. Try to paste the item
5. Verify confirmation dialog appears
6. Test all four options:
   - **Paste Anyway**: Should paste original text
   - **Strip Hidden Characters**: Should paste cleaned text
   - **Inspect**: Should open inspection window showing hidden chars
   - **Cancel**: Should do nothing

### Test Text Examples
Create test cases with these strings:
```swift
// Zero-width space
"Hello\u{200B}World"

// Zero-width non-joiner
"test\u{200C}ing"

// Right-to-left override (can reverse text display)
"admin\u{202E}tset"

// Multiple hidden chars
"safe\u{200B}\u{200C}\u{200D}text"
```

## UI/UX Considerations

### Visual Design
- Warning icon color: Orange (`.orange`)
- Background tint: Red with 10% opacity (`.red.opacity(0.1)`)
- When selected, blue highlight overrides red tint

### User Flow
```
Copy text with hidden chars
    ↓
Item appears in history with warning
    ↓
User selects/pastes item
    ↓
Confirmation dialog appears
    ↓
User chooses action:
    - Paste Anyway → Original text
    - Strip → Cleaned text
    - Inspect → Modal with details
    - Cancel → Nothing
```

## Security Considerations

### What Hidden Characters Are Detected
1. **Zero-width characters**: U+200B to U+200F
2. **Directional formatting**: U+202A to U+202E (can cause text reversal attacks)
3. **Word joiners**: U+2060 to U+2064
4. **Byte Order Mark (BOM)**: U+FEFF
5. **Control characters** (except tab, newline, carriage return)
6. **Non-character code points**

### Why This Matters
- **Trojan Source attacks**: Hidden chars can make code appear safe while being malicious
- **Homograph attacks**: Visual confusion attacks
- **Data exfiltration**: Steganographic data hiding
- **Social engineering**: Invisible text manipulation

## Future Enhancements

### Possible Improvements
1. Add user preference to auto-strip hidden chars
2. Show count of hidden chars in tooltip
3. Add whitelist for specific unicode ranges
4. Log/analytics for detected threats
5. Option to disable warning for trusted sources
6. Regex-based custom detection rules

### Localization
The following strings need localization:
- "Hidden Characters Detected"
- "This text contains hidden or invisible characters..."
- "Paste Anyway"
- "Strip Hidden Characters"
- "Inspect"
- "Cancel"
- "Hidden Characters Inspection"
- "Copy Without Hidden Characters"

Add to appropriate `.lproj` folders.

## Performance Notes

- Detection runs during `generateTitle()` which is called when copying
- Only checks first 1000 characters (existing truncation)
- String extension methods are O(n) complexity
- Should have minimal impact on performance

## Questions or Issues

If you encounter problems:
1. Check Xcode build errors for missing file references
2. Verify SwiftData schema migration completed
3. Test with debug logging enabled
4. Check that all new files are in target membership

## Code Review Checklist

- [ ] All new Swift files added to Xcode project
- [ ] Tests pass
- [ ] SwiftLint passes
- [ ] Manual testing completed
- [ ] UI looks correct on different screen sizes
- [ ] Dialog shows properly
- [ ] Inspect view displays correctly
- [ ] Performance is acceptable
- [ ] No crashes or memory leaks
