import SwiftUI

struct PlayerDetailView: View {
    let player: Player
    @State private var showingAchievements = false
    @State private var navigateToSoloGame = false

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Basic player info
            Text(player.playerName)
                .font(.largeTitle)
                .fontWeight(.bold)

            if !player.deckName.isEmpty {
                Text("Deck: \(player.deckName)")
                    .font(.headline)
            }

            if !player.commander.isEmpty {
                Text("Commander: \(player.commander)")
                    .font(.subheadline)
            }

            HStack(spacing: 12) {
                Label("Points: \(player.points)", systemImage: "star.fill")
                if player.absent {
                    Label("Absent", systemImage: "person.fill.xmark")
                        .foregroundStyle(.red)
                }
            }
            .font(.footnote)
            .foregroundStyle(.secondary)
            NavigationLink(isActive: $navigateToSoloGame) {
                GameView()
            } label: {
                EmptyView()
            }
            .hidden()
            Button {
                navigateToSoloGame = true
            } label: {
                Label("Solo Game", systemImage: "person.fill")
                    .frame(maxWidth: .infinity)
            }.buttonStyle(AppButtonStyle())
            Button {
                
            } label: {
                Label("Join Game", systemImage: "person.2.fill")
                    .frame(maxWidth: .infinity)
            }.buttonStyle(AppButtonStyle())
            Button {
                
            } label: {
                Label("Host Game", systemImage: "person.3.fill")
                    .frame(maxWidth: .infinity)
            }.buttonStyle(AppButtonStyle())
            Button {
                showingAchievements = true
            } label: {
                Label("Completed Achievements", systemImage: "rosette")
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .font(.headline)
            }
            .buttonStyle(.bordered)

            Spacer(minLength: 8)

            // Navigate to the deck details
            NavigationLink {
                DeckDetailView(player: player)
            } label: {
                Text("View Deck")
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .font(.headline)
            }
            .buttonStyle(.borderedProminent)
        }
        .sheet(isPresented: $showingAchievements) {
            NavigationStack {
                Group {
                    if player.completedAchievements.isEmpty {
                        ContentUnavailableView("No Completed Achievements", systemImage: "rosette")
                    } else {
                        List(player.completedAchievements, id: \.self) { achievementID in
                            Text(achievementID)
                        }
                    }
                }
                .navigationTitle("Completed Achievements")
                .toolbar {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button("Done") { showingAchievements = false }
                    }
                }
            }
        }
        .padding()
        .navigationTitle("Player")
        .navigationBarTitleDisplayMode(.inline)
    }
}

// Keep a lightweight preview helper so the file still previews in Xcode
#Preview {
    let sampleDeck = Player.Deck(
        name: "Azorius Control",
        cards: ["Arcane Signet", "Talisman of Curiosity", "Command Tower"],
        commander: "Brago, King Eternal"
    )

    let samplePlayer = Player(
        id: "p-001",
        playerName: "Alice Storm",
        email: "alice@example.com",
        discordUsername: "alice#1001",
        deckName: "Azorius Control",
        deck: sampleDeck,
        commander: "Brago, King Eternal",
        points: 17,
        absent: false,
        completedAchievements: ["ach-001"],
        deckList: ["Arcane Signet", "Talisman of Curiosity", "Command Tower"],
        requiresPasswordSetup: true,
        passwordNeedsReset: true
    )
    NavigationStack {
        PlayerDetailView(player: samplePlayer)
    }
}

