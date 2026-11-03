//
//  ManaTrackerView.swift
//  CommanderAchievements
//
//  Created by jason debottis on 10/26/26.
//

import SwiftUI

struct ManaTrackerView: View {
    @State var blueManaCount: Int = 0
    @State var greenManaCount: Int = 0
    @State var redManaCount: Int = 0
    @State var whiteManaCount: Int = 0
    @State var blackManaCount: Int = 0
    
    var body: some View {
        HStack {
            ManaButton(color: .blue, count: blueManaCount)
            ManaButton(color: .green, count: greenManaCount)
            ManaButton(color: .red, count: redManaCount)
            ManaButton(color: .gray, count: whiteManaCount)
            ManaButton(color: .black, count: blackManaCount)
        }.padding(8)
        .background {
            RoundedRectangle(cornerRadius: 10)
                .fill(Color.gray.opacity(0.2))
                
        }.shadow(color: Color.gray.opacity(0.5), radius: 4, x: 3, y: 5)
        
    }
}

#Preview {
    ManaTrackerView()
}
