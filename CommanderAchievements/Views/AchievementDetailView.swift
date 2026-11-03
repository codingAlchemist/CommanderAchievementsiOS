import SwiftUI
import SwiftData

private let AchievementCompletedNotification = Notification.Name("AchievementCompletedNotification")
private let CompletedAchievementsDefaultsKey = "completedAchievementIDs"

public struct AchievementDetailView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Query(sort: \CompletedAchievementEntity.completedAt) private var completedAchievementEntities: [CompletedAchievementEntity]
    let player = PlayerManager.shared.getPlayerFromPreferences()

    let achievement: Achievement

    public init(achievement: Achievement) {
        self.achievement = achievement
    }

    private var isAchievementCompleted: Bool {
        completedAchievementEntities.contains { $0.id == achievement.id }
    }

    public func completeAchievement() async {
        guard !isAchievementCompleted else { return }
        do {
            try await APIService.shared.completeAchievement(playerID: player?.id ?? "0", achievementID: achievement.id) { result in
                switch result {
                case .success:
                    Task { @MainActor in
                        // Notify listeners that this achievement was completed
                        NotificationCenter.default.post(name: AchievementCompletedNotification, object: achievement.id)
                        // Persist completion via Swift Data
                        if !completedAchievementEntities.contains(where: { $0.id == achievement.id }) {
                            let completed = CompletedAchievementEntity(
                                id: achievement.id,
                                title: achievement.title,
                                achievementDescription: achievement.description,
                                rarity: achievement.rarity,
                                category: achievement.category,
                                points: achievement.points
                            )
                            modelContext.insert(completed)
                            do {
                                try modelContext.save()
                            } catch {
                                print("Failed to save completed achievement to Swift Data: \(error)")
                            }
                        }
                        dismiss()
                    }

                case .failure(let error):
                    Task { @MainActor in
                        // Update UI or show an alert here if needed
                        print("Failed to complete achievement: \(error)")
                    }
                }
            }
        } catch {
            print("Error completing achievement: \(error)")
        }
    }
    public var body: some View {
        VStack(spacing: 28) {
            VStack(spacing: 8) {
                Text(achievement.title)
                    .font(.largeTitle.weight(.bold))
                    .foregroundColor(.primary)
                Text(achievement.rarity)
                    .font(.headline)
                    .foregroundColor(.secondary)
            }
            .padding(.top, 32)

            Text(achievement.description)
                .font(.title3)
                .foregroundColor(.primary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)

            HStack(spacing: 24) {
                VStack {
                    Image(systemName: "star.fill")
                        .foregroundColor(.yellow)
                    Text("\(achievement.points) Points")
                        .font(.headline)
                }
                VStack {
                    Image(systemName: "tag")
                        .foregroundColor(.blue)
                    Text(achievement.category.capitalized)
                        .font(.headline)
                }

            }
            Button {
                Task {
                    await completeAchievement()
                }
            } label: {
                Text(isAchievementCompleted ? "Achievement Completed" : "Complete Achievement")
                    .font(.headline)
            }
            .buttonStyle(AppButtonStyle())
            .disabled(isAchievementCompleted)
            .opacity(isAchievementCompleted ? 0.65 : 1.0)
            Spacer()
            Button {
                Task {
                    do {
                        try await APIService.shared.syncAchievementsToSwiftData(using: modelContext)
                    } catch {
                        // Optionally handle error (e.g., show an alert)
                        print("Failed to refresh achievements: \(error)")
                    }
                }
            } label: {
                Text("Refresh Achievements")
            }
            .buttonStyle(AppButtonStyle())
            Spacer()
        }
        .padding()
        .background(.thinMaterial)
        .cornerRadius(20)
        .padding()
        .navigationTitle("Achievement")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    AchievementDetailView(achievement: Achievement(
        id: "demo1",
        title: "Unstoppable",
        description: "Win 10 matches without a loss.",
        rarity: "Legendary",
        category: "streak",
        points: 50
    ))
}
