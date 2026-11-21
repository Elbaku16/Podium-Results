import Foundation
import SwiftData

@Model
final class Player {
    var id: UUID
    var name: String
    var score: Double
    var seed: Int = 0

    var tournament: Tournament?

    init(name: String, score: Double = 0, seed: Int = 0) {
        self.id = UUID()
        self.name = name
        self.score = score
        self.seed = seed
    }
}

