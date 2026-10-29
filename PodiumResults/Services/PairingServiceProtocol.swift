import Foundation

struct RoundPairing {
    let round: Int
    let player1: Player
    let player2: Player?
}

protocol PairingServiceProtocol {
    func generateSchedule(for players: [Player]) -> [RoundPairing]
}

