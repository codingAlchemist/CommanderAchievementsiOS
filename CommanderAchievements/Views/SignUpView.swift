import SwiftUI

public struct SignUpView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var playerName: String = ""
    @State private var email: String = ""
    @State private var discordUsername: String = ""
    @State private var deckSelection: String = ""
    @State private var commander: String = ""
    @State private var password: String = ""
    @State private var confirmPassword: String = ""
    @State private var isPasswordVisible = false
    @State private var isSigningUp = false
    @State private var alertMessage: String? = nil

    // Callback with created Player (nil on failure/cancel)
    public var onComplete: (Player?) -> Void

    public init(onComplete: @escaping (Player?) -> Void = { _ in }) {
        self.onComplete = onComplete
    }

    public var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                Text("Create an account")
                    .font(.title2.bold())

                TextField("Full name", text: $playerName)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .autocapitalization(.words)

                TextField("Email", text: $email)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .keyboardType(.emailAddress)
                    .autocapitalization(.none)

                HStack {
                    Group {
                        if isPasswordVisible {
                            TextField("Password", text: $password)
                                .autocapitalization(.none)
                        } else {
                            SecureField("Password", text: $password)
                        }
                    }
                    .textFieldStyle(RoundedBorderTextFieldStyle())

                    Button(action: { isPasswordVisible.toggle() }) {
                        Image(systemName: isPasswordVisible ? "eye.slash" : "eye")
                            .foregroundColor(.gray)
                    }
                }

                SecureField("Confirm password", text: $confirmPassword)
                    .textFieldStyle(RoundedBorderTextFieldStyle())

                TextField("Discord username", text: $discordUsername)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .autocapitalization(.none)

                TextField("Deck selection", text: $deckSelection)
                    .textFieldStyle(RoundedBorderTextFieldStyle())

                TextField("Commander", text: $commander)
                    .textFieldStyle(RoundedBorderTextFieldStyle())

                if let alertMessage {
                    Text(alertMessage)
                        .foregroundColor(.red)
                        .multilineTextAlignment(.center)
                }

                Button(action: {
                    signUp()
                }) {
                    if isSigningUp {
                        ProgressView()
                    } else {
                        Text("Sign Up")
                            .frame(maxWidth: .infinity)
                    }
                }
                .buttonStyle(AppButtonStyle())
                .disabled(isSigningUp)

                Spacer()
            }
            .padding()
            .navigationTitle("Sign Up")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Close") { dismiss() }
                }
            }
        }
    }

    private func signUp() {
        alertMessage = nil
        guard !playerName.trimmingCharacters(in: .whitespaces).isEmpty else {
            alertMessage = "Please enter your name"
            return
        }
        guard !email.trimmingCharacters(in: .whitespaces).isEmpty else {
            alertMessage = "Please enter your email"
            return
        }
        guard !password.isEmpty, password == confirmPassword else {
            alertMessage = "Passwords do not match"
            return
        }

        Task {
            await MainActor.run { isSigningUp = true }
            do {
                let player = try await APIService.shared.signUp(email: email, password: password, discordUsername: discordUsername, deckSelection: deckSelection, commander: commander)
                PlayerManager.shared.savePlayerToPreferences(player)
                await MainActor.run {
                    isSigningUp = false
                }
                onComplete(player)
                dismiss()
            } catch {
                await MainActor.run {
                    isSigningUp = false
                    if let apiError = error as? APIService.APIError {
                        alertMessage = apiError.errorDescription ?? String(describing: apiError)
                    } else {
                        alertMessage = error.localizedDescription
                    }
                }
            }
        }
    }
}

#Preview {
    SignUpView()
}
