import SwiftUI

struct HomeFeaturedHeroView: View {
    let tournament: Tournament

    private var currentRound: Int {
        let rounds = tournament.matches.map(\.round)
        let pending = tournament.matches.filter { !$0.isComplete }.map(\.round)
        return pending.min() ?? rounds.max() ?? 1
    }

    private var winner: String? {
        TiebreakCalculator.standings(for: tournament).first?.player.name
    }

    private var nextActionLabel: String {
        switch tournament.status {
        case .live: return "View pairings"
        case .upcoming: return tournament.matches.isEmpty ? "Generate schedule" : "View pairings"
        case .finished: return "View final standings"
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            ZStack(alignment: .topTrailing) {
                ZStack(alignment: .bottomLeading) {
                    Image("ChessBackdrop")
                        .resizable()
                        .scaledToFill()
                        .frame(height: 180)
                        .clipped()

                    LinearGradient(
                        colors: [Color.podiumCharcoal.opacity(0.05), Color.podiumCharcoal.opacity(0.45), Color.podiumCharcoal.opacity(0.97)],
                        startPoint: .top, endPoint: .bottom
                    )
                    .frame(height: 180)

                    VStack(alignment: .leading, spacing: 4) {
                        Text("FEATURED TOURNAMENT")
                            .font(.caption2.weight(.bold))
                            .foregroundStyle(Color.podiumCopper)
                            .tracking(0.6)
                        Text(tournament.name)
                            .font(.title2.weight(.bold))
                            .foregroundStyle(.white)
                            .lineLimit(1)

                        switch tournament.status {
                        case .live:
                            Label("Round \(currentRound) · \(tournament.players.count) players", systemImage: "flag.checkered")
                        case .upcoming:
                            HStack(spacing: 10) {
                                if !tournament.location.isEmpty {
                                    Label(tournament.location, systemImage: "mappin.and.ellipse")
                                }
                                Label(tournament.date.formatted(date: .abbreviated, time: .omitted), systemImage: "calendar")
                            }
                        case .finished:
                            if let winner {
                                Label("\(winner) wins", systemImage: "crown.fill")
                            }
                        }
                    }
                    .font(.caption)
                    .foregroundStyle(.white.opacity(0.85))
                    .padding(.horizontal, 20)
                    .padding(.bottom, 14)
                }

                Text(tournament.status.rawValue.uppercased())
                    .font(.caption2.weight(.bold))
                    .foregroundStyle(.white)
                    .padding(.horizontal, 11)
                    .padding(.vertical, 5)
                    .background(.ultraThinMaterial.opacity(0.9), in: Capsule())
                    .environment(\.colorScheme, .dark)
                    .padding(12)
            }
            .frame(height: 180)

            NavigationLink(value: tournament) {
                HStack {
                    Text(nextActionLabel)
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(.white)
                    Spacer()
                    Image(systemName: "arrow.right")
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(Color.podiumCopper)
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 15)
            }
            .overlay(Rectangle().fill(.white.opacity(0.07)).frame(height: 1), alignment: .bottom)
        }
    }
}
