//
//  Opponent.swift
//  CommanderAchievements
//
//  Created by jason debottis on 9/14/26.
//

import SwiftUI
import Combine

struct Opponent: Identifiable, Codable, Hashable {
    var id = UUID()
    var name: String?
    var commanders: [String]?
    var damageDealt: Int = 0
}
