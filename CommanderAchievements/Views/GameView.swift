// fix textfield not allowing text to be entered in GameView.swift

import SwiftUI
import Combine
import _SwiftData_SwiftUI

public struct GameView: View {
    // State for player's life (defaulted to 40 for a typical MTG start)
    @State private var lifePoints: Int = 40
    // Randomly assigned achievements for preview/demo
    // @State private var currentAchievements: [Achievement] = []
    // State for different counter types (example: poison, energy)
    @State private var poisonCounters: Int = 0
    @State private var energyCounters: Int = 0
    @State private var showKOOverlay: Bool = false
    // Commander damage tracking: array of (commander name, damage)
    @State private var newCommanderName: String? = nil
    @State private var showingSettingsSheet: Bool = false
    @State private var trackPoisonCounters: Bool = false
    @State private var trackEnergyCounters: Bool = false
    // New opponents state replacing commanderPlayers and commanderNames
    @ObservedObject private var gameViewModel: GameViewModel = GameViewModel()
    @Query(sort: \CompletedAchievementEntity.completedAt) private var completedAchievementEntities: [CompletedAchievementEntity]
    @Environment(\.modelContext) private var modelContext: ModelContext

    private func isCompleted(_ achievement: Achievement) -> Bool {
        completedAchievementEntities.contains { $0.id == achievement.id }
    }
    
    public var body: some View {
        NavigationStack {
            ZStack {
                ScrollView(.vertical) {
                    VStack(spacing: 32) {
                        // Life Points Display
                        VStack {
                            Text("Life Points")
                                .font(.headline)
                            HStack(spacing: 32) {
                                Button(action: { lifePoints -= 1 }) {
                                    Image(systemName: "minus.circle.fill")
                                        .font(.system(size: 40))
                                        .foregroundColor(.red)
                                }
                                Text("\(lifePoints)")
                                    .font(.system(size: 48, weight: .bold, design: .rounded))
                                    .padding(.horizontal, 8)
                                Button(action: { lifePoints += 1 }) {
                                    Image(systemName: "plus.circle.fill")
                                        .font(.system(size: 40))
                                        .foregroundColor(.green)
                                }
                            }
                        }
                        .padding()
                        .background(.thinMaterial)
                        .cornerRadius(16)
                        .shadow(radius: 4, y: 2)
                        
                        // Achievement Cards
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Achievements")
                                .font(.title2.bold())
                            ForEach(gameViewModel.achievements, id: \.id) { achievement in
                                NavigationLink(destination: AchievementDetailView(achievement: achievement)) {
                                    AchievementRow(achievement: achievement, isCompleted: isCompleted(achievement))
                                }
                            }
                        }
                        .padding()
                        .background(.thinMaterial)
                        .cornerRadius(16)
                        .shadow(radius: 4, y: 2)
                        
                        // Commander Damage
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Commander Damage")
                                .font(.title2.bold())
                            HStack {
                                TextField("Add opponent name", text: Binding<String>(
                                    get: { newCommanderName ?? "" },
                                    set: { newValue in newCommanderName = newValue }
                                ))
                                .onSubmit {
                                    let raw = newCommanderName ?? ""
                                    let trimmed = raw.trimmingCharacters(in: .whitespacesAndNewlines)
                                    guard !trimmed.isEmpty else { return }
                                    gameViewModel.opponents.append(Opponent(name: trimmed))
                                    newCommanderName = nil
                                }
                                Button("Add") {
                                    let raw = newCommanderName ?? ""
                                    let trimmed = raw.trimmingCharacters(in: .whitespacesAndNewlines)
                                    guard !trimmed.isEmpty else { return }
                                    
                                    // Append a new opponent with the entered name
                                    gameViewModel.opponents.append(Opponent(name: trimmed))
                                    
                                    // Clear the text field
                                    newCommanderName = nil
                                }
                                .buttonStyle(.borderedProminent)
                            }
                            .padding(.bottom, 4)

                            if gameViewModel.opponents.isEmpty {
                                Text("No opponents added yet.")
                                    .foregroundStyle(.secondary)
                            } else {
                                ForEach(gameViewModel.opponents) { entry in
                                    OpponentRowView(entry: entry) {
                                        if let idx = gameViewModel.opponents.firstIndex(where: { $0.id == entry.id }) {
                                            gameViewModel.opponents.remove(at: idx)
                                        }
                                    } didChange: { newValue in
                                        if let idx = gameViewModel.opponents.firstIndex(where: { $0.id == entry.id }) {
                                            gameViewModel.opponents[idx].damageDealt = newValue
                                        }
                                    }
                                }
                            }
                        }
                        .padding()
                        .background(.thinMaterial)
                        .cornerRadius(16)
                        .shadow(radius: 4, y: 2)
                        
                        // Other Counters
                        VStack(spacing: 20) {
                            if trackPoisonCounters {
                                CounterView(title: "Poison Counters", count: $poisonCounters, color: .purple)
                            }
                            if trackEnergyCounters {
                                CounterView(title: "Energy Counters", count: $energyCounters, color: .blue)
                            }
                        }
                        .padding(.top, 8)
                        
                        Spacer()
                    }
                    .padding()
                }

                if showKOOverlay {
                    KOOverlay(
                        reason: "Player reached 10 poison counters.",
                        onDismiss: {
                            showKOOverlay = false
                            // Optionally reset poison counters
                            // poisonCounters = 0
                        }
                    )
                    .transition(.opacity.combined(with: .scale))
                    .animation(.spring(), value: showKOOverlay)
                }
            }
            .task {
                do {
                    let vm = gameViewModel
                    let ctx = modelContext
                    try await vm.fetchAndReplaceAchievements(using: ctx)
                } catch {
                    print("Failed to fetch achievements on appear: \(error)")
                }
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    HStack(spacing: 12) {
                        // Refresh achievements assigned to the current player using the shared helper
                        Button {
                            Task {
                                do {
                                    try await gameViewModel.fetchAndReplaceAchievements(using: modelContext)
                                } catch {
                                    print("Failed to refresh achievements: \(error)")
                                }
                            }
                        } label: {
                            Image(systemName: "arrow.clockwise")
                        }

                        Button {
                            showingSettingsSheet = true
                        } label: {
                            Image(systemName: "gearshape.fill")
                        }
                    }
                }
            }
            .sheet(isPresented: $showingSettingsSheet) {
                NavigationStack {
                    Form {
                        Section(header: Text("Counters")) {
                            Toggle(isOn: $trackPoisonCounters) {
                                Text("Track Poison Counters")
                            }
                            Toggle(isOn: $trackEnergyCounters) {
                                Text("Track Energy Counters")
                            }
                        }
                    }
                    .navigationTitle("Settings")
                    .toolbar {
                        ToolbarItem(placement: .topBarTrailing) {
                            Button("Done") { showingSettingsSheet = false }
                        }
                    }
                    .onChange(of: gameViewModel.opponents) { newOpponents in
                        // intentionally left blank
                    }
                }
            }
            .onChange(of: poisonCounters) { _, newValue in
                showKOOverlay = newValue >= 10
            }
        }
    }
}

#Preview {
    GameView()
}

private struct KOOverlay: View {
    let reason: String
    let onDismiss: () -> Void

    var body: some View {
        ZStack {
            Color.black.opacity(0.7).ignoresSafeArea()
            VStack(spacing: 16) {
                Image(systemName: "skull.fill")
                    .font(.system(size: 72, weight: .bold))
                    .foregroundStyle(.red)
                Text("KO")
                    .font(.system(size: 56, weight: .heavy))
                    .foregroundStyle(.red)
                Text(reason)
                    .font(.headline)
                    .foregroundStyle(.white)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)

                Button("OK") {
                    onDismiss()
                }
                .font(.headline)
                .padding(.horizontal, 24)
                .padding(.vertical, 12)
                .buttonStyle(.borderedProminent)
                .tint(.red)
                .padding(.top, 8)
            }
            .padding()
        }
        .accessibilityAddTraits(.isModal)
    }
}
