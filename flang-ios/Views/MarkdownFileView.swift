import MarkdownUI
import SwiftUI

struct MarkdownFileView: View {
    
    let file: String
    
    private func markdownString(for file: String) -> String? {
        guard let file = Bundle.main.url(forResource: file, withExtension: "md"),
              let content = try? String(contentsOf: file, encoding: .utf8)
        else { return nil }
        return content
    }
    
    var body: some View {
        Group {
            if let markdownString = markdownString(for: file) {
                ScrollView {
                    Markdown(markdownString)
                        .frame(maxWidth: .infinity)
                        .padding(20)
                }
            } else {
                VStack {
                    Image(systemName: "exclamationmark.triangle.fill").font(.largeTitle)
                    Text("error_file_not_found").font(.title.weight(.semibold))
                }
                .foregroundStyle(.red)
            }
        }
    }
    
}
