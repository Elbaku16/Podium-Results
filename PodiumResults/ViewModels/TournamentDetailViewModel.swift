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
        createMatches(for: tournament, players: tournament.players)
    }

    private func createMatches(for tournament: Tournament, players: [Player]) {
        let pairings = pairingService.generateSchedule(for: players)

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

    func entryRound(for tournament: Tournament) -> Int? {
        let played = tournament.matches.filter { $0.isComplete && $0.player2 != nil }
        guard let lastPlayed = played.map(\.round).max() else { return nil }
        return lastPlayed + 1
    }

    @discardableResult
    func addPlayer(named name: String, to tournament: Tournament, missedRoundPoints: Double = 0) -> Bool {
        let trimmed = name.trimmingCharacters(in: .whitespaces)
        let isDuplicate = tournament.players.contains { $0.name.lowercased() == trimmed.lowercased() }
        guard !trimmed.isEmpty, !isDuplicate, tournament.status != .finished else { return false }

        let current = tournament.players
        let player = Player(name: trimmed)
        player.tournament = tournament
        modelContext.insert(player)

        guard !tournament.matches.isEmpty else { return true }

        notify("New player", "\(trimmed) joined \(tournament.name).", icon: "person.badge.plus")

        guard let firstRound = entryRound(for: tournament) else {
            tournament.matches.forEach(modelContext.delete)
            (current + [player]).forEach { $0.score = 0 }
            createMatches(for: tournament, players: current + [player])
            return true
        }

        for round in 1..<firstRound {
            let missed = Match(round: round, player1: player, player2: nil, score1: missedRoundPoints, score2: 0, isComplete: true)
            missed.tournament = tournament
            modelContext.insert(missed)
            player.score += missedRoundPoints
        }

        pairLatePlayer(player, from: firstRound, in: tournament)
        return true
    }

    private func pairLatePlayer(_ player: Player, from firstRound: Int, in tournament: Tournament) {
        let lastRound = tournament.matches.map(\.round).max() ?? firstRound
        var met = Set<UUID>()

        for round in firstRound...max(firstRound, lastRound) {
            let inRound = tournament.matches.filter { $0.round == round && $0.player1?.id != player.id }

            if let bye = inRound.first(where: { $0.player2 == nil }), let holder = bye.player1, !met.contains(holder.id) {
                holder.score -= bye.score1
                bye.player2 = player
                bye.score1 = 0
                bye.score2 = 0
                bye.isComplete = false
                met.insert(holder.id)
                continue
            }

            let candidates = inRound.filter { $0.player2 != nil && !$0.isComplete }
            var chosen: (game: Match, opponent: Player, resting: Player)?
            for game in candidates {
                guard let first = game.player1, let second = game.player2 else { continue }
                let firstFree = !met.contains(first.id)
                let secondFree = !met.contains(second.id)
                if firstFree && secondFree {
                    let lowerFirst = first.score < second.score
                    chosen = (game, lowerFirst ? second : first, lowerFirst ? first : second)
                } else if firstFree {
                    chosen = (game, first, second)
                } else if secondFree {
                    chosen = (game, second, first)
                }
                if chosen != nil { break }
            }
            guard let (game, opponent, resting) = chosen else { continue }

            game.player1 = opponent
            game.player2 = player
            met.insert(opponent.id)

            let rest = Match(round: round, player1: resting, player2: nil, score1: 1, score2: 0, isComplete: true)
            rest.tournament = tournament
            modelContext.insert(rest)
            resting.score += 1
        }
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

