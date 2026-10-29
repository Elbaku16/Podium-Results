import Foundation
import SwiftData

@Model
final class Match {
    var id: UUID
    var round: Int
    var score1: Double
    var score2: Double
    var isComplete: Bool

    var tournament: Tournament?
    var player1: Player?
    var player2: Player?

    init(round: Int, player1: Player, player2: Player?, score1: Double = 0, score2: Double = 0, isComplete: Bool = false) {
        self.id = UUID()
        self.round = round
        self.player1 = player1
        self.player2 = player2
        self.score1 = score1
        self.score2 = score2
        self.isComplete = isComplete
    }
}

