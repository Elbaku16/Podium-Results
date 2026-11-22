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
    var publishedAt: Date?
    var totalRounds: Int = 0

    @Relationship(deleteRule: .cascade, inverse: \Player.tournament)
    var players: [Player] = []

    @Relationship(deleteRule: .cascade, inverse: \Match.tournament)
    var matches: [Match] = []

    init(name: String, format: String = "Round Robin", date: Date = .now, isFinished: Bool = false,
         location: String = "", timeControl: String = "", arbiter: String = "", categories: String = "",
         totalRounds: Int = 0) {
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
        self.totalRounds = totalRounds
    }
}

extension Tournament {
    var progress: Double {
        guard !matches.isEmpty else { return 0 }
        let done = matches.filter(\.isComplete).count
        return Double(done) / Double(matches.count)
    }

    var isSwiss: Bool { format == "Swiss" }

    var latestRound: Int { matches.map(\.round).max() ?? 0 }

    private var playedGames: [Match] { matches.filter { $0.player2 != nil } }

    func isRoundComplete(_ round: Int) -> Bool {
        playedGames.filter { $0.round == round }.allSatisfy(\.isComplete)
    }

    // en suizo la siguiente ronda se empareja hasta que termina la anterior
    var nextSwissRound: Int? {
        guard isSwiss, !matches.isEmpty, latestRound < totalRounds, isRoundComplete(latestRound) else { return nil }
        return latestRound + 1
    }

    // puntos que llevaba el jugador antes de empezar la ronda
    func points(of player: Player, before round: Int) -> Double {
        matches.filter { $0.round < round && $0.isComplete }.reduce(0) { total, match in
            if match.player1?.id == player.id { return total + match.score1 }
            if match.player2?.id == player.id { return total + match.score2 }
            return total
        }
    }

    // fide: en suizo solo se puede entrar hasta la ronda 3
    var acceptsPlayers: Bool {
        status != .finished && (!isSwiss || matches.isEmpty || latestRound < min(3, totalRounds))
    }

    // live solo cuenta si ya se jugo algo, tener el calendario generado no es lo mismo que haber empezado
    var status: TournamentStatus {
        if matches.isEmpty { return .upcoming }
        let games = playedGames
        let completed = games.filter(\.isComplete).count
        if completed == 0 { return .upcoming }
        let allDone = completed >= games.count
        if isSwiss { return allDone && latestRound >= totalRounds ? .finished : .live }
        return allDone ? .finished : .live
    }
}

enum TournamentStatus: String, CaseIterable {
    case upcoming = "Upcoming"
    case live = "Live"
    case finished = "Finished"
}

