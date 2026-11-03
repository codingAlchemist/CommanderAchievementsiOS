import SwiftUI

struct CompletedAchievementsCard: View {
    let achievements: [CompletedAchievementEntity]

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Completed Achievements")
                    .font(.title3.bold())
                Spacer()
                Text("\(achievements.count)")
                    .font(.headline)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(Color.green.opacity(0.2))
                    .clipShape(Capsule())
            }

            if achievements.isEmpty {
                Text("Complete an achievement to see it here.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            } else {
                ForEach(achievements, id: \.id) { achievement in
                    HStack(alignment: .top, spacing: 10) {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundStyle(.green)
                            .padding(.top, 2)

                        VStack(alignment: .leading, spacing: 4) {
                            Text(achievement.title)
                                .font(.headline)
                            Text("+\(achievement.points) points")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }

                        Spacer()
                    }
                    .padding(10)
                    .background(Color.green.opacity(0.12))
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                }
            }
        }
        .padding()
        .background(.thinMaterial)
        .cornerRadius(16)
        .shadow(radius: 4, y: 2)
    }
}

#Preview {
    CompletedAchievementsCard(achievements: [
        CompletedAchievementEntity(
            id: "1",
            title: "First Blood",
            achievementDescription: "Deal combat damage",
            rarity: "Common",
            category: "Combat",
            points: 5
        ),
        CompletedAchievementEntity(
            id: "2",
            title: "Arcane Master",
            achievementDescription: "Cast 5 spells",
            rarity: "Uncommon",
            category: "Spells",
            points: 10
        )
    ])
    .padding()
}
