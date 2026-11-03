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
            .overlay(alignment: .topTrailing) {
                if isCompleted {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.title3)
                        .foregroundStyle(.white, .green)
                        .padding(8)
                        .accessibilityLabel("Completed")
                }
            }
            .background(bgColor)
            .cornerRadius(12)
            .shadow(radius: 2, y: 1)
            .opacity(isCompleted ? 0.45 : 1.0)
            .animation(.easeOut(duration: 0.35), value: isCompleted)
    }
}
#Preview {
    AchievementRow(achievement: Achievement(id: "0", title: "Test", description: "Some Desc", rarity: "Rare", category: "Category", points: 10), isCompleted: false)
}
