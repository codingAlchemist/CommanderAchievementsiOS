import Foundation
import CommanderAchievements

final class ApiServiceMock: ApiserviceInterface {
    var shouldFailLogin: Bool = false
    var shouldFailFetch: Bool = false
    var savedDataURL: URL? = nil

    func login(username: String, password: String) async throws -> Player {
        if shouldFailLogin {
            throw URLError(.userAuthenticationRequired)
        }
        let player = Player(
            id: "p-001",
            playerName: username.isEmpty ? "Alice Storm" : username,
            email: "alice@example.com",
            discordUsername: "alice#1001",
            deckName: "Azorius Control",
            commander: "Brago, King Eternal",
            points: 12,
            createdAt: ISO8601DateFormatter().date(from: "2026-05-01T10:15:00Z") ?? Date(),
            absent: false,
            deckList: [
                "Arcane Signet",
                "Talisman of Curiosity",
                "Command Tower",
                "Flooded Strand",
                "Hallowed Fountain",
                "Temple Garden",
                "Seachrome Coast",
                "Farseek",
                "Cultivate",
                "Sakura-Tribe Elder",
                "Sol Ring",
                "Boseiju, Who Endures",
                "Brainstorm",
                "Mystic Remora",
                "Swords to Plowshares",
                "Heroic Intervention",
                "Supreme Verdict",
                "The One Ring"
            ],
            requiresPasswordSetup: true,
            passwordNeedsReset: true,
            message: "Login Successful",
            success: true
        )
        return player
    }

    func fetchAchievements() async throws -> [Achievement] {
        if shouldFailFetch {
            throw URLError(.badServerResponse)
        }
        return sampleAchievements()
    }

    func saveAchievementsToLocalFile(_ achievements: [Achievement], fileName: String) async throws {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted]
        let data = try encoder.encode(achievements)
        let url = FileManager.default.temporaryDirectory.appendingPathComponent(fileName)
        try data.write(to: url)
        savedDataURL = url
    }

    // MARK: - Sample Data

    private func sampleAchievements() -> [Achievement] {
        return [
            Achievement(
                id: "achv_001",
                title: "First Steps",
                description: "Complete the tutorial to get started.",
                rarity: "common",
                category: "onboarding",
                points: 5
            ),
            Achievement(
                id: "achv_002",
                title: "Marathon Runner",
                description: "Accumulate 42 km in total distance.",
                rarity: "rare",
                category: "fitness",
                points: 25
            ),
            Achievement(
                id: "achv_003",
                title: "Mariner",
                description: "Sail across all seas.",
                rarity: "epic",
                category: "exploration",
                points: 50
            )
        ]
    }
}
