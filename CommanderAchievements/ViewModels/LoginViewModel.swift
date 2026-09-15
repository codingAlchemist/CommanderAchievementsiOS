//
//  LoginViewModel.swift
//  CommanderAchievements
//
//  Created by jason debottis on 8/16/26.
//

import Foundation
import Combine

@MainActor
public class LoginViewModel: ObservableObject {
    @Published var isLoggingIn: Bool = false
    @Published var loginError: String? = nil
    @Published var player: Player? = nil
    
    public init() {
        // Restore saved player if present so login state persists across launches
        if let saved = PlayerManager.shared.getPlayerFromPreferences() {
            self.player = saved
        }
    }

    public func logout() {
        PlayerManager.shared.clearPlayerPreferences()
        self.player = nil
    }

    public func login(username: String, password: String) async {
        await MainActor.run { self.isLoggingIn = true }
        do {
            let player = try await APIService.shared.login(username: username, password: password)
            PlayerManager.shared.savePlayerToPreferences(player)
            await MainActor.run {
                self.player = player
                self.loginError = nil
                self.isLoggingIn = false
            }
        } catch {
            print("Login failed: \(error)")
            let message: String
            if let apiError = error as? APIService.APIError {
                message = apiError.errorDescription ?? String(describing: apiError)
            } else {
                message = error.localizedDescription
            }
            await MainActor.run {
                self.player = nil
                self.loginError = message
                self.isLoggingIn = false
            }
        }
    }
}
