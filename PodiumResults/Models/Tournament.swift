import Foundation
import SwiftData
import SwiftUI

@Model
final class Tournament {
    var id: UUID
    var name: String
    var format: String
    var icon: String = "crown.fill"
    var date: Date
    var isFinished: Bool
    var location: String = ""
    var timeControl: String = ""
    var arbiter: String = ""
    var categories: String = ""

    @Relationship(deleteRule: .cascade, inverse: \Player.tournament)
    var players: [Player] = []

    @Relationship(deleteRule: .cascade, inverse: \Match.tournament)
    var matches: [Match] = []

    init(name: String, format: String = "Round Robin", date: Date = .now, isFinished: Bool = false,
         location: String = "", timeControl: String = "", arbiter: String = "", categories: String = "") {
        self.id = UUID()
        self.name = name
        self.format = format
        self.icon = "crown.fill"
        self.date = date
        self.isFinished = isFinished
        self.location = location
        self.timeControl = timeControl
        self.arbiter = arbiter
        self.categories = categories
    }
}

extension Tournament {
    var progress: Double {
        guard !matches.isEmpty else { return 0 }
        let done = matches.filter(\.isComplete).count
        return Double(done) / Double(matches.count)
    }

    // live solo cuenta si ya se jugo algo, tener el calendario generado no es lo mismo que haber empezado
    var status: TournamentStatus {
        if matches.isEmpty { return .upcoming }
        let completed = matches.filter(\.isComplete).count
        if completed == 0 { return .upcoming }
        return completed >= matches.count ? .finished : .live
    }
}

enum TournamentStatus: String, CaseIterable {
    case upcoming = "Upcoming"
    case live = "Live"
    case finished = "Finished"
}

