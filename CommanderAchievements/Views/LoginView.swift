//
//  LoginView.swift
//  CommanderAchievements
//
//  Created by jason debottis on 7/28/26.
//

import SwiftUI

public struct LoginView: View {
    @ObservedObject var viewModel: LoginViewModel
    @Binding private var username: String
    @Binding private var password: String
    
    @State private var isPasswordVisible = false
    @State private var showAlert = false
    @State private var showSignUp = false

    // Explicit initializer to avoid access control issues with synthesized memberwise init
    public init(viewModel: LoginViewModel, username: Binding<String>, password: Binding<String>) {
        self.viewModel = viewModel
        self._username = username
        self._password = password
    }

    public var body: some View {
        ZStack {
            LinearGradient(
                gradient: Gradient(colors: [Color.blue, Color.purple]),
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            VStack(spacing: 20) {
                Text("login.title")
                    .font(.largeTitle)
                TextField("login.username.placeholder", text: $username)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .autocapitalization(.none)
                    .padding(.horizontal)
                HStack {
                    Group {
                        if isPasswordVisible {
                            TextField("login.password.placeholder", text: $password)
                                .autocapitalization(.none)
                        } else {
                            SecureField("login.password.placeholder", text: $password)
                        }
                    }
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    
                    Button(action: { isPasswordVisible.toggle() }) {
                        Image(systemName: isPasswordVisible ? "eye.slash" : "eye")
                            .foregroundColor(.gray)
                    }
                }
                .padding(.horizontal)
                if let loginError = viewModel.loginError {
                    Text(loginError)
                        .foregroundColor(.red)
                }
                if viewModel.isLoggingIn {
                    ProgressView()
                }
                Button("login.button.title") {
                    Task {
                        await viewModel.login(username: username, password: password)
                        showAlert = viewModel.loginError != nil
                    }
                }
                Button("Sign Up") {
                    showSignUp = true
                }
                .buttonStyle(.bordered)
                .buttonStyle(AppButtonStyle())
                .disabled(viewModel.isLoggingIn)
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color(.systemBackground))
                    .shadow(color: .black.opacity(0.15), radius: 8, x: 0, y: 4)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(Color.gray.opacity(0.25), lineWidth: 1)
                    )
            )
            .padding()
            .alert(isPresented: $showAlert) {
                Alert(title: Text(viewModel.loginError == nil ? "login.success.title" : "login.failure.title"),
                      message: Text(viewModel.loginError ?? String(localized: "login.success.message")),
                      dismissButton: .default(Text("login.alert.ok")) {
                          // Clear error after acknowledging
                          viewModel.loginError = nil
                      })
            }
        }
        .sheet(isPresented: $showSignUp) {
            SignUpView { player in
                // dismiss sheet and auto-login if player was returned
                showSignUp = false
                if let player = player {
                    // set the view model's player so the rest of the app reacts
                    viewModel.player = player
                }
            }
        }
    }
}
#Preview {
    @Previewable @State var username = "demo@example.com"
    @Previewable @State var password = "password"
    let vm = LoginViewModel()
    LoginView(viewModel: vm, username: $username, password: $password)
}

