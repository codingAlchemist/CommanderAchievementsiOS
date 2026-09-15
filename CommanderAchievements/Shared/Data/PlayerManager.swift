//
//  UserData.swift
//  CommanderAchievements
//
//  Created by jason debottis on 8/16/26.
//

import Foundation
import Combine
// Singleton manager for accessing and mutating the current player
@MainActor
public final class PlayerManager: ObservableObject, Sendable {
    public static let shared = PlayerManager()
    private let userDefaultsKey = "savedPlayer"
    
    // The current player; publish changes for SwiftUI bindings
    public init() {
    }
    /// Retrieves saved player information from UserDefaults
    /// - Returns: The saved Player object, or nil if no player is saved
    public func getPlayerFromPreferences() -> Player? {
        guard let data = UserDefaults.standard.data(forKey: userDefaultsKey) else {
            return nil
        }
        do {
            let decoder = JSONDecoder()
            let player = try decoder.decode(Player.self, from: data)
            return player
        } catch {
            print("Failed to retrieve player from UserDefaults: \(error.localizedDescription)")
            return nil
        }
    }
    
    
    /// Saves player information to UserDefaults
    /// - Parameter player: The player object to save
    public func savePlayerToPreferences(_ player: Player) {
        do {
            let encoder = JSONEncoder()
            let encodedData = try encoder.encode(player)
            UserDefaults.standard.set(encodedData, forKey: userDefaultsKey)
        } catch {
            print("Failed to save player to UserDefaults: \(error.localizedDescription)")
        }
    }
    
    /// Clears saved player information from UserDefaults
    public func clearPlayerPreferences() {
        UserDefaults.standard.removeObject(forKey: userDefaultsKey)
    }
    
    /// Checks if a player is already saved in UserDefaults
    /// - Returns: True if a player is saved, false otherwise
    public func isPlayerSaved() -> Bool {
        return UserDefaults.standard.data(forKey: userDefaultsKey) != nil
    }
}
