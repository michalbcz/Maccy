import SwiftUI

struct HiddenCharactersConfirmationView: View {
  @Binding var isPresented: Bool
  var item: HistoryItemDecorator?
  var onYes: () -> Void
  var onStrip: () -> Void
  var onInspect: () -> Void
  var onNo: () -> Void

  var body: some View {
    VStack(spacing: 0) {
      // Empty content - the confirmation dialog is shown modally
    }
    .confirmationDialog(
      "Hidden Characters Detected",
      isPresented: $isPresented,
      titleVisibility: .visible
    ) {
      Button("Paste Anyway") {
        onYes()
      }
      Button("Strip Hidden Characters") {
        onStrip()
      }
      Button("Inspect") {
        onInspect()
      }
      Button("Cancel", role: .cancel) {
        onNo()
      }
    } message: {
      Text("This text contains hidden or invisible characters that could be dangerous. What would you like to do?")
    }
  }
}
