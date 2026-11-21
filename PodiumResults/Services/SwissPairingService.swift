import Foundation

struct SwissPairingService: SwissPairingServiceProtocol {
    private struct History {
        var opponents: [UUID: Set<UUID>] = [:]
        var whites: [UUID: Int] = [:]
        var blacks: [UUID: Int] = [:]
        var hadBye: Set<UUID> = []
    }

    private final class Budget {
        var steps = 0
    }

    func pairRound(_ round: Int, players: [Player], matches: [Match]) -> [RoundPairing] {
        guard players.count >= 2 else { return [] }

        let ranked = players.sorted { a, b in
            if a.score != b.score { return a.score > b.score }
            if a.seed != b.seed { return a.seed < b.seed }
            return a.name < b.name
        }

        let history = makeHistory(before: round, matches: matches)

        if round == 1 && history.opponents.isEmpty {
            return firstRound(ranked)
        }

        var byeCandidates: [Player?] = [nil]
        if ranked.count % 2 == 1 {
            let withoutBye = Array(ranked.filter { !history.hadBye.contains($0.id) }.reversed())
            let rest = Array(ranked.filter { history.hadBye.contains($0.id) }.reversed())
            byeCandidates = (withoutBye + rest).map { Optional($0) }
        }

        for allowRematch in [false, true] {
            for candidate in byeCandidates {
                let pool = ranked.filter { $0.id != candidate?.id }
                let budget = Budget()
                if let pairs = solve(pool, history: history, allowRematch: allowRematch, budget: budget) {
                    return makePairings(round: round, pairs: pairs, bye: candidate, history: history)
                }
            }
        }
        return firstRound(ranked)
    }

    private func makeHistory(before round: Int, matches: [Match]) -> History {
        var history = History()
        for match in matches where match.round < round {
            guard let first = match.player1 else { continue }
            if let second = match.player2 {
                history.opponents[first.id, default: []].insert(second.id)
                history.opponents[second.id, default: []].insert(first.id)
                history.whites[first.id, default: 0] += 1
                history.blacks[second.id, default: 0] += 1
            } else if match.score1 >= 1 {
                history.hadBye.insert(first.id)
            }
        }
        return history
    }

    private func firstRound(_ ranked: [Player]) -> [RoundPairing] {
        var list = ranked
        var bye: Player?
        if list.count % 2 == 1 { bye = list.removeLast() }
        let half = list.count / 2
        var pairings: [RoundPairing] = []
        for index in 0..<half {
            let top = list[index], bottom = list[index + half]
            let topWhite = index % 2 == 0
            pairings.append(RoundPairing(round: 1, player1: topWhite ? top : bottom, player2: topWhite ? bottom : top))
        }
        if let bye { pairings.append(RoundPairing(round: 1, player1: bye, player2: nil)) }
        return pairings
    }

    // dutch simplificado: dentro de un grupo de puntos, la mitad de arriba contra la de abajo
    private func solve(_ list: [Player], history: History, allowRematch: Bool, budget: Budget) -> [(Player, Player)]? {
        guard let first = list.first else { return [] }
        budget.steps += 1
        if budget.steps > 100_000 { return nil }

        let rest = Array(list.dropFirst())
        let sameScore = rest.filter { $0.score == first.score }
        let lowerScore = rest.filter { $0.score != first.score }

        var ordered: [Player] = []
        if !sameScore.isEmpty {
            let half = (sameScore.count + 1) / 2
            let preferred = min(max(half - 1, 0), sameScore.count - 1)
            ordered = Array(sameScore[preferred...]) + Array(sameScore[..<preferred])
        }
        ordered += lowerScore

        for other in ordered {
            if !allowRematch && history.opponents[first.id]?.contains(other.id) == true { continue }
            var remaining = rest
            remaining.removeAll { $0.id == other.id }
            if let tail = solve(remaining, history: history, allowRematch: allowRematch, budget: budget) {
                return [(first, other)] + tail
            }
        }
        return nil
    }

    private func makePairings(round: Int, pairs: [(Player, Player)], bye: Player?, history: History) -> [RoundPairing] {
        func colorBalance(_ player: Player) -> Int {
            (history.whites[player.id] ?? 0) - (history.blacks[player.id] ?? 0)
        }

        let boards = pairs.sorted { a, b in
            let topA = max(a.0.score, a.1.score), topB = max(b.0.score, b.1.score)
            if topA != topB { return topA > topB }
            return (a.0.score + a.1.score) > (b.0.score + b.1.score)
        }

        var pairings = boards.map { higher, lower -> RoundPairing in
            let higherWhite = colorBalance(higher) <= colorBalance(lower)
            return RoundPairing(round: round, player1: higherWhite ? higher : lower,
                                player2: higherWhite ? lower : higher)
        }
        if let bye { pairings.append(RoundPairing(round: round, player1: bye, player2: nil)) }
        return pairings
    }
}
