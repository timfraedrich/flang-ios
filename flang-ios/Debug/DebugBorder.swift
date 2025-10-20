import SwiftUI

struct DebugBorder: ViewModifier {
    var color: Color = .red
    var width: CGFloat = 1.0
    
    func body(content: Content) -> some View {
        content
            .overlay(
                Rectangle()
                    .stroke(color, lineWidth: width)
            )
    }
}

extension View {
    func debugBorder(_ color: Color = .red, width: CGFloat = 1.0) -> some View {
        self.modifier(DebugBorder(color: color, width: width))
    }
}
