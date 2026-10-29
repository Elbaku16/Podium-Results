import Foundation

enum TiebreakCalculator {
    struct Standing: Identifiable {
        let player: Player
        let score: Double
        let sonnebornBerger: Double
        let koya: Double
        let wins: Int
        var id: UUID { player.id }
    }

    private struct PlayedMatch {
        let opponent: Player
        let pointsEarned: Double
    }

    // orden oficial FIDE C.07 pa round robin: direct encounter, koya, sonneborn-berger, ganadas
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

        func wins(_ player: Player) -> Int {
            played(by: player).filter { $0.pointsEarned == 1 }.count
        }

        let groupedByScore = Dictionary(grouping: players, by: \.score)
        func directEncounter(_ player: Player) -> Double {
            let tiedGroup = Set((groupedByScore[player.score] ?? []).map(\.id))
            return played(by: player)
                .filter { tiedGroup.contains($0.opponent.id) }
                .reduce(0) { $0 + $1.pointsEarned }
        }

        return players
            .map { player in
                Standing(player: player, score: player.score,
                         sonnebornBerger: sonnebornBerger(player),
                         koya: koya(player), wins: wins(player))
            }
            .sorted { a, b in
                if a.score != b.score { return a.score > b.score }
                let deA = directEncounter(a.player), deB = directEncounter(b.player)
                if deA != deB { return deA > deB }
                if a.koya != b.koya { return a.koya > b.koya }
                if a.sonnebornBerger != b.sonnebornBerger { return a.sonnebornBerger > b.sonnebornBerger }
                if a.wins != b.wins { return a.wins > b.wins }
                return a.player.name < b.player.name
            }
    }
}

