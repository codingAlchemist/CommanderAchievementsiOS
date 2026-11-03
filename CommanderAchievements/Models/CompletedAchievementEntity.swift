import Foundation
import SwiftData

@Model
final class CompletedAchievementEntity {
    @Attribute(.unique) var id: String
    var title: String
    var achievementDescription: String
    var rarity: String
    var category: String
    var points: Int
    var completedAt: Date

    init(
        id: String,
        title: String = "",
        achievementDescription: String = "",
        rarity: String = "",
        category: String = "",
        points: Int = 0,
        completedAt: Date = Date()
    ) {
        self.id = id
        self.title = title
        self.achievementDescription = achievementDescription
        self.rarity = rarity
        self.category = category
        self.points = points
        self.completedAt = completedAt
    }
}
