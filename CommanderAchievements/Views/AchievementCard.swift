//
//  Untitled.swift
//  CommanderAchievements
//
//  Created by jason debottis on 8/14/26.
//

import SwiftUI

public struct AchievementCard: View {
    
    let achievement: Achievement
    
    public init(achievement: Achievement) {
        self.achievement = achievement
    }
        
    public var body: some View {
        VStack {
            Text("Achievement \(achievement.description)")
                .padding()
        }
    }
    
}

#Preview {
    let achievement = Achievement(id: "123",
                                  title: "Test",
                                  description: "Description",
                                  rarity: "Rare",
                                  category: "msc",
                                  points: 5)
    AchievementCard(achievement: achievement)
}
