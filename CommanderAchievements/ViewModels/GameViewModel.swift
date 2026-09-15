//
//  GameViewModel.swift
//  CommanderAchievements
//
//  Created by jason debottis on 9/14/26.
//

import Combine

class GameViewModel: ObservableObject {
    @Published var opponents: [Opponent]

    init(opponents: [Opponent] = []) {
        self.opponents = opponents
    }
}
