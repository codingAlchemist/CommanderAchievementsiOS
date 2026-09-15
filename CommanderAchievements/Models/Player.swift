//
//  Player.swift
//  CommanderAchievements
//
//  Created by jason debottis on 8/13/26.
//
import Foundation

public struct Player: Codable, Sendable {
    public struct Deck: Codable, Sendable {
        public let name: String
        public let cards: [String]
        public let commander: String
    }

    public let id: String
    public let playerName: String
    public let email: String
    public let discordUsername: String
    public let deckName: String
    public let deck: Deck
    public let commander: String
    public let points: Int
    public let absent: Bool
    public let completedAchievements: [String]
    public let deckList: [String]
    public let requiresPasswordSetup: Bool
    public let passwordNeedsReset: Bool

    enum CodingKeys: String, CodingKey {
        case id
        case playerName
        case email
        case discordUsername
        case deckName
        case deck
        case commander
        case points
        case absent
        case completedAchievements
        case deckList
        case requiresPasswordSetup
        case passwordNeedsReset
    }

    public init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(String.self, forKey: .id)
        self.playerName = try container.decode(String.self, forKey: .playerName)
        self.email = try container.decode(String.self, forKey: .email)
        self.discordUsername = try container.decode(String.self, forKey: .discordUsername)
        self.deckName = try container.decode(String.self, forKey: .deckName)
        self.deck = try container.decode(Deck.self, forKey: .deck)
        self.commander = try container.decode(String.self, forKey: .commander)
        self.points = try container.decode(Int.self, forKey: .points)
        self.absent = try container.decode(Bool.self, forKey: .absent)
        self.completedAchievements = try container.decode([String].self, forKey: .completedAchievements)
        self.deckList = try container.decode([String].self, forKey: .deckList)
        self.requiresPasswordSetup = try container.decode(Bool.self, forKey: .requiresPasswordSetup)
        self.passwordNeedsReset = try container.decode(Bool.self, forKey: .passwordNeedsReset)
    }

    public func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.id, forKey: .id)
        try container.encode(self.playerName, forKey: .playerName)
        try container.encode(self.email, forKey: .email)
        try container.encode(self.discordUsername, forKey: .discordUsername)
        try container.encode(self.deckName, forKey: .deckName)
        try container.encode(self.deck, forKey: .deck)
        try container.encode(self.commander, forKey: .commander)
        try container.encode(self.points, forKey: .points)
        try container.encode(self.absent, forKey: .absent)
        try container.encode(self.completedAchievements, forKey: .completedAchievements)
        try container.encode(self.deckList, forKey: .deckList)
        try container.encode(self.requiresPasswordSetup, forKey: .requiresPasswordSetup)
        try container.encode(self.passwordNeedsReset, forKey: .passwordNeedsReset)
    }

    public init(
        id: String,
        playerName: String,
        email: String,
        discordUsername: String,
        deckName: String,
        deck: Deck,
        commander: String,
        points: Int,
        absent: Bool,
        completedAchievements: [String],
        deckList: [String],
        requiresPasswordSetup: Bool,
        passwordNeedsReset: Bool
    ) {
        self.id = id
        self.playerName = playerName
        self.email = email
        self.discordUsername = discordUsername
        self.deckName = deckName
        self.deck = deck
        self.commander = commander
        self.points = points
        self.absent = absent
        self.completedAchievements = completedAchievements
        self.deckList = deckList
        self.requiresPasswordSetup = requiresPasswordSetup
        self.passwordNeedsReset = passwordNeedsReset
    }
}
