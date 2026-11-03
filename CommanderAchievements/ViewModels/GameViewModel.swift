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

    private func pickNewGameAchievements(from fetched: [Achievement], excluding completedIDs: Set<String>, count: Int = 3) -> [Achievement] {
        let uncompleted = fetched.filter { !completedIDs.contains($0.id) }

        // Preferred path: only use uncompleted achievements for a new game.
        if uncompleted.count >= count {
            return Array(uncompleted.shuffled().prefix(count))
        }

        // Fallback: if not enough remain, fill the rest from completed achievements.
        let usedIDs = Set(uncompleted.map(\.id))
        let remainingPool = fetched.filter { !usedIDs.contains($0.id) }
        let needed = max(0, count - uncompleted.count)
        let fallback = Array(remainingPool.shuffled().prefix(needed))

        return uncompleted + fallback
    }

    // Shared helper to fetch achievements from the API and ensure local Swift Data is in sync.
    // Set randomizeSelection to true when you want a different three-achievement game set.
    public func fetchAndReplaceAchievements(using modelContext: ModelContext, randomizeSelection: Bool = false) async throws {
        // Fetch latest achievements from the API
        let fetched = try await APIService.shared.fetchAchievements()

        // Ensure local Swift Data is synced (inserts completed achievement entities as needed)
        try await APIService.shared.syncAchievementsToSwiftData(using: modelContext)

        if randomizeSelection {
            let descriptor = FetchDescriptor<CompletedAchievementEntity>()
            let completedIDs = Set(try modelContext.fetch(descriptor).map(\.id))
            self.achievements = pickNewGameAchievements(from: fetched, excluding: completedIDs)
        } else {
            // Keep a stable set of the first three achievements for regular loads.
            self.achievements = Array(fetched.prefix(3))
        }
    }
}
