//
//  Achievement.swift
//  CommanderAchievements
//
//  Created by jason debottis on 8/13/26.
//

public struct Achievement: Codable, Equatable, Identifiable {
    public let id: String
    public let title: String
    public let description: String
    public let rarity: String
    public let category: String
    public let points: Int
    
    enum CodingKeys: String, CodingKey {
        case id, title, description, rarity, category, points
    }
    
    public init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(String.self, forKey: .id)
        self.title = try container.decode(String.self, forKey: .title)
        self.description = try container.decode(String.self, forKey: .description)
        self.rarity = try container.decode(String.self, forKey: .rarity)
        self.category = try container.decode(String.self, forKey: .category)
        self.points = try container.decode(Int.self, forKey: .points)
    }
    
    public func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(title, forKey: .title)
        try container.encode(description, forKey: .description)
        try container.encode(rarity, forKey: .rarity)
        try container.encode(category, forKey: .category)
        try container.encode(points, forKey: .points)
    }
    
    public init(id: String, title: String, description: String, rarity: String, category: String, points: Int) {
        self.id = id
        self.title = title
        self.description = description
        self.rarity = rarity
        self.category = category
        self.points = points
    }
}
