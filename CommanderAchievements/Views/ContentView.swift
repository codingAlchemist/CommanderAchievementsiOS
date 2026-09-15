//
//  ContentView.swift
//  CommanderAchievements
//
//  Created by jason debottis on 7/28/26.
//

import SwiftUI
import SwiftData
import Combine

struct ContentView: View {
    @State var isLoggedIn: Bool = false
    @State var username: String = ""
    @State var password: String = ""
    @State var loginError: String? = nil
    @State var isLoading: Bool = false
    @StateObject private var loginViewModel = LoginViewModel()
    @State private var showLogoutConfirm: Bool = false
    // MARK: - Navigation state
    @State private var loggedInPlayer: Player? = nil
    let achievementsVIewModel: AchievementsViewModel = AchievementsViewModel()
    
    init(isLoggedIn: Bool = false) {
        _isLoggedIn = State(initialValue: isLoggedIn)
    }

    var body: some View {
        NavigationStack {
            Group {
                if !isLoggedIn {
                    LoginView(viewModel: loginViewModel, username: $username, password: $password)
                        .onReceive(loginViewModel.$player.compactMap { $0 }) { player in
                            self.loggedInPlayer = player
                            self.isLoggedIn = true
                        }
                } else {
                    if let player = loggedInPlayer {
                        PlayerDetailView(player: player)
                    } else {
                        // Placeholder until the player is set; you can replace this with your Achievements view or a progress view
                        Text("Loading player...")
                    }
                }
            }
            .navigationTitle(isLoggedIn ? "Player" : "Login")
            .onAppear {
                // Restore login state from saved preferences if present
                if let saved = PlayerManager.shared.getPlayerFromPreferences() {
                    self.loggedInPlayer = saved
                    self.isLoggedIn = true
                    // also ensure view model has the player
                    loginViewModel.player = saved
                }
            }
            .toolbar {
                if isLoggedIn {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button(role: .destructive) {
                            // confirm logout
                            showLogoutConfirm = true
                        } label: {
                            Text("Logout")
                        }
                    }
                }
            }
            .alert("Confirm Logout", isPresented: $showLogoutConfirm) {
                Button("Logout", role: .destructive) {
                    loginViewModel.logout()
                    self.loggedInPlayer = nil
                    self.isLoggedIn = false
                    self.username = ""
                    self.password = ""
                }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("Are you sure you want to log out?")
            }
        }
    }
}

#Preview {
    ContentView(isLoggedIn: false)
}
