import Foundation

protocol SwissPairingServiceProtocol {
    func pairRound(_ round: Int, players: [Player], matches: [Match]) -> [RoundPairing]
}
