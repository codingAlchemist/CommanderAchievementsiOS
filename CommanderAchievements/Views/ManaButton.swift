//
//  ManaButton.swift
//  CommanderAchievements
//
//  Created by jason debottis on 10/26/26.
//

import SwiftUI

struct ManaButton: View {
    let color: Color
    @State var count: Int

    var body: some View {
        VStack {
            Button(action: {
                if count > 0 {
                    count -= 1
                }
            }) {
                Image(systemName: "minus.circle")
                    .font(.system(size: 30))
                    .foregroundColor(color)
            }

            Image(systemName: "circle.fill")
                .resizable()
                .frame(width: 40, height: 40)
                .foregroundColor(color)
                .overlay(
                    Text("\(count)")
                        .font(.headline)
                        .foregroundColor(.white)
                )

            Button(action: { count += 1 }) {
                Image(systemName: "plus.circle")
                    .font(.system(size: 30))
                    .foregroundColor(color)
            }
        }
    }
}

#Preview {
    ManaButton(color: .blue, count: 0)
}
