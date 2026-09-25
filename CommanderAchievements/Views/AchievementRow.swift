import SwiftUI

struct AchievementRow: View {
    let achievement: Achievement
    let isCompleted: Bool

    var body: some View {
        let borderColor: Color = isCompleted ? .green : .clear
        let bgColor: Color = isCompleted ? Color.green.opacity(0.15) : .clear
        return AchievementCard(achievement: achievement)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(borderColor, lineWidth: 3)
            )
            .background(bgColor)
            .cornerRadius(12)
            .shadow(radius: 2, y: 1)
    }
}
#Preview {
    AchievementRow(achievement: Achievement(id: "0", title: "Test", description: "Some Desc", rarity: "Rare", category: "Category", points: 10), isCompleted: true)
}
