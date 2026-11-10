import Foundation
import SwiftData

struct TournamentDetailViewModel {
    private let modelContext: ModelContext
    private let pairingService: PairingServiceProtocol

    init(modelContext: ModelContext, pairingService: PairingServiceProtocol = RoundRobinPairingService()) {
        self.modelContext = modelContext
        self.pairingService = pairingService
    }

    func generateSchedule(for tournament: Tournament) {
        let pairings = pairingService.generateSchedule(for: tournament.players)

        for pairing in pairings {
            if let player2 = pairing.player2 {
                let match = Match(round: pairing.round, player1: pairing.player1, player2: player2)
                match.tournament = tournament
                modelContext.insert(match)
            } else {
                let match = Match(round: pairing.round, player1: pairing.player1, player2: nil,
                                   score1: 1, score2: 0, isComplete: true)
                match.tournament = tournament
                modelContext.insert(match)
                pairing.player1.score += 1
            }
        }
    }

    @discardableResult
    func addPlayer(named name: String, to tournament: Tournament) -> Bool {
        let trimmed = name.trimmingCharacters(in: .whitespaces)
        let isDuplicate = tournament.players.contains { $0.name.lowercased() == trimmed.lowercased() }
        guard !trimmed.isEmpty, !isDuplicate, tournament.status != .finished else { return false }

        let opponents = tournament.players
        let player = Player(name: trimmed)
        player.tournament = tournament
        modelContext.insert(player)

        guard !tournament.matches.isEmpty else { return true }

        let lastRound = tournament.matches.map(\.round).max() ?? 0
        for (index, opponent) in opponents.enumerated() {
            let match = Match(round: lastRound + 1 + index, player1: opponent, player2: player)
            match.tournament = tournament
            modelContext.insert(match)
        }
        return true
    }

    // si ya tenia resultado le quito antes el puntaje viejo, si no nomas duplicaria puntos al corregir
    func recordResult(for match: Match, score1: Double, score2: Double) {
        if match.isComplete {
            applyStandingsPoints(match.score1, match.score2, to: match, sign: -1)
        }
        match.score1 = score1
        match.score2 = score2
        match.isComplete = true
        applyStandingsPoints(score1, score2, to: match, sign: 1)
    }

    private func applyStandingsPoints(_ score1: Double, _ score2: Double, to match: Match, sign: Double) {
        if score1 == score2 {
            match.player1?.score += 0.5 * sign
            match.player2?.score += 0.5 * sign
        } else if score1 > score2 {
            match.player1?.score += 1 * sign
        } else {
            match.player2?.score += 1 * sign
        }
    }
}

