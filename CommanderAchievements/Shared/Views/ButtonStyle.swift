//
//  ButtonStyle.swift
//  CommanderAchievements
//
//  Created by jason debottis on 8/16/26.
//

import SwiftUI

struct AppButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline)
            .padding()
            .foregroundStyle(.white)
            .background(Color.blue)
            .clipShape(Capsule())
        // Scales down slightly when the user presses the button
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
        // Changes opacity based on interaction state
            .opacity(configuration.isPressed ? 0.8 : 1.0)
            .animation(.easeOut(duration: 0.2), value: configuration.isPressed)
    }
}

#Preview {
    Button("Test") {
        print("pressed")
    }.buttonStyle(AppButtonStyle())
}
