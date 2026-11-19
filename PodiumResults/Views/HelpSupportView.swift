import SwiftUI

struct HelpSupportView: View {
    private let questions: [(String, String)] = [
        ("How do I create a tournament?",
         "Tap + on Home or Tournaments, write a name, add at least two players and save. Then open the tournament and tap Generate Schedule."),
        ("How are the pairings made?",
         "The tournament is round robin: everybody plays everybody once. If the number of players is odd, one player rests each round and gets a bye."),
        ("How do I enter or fix a result?",
         "Open the Pairings tab and tap a game. Pick who won or a draw. If you made a mistake, tap the game again and change it. The points are updated."),
        ("What if a player arrives late?",
         "Tap Add Player. He joins in the next round and the rounds already played don't change. For the rounds he missed he gets half a point or no points, you choose."),
        ("How do the standings break ties?",
         "By direct encounter, then Koya, then Sonneborn-Berger, then number of wins."),
        ("What does Publish Online do?",
         "It saves a copy of the tournament online so others can follow it. It updates by itself when you save results. You can remove it anytime with Remove from Online."),
    ]

    @State private var openIndex: Int?

    var body: some View {
        SettingsScreen(title: "Help & Support") {
            SettingsGroup(title: "Common questions") {
                ForEach(Array(questions.enumerated()), id: \.offset) { index, item in
                    question(index: index, title: item.0, answer: item.1)
                    if index != questions.count - 1 { SettingsDivider(inset: 0) }
                }
            }

            SettingsGroup(title: "Need more help?", footer: "Opens the project page on GitHub. You need a GitHub account to write there.") {
                Link(destination: URL(string: "https://github.com/Elbaku16/Podium-Results/issues")!) {
                    HStack(spacing: 12) {
                        SettingsIcon(name: "exclamationmark.bubble.fill")
                        Text("Report a problem")
                            .font(.body)
                            .foregroundStyle(.white)
                        Spacer()
                        Image(systemName: "arrow.up.right")
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(Color.podiumMuted.opacity(0.6))
                    }
                    .padding(.vertical, 12)
                }
            }
        }
    }

    private func question(index: Int, title: String, answer: String) -> some View {
        let isOpen = openIndex == index
        return VStack(alignment: .leading, spacing: 8) {
            Button {
                withAnimation(.easeInOut(duration: 0.2)) { openIndex = isOpen ? nil : index }
            } label: {
                HStack(spacing: 12) {
                    Text(title)
                        .font(.body)
                        .foregroundStyle(.white)
                        .multilineTextAlignment(.leading)
                    Spacer(minLength: 8)
                    Image(systemName: "chevron.down")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(Color.podiumMuted)
                        .rotationEffect(.degrees(isOpen ? 180 : 0))
                }
                .padding(.vertical, 12)
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)

            if isOpen {
                Text(answer)
                    .font(.subheadline)
                    .foregroundStyle(Color.podiumMuted)
                    .padding(.bottom, 12)
            }
        }
    }
}
