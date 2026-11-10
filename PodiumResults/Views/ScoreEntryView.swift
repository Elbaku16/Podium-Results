import SwiftUI

struct ScoreEntryView: View {
    let match: Match
    let onSave: (Double, Double) -> Void

    @Environment(\.dismiss) private var dismiss

    @State private var outcomeScore1: Double
    @State private var outcomeScore2: Double
    @State private var hasPickedOutcome: Bool

    private var player1Name: String { match.player1?.name ?? "Player 1" }
    private var player2Name: String { match.player2?.name ?? "Player 2" }

    init(match: Match, onSave: @escaping (Double, Double) -> Void) {
        self.match = match
        self.onSave = onSave
        _outcomeScore1 = State(initialValue: match.isComplete ? match.score1 : 0)
        _outcomeScore2 = State(initialValue: match.isComplete ? match.score2 : 0)
        _hasPickedOutcome = State(initialValue: match.isComplete)
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Color.podiumCharcoal.ignoresSafeArea()

                ScrollView {
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Round \(match.round)".uppercased())
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(Color.podiumMuted)
                        outcomePicker(options: [
                            (player1Name, 1, 0),
                            ("Draw", 0.5, 0.5),
                            (player2Name, 0, 1),
                        ])
                    }
                    .padding(16)
                }
            }
            .navigationTitle(match.isComplete ? "Correct Result" : "Result")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(Color.podiumCharcoal, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        onSave(outcomeScore1, outcomeScore2)
                        dismiss()
                    }
                    .fontWeight(.semibold)
                    .disabled(!hasPickedOutcome)
                }
            }
        }
        .tint(.podiumCopper)
    }

    private func outcomePicker(options: [(label: String, s1: Double, s2: Double)]) -> some View {
        VStack(spacing: 10) {
            ForEach(options, id: \.label) { option in
                let isSelected = hasPickedOutcome && outcomeScore1 == option.s1 && outcomeScore2 == option.s2
                Button {
                    outcomeScore1 = option.s1
                    outcomeScore2 = option.s2
                    hasPickedOutcome = true
                } label: {
                    HStack {
                        Text(option.label)
                            .font(.headline)
                        Spacer()
                        if isSelected {
                            Image(systemName: "checkmark.circle.fill")
                        }
                    }
                    .foregroundStyle(.white)
                    .padding(16)
                    .background(isSelected ? Color.podiumCopper : Color.white.opacity(0.06))
                    .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                }
            }
        }
    }
}

