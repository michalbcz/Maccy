# Development Guide

This guide will help you understand the Maccy codebase structure and how to build the application.

## Prerequisites

- macOS 14 (Sonoma) or higher
- Xcode 15 or higher
- Swift 5.9 or higher

## Project Structure

Maccy is a native macOS application written in Swift using SwiftUI for the user interface. The project follows a clean architecture with clear separation of concerns.

### Entry Point

The application entry point is **`Maccy/MaccyApp.swift`**:
- Uses SwiftUI's `@main` attribute
- Defines the main `App` structure
- Delegates application lifecycle to `AppDelegate`
- Creates a hidden MenuBarExtra scene (required by SwiftUI, but not used directly)

The primary application logic is handled in **`Maccy/AppDelegate.swift`**:
- Manages the status bar item (menu bar icon)
- Initializes the floating panel window
- Sets up the clipboard monitoring
- Configures keyboard shortcuts and global hotkeys
- Handles application lifecycle events

### Core Components

#### 1. **Clipboard Management** (`Maccy/Clipboard.swift`)
- Monitors the system pasteboard for changes
- Uses a timer-based polling mechanism (default: 500ms interval)
- Filters clipboard content based on supported types
- Triggers hooks when new content is copied
- Handles copying items back to the clipboard

#### 2. **History Management** (`Maccy/Observables/History.swift`)
- Manages the clipboard history items
- Implements search functionality using fuzzy matching
- Handles pinned vs. unpinned items
- Sorts items based on user preferences
- Integrates with SwiftData for persistence

#### 3. **Storage** (`Maccy/Storage.swift`)
- Uses SwiftData (Core Data modern API) for persistence
- Stores history items in SQLite database
- Located at: `~/Library/Application Support/Maccy/Storage.sqlite`

#### 4. **Models**
- **`Maccy/Models/HistoryItem.swift`**: Represents a single clipboard item with its content, metadata, and security features
- **`Maccy/Models/HistoryItemContent.swift`**: Represents the actual content data (text, images, files, etc.)

#### 5. **User Interface**
- **`Maccy/FloatingPanel.swift`**: Custom NSPanel that implements the floating window behavior
- **`Maccy/Views/ContentView.swift`**: Main SwiftUI view that displays the history list
- **`Maccy/Views/HistoryListView.swift`**: List of clipboard history items
- **`Maccy/Views/HeaderView.swift`**: Search field and header UI
- **`Maccy/Views/FooterView.swift`**: Footer with status information

#### 6. **Application State** (`Maccy/Observables/AppState.swift`)
- Central observable state manager
- Coordinates between different parts of the application
- Manages navigation, popup state, and menu icon text

#### 7. **Settings** (`Maccy/Settings/`)
- Multiple settings panes using the Settings library
- GeneralSettingsPane, AppearanceSettingsPane, IgnoreSettingsPane, etc.
- Uses Defaults library for persistent user preferences

### Key Dependencies

The project uses Swift Package Manager for dependencies:
- **Sauce**: Keyboard handling and key code utilities
- **KeyboardShortcuts**: Global keyboard shortcut registration
- **Defaults**: Type-safe UserDefaults wrapper
- **Sparkle**: Automatic update framework
- **Settings**: macOS settings window library
- **Fuse**: Fuzzy search algorithm
- **swift-log**: Logging framework

## Building the Application

### Using Xcode (Recommended)

1. **Clone the repository**
   ```bash
   git clone https://github.com/michalbcz/Maccy.git
   cd Maccy
   ```

2. **Open the project in Xcode**
   ```bash
   open Maccy.xcodeproj
   ```

3. **Wait for dependencies to resolve**
   - Xcode will automatically fetch Swift Package Manager dependencies
   - This may take a few minutes on first open

4. **Select the build scheme**
   - Select "Maccy" scheme from the scheme selector
   - Choose "My Mac" as the destination

5. **Build the project**
   - Press `⌘B` to build
   - Or select Product → Build from the menu

6. **Run the application**
   - Press `⌘R` to build and run
   - Or select Product → Run from the menu
   - The app will launch and appear in the menu bar

### Using xcodebuild (Command Line)

1. **Build the project**
   ```bash
   xcodebuild -project Maccy.xcodeproj -scheme Maccy -configuration Release build
   ```

2. **Run tests**
   ```bash
   xcodebuild test -project Maccy.xcodeproj -scheme Maccy -destination 'platform=macOS'
   ```

3. **Build for distribution**
   ```bash
   xcodebuild archive \
     -project Maccy.xcodeproj \
     -scheme Maccy \
     -archivePath ./build/Maccy.xcarchive
   ```

## Development Workflow

### Running in Debug Mode

When running from Xcode, the app runs in debug mode with:
- Verbose logging enabled
- Hot reloading for SwiftUI views
- Debugger attached for breakpoints

### Testing

The project includes two test targets:
- **MaccyTests**: Unit tests
- **MaccyUITests**: UI automation tests

Run tests with:
- Press `⌘U` in Xcode
- Or Product → Test from the menu
- Or use `xcodebuild test` from command line

### Code Quality Tools

1. **SwiftLint** (`.swiftlint.yml`)
   - Install: `brew install swiftlint`
   - Run: `swiftlint` in the project directory
   - Enforces Swift style and conventions

2. **Periphery** (`.periphery.yml`)
   - Install: `brew install peripheryapp/periphery/periphery`
   - Run: `periphery scan` in the project directory
   - Finds unused code

### Debugging Tips

1. **Clipboard monitoring**: Set breakpoints in `Clipboard.swift`'s `checkForChangesInPasteboard` method
2. **UI issues**: Use Xcode's View Debugging (Debug → View Debugging → Capture View Hierarchy)
3. **Storage issues**: Check the SQLite database at `~/Library/Application Support/Maccy/Storage.sqlite`
4. **Performance**: Use Instruments (Product → Profile) to analyze performance

## Common Development Tasks

### Adding a New Setting

1. Add the default key in the appropriate Settings file
2. Create or update the settings pane UI in `Maccy/Settings/`
3. Use `Defaults[.yourSetting]` to access the value
4. Add observers in `AppDelegate` if needed for runtime changes

### Adding a New Pasteboard Type

1. Add the type to `supportedTypes` in `Clipboard.swift`
2. Add handling in `HistoryItem.swift` for display and storage
3. Update UI components to render the new type

### Modifying the UI

1. SwiftUI views are in `Maccy/Views/`
2. Most UI uses SwiftUI modifiers and custom view modifiers
3. The floating panel uses AppKit (NSPanel) wrapped with SwiftUI

## Architecture Overview

```
┌─────────────────────────────────────────────────┐
│                  MaccyApp.swift                 │
│              (Application Entry)                │
└──────────────────┬──────────────────────────────┘
                   │
                   ▼
┌─────────────────────────────────────────────────┐
│               AppDelegate.swift                 │
│    (Lifecycle, Status Bar, Panel Setup)         │
└──────┬─────────────────────────┬────────────────┘
       │                         │
       ▼                         ▼
┌─────────────┐          ┌──────────────┐
│ Clipboard   │          │ FloatingPanel│
│  .swift     │────┐     │   .swift     │
└─────────────┘    │     └──────┬───────┘
                   │            │
                   ▼            ▼
            ┌──────────────────────┐
            │   History.swift      │
            │ (Observable State)   │
            └──────┬───────────────┘
                   │
                   ▼
            ┌──────────────┐
            │ Storage.swift│
            │  (SwiftData) │
            └──────────────┘
```

## Troubleshooting

### Build Failures

- **"Cannot find X in scope"**: Clean build folder (⌘⇧K) and rebuild
- **Package resolution failed**: File → Packages → Reset Package Caches
- **Signing issues**: Check Developer account in Xcode preferences

### Runtime Issues

- **App doesn't appear in menu bar**: Check "Show in menu bar" in preferences
- **Clipboard not monitored**: Grant Accessibility permissions in System Settings
- **Database errors**: Delete `~/Library/Application Support/Maccy/Storage.sqlite` and restart

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Run tests and linting
5. Submit a pull request

## Resources

- [Swift Documentation](https://swift.org/documentation/)
- [SwiftUI Documentation](https://developer.apple.com/documentation/swiftui/)
- [SwiftData Documentation](https://developer.apple.com/documentation/swiftdata/)
- [macOS Human Interface Guidelines](https://developer.apple.com/design/human-interface-guidelines/macos)

## License

Maccy is licensed under the MIT License. See [LICENSE](./LICENSE) file for details.
