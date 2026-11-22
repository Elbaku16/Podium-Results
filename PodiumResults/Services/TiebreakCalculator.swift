import Foundation

enum TiebreakCalculator {
    struct Standing: Identifiable {
        let player: Player
        let score: Double
        let sonnebornBerger: Double
        let koya: Double
        let buchholz: Double
        let wins: Int
        var id: UUID { player.id }
    }

    private struct PlayedMatch {
        let opponent: Player
        let pointsEarned: Double
    }

    // round robin: direct encounter, koya, sonneborn-berger, ganadas. suizo: direct encounter, buchholz, sonneborn-berger, ganadas
    static func standings(for tournament: Tournament) -> [Standing] {
        let players = tournament.players
        let completed = tournament.matches.filter { $0.isComplete && $0.player2 != nil }

        func played(by player: Player) -> [PlayedMatch] {
            completed.compactMap { match in
                if match.player1?.id == player.id, let opponent = match.player2 {
                    return PlayedMatch(opponent: opponent, pointsEarned: match.score1)
                } else if match.player2?.id == player.id, let opponent = match.player1 {
                    return PlayedMatch(opponent: opponent, pointsEarned: match.score2)
                }
                return nil
            }
        }

        let maxScore = Double(max(players.count - 1, 0))
        let koyaThreshold = maxScore / 2

        func sonnebornBerger(_ player: Player) -> Double {
            played(by: player).reduce(0) { total, match in
                if match.pointsEarned == 1 { return total + match.opponent.score }
                if match.pointsEarned == 0.5 { return total + match.opponent.score / 2 }
                return total
            }
        }

        func koya(_ player: Player) -> Double {
            played(by: player)
                .filter { $0.opponent.score >= koyaThreshold }
                .reduce(0) { $0 + $1.pointsEarned }
        }

        func buchholz(_ player: Player) -> Double {
            played(by: player).reduce(0) { $0 + $1.opponent.score }
        }

        func wins(_ player: Player) -> Int {
            played(by: player).filter { $0.pointsEarned == 1 }.count
        }

        let standings = players.map { player in
            Standing(player: player, score: player.score,
                     sonnebornBerger: sonnebornBerger(player),
                     koya: koya(player), buchholz: buchholz(player), wins: wins(player))
        }

        // fide 2026 (play-off and tie-break regulations), art. 6: el encuentro directo solo cuenta entre los empatados
        func directScores(in group: [Standing]) -> [UUID: Double] {
            let ids = Set(group.map(\.id))
            return Dictionary(uniqueKeysWithValues: group.map { standing in
                (standing.id, played(by: standing.player).filter { ids.contains($0.opponent.id) }.reduce(0) { $0 + $1.pointsEarned })
            })
        }

        func opponentsMet(_ standing: Standing, in group: [Standing]) -> Int {
            let ids = Set(group.map(\.id))
            return Set(played(by: standing.player).map(\.opponent.id).filter { ids.contains($0) }).count
        }

        func directEncounter(_ group: [Standing], then rest: [(Standing) -> Double]) -> [Standing] {
            let scores = directScores(in: group)
            let allMet = group.allSatisfy { opponentsMet($0, in: group) == group.count - 1 }

            if allMet {
                // art. 6.2: todos se enfrentaron, el mini-ranking decide y los que sigan empatados repiten el desempate
                let values = Set(scores.values).sorted(by: >)
                return values.flatMap { value -> [Standing] in
                    let bucket = group.filter { scores[$0.id] == value }
                    return bucket.count == group.count ? order(bucket, rest) : directEncounter(bucket, then: rest)
                }
            }

            // art. 6.3 (suizo): si alguien queda solo arriba aunque se jueguen las partidas que faltan, va primero
            if tournament.isSwiss,
               let top = group.max(by: { scores[$0.id]! < scores[$1.id]! }),
               group.filter({ $0.id != top.id }).allSatisfy({ other in
                   scores[top.id]! > scores[other.id]! + Double(group.count - 1 - opponentsMet(other, in: group))
               }) {
                return [top] + directEncounter(group.filter { $0.id != top.id }, then: rest)
            }
            return order(group, rest)
        }

        func order(_ group: [Standing], _ criteria: [(Standing) -> Double]) -> [Standing] {
            guard group.count > 1 else { return group }
            guard let criterion = criteria.first else { return group.sorted { $0.player.name < $1.player.name } }
            let values = Set(group.map(criterion)).sorted(by: >)
            return values.flatMap { value in
                order(group.filter { criterion($0) == value }, Array(criteria.dropFirst()))
            }
        }

        let criteria: [(Standing) -> Double] = tournament.isSwiss
            ? [{ $0.buchholz }, { $0.sonnebornBerger }, { Double($0.wins) }]
            : [{ $0.koya }, { $0.sonnebornBerger }, { Double($0.wins) }]

        return Set(standings.map(\.score)).sorted(by: >).flatMap { score in
            directEncounter(standings.filter { $0.score == score }, then: criteria)
        }
    }
}
