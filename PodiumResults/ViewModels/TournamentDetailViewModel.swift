import Foundation
import SwiftData

struct TournamentDetailViewModel {
    private let modelContext: ModelContext
    private let pairingService: PairingServiceProtocol
    private let notifier: NotificationServiceProtocol

    init(modelContext: ModelContext,
         pairingService: PairingServiceProtocol = RoundRobinPairingService(),
         notifier: NotificationServiceProtocol = LocalNotificationService()) {
        self.modelContext = modelContext
        self.pairingService = pairingService
        self.notifier = notifier
    }

    private func notify(_ title: String, _ message: String, icon: String) {
        modelContext.insert(AppNotification(title: title, message: message, icon: icon))
        notifier.deliver(title: title, body: message)
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

        notify("New player", "\(trimmed) joined \(tournament.name).", icon: "person.badge.plus")

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
        let wasComplete = match.isComplete
        if match.isComplete {
            applyStandingsPoints(match.score1, match.score2, to: match, sign: -1)
        }
        match.score1 = score1
        match.score2 = score2
        match.isComplete = true
        applyStandingsPoints(score1, score2, to: match, sign: 1)
        if !wasComplete { announceProgress(after: match) }
    }

    private func announceProgress(after match: Match) {
        guard let tournament = match.tournament else { return }
        if tournament.status == .finished {
            let winner = TiebreakCalculator.standings(for: tournament).first?.player.name ?? "Someone"
            notify("\(tournament.name) finished", "\(winner) wins the tournament.", icon: "crown.fill")
            return
        }
        let roundDone = tournament.matches.filter { $0.round == match.round }.allSatisfy(\.isComplete)
        if roundDone {
            notify("Round \(match.round) complete", "All games of round \(match.round) in \(tournament.name) are finished.",
                   icon: "checkmark.seal.fill")
        }
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

