import SwiftUI
import SwiftData

private let AchievementCompletedNotification = Notification.Name("AchievementCompletedNotification")
private let CompletedAchievementsDefaultsKey = "completedAchievementIDs"

public struct AchievementDetailView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    let player = PlayerManager.shared.getPlayerFromPreferences()

    let achievement: Achievement
    
    public init(achievement: Achievement) {
        self.achievement = achievement
    }
    public func completeAchievement() async {
        do {
            try await APIService.shared.completeAchievement(playerID: player?.id ?? "0", achievementID: achievement.id) { result in
                switch result {
                case .success(let message):
                    // Notify listeners that this achievement was completed
                    NotificationCenter.default.post(name: AchievementCompletedNotification, object: achievement.id)
                    // Persist completion via Swift Data
                    let completed = CompletedAchievementEntity(id: achievement.id)
                    modelContext.insert(completed)
                    do {
                        try modelContext.save()
                    } catch {
                        print("Failed to save completed achievement to Swift Data: \(error)")
                    }
                    // Dismiss the detail view
                    
                case .failure(let error):
                    // Handle the error appropriately (e.g., show an alert to the user)
                    DispatchQueue.main.async {
                        // Update UI or show an alert here if needed
                    }
                }
                
            }
           
            await MainActor.run { dismiss() }
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
                Text("Complete Achievement")
                    .font(.headline)
                    
            }.buttonStyle(AppButtonStyle())
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

