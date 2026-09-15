import Foundation
import SwiftData

@Model
final class CompletedAchievementEntity {
    @Attribute(.unique) var id: String
    var completedAt: Date

    init(id: String, completedAt: Date = Date()) {
        self.id = id
        self.completedAt = completedAt
    }
}
