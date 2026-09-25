//
//  Achievements.swift
//  CommanderAchievements
//
//  Created by jason debottis on 8/14/26.
//

import SwiftUI

public struct Achievements: View {
    @ObservedObject var viewModel: AchievementsViewModel
    @State private var selectedAchievement: Achievement? = nil
    public var text = "Login Successful"
    
    public var body: some View {
        NavigationStack {
            ZStack {
                Color(.systemGroupedBackground)
                    .ignoresSafeArea()
                VStack(spacing: 24) {
                    VStack(spacing: 2) {
                        Text("Achievements")
                            .font(.largeTitle.bold())
                            .foregroundColor(.primary)
                            .padding(.top, 16)
                        Text("You've earned these milestones")
                            .font(.title3)
                            .foregroundColor(.secondary)
                    }
                    .padding(.bottom, 8)

                    if viewModel.achievements.isEmpty {
                        Spacer()
                        Text("No achievements yet.")
                            .font(.title3)
                            .foregroundColor(.secondary)
                            .padding()
                        Spacer()
                    } else {
                        ScrollView {
                            VStack(spacing: 20) {
                                ForEach(viewModel.achievements) { achievement in
                                    Button(action: {
                                        selectedAchievement = achievement
                                    }) {
                                        AchievementCard(achievement: achievement)
                                            .background(.thinMaterial)
                                            .cornerRadius(16)
                                            .shadow(radius: 5, y: 2)
                                            .padding(.horizontal)
                                    }
                                    .buttonStyle(.plain)
                                }
                            }
                            .padding(.bottom, 40)
                        }
                    }
                }
                .padding(.top, 8)
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        Task {
                            // Clear current list immediately, then fetch new achievements
                            await MainActor.run {
                                viewModel.achievements = []
                            }
                            await viewModel.getAchievements()
                        }
                    } label: {
                        Image(systemName: "arrow.clockwise")
                    }
                }
            }
            .sheet(item: $selectedAchievement) { achievement in
                AchievementDetailView(achievement: achievement)
            }
        }
    }
    
    init(viewModel: AchievementsViewModel, text: String = "Login Successful") {
        self.viewModel = viewModel
        self.text = text
    }
}
#Preview {
    let sampleAchievements = [
        Achievement(id: "1", title: "Winner", description: "Win your first match.", rarity: "Common", category: "gameplay", points: 5),
        Achievement(id: "2", title: "Undefeated", description: "Win 5 matches in a row.", rarity: "Rare", category: "streak", points: 20)
    ]
    let vm = AchievementsViewModel(achievements: sampleAchievements)
    NavigationStack {
        Achievements(viewModel: vm)
    }
}
