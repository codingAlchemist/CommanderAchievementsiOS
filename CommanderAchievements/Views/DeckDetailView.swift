import SwiftUI
import SwiftData

struct DeckDetailView: View {
    let player: Player
    @Environment(\.modelContext) private var modelContext
    @State private var isSyncing: Bool = false
    @State private var alertMessage: String?
    @State private var showAlert: Bool = false
    @State private var showPlayerDetail: Bool = false

    var body: some View {
        ScrollView {
            // NavigationLink to push the (deprecated) PlayerDetailView when requested
            NavigationLink(destination: PlayerDetailView(player: player), isActive: $showPlayerDetail) { EmptyView() }
            VStack(alignment: .leading, spacing: 12) {
                Group {
                    Text(player.playerName)
                        .font(.largeTitle.bold())
                    Text(player.email)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    if !player.discordUsername.isEmpty {
                        Text("Discord: \(player.discordUsername)")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                Divider()

                Group {
                    LabeledContent("Deck Name", value: player.deckName)
                    LabeledContent("Points", value: String(player.points))
                    LabeledContent("Absent", value: player.absent ? "Yes" : "No")
                    LabeledContent("Requires Password Setup", value: player.requiresPasswordSetup ? "Yes" : "No")
                    LabeledContent("Password Needs Reset", value: player.passwordNeedsReset ? "Yes" : "No")

                    // Deck preview: separate commander and cards visually
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Deck")
                            .font(.headline)

                        HStack(alignment: .top, spacing: 16) {
                            // Commander card
                            VStack(alignment: .leading, spacing: 6) {
                                Text("Commander")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                                Text(player.deck.commander)
                                    .font(.title3.weight(.semibold))
                                    .padding(10)
                                    .background(RoundedRectangle(cornerRadius: 10).fill(Color.gray.opacity(0.1)))
                            }

                            // Horizontal list of notable deck cards
                            ScrollView(.horizontal, showsIndicators: false) {
                                LazyHStack(spacing: 8) {
                                    ForEach(player.deck.cards, id: \.self) { card in
                                        Text(card)
                                            .font(.subheadline)
                                            .padding(.vertical, 8)
                                            .padding(.horizontal, 12)
                                            .background(Capsule().fill(Color.blue.opacity(0.12)))
                                            .foregroundStyle(.primary)
                                    }
                                }
                            }
                        }
                    }
                }

                Divider()

                if !player.completedAchievements.isEmpty {
                    Text("Completed Achievements")
                        .font(.headline)
                    ForEach(player.completedAchievements, id: \.self) { ach in
                        Text(ach)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }

                if !player.deckList.isEmpty {
                    Text("Deck List")
                        .font(.headline)
                    ForEach(player.deckList, id: \.self) { card in
                        Text(card)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }
            }
            .padding()
        }
        .navigationTitle("Deck")
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button("Player") {
                    showPlayerDetail = true
                }
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                if isSyncing {
                    ProgressView()
                } else {
                    Button("Fetch Achievements") {
                        Task { await fetchAndReplaceAchievements() }
                    }
                }
            }
        }
        .alert("Achievements", isPresented: $showAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(alertMessage ?? "")
        }
    }

    private func fetchAndReplaceAchievements() async {
        guard !isSyncing else { return }
        isSyncing = true
        do {
            try await APIService.shared.syncAchievementsToSwiftData(using: modelContext)
            // provide user feedback
            alertMessage = "Achievements updated"
            showAlert = true
        } catch {
            // surface the error message
            alertMessage = (error as? LocalizedError)?.errorDescription ?? error.localizedDescription
            showAlert = true
            print("[DeckDetailView] Failed to sync achievements: \(error)")
        }
        isSyncing = false
    }
}

private struct LabeledContent: View {
    let title: String
    let value: String
    init(_ title: String, value: String) { self.title = title; self.value = value }
    var body: some View {
        HStack(alignment: .firstTextBaseline) {
            Text(title)
                .font(.subheadline)
                .foregroundStyle(.secondary)
            Spacer()
            Text(value)
                .font(.body)
                .multilineTextAlignment(.trailing)
        }
    }
}

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
    NavigationStack { DeckDetailView(player: samplePlayer) }
}
