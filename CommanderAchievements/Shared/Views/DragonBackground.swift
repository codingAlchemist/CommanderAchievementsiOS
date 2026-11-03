//
//  DragonBackground.swift
//  CommanderAchievements
//
//  Created by jason debottis on 10/10/26.
//
import SwiftUI

struct DragonBackground: ViewModifier {
    func body(content: Content) -> some View {
        ZStack {
            // Dragon image
            Image("Dragon")
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()

            // Subtle dark overlay to improve foreground contrast across the app
            Color.black
                .opacity(0.22)
                .ignoresSafeArea()

            // The content of the view sits above the background + overlay
            content
        }
    }
}

extension View {
    func dragonBackground() -> some View {
        self.modifier(DragonBackground())
    }
}
