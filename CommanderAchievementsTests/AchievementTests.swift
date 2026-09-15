//
//  AchievementTests.swift
//  CommanderAchievements
//
//  Created by jason debottis on 8/13/26.
//

import Foundation
import Testing
@testable import CommanderAchievements

struct AchievementTests {
    @Test
    func example() {
        #expect(1 + 1 == 2)
    }
    
    @Test("fetchAchievements returns an array of achievements")
    @MainActor
    func testFetchAchievementsReturnsArray() async throws {
        let achievements = try await APIService.shared.fetchAchievements()
        print("Fetched achievements: \(achievements)")
        // You can adjust this assertion based on if you expect seeded data or just want to ensure decoding works
        #expect(type(of: achievements) == Array<Achievement>.self, "Should return an array of Achievement")
    }
}
