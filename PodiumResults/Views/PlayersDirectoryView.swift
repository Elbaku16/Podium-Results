import SwiftUI
import SwiftData

// resumen de un jugador a traves de todos los torneos en los que aparece (se identifican por nombre,
// los Player de swiftdata viven dentro de cada torneo, no hay un jugador "global" en el modelo)
private struct PlayerSummary: Identifiable {
    let name: String
    let tournamentNames: [String]
    let wins: Int
    let completedMatches: Int
    var id: String { name }

    var winRate: Int {
        guard completedMatches > 0 else { return 0 }
        return Int((Double(wins) / Double(completedMatches) * 100).rounded())
    }
}

struct PlayersDirectoryView: View {
    @Query private var tournaments: [Tournament]
    @State private var searchText = ""
    @State private var selectedSummary: PlayerSummary?

    private var summaries: [PlayerSummary] {
        let allPlayers = tournaments.flatMap { tournament in
            tournament.players.map { (player: $0, tournament: tournament) }
        }
        let grouped = Dictionary(grouping: allPlayers, by: { $0.player.name })

        return grouped.map { name, entries in
            var wins = 0
            var completed = 0
            for (player, tournament) in entries {
                let playerMatches = tournament.matches.filter {
                    $0.isComplete && ($0.player1?.id == player.id || $0.player2?.id == player.id)
                }
                completed += playerMatches.count
                wins += playerMatches.filter {
                    ($0.player1?.id == player.id && $0.score1 > $0.score2) ||
                    ($0.player2?.id == player.id && $0.score2 > $0.score1)
                }.count
            }
            return PlayerSummary(name: name, tournamentNames: entries.map { $0.tournament.name }, wins: wins, completedMatches: completed)
        }
        .sorted { $0.wins != $1.wins ? $0.wins > $1.wins : $0.name < $1.name }
    }

    private var filtered: [PlayerSummary] {
        summaries.filter { searchText.isEmpty || $0.name.localizedCaseInsensitiveContains(searchText) }
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Color.podiumCharcoal.ignoresSafeArea()

                ScrollView {
                    VStack(alignment: .leading, spacing: 18) {
                        Text("Players")
                            .font(.system(size: 30, weight: .bold, design: .rounded))
                            .foregroundStyle(.white)
                            .padding(.top, 8)

                        searchField

                        if filtered.isEmpty {
                            emptyState.padding(.top, 40).frame(maxWidth: .infinity)
                        } else {
                            VStack(spacing: 0) {
                                ForEach(Array(filtered.enumerated()), id: \.element.id) { index, summary in
                                    Button { selectedSummary = summary } label: {
                                        row(summary, rank: index)
                                    }
                                    .buttonStyle(.plain)
                                    if index != filtered.count - 1 {
                                        Divider().overlay(Color.podiumEspresso.opacity(0.1))
                                    }
                                }
                            }
                            .background(Color.podiumCream)
                            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                        }
                    }
                    .padding(16)
                    .padding(.bottom, 20)
                }
            }
        }
        .tint(.podiumCopper)
        .sheet(item: $selectedSummary) { summary in
            summarySheet(summary)
        }
    }

    private var searchField: some View {
        HStack(spacing: 8) {
            Image(systemName: "magnifyingglass")
                .foregroundStyle(Color.podiumEspresso.opacity(0.5))
            TextField("Search players...", text: $searchText)
                .font(.subheadline)
                .foregroundStyle(Color.podiumEspresso)
                .autocorrectionDisabled()
        }
        .padding(.vertical, 11)
        .padding(.horizontal, 14)
        .background(Color.podiumCream)
        .clipShape(Capsule())
    }

    private func row(_ summary: PlayerSummary, rank: Int) -> some View {
        HStack(spacing: 12) {
            if let medal = medalColor(for: rank), summary.wins > 0 {
                Image(systemName: "medal.fill")
                    .foregroundStyle(medal)
                    .frame(width: 22)
            } else {
                Text("\(rank + 1)")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.secondary)
                    .frame(width: 22)
            }
            PlayerAvatar(name: summary.name, size: 38)
            VStack(alignment: .leading, spacing: 3) {
                Text(summary.name)
                    .font(.headline)
                    .foregroundStyle(Color.podiumEspresso)
                Text("\(summary.tournamentNames.count) tournament\(summary.tournamentNames.count == 1 ? "" : "s") · \(summary.wins) wins")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            Spacer()
            Image(systemName: "chevron.right")
                .font(.caption.weight(.semibold))
                .foregroundStyle(Color.podiumEspresso.opacity(0.3))
        }
        .padding(14)
    }

    private func medalColor(for rank: Int) -> Color? {
        switch rank {
        case 0: return .boardGold
        case 1: return .boardSilver
        case 2: return .boardBronze
        default: return nil
        }
    }

    private func summarySheet(_ summary: PlayerSummary) -> some View {
        NavigationStack {
            ZStack {
                Color.podiumCharcoal.ignoresSafeArea()
                VStack(spacing: 20) {
                    VStack(spacing: 10) {
                        PlayerAvatar(name: summary.name, size: 64)
                        Text(summary.name)
                            .font(.title2.weight(.bold))
                            .foregroundStyle(.white)
                    }
                    .padding(.top, 8)

                    HStack(spacing: 0) {
                        summaryStat(value: "\(summary.tournamentNames.count)", label: "Tournaments")
                        Rectangle().fill(.white.opacity(0.08)).frame(width: 1, height: 36)
                        summaryStat(value: "\(summary.wins)", label: "Wins")
                        Rectangle().fill(.white.opacity(0.08)).frame(width: 1, height: 36)
                        summaryStat(value: "\(summary.winRate)%", label: "Win Rate")
                    }

                    VStack(alignment: .leading, spacing: 4) {
                        SectionHeading(title: "Recent Tournaments")
                        VStack(spacing: 0) {
                            ForEach(summary.tournamentNames, id: \.self) { name in
                                HStack {
                                    Text(name)
                                        .font(.subheadline)
                                        .foregroundStyle(.white)
                                    Spacer()
                                }
                                .padding(.vertical, 10)
                                if name != summary.tournamentNames.last {
                                    Divider().overlay(.white.opacity(0.07))
                                }
                            }
                        }
                    }

                    Spacer()
                }
                .padding(20)
            }
            .navigationBarTitleDisplayMode(.inline)
        }
        .presentationDetents([.medium, .large])
    }

    private func summaryStat(value: String, label: String) -> some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.title3.weight(.bold))
                .foregroundStyle(.white)
            Text(label)
                .font(.caption2)
                .foregroundStyle(Color.podiumMuted)
        }
        .frame(maxWidth: .infinity)
    }

    private var emptyState: some View {
        VStack(spacing: 8) {
            Image(systemName: "person.2.fill")
                .font(.system(size: 38))
                .foregroundStyle(Color.podiumCopper)
            Text("No Players Yet")
                .font(.headline)
                .foregroundStyle(.white)
            Text("Players show up here once you add them to a tournament.")
                .font(.subheadline)
                .foregroundStyle(.white.opacity(0.5))
                .multilineTextAlignment(.center)
        }
    }
}

#Preview {
    PlayersDirectoryView()
        .modelContainer(for: [Tournament.self, Player.self, Match.self], inMemory: true)
}

