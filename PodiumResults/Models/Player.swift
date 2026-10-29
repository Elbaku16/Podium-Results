import Foundation
import SwiftData

@Model
final class Player {
    var id: UUID
    var name: String
    var score: Double

    var tournament: Tournament?

    init(name: String, score: Double = 0) {
        self.id = UUID()
        self.name = name
        self.score = score
    }
}

