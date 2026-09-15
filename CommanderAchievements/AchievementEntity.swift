import Foundation
import SwiftData

@Model
final class AchievementEntity {
    @Attribute(.unique) var id: String
    var title: String
    var achievementDescription: String
    var rarity: String
    var category: String
    var points: Int

    init(id: String, title: String, achievementDescription: String, rarity: String, category: String, points: Int) {
        self.id = id
        self.title = title
        self.achievementDescription = achievementDescription
        self.rarity = rarity
        self.category = category
        self.points = points
    }
}
