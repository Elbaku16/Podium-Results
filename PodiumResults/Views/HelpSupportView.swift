import SwiftUI

struct HelpSupportView: View {
    private let questions: [(String, String)] = [
        ("How do I create a tournament?",
         "Tap + on Home or Tournaments, enter a name, add at least two players and tap Save. Then open the tournament and select Generate Schedule to create the rounds."),
        ("How are the pairings made?",
         "In a round robin tournament every player plays every other player once. In a Swiss tournament you pair one round at a time: players with a similar score face each other and nobody plays the same opponent twice. When the number of players is odd, one player rests each round and receives a bye."),
        ("How do I enter or change a result?",
         "Open the Pairings tab and select a game, then choose a win for either player or a draw. To change a result, select the game again and update it. The standings update automatically."),
        ("Can I add a player after the tournament has started?",
         "Yes. Select Add Player in the Information tab. The player joins in the next round, and rounds already played are not changed. For each round missed, the player receives half a point or no points, depending on your Preferences. In a Swiss tournament, players can join until the last round is paired."),
        ("How are ties broken in the standings?",
         "Players with the same score are ranked with the FIDE tie-break rules (C.07). First the direct encounter, which is the result of the games between the tied players. In round robin, then Koya, Sonneborn-Berger and wins. In Swiss, then Buchholz, Sonneborn-Berger and wins."),
        ("How do I share a tournament online?",
         "Select Publish Online in the Information tab to save a copy that others can follow. The copy updates when results change. Select Remove from Online at any time to delete it."),
        ("How do I export the results?",
         "Open the Information tab and select Export Results (PDF). The file includes the standings and the pairings of every round. You can save it, print it or send it to other people."),
        ("How do I turn on notifications?",
         "Go to Profile, then Preferences, and turn on Phone alerts. You will be notified when a round or a tournament ends."),
        ("How do I delete my account?",
         "Go to Profile, then Personal Information, and select Delete Account. Your account and your online tournaments are deleted. Tournaments saved on your device are not affected."),
    ]

    @State private var openIndex: Int?

    var body: some View {
        SettingsScreen(title: "Help & Support") {
            SettingsGroup(title: "Frequently asked questions") {
                ForEach(Array(questions.enumerated()), id: \.offset) { index, item in
                    question(index: index, title: item.0, answer: item.1)
                    if index != questions.count - 1 { SettingsDivider(inset: 0) }
                }
            }

            SettingsGroup(title: "Contact") {
                Link(destination: URL(string: "https://github.com/Elbaku16/Podium-Results/issues/new")!) {
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
