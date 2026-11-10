import SwiftUI
import SwiftData

enum TournamentSort: String, CaseIterable, Identifiable {
    case newest = "Newest first"
    case oldest = "Oldest first"
    case name = "Name"

    var id: String { rawValue }

    var descriptors: [SortDescriptor<Tournament>] {
        switch self {
        case .newest: return [SortDescriptor(\.date, order: .reverse)]
        case .oldest: return [SortDescriptor(\.date)]
        case .name: return [SortDescriptor(\.name)]
        }
    }
}

struct TournamentResultsView: View {
    @Query private var tournaments: [Tournament]
    let searchText: String
    let statusFilter: TournamentStatus?

    init(searchText: String, sortOption: TournamentSort, statusFilter: TournamentStatus?) {
        self.searchText = searchText
        self.statusFilter = statusFilter
        let predicate = #Predicate<Tournament> {
            searchText.isEmpty || $0.name.localizedStandardContains(searchText)
        }
        _tournaments = Query(filter: predicate, sort: sortOption.descriptors)
    }

    private var visible: [Tournament] {
        tournaments.filter { statusFilter == nil || $0.status == statusFilter }
    }

    var body: some View {
        if visible.isEmpty {
            noResultsState.padding(.top, 30).frame(maxWidth: .infinity)
        } else {
            VStack(alignment: .leading, spacing: 8) {
                Text("\(visible.count) tournament\(visible.count == 1 ? "" : "s")")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(Color.podiumMuted)

                VStack(spacing: 0) {
                    ForEach(Array(visible.enumerated()), id: \.element.id) { index, tournament in
                        NavigationLink(value: tournament) {
                            TournamentRow(tournament: tournament)
                        }
                        .buttonStyle(.plain)
                        if index != visible.count - 1 {
                            Divider().overlay(.white.opacity(0.07))
                        }
                    }
                }
            }
        }
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
    }
}
