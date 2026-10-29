import SwiftUI
import SwiftData

struct HomeDashboardView: View {
    @Query(sort: \Tournament.date, order: .reverse) private var tournaments: [Tournament]
    @State private var isShowingNewTournament = false
    @State private var isShowingNotifications = false

    private var greeting: String {
        switch Calendar.current.component(.hour, from: .now) {
        case 0..<12: return "Good morning"
        case 12..<18: return "Good afternoon"
        default: return "Good evening"
        }
    }

    private var featured: Tournament? {
        tournaments.first { $0.status == .live }
            ?? tournaments.first { $0.status == .upcoming }
            ?? tournaments.first { $0.status == .finished }
    }

    private var upcoming: [Tournament] {
        tournaments.filter { $0.id != featured?.id && $0.status != .finished }
    }

    private var recentActivity: [HomeActivityItem] {
        tournaments.compactMap { tournament -> HomeActivityItem? in
            guard tournament.id != featured?.id else { return nil }
            switch tournament.status {
            case .finished:
                return HomeActivityItem(tournament: tournament, icon: "checkmark.seal.fill", message: "Results published")
            case .live:
                return HomeActivityItem(tournament: tournament, icon: "square.grid.2x2.fill", message: "Pairings available")
            case .upcoming:
                return nil
            }
        }
        .prefix(4)
        .map { $0 }
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Color.podiumCharcoal.ignoresSafeArea()

                ScrollView {
                    VStack(alignment: .leading, spacing: 0) {
                        header
                            .padding(.horizontal, 20)
                            .padding(.top, 8)
                            .padding(.bottom, 16)

                        if tournaments.isEmpty {
                            HomeEmptyHeroView(onCreateTournament: { isShowingNewTournament = true })
                        } else {
                            if let featured {
                                HomeFeaturedHeroView(tournament: featured)
                            }

                            VStack(alignment: .leading, spacing: 24) {
                                if !recentActivity.isEmpty {
                                    HomeRecentActivityView(items: recentActivity)
                                }

                                if !upcoming.isEmpty {
                                    VStack(alignment: .leading, spacing: 8) {
                                        SectionHeading(title: "Upcoming Tournaments")
                                        VStack(spacing: 0) {
                                            ForEach(Array(upcoming.enumerated()), id: \.element.id) { index, tournament in
                                                NavigationLink(value: tournament) {
                                                    TournamentRow(tournament: tournament)
                                                }
                                                .buttonStyle(.plain)
                                                if index != upcoming.count - 1 {
                                                    Divider().overlay(.white.opacity(0.07))
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                            .padding(.horizontal, 20)
                            .padding(.top, 22)
                        }
                    }
                    .padding(.bottom, 24)
                }
                .navigationDestination(for: Tournament.self) { tournament in
                    TournamentDetailView(tournament: tournament)
                }
            }
        }
        .tint(.podiumCopper)
        .sheet(isPresented: $isShowingNewTournament) {
            NewTournamentView()
        }
        .sheet(isPresented: $isShowingNotifications) {
            NotificationsView()
        }
    }

    private var header: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: 2) {
                Text(greeting)
                    .font(.subheadline)
                    .foregroundStyle(Color.podiumMuted)
                Text("Welcome back")
                    .font(.title2.weight(.bold))
                    .foregroundStyle(.white)
            }
            Spacer()
            HStack(spacing: 10) {
                Button {
                    isShowingNewTournament = true
                } label: {
                    Image(systemName: "plus")
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundStyle(.white)
                        .frame(width: 36, height: 36)
                        .background(Color.podiumCopper)
                        .clipShape(Circle())
                }
                Button {
                    isShowingNotifications = true
                } label: {
                    Image(systemName: "bell.fill")
                        .font(.system(size: 15))
                        .foregroundStyle(.white.opacity(0.85))
                        .frame(width: 36, height: 36)
                        .background(Color.white.opacity(0.06))
                        .clipShape(Circle())
                }
            }
        }
    }
}

#Preview {
    HomeDashboardView()
        .modelContainer(for: [Tournament.self, Player.self, Match.self], inMemory: true)
}
