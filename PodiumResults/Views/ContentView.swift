import SwiftUI
import SwiftData

struct ContentView: View {
    @Query(sort: \Tournament.date, order: .reverse) private var tournaments: [Tournament]
    @State private var isShowingNewTournament = false
    @State private var isShowingNotifications = false
    @State private var searchText = ""
    @State private var selectedFilter: TournamentStatus?

    private var filteredTournaments: [Tournament] {
        tournaments
            .filter { selectedFilter == nil || $0.status == selectedFilter }
            .filter { searchText.isEmpty || $0.name.localizedCaseInsensitiveContains(searchText) }
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Color.podiumCharcoal.ignoresSafeArea()

                ScrollView {
                    VStack(alignment: .leading, spacing: 16) {
                        header
                        searchField

                        if tournaments.isEmpty {
                            emptyState
                                .padding(.top, 40)
                                .frame(maxWidth: .infinity)
                        } else {
                            filterPills
                            if filteredTournaments.isEmpty {
                                noResultsState.padding(.top, 30).frame(maxWidth: .infinity)
                            } else {
                                VStack(spacing: 0) {
                                    ForEach(Array(filteredTournaments.enumerated()), id: \.element.id) { index, tournament in
                                        NavigationLink(value: tournament) {
                                            TournamentRow(tournament: tournament)
                                        }
                                        .buttonStyle(.plain)
                                        if index != filteredTournaments.count - 1 {
                                            Divider().overlay(.white.opacity(0.07))
                                        }
                                    }
                                }
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 8)
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
            Text("Tournaments")
                .font(.title2.weight(.bold))
                .foregroundStyle(.white)
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
        .padding(.bottom, 4)
    }

    private var searchField: some View {
        HStack(spacing: 8) {
            Image(systemName: "magnifyingglass")
                .foregroundStyle(Color.podiumMuted)
            TextField("Search tournaments...", text: $searchText)
                .font(.subheadline)
                .foregroundStyle(.white)
                .tint(.white)
                .autocorrectionDisabled()
        }
        .padding(.vertical, 11)
        .padding(.horizontal, 14)
        .background(Color.white.opacity(0.06))
        .clipShape(Capsule())
    }

    private var filterPills: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                filterPill(title: "All", isSelected: selectedFilter == nil) { selectedFilter = nil }
                ForEach(TournamentStatus.allCases, id: \.self) { status in
                    filterPill(title: status.rawValue, isSelected: selectedFilter == status) {
                        selectedFilter = status
                    }
                }
            }
        }
    }

    private func filterPill(title: String, isSelected: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(title)
                .font(.caption.weight(.semibold))
                .padding(.vertical, 7)
                .padding(.horizontal, 14)
                .foregroundStyle(isSelected ? .white : .white.opacity(0.7))
                .background(isSelected ? Color.podiumCopper : Color.white.opacity(0.08))
                .clipShape(Capsule())
        }
        .buttonStyle(.plain)
    }

    private var emptyState: some View {
        VStack(spacing: 10) {
            Image(systemName: "trophy.fill")
                .font(.system(size: 44))
                .foregroundStyle(Color.podiumCopper)
            Text("No Tournaments Yet")
                .font(.title3.weight(.semibold))
                .foregroundStyle(.white)
            Text("Tap + to set up your players and get started.")
                .font(.subheadline)
                .foregroundStyle(.white.opacity(0.5))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 20)
        }
        .frame(maxWidth: .infinity)
    }

    private var noResultsState: some View {
        VStack(spacing: 6) {
            Text("No matches")
                .font(.headline)
                .foregroundStyle(.white)
            Text("Try a different search or filter.")
                .font(.subheadline)
                .foregroundStyle(.white.opacity(0.5))
        }
        .frame(maxWidth: .infinity)
    }
}

#Preview {
    ContentView()
        .modelContainer(for: [Tournament.self, Player.self, Match.self], inMemory: true)
}

