// fix textfield not allowing text to be entered in GameView.swift

import SwiftUI
import Combine
import _SwiftData_SwiftUI

public struct GameView: View {
    // State for player's life (defaulted to 40 for a typical MTG start)
    @State private var lifePoints: Int = 40
    // Randomly assigned achievements for preview/demo
    @State private var currentAchievements: [Achievement]
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

    public init(achievements: [Achievement] = GameView.randomAchievements()) {
        self._currentAchievements = State(initialValue: achievements)
    }
    
    struct CommanderDamage: Identifiable, Hashable {
        let id = UUID()
        var name: String
        var damage: Int
    }

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
                            ForEach(currentAchievements.prefix(3)) { achievement in
                                NavigationLink(destination: AchievementDetailView(achievement: achievement)) {
                                    AchievementCard(achievement: achievement)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 12)
                                                .stroke(isCompleted(achievement) ? Color.green : Color.clear, lineWidth: 3)
                                        )
                                        .background(
                                            (isCompleted(achievement) ? Color.green.opacity(0.15) : Color.clear)
                                        )
                                        .cornerRadius(12)
                                        .shadow(radius: 2, y: 1)
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
                                ForEach($gameViewModel.opponents) { $entry in
                                    
                                    HStack {
                                        Text(entry.name ?? "Unnamed Opponent")
                                            .font(.headline)
                                        Spacer()
                                        Button(action: { entry.damageDealt = max(0, entry.damageDealt - 1) }) {
                                            Image(systemName: "minus.circle")
                                                .font(.system(size: 24))
                                        }
                                        Text("\(entry.damageDealt)")
                                            .font(.title3).monospacedDigit()
                                            .frame(minWidth: 36)
                                        Button(action: { entry.damageDealt += 1 }) {
                                            Image(systemName: "plus.circle")
                                                .font(.system(size: 24))
                                        }
                                        Button("+1") { entry.damageDealt += 1 }
                                            .buttonStyle(.bordered)
                                        Button("+5") { entry.damageDealt += 5 }
                                            .buttonStyle(.borderedProminent)
                                        Button(role: .destructive) {
                                            if let idx = gameViewModel.opponents.firstIndex(where: { $0.id == entry.id }) {
                                                gameViewModel.opponents.remove(at: idx)
                                            }
                                        } label: {
                                            Image(systemName: "trash")
                                        }
                                    }
                                    .padding(8)
                                    .background(.regularMaterial)
                                    .cornerRadius(10)
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
            .navigationTitle("Game")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showingSettingsSheet = true
                    } label: {
                        Image(systemName: "gearshape.fill")
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
                        // Build a fresh array explicitly to help the type-checker
                        
                        for (index, opponent) in newOpponents.enumerated() {
                            let rawName: String
                            if let optName = opponent.name {
                                rawName = optName
                            } else {
                                rawName = ""
                            }
                            let trimmed = rawName.trimmingCharacters(in: .whitespacesAndNewlines)
                            let displayName: String
                            if trimmed.isEmpty {
                                displayName = "Player #\(index + 1)"
                            } else {
                                displayName = trimmed
                            }
                            gameViewModel.opponents.append(Opponent(name: displayName, damageDealt: 0))
                        }

                    }
                }
            }
            .onChange(of: poisonCounters) { _, newValue in
                showKOOverlay = newValue >= 10
            }
        }
    }
    
    // Helper for random demo data
    public static func randomAchievements() -> [Achievement] {
        return [
            Achievement(id: "1", title: "First Blood", description: "Deal the first damage.", rarity: "Common", category: "damage", points: 5),
            Achievement(id: "2", title: "Survivor", description: "Remain above 20 life for 5 turns.", rarity: "Rare", category: "life", points: 10),
            Achievement(id: "3", title: "Combo Master", description: "Execute a 3-card combo.", rarity: "Epic", category: "combo", points: 20)
        ].shuffled()
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

