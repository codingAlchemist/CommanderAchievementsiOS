import SwiftUI
import Combine

struct OpponentView: View {
    @Binding var opponent: Opponent
    var didDelete: (() -> Void)?
    var didUpdateDamage: ((Int) -> Void)?
    var body: some View {
        Section(header: Text("Opponents")) {
            HStack {
                Text(opponent.name ?? "Unknown Opponent")
                    .font(.headline)
                Spacer()
                Button(action: { opponent.damageDealt = max(0, (opponent.damageDealt ?? 0) - 1); didUpdateDamage?(opponent.damageDealt ?? 0) }) {
                    Image(systemName: "minus.circle")
                        .font(.system(size: 24))
                }
                Text("\(opponent.damageDealt ?? 0)")
                    .font(.title3).monospacedDigit()
                    .frame(minWidth: 36)
                Button(action: { opponent.damageDealt = (opponent.damageDealt ?? 0) + 1; didUpdateDamage?(opponent.damageDealt ?? 0) }) {
                    Image(systemName: "plus.circle")
                        .font(.system(size: 24))
                }
                Button("+1") { opponent.damageDealt = (opponent.damageDealt ?? 0) + 1; didUpdateDamage?(opponent.damageDealt ?? 0) }
                    .buttonStyle(.bordered)
                Button("+5") { opponent.damageDealt = (opponent.damageDealt ?? 0) + 5; didUpdateDamage?(opponent.damageDealt ?? 0) }
                    .buttonStyle(.borderedProminent)
                Button(role: .destructive) {
                    // Handle delete action here
                    didDelete?()
                } label: {
                    Image(systemName: "trash")
                }
            }
            .padding(8)
            .background(.regularMaterial)
            .cornerRadius(10)
        }
        
    }
}

#Preview {
    @State var previewOpponent = Opponent(name: "Goblin", damageDealt: 0)
    return OpponentView(opponent: $previewOpponent, didDelete: {
        print("Opponent deleted")
    }, didUpdateDamage: { newDamage in
        print("Damage updated to \(newDamage)")
    })
}
