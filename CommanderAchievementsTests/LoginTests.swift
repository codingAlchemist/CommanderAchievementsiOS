//
//  LoginTests.swift
//  CommanderAchievements
//
//  Created by jason debottis on 8/13/26.
//

import Testing
import Foundation
@testable import CommanderAchievements

@Suite("LoginViewModel Tests")
struct LoginViewModelTests {
    
    var loginViewModel: LoginViewModel
    
    init() {
        loginViewModel = LoginViewModel()
        // Clean up UserDefaults before each test
        UserDefaults.standard.removeObject(forKey: "savedPlayer")
    }
    
    @Test("Save player to preferences successfully")
    func testSavePlayerToPreferences() {
        let testPlayer = Player(
            id: "123",
            playerName: "TestPlayer",
            email: "test@example.com",
            discordUsername: "TestDiscord",
            deckName: "Test Deck",
            commander: "Test Commander",
            points: 100,
            createdAt: Date(),
            absent: false,
            deckList: ["Card1", "Card2"],
            requiresPasswordSetup: false,
            passwordNeedsReset: false,
            message: nil,
            success: true
        )
        
        loginViewModel.savePlayerToPreferences(testPlayer)
        
        let savedPlayer = loginViewModel.getPlayerFromPreferences()
        #expect(savedPlayer != nil)
        #expect(savedPlayer?.id == testPlayer.id)
        #expect(savedPlayer?.playerName == testPlayer.playerName)
        #expect(savedPlayer?.email == testPlayer.email)
    }
    
    @Test("Retrieve player from preferences")
    func testGetPlayerFromPreferences() {
        let testPlayer = Player(
            id: "456",
            playerName: "AnotherPlayer",
            email: "another@example.com",
            discordUsername: "AnotherDiscord",
            deckName: "Another Deck",
            commander: "Another Commander",
            points: 50,
            createdAt: Date(),
            absent: true,
            deckList: ["Card3"],
            requiresPasswordSetup: true,
            passwordNeedsReset: false,
            message: "Test message",
            success: true
        )
        
        loginViewModel.savePlayerToPreferences(testPlayer)
        let retrievedPlayer = loginViewModel.getPlayerFromPreferences()
        
        #expect(retrievedPlayer != nil)
        #expect(retrievedPlayer?.points == 50)
        #expect(retrievedPlayer?.absent == true)
    }
    
    @Test("Return nil when no player is saved")
    func testGetPlayerFromPreferencesWhenNothingSaved() {
        UserDefaults.standard.removeObject(forKey: "savedPlayer")
        
        let retrievedPlayer = loginViewModel.getPlayerFromPreferences()
        
        #expect(retrievedPlayer == nil)
    }
    
    @Test("Clear player preferences")
    func testClearPlayerPreferences() {
        let testPlayer = Player(
            id: "789",
            playerName: "ClearTestPlayer",
            email: "clear@example.com",
            discordUsername: "ClearDiscord",
            deckName: "Clear Deck",
            commander: "Clear Commander",
            points: 75,
            createdAt: Date(),
            absent: false,
            deckList: [],
            requiresPasswordSetup: false,
            passwordNeedsReset: false,
            success: true
        )
        
        loginViewModel.savePlayerToPreferences(testPlayer)
        #expect(loginViewModel.isPlayerSaved())
        
        loginViewModel.clearPlayerPreferences()
        
        #expect(!loginViewModel.isPlayerSaved())
        #expect(loginViewModel.getPlayerFromPreferences() == nil)
    }
    
    @Test("Check if player is saved")
    func testIsPlayerSaved() {
        #expect(!loginViewModel.isPlayerSaved())
        
        let testPlayer = Player(
            id: "101",
            playerName: "SavedPlayer",
            email: "saved@example.com",
            discordUsername: "SavedDiscord",
            deckName: "Saved Deck",
            commander: "Saved Commander",
            points: 200,
            createdAt: Date(),
            absent: false,
            deckList: ["Card4", "Card5"],
            requiresPasswordSetup: false,
            passwordNeedsReset: false,
            success: true
        )
        
        loginViewModel.savePlayerToPreferences(testPlayer)
        
        #expect(loginViewModel.isPlayerSaved())
    }
    
    @Test("Save and retrieve player with all properties")
    func testSaveAndRetrieveCompletePlayer() {
        let createdDate = Date()
        let testPlayer = Player(
            id: "full-test-id",
            playerName: "FullTestPlayer",
            email: "fulltest@example.com",
            discordUsername: "FullTestDiscord",
            deckName: "Full Test Deck",
            commander: "Full Test Commander",
            points: 350,
            createdAt: createdDate,
            absent: false,
            deckList: ["Card1", "Card2", "Card3"],
            requiresPasswordSetup: true,
            passwordNeedsReset: true,
            message: "Full test message",
            success: true
        )
        
        loginViewModel.savePlayerToPreferences(testPlayer)
        let retrievedPlayer = loginViewModel.getPlayerFromPreferences()
        
        #expect(retrievedPlayer?.id == testPlayer.id)
        #expect(retrievedPlayer?.playerName == testPlayer.playerName)
        #expect(retrievedPlayer?.email == testPlayer.email)
        #expect(retrievedPlayer?.discordUsername == testPlayer.discordUsername)
        #expect(retrievedPlayer?.deckName == testPlayer.deckName)
        #expect(retrievedPlayer?.commander == testPlayer.commander)
        #expect(retrievedPlayer?.points == testPlayer.points)
        #expect(retrievedPlayer?.absent == testPlayer.absent)
        #expect(retrievedPlayer?.deckList == testPlayer.deckList)
        #expect(retrievedPlayer?.requiresPasswordSetup == testPlayer.requiresPasswordSetup)
        #expect(retrievedPlayer?.passwordNeedsReset == testPlayer.passwordNeedsReset)
        #expect(retrievedPlayer?.message == testPlayer.message)
        #expect(retrievedPlayer?.success == testPlayer.success)
    }
}
