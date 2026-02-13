import SwiftData
import SwiftUI

struct ContentView: View {
  @State private var appState = AppState.shared
  @State private var modifierFlags = ModifierFlags()
  @State private var scenePhase: ScenePhase = .background
  @State private var showInspectView = false

  @FocusState private var searchFocused: Bool

  var body: some View {
    ZStack {
      if #available(macOS 26.0, *) {
        GlassEffectView()
      } else {
        VisualEffectView()
      }

      KeyHandlingView(searchQuery: $appState.history.searchQuery, searchFocused: $searchFocused) {
        VStack(spacing: 0) {
          SlideoutView(controller: appState.preview) {
            HeaderView(
              controller: appState.preview,
              searchFocused: $searchFocused
            )

            VStack(alignment: .leading, spacing: 0) {
              HistoryListView(
                searchQuery: $appState.history.searchQuery,
                searchFocused: $searchFocused
              )

              FooterView(footer: appState.footer)
            }
            .animation(.default.speed(3), value: appState.history.items)
            .animation(
              .default.speed(3),
              value: appState.history.pasteStack?.id
            )
            .padding(.horizontal, Popup.horizontalPadding)
            .onAppear {
              searchFocused = true
            }
            .onMouseMove {
              appState.navigator.isKeyboardNavigating = false
            }
          } slideout: {
            SlideoutContentView()
          }
          .frame(minHeight: 0)
          .layoutPriority(1)
        }
      }
      .frame(maxWidth: .infinity, alignment: .leading)
      .task {
        try? await appState.history.load()
      }
    }
    .animation(.easeInOut(duration: 0.2), value: appState.searchVisible)
    .environment(appState)
    .environment(modifierFlags)
    .environment(\.scenePhase, scenePhase)
    .confirmationDialog(
      NSLocalizedString("hidden_chars_alert_title", comment: ""),
      isPresented: $appState.showHiddenCharConfirmation,
      titleVisibility: .visible
    ) {
      Button(NSLocalizedString("hidden_chars_alert_paste_anyway", comment: "")) {
        if let item = appState.pendingPasteItem {
          appState.history.performSelection(item, removeHiddenChars: false)
        }
        appState.pendingPasteItem = nil
      }
      Button(NSLocalizedString("hidden_chars_alert_strip", comment: "")) {
        if let item = appState.pendingPasteItem {
          appState.history.performSelection(item, removeHiddenChars: true)
        }
        appState.pendingPasteItem = nil
      }
      Button(NSLocalizedString("hidden_chars_alert_inspect", comment: "")) {
        showInspectView = true
        appState.showHiddenCharConfirmation = false
      }
      Button(NSLocalizedString("hidden_chars_alert_cancel", comment: ""), role: .cancel) {
        appState.pendingPasteItem = nil
      }
    } message: {
      Text(NSLocalizedString("hidden_chars_alert_message", comment: ""))
    }
    .sheet(isPresented: $showInspectView) {
      if let item = appState.pendingPasteItem {
        InspectHiddenCharactersView(text: item.text)
      }
    }
    // FloatingPanel is not a scene, so let's implement custom scenePhase..
    .onReceive(NotificationCenter.default.publisher(for: NSWindow.didBecomeKeyNotification)) {
      if let window = $0.object as? NSWindow,
         let bundleIdentifier = Bundle.main.bundleIdentifier,
         window.identifier == NSUserInterfaceItemIdentifier(bundleIdentifier) {
        scenePhase = .active
      }
    }
    .onReceive(NotificationCenter.default.publisher(for: NSWindow.didResignKeyNotification)) {
      if let window = $0.object as? NSWindow,
         let bundleIdentifier = Bundle.main.bundleIdentifier,
         window.identifier == NSUserInterfaceItemIdentifier(bundleIdentifier) {
        scenePhase = .background
      }
    }
  }
}

#Preview {
  ContentView()
    .environment(\.locale, .init(identifier: "en"))
    .modelContainer(Storage.shared.container)
}
