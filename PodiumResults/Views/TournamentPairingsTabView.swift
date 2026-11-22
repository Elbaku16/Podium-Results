import SwiftUI

struct TournamentPairingsTabView: View {
    let tournament: Tournament
    let rounds: [Int]
    @Binding var selectedRound: Int?
    let currentRound: Int
    @Binding var matchBeingScored: Match?
    let onPairNextRound: () -> Void
    let onExport: () -> Void

    private var roundMatches: [Match] {
        tournament.matches
            .filter { $0.round == currentRound }
            .sorted {
                if $0.board != $1.board { return $0.board < $1.board }
                return ($0.player1?.name ?? "") < ($1.player1?.name ?? "")
            }
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
                roundAction
            }
        }
    }

    @ViewBuilder
    private var roundAction: some View {
        if let next = tournament.nextSwissRound, currentRound == tournament.latestRound {
            actionButton("Pair Round \(next)", icon: "arrow.triangle.2.circlepath", action: onPairNextRound)
        } else if tournament.status == .finished, currentRound == tournament.latestRound {
            actionButton("Export Results (PDF)", icon: "square.and.arrow.up", action: onExport)
        }
    }

    private func actionButton(_ title: String, icon: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Label(title, systemImage: icon)
                .font(.headline)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .foregroundStyle(.white)
                .background(Color.podiumCopper)
                .clipShape(Capsule())
        }
    }

    private func playerName(_ player: Player) -> some View {
        VStack(alignment: .leading, spacing: 1) {
            Text(player.name)
                .font(.subheadline)
                .foregroundStyle(.white)
                .lineLimit(2)
                .minimumScaleFactor(0.85)
            if currentRound > 1 {
                let points = tournament.points(of: player, before: currentRound)
                Text("\(points.scoreText) \(points > 0 && points <= 1 ? "pt" : "pts")")
                    .font(.caption2)
                    .foregroundStyle(Color.podiumMuted)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
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

                    if let player1 = match.player1 { playerName(player1) } else { Text(name1).frame(maxWidth: .infinity, alignment: .leading) }

                    playerName(player2)

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
                Text(match.score1 < 1 ? "MISSED \u{00B7} \(match.score1.scoreText)" : "BYE")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(Color.podiumMuted)
                    .frame(width: 56 + 56, alignment: .trailing)
            }
            .padding(14)
        }
    }
}
