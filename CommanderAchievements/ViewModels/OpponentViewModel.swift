//
//  OpponentViewModel.swift
//  CommanderAchievements
//
//  Created by jason debottis on 9/14/26.
//

import Foundation
import Combine

class OpponentViewModel: ObservableObject, Identifiable {
    @Published var opponent: Opponent

    init(opponent: Opponent = Opponent()) {
        self.opponent = opponent
    }
}
