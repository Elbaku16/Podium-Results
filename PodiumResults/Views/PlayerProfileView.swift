import SwiftUI

struct PlayerProfileView: View {
    let player: Player
    let tournament: Tournament

    @Environment(\.dismiss) private var dismiss

    private var playerMatches: [Match] {
        tournament.matches
            .filter { $0.player1?.id == player.id || $0.player2?.id == player.id }
            .sorted { $0.round < $1.round }
    }

    private func myScore(_ match: Match) -> Double? {
        if match.player1?.id == player.id { return match.score1 }
        if match.player2?.id == player.id { return match.score2 }
        return nil
    }

    private func opponentScore(_ match: Match) -> Double? {
        if match.player1?.id == player.id { return match.score2 }
        if match.player2?.id == player.id { return match.score1 }
        return nil
    }

    private func opponent(_ match: Match) -> Player? {
        match.player1?.id == player.id ? match.player2 : match.player1
    }

    private var wins: Int {
        playerMatches.filter { $0.isComplete && (myScore($0) ?? 0) > (opponentScore($0) ?? 0) }.count
    }
    private var losses: Int {
        playerMatches.filter { $0.isComplete && (myScore($0) ?? 0) < (opponentScore($0) ?? 0) }.count
    }
    private var draws: Int {
        playerMatches.filter { $0.isComplete && myScore($0) == opponentScore($0) }.count
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Color.podiumCharcoal.ignoresSafeArea()
                ScrollView {
                    VStack(spacing: 16) {
                        VStack(spacing: 10) {
                            PlayerAvatar(name: player.name, size: 72)
                            Text(player.name)
                                .font(.title2.weight(.bold))
                                .foregroundStyle(.white)
                            HStack(spacing: 24) {
                                statPill(value: wins, label: "Wins")
                                statPill(value: losses, label: "Losses")
                                if draws > 0 {
                                    statPill(value: draws, label: "Draws")
                                }
                            }
                            .padding(.top, 4)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.top, 8)

                        if !playerMatches.isEmpty {
                            VStack(alignment: .leading, spacing: 8) {
                                SectionHeading(title: "Matches")
                                VStack(spacing: 0) {
                                    ForEach(playerMatches) { match in
                                        HStack {
                                            Text("R\(match.round)")
                                                .font(.caption)
                                                .foregroundStyle(Color.podiumMuted)
                                                .frame(width: 28, alignment: .leading)
                                            Text(opponent(match)?.name ?? "BYE")
                                                .foregroundStyle(.white)
                                            Spacer()
                                            if match.isComplete, let mine = myScore(match), let theirs = opponentScore(match) {
                                                Text("\(mine.scoreText) - \(theirs.scoreText)")
                                                    .fontWeight(.semibold)
                                                    .foregroundStyle(mine > theirs ? Color.podiumCopper : (mine == theirs ? Color.podiumMuted : .red))
                                            } else {
                                                Text("Pending")
                                                    .font(.caption)
                                                    .foregroundStyle(Color.podiumMuted)
                                            }
                                        }
                                        .padding(.vertical, 10)
                                        if match.id != playerMatches.last?.id {
                                            Divider().overlay(.white.opacity(0.07))
                                        }
                                    }
                                }
                            }
                        }
                    }
                    .padding(16)
                }
            }
            .navigationTitle("Player")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(Color.podiumCharcoal, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }
                }
            }
        }
        .tint(.podiumCopper)
    }

    private func statPill(value: Int, label: String) -> some View {
        VStack(spacing: 2) {
            Text("\(value)")
                .font(.title3.weight(.bold))
                .foregroundStyle(Color.podiumCopper)
            Text(label)
                .font(.caption)
                .foregroundStyle(Color.podiumMuted)
        }
    }
}

