import SwiftUI

struct TournamentStandingsTabView: View {
    let standings: [TiebreakCalculator.Standing]
    @Binding var selectedPlayer: Player?

    var body: some View {
        VStack(spacing: 0) {
            ForEach(Array(standings.enumerated()), id: \.element.id) { index, standing in
                Button {
                    selectedPlayer = standing.player
                } label: {
                    row(standing, index: index)
                }
                .buttonStyle(.plain)
                if standing.id != standings.last?.id {
                    Divider().overlay(.white.opacity(0.07))
                }
            }
        }
        .background(Color.white.opacity(0.06))
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
    }

    private func row(_ standing: TiebreakCalculator.Standing, index: Int) -> some View {
        HStack(spacing: 12) {
            if let medal = medalColor(for: index) {
                Image(systemName: "medal.fill")
                    .foregroundStyle(medal)
                    .frame(width: 20)
            } else {
                Text("\(index + 1)")
                    .foregroundStyle(Color.podiumMuted)
                    .frame(width: 20)
            }
            PlayerAvatar(name: standing.player.name, size: 28)
            VStack(alignment: .leading, spacing: 1) {
                Text(standing.player.name)
                    .foregroundStyle(.white)
                    .lineLimit(1)
                Text("SB \(standing.sonnebornBerger.scoreText) · Koya \(standing.koya.scoreText) · \(standing.wins)W")
                    .font(.caption2)
                    .foregroundStyle(Color.podiumMuted)
                    .lineLimit(1)
            }
            Spacer(minLength: 8)
            Text(standing.score.scoreText)
                .fontWeight(.semibold)
                .foregroundStyle(medalColor(for: index) ?? .white)
        }
        .padding(14)
    }

    private func medalColor(for index: Int) -> Color? {
        switch index {
        case 0: return .boardGold
        case 1: return .boardSilver
        case 2: return .boardBronze
        default: return nil
        }
    }
}
