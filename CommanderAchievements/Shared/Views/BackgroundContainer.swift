//
//  BackgroundContainer.swift
//  GameAchievementsiOS
//
//  Created by jason debottis on 2/7/24.
//

import SwiftUI

struct BackgroundContainer<Content: View>: View {
    @ViewBuilder let content: Content
    var body: some View {
        ZStack(alignment: .center) {
            Image("Dragon")
                .resizable()
            content
                .padding(.horizontal, 20)
        }.ignoresSafeArea()
    }
}

#Preview {
    BackgroundContainer(content: {
        Text("Test")
    })
}
