import SwiftUI

struct InspectHiddenCharactersView: View {
  @Environment(\.dismiss) private var dismiss
  var text: String

  var body: some View {
    VStack(alignment: .leading, spacing: 15) {
      HStack {
        Text("Hidden Characters Inspection")
          .font(.headline)
        Spacer()
        Button("Close") {
          dismiss()
        }
      }

      Text("Hidden or invisible characters are shown with labels on a red background:")
        .font(.subheadline)
        .foregroundColor(.secondary)

      ScrollView {
        if let attributedString = try? AttributedString(text.highlightingHiddenCharacters(), including: \.appKit) {
          Text(attributedString)
            .textSelection(.enabled)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding()
        } else {
          Text("Unable to display text")
            .foregroundColor(.red)
        }
      }
      .frame(maxHeight: 400)
      .border(Color.gray.opacity(0.3))

      HStack {
        Spacer()
        Button("Copy Without Hidden Characters") {
          let cleanText = text.removingHiddenCharacters
          NSPasteboard.general.clearContents()
          NSPasteboard.general.setString(cleanText, forType: .string)
          dismiss()
        }
        .keyboardShortcut(.defaultAction)
      }
    }
    .padding()
    .frame(width: 600)
  }
}
