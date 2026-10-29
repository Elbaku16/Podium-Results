import Foundation

struct RoundRobinPairingService: PairingServiceProtocol {
    func generateSchedule(for players: [Player]) -> [RoundPairing] {
        guard players.count >= 2 else { return [] }

        var rotation = players
        let hasBye = rotation.count % 2 != 0
        if hasBye {
            rotation.append(Player(name: "BYE"))
        }

        let n = rotation.count
        let roundCount = n - 1
        var pairings: [RoundPairing] = []

        for round in 0..<roundCount {
            for i in 0..<(n / 2) {
                let p1 = rotation[i]
                let p2 = rotation[n - 1 - i]
                if p1.name == "BYE" {
                    pairings.append(RoundPairing(round: round + 1, player1: p2, player2: nil))
                } else if p2.name == "BYE" {
                    pairings.append(RoundPairing(round: round + 1, player1: p1, player2: nil))
                } else {
                    pairings.append(RoundPairing(round: round + 1, player1: p1, player2: p2))
                }
            }
            let fixed = rotation[0]
            var rest = Array(rotation[1...])
            rest.insert(rest.removeLast(), at: 0)
            rotation = [fixed] + rest
        }

        return pairings
    }
}

