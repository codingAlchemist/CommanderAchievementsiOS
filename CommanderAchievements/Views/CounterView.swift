//
//  CounterView.swift
//  CommanderAchievements
//
//  Created by jason debottis on 8/16/26.
//
import SwiftUI

struct CounterView: View {
    let title: String
    @Binding var count: Int
    let color: Color
    
    var body: some View {
        VStack(spacing: 4) {
            Text(title)
                .font(.headline)
            HStack(spacing: 24) {
                Button(action: { count = max(count - 1, 0) }) {
                    Image(systemName: "minus.circle")
                        .font(.system(size: 30))
                        .foregroundColor(color)
                }
                Text("\(count)")
                    .font(.title)
                    .padding(.horizontal, 4)
                Button(action: { count += 1 }) {
                    Image(systemName: "plus.circle")
                        .font(.system(size: 30))
                        .foregroundColor(color)
                }
            }
        }
        .padding(8)
        .background(color.opacity(0.08))
        .cornerRadius(10)
    }
}

#Preview {
    CounterView(title: "Test", count: .constant(0), color: .accentColor)
}
