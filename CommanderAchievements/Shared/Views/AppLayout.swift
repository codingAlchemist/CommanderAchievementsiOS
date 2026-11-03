import SwiftUI

struct AppContentWidth: ViewModifier {
    var maxWidth: CGFloat = 900
    func body(content: Content) -> some View {
        content
            .frame(maxWidth: maxWidth)
            .frame(maxWidth: .infinity)
    }
}

extension View {
    func appContentWidth(_ maxWidth: CGFloat = 900) -> some View {
        self.modifier(AppContentWidth(maxWidth: maxWidth))
    }
}

#Preview {
    VStack {
        Text("Test")
    }
    .appContentWidth()
}
