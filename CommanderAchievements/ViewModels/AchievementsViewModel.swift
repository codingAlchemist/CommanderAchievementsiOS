//
//  AchievementsViewModel.swift
//  CommanderAchievements
//
//  Created by jason debottis on 8/14/26.
//
import Combine

public class AchievementsViewModel: ObservableObject {
    @Published public var achievements: [Achievement]
    
    init(achievements: [Achievement] = []) {
        self.achievements = achievements
    }
    
    public func getAchievements() async {
        self.achievements = try! await APIService.shared.fetchAchievements()
    }
}
