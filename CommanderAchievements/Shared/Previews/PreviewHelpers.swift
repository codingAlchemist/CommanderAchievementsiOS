import SwiftUI

extension View {
    /// Attach a default `LoginViewModel` to previews to satisfy views that require it
    func previewWithLogin() -> some View {
        self.environmentObject(LoginViewModel())
    }
}

#Preview {
    Text("Preview helper")
        .previewWithLogin()
}
