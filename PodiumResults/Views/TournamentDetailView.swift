import SwiftUI
import SwiftData

struct TournamentDetailView: View {
    @Bindable var tournament: Tournament
    @Environment(\.modelContext) private var modelContext
    @State private var matchBeingScored: Match?
    @State private var selectedPlayer: Player?
    @State private var selectedRound: Int?
    @State private var showConfetti = false
    @State private var isShowingAddPlayer = false
    @State private var selectedTab: DetailTab

    enum DetailTab: String, CaseIterable {
        case info = "Information"
        case pairings = "Pairings"
        case standings = "Standings"
    }

    init(tournament: Tournament) {
        self.tournament = tournament
        let initialTab: DetailTab
        switch tournament.status {
        case .finished: initialTab = .standings
        case .live: initialTab = .pairings
        case .upcoming: initialTab = tournament.matches.isEmpty ? .info : .pairings
        }
        _selectedTab = State(initialValue: initialTab)
    }

    private var viewModel: TournamentDetailViewModel {
        TournamentDetailViewModel(modelContext: modelContext)
    }

    private var rounds: [Int] {
        Array(Set(tournament.matches.map(\.round))).sorted()
    }

    private var standings: [TiebreakCalculator.Standing] {
        TiebreakCalculator.standings(for: tournament)
    }

    private var nextMatch: Match? {
        tournament.matches
            .filter { !$0.isComplete && $0.player2 != nil }
            .sorted { $0.round < $1.round }
            .first
    }

    private var currentRound: Int {
        selectedRound ?? nextMatch?.round ?? rounds.last ?? 1
    }

    var body: some View {
        ZStack {
            Color.podiumCharcoal.ignoresSafeArea()

            VStack(spacing: 0) {
                coverHeader
                tabSelector

                ScrollView {
                    VStack(spacing: 16) {
                        switch selectedTab {
                        case .info:
                            TournamentInfoTabView(
                                tournament: tournament,
                                rounds: rounds,
                                currentRound: currentRound,
                                onGenerateSchedule: { viewModel.generateSchedule(for: tournament) },
                                onViewPairings: { selectedTab = .pairings },
                                onAddPlayer: { isShowingAddPlayer = true }
                            )
                        case .pairings:
                            TournamentPairingsTabView(
                                tournament: tournament,
                                rounds: rounds,
                                selectedRound: $selectedRound,
                                currentRound: currentRound,
                                matchBeingScored: $matchBeingScored
                            )
                        case .standings:
                            TournamentStandingsTabView(standings: standings, selectedPlayer: $selectedPlayer)
                        }
                    }
                    .padding(16)
                }
            }

            if showConfetti {
                ConfettiView()
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(Color.podiumCharcoal, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .toolbarColorScheme(.dark, for: .navigationBar)
        .tint(.podiumCopper)
        .sheet(item: $matchBeingScored) { match in
            ScoreEntryView(match: match) { score1, score2 in
                viewModel.recordResult(for: match, score1: score1, score2: score2)
                showConfetti = true
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) { showConfetti = false }
            }
        }
        .sheet(isPresented: $isShowingAddPlayer) {
            AddPlayerView(
                existingNames: tournament.players.map(\.name),
                hasSchedule: !tournament.matches.isEmpty
            ) { name in
                viewModel.addPlayer(named: name, to: tournament)
            }
        }
        .sheet(item: $selectedPlayer) { player in
            PlayerProfileView(player: player, tournament: tournament)
        }
    }

    private var coverHeader: some View {
        ZStack(alignment: .topTrailing) {
            ZStack(alignment: .bottomLeading) {
                Image("ChessBackdrop")
                    .resizable()
                    .scaledToFill()
                    .frame(height: 170)
                    .clipped()

                LinearGradient(
                    colors: [.clear, Color.podiumCharcoal.opacity(0.95)],
                    startPoint: .top, endPoint: .bottom
                )
                .frame(height: 170)

                VStack(alignment: .leading, spacing: 4) {
                    Text(tournament.name)
                        .font(.title2.weight(.bold))
                        .foregroundStyle(.white)
                    HStack(spacing: 10) {
                        if !tournament.location.isEmpty {
                            Label(tournament.location, systemImage: "mappin.and.ellipse")
                        }
                        Label(tournament.date.formatted(date: .abbreviated, time: .omitted), systemImage: "calendar")
                        Label("\(tournament.players.count)", systemImage: "person.2.fill")
                    }
                    .font(.caption)
                    .foregroundStyle(.white.opacity(0.8))
                }
                .padding(16)
            }

            StatusLabel(status: tournament.status)
                .padding(14)
        }
        .frame(height: 170)
    }

    private var tabSelector: some View {
        HStack(spacing: 8) {
            ForEach(DetailTab.allCases, id: \.self) { tab in
                Button {
                    selectedTab = tab
                } label: {
                    Text(tab.rawValue)
                        .font(.caption.weight(.semibold))
                        .padding(.vertical, 8)
                        .frame(maxWidth: .infinity)
                        .foregroundStyle(selectedTab == tab ? Color.podiumEspresso : .white.opacity(0.7))
                        .background(selectedTab == tab ? Color.podiumCream : Color.white.opacity(0.08))
                        .clipShape(Capsule())
                }
                .buttonStyle(.plain)
            }
        }
        .padding(16)
        .background(Color.podiumCharcoal)
    }
}

#Preview {
    NavigationStack {
        TournamentDetailView(tournament: Tournament(name: "Preview Tournament"))
    }
    .modelContainer(for: [Tournament.self, Player.self, Match.self], inMemory: true)
}
