//
//  GameViewModel.swift
//  CommanderAchievements
//
//  Created by jason debottis on 9/14/26.
//

import Combine
import SwiftData

class GameViewModel: ObservableObject {
    @Published var opponents: [Opponent]
    @Published var achievements: [Achievement] = []
    
    init(opponents: [Opponent] = []) {
        self.opponents = opponents
    }
    
    // Shared helper to fetch achievements from the API and ensure local Swift Data is in sync.
    // Returns the fetched achievements so callers can update any in-memory lists.
    public func fetchAndReplaceAchievements(using modelContext: ModelContext) async throws {
        // Fetch latest achievements from the API
        let fetched = try await APIService.shared.fetchAchievements()

        // Ensure local Swift Data is synced (inserts completed achievement entities as needed)
        try await APIService.shared.syncAchievementsToSwiftData(using: modelContext)
        self.achievements = fetched.shuffled().prefix(3).map { $0 }
    }
}
