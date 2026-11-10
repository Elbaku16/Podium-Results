import SwiftUI

struct TournamentPairingsTabView: View {
    let tournament: Tournament
    let rounds: [Int]
    @Binding var selectedRound: Int?
    let currentRound: Int
    @Binding var matchBeingScored: Match?

    private var roundMatches: [Match] {
        tournament.matches
            .filter { $0.round == currentRound }
            .sorted { ($0.player1?.name ?? "") < ($1.player1?.name ?? "") }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            if rounds.isEmpty {
                Text("No rounds yet. Generate the schedule from the Information tab.")
                    .font(.subheadline)
                    .foregroundStyle(.white.opacity(0.6))
                    .frame(maxWidth: .infinity)
                    .padding(.top, 30)
            } else {
                roundPicker
                columnHeader
                matchList
            }
        }
    }

    private var roundPicker: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(rounds, id: \.self) { round in
                    Button {
                        selectedRound = round
                    } label: {
                        Text("Round \(round)")
                            .font(.caption.weight(.semibold))
                            .padding(.vertical, 7)
                            .padding(.horizontal, 14)
                            .foregroundStyle(currentRound == round ? .white : .white.opacity(0.7))
                            .background(currentRound == round ? Color.podiumCopper : Color.white.opacity(0.08))
                            .clipShape(Capsule())
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    private var columnHeader: some View {
        HStack {
            Text("Table").frame(width: 44, alignment: .leading)
            Text("White").frame(maxWidth: .infinity, alignment: .leading)
            Text("Black").frame(maxWidth: .infinity, alignment: .leading)
            Text("Result").frame(width: 56, alignment: .trailing)
        }
        .font(.caption2.weight(.semibold))
        .foregroundStyle(.white.opacity(0.4))
        .padding(.horizontal, 14)
    }

    private var matchList: some View {
        VStack(spacing: 0) {
            ForEach(Array(roundMatches.enumerated()), id: \.element.id) { index, match in
                matchRow(match, table: index + 1)
                if match.id != roundMatches.last?.id {
                    Divider().overlay(.white.opacity(0.07))
                }
            }
        }
        .background(Color.white.opacity(0.06))
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
    }

    @ViewBuilder
    private func matchRow(_ match: Match, table: Int) -> some View {
        let name1 = match.player1?.name ?? "-"
        if let player2 = match.player2 {
            Button {
                matchBeingScored = match
            } label: {
                HStack(spacing: 8) {
                    Text("\(table)")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(Color.podiumMuted)
                        .frame(width: 44, alignment: .leading)

                    Text(name1)
                        .font(.subheadline)
                        .foregroundStyle(.white)
                        .lineLimit(1)
                        .frame(maxWidth: .infinity, alignment: .leading)

                    Text(player2.name)
                        .font(.subheadline)
                        .foregroundStyle(.white)
                        .lineLimit(1)
                        .frame(maxWidth: .infinity, alignment: .leading)

                    Group {
                        if match.isComplete {
                            Text("\(match.score1.scoreText)-\(match.score2.scoreText)")
                                .foregroundStyle(Color.podiumCopper)
                        } else {
                            Text("vs")
                                .foregroundStyle(Color.podiumMuted)
                        }
                    }
                    .font(.subheadline.weight(.semibold))
                    .frame(width: 56, alignment: .trailing)
                }
            }
            .buttonStyle(.plain)
            .padding(14)
        } else {
            HStack(spacing: 8) {
                Text("\(table)")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(Color.podiumMuted)
                    .frame(width: 44, alignment: .leading)
                Text(name1)
                    .font(.subheadline)
                    .foregroundStyle(.white)
                    .lineLimit(1)
                    .frame(maxWidth: .infinity, alignment: .leading)
                Text("BYE")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(Color.podiumMuted)
                    .frame(width: 56 + 56, alignment: .trailing)
            }
            .padding(14)
        }
    }
}
