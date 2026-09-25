import SwiftUI

struct OpponentRowView: View {
    let entry: Opponent
    var didDelete: () -> Void
    var didChange: (Int) -> Void

    var displayName: String { entry.name ?? "Unnamed Opponent" }
    var damage: Int { entry.damageDealt }

    var body: some View {
        HStack {
            Text(displayName)
                .font(.headline)
            Spacer()
            Button(action: { didChange(max(0, damage - 1)) }) {
                Image(systemName: "minus.circle")
                    .font(.system(size: 24))
            }
            Text("\(damage)")
                .font(.title3)
                .monospacedDigit()
                .frame(minWidth: 36)
            Button(action: { didChange(damage + 1) }) {
                Image(systemName: "plus.circle")
                    .font(.system(size: 24))
            }
            Button("+1") { didChange(damage + 1) }
                .buttonStyle(.bordered)
            Button("+5") { didChange(damage + 5) }
                .buttonStyle(.borderedProminent)
            Button(role: .destructive) { didDelete() } label: {
                Image(systemName: "trash")
            }
        }
        .padding(8)
        .background(.regularMaterial)
        .cornerRadius(10)
    }
}
#Preview {
    OpponentRowView(entry: Opponent(name: "Goblin", damageDealt: 0), didDelete: {
        print("Opponent deleted")
    }, didChange: { newDamage in
        print("Damage updated to \(newDamage)")
    })
}
