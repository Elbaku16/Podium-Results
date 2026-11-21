import Foundation
import FirebaseFirestore

struct FirestoreTournamentService: TournamentPublishServiceProtocol {
    private let collection = "tournaments"

    func publish(_ tournament: Tournament, ownerID: String) async throws {
        let standings = TiebreakCalculator.standings(for: tournament).map {
            [
                "name": $0.player.name,
                "points": $0.score,
                "sonnebornBerger": $0.sonnebornBerger,
                "koya": $0.koya,
                "buchholz": $0.buchholz,
                "wins": $0.wins,
            ] as [String: Any]
        }

        let players = tournament.players.map {
            ["id": $0.id.uuidString, "name": $0.name, "score": $0.score] as [String: Any]
        }

        let matches = tournament.matches.map {
            [
                "round": $0.round,
                "player1": $0.player1?.name ?? "",
                "player2": $0.player2?.name ?? "",
                "score1": $0.score1,
                "score2": $0.score2,
                "isComplete": $0.isComplete,
            ] as [String: Any]
        }

        let data: [String: Any] = [
            "name": tournament.name,
            "format": tournament.format,
            "totalRounds": tournament.totalRounds,
            "date": Timestamp(date: tournament.date),
            "location": tournament.location,
            "timeControl": tournament.timeControl,
            "arbiter": tournament.arbiter,
            "categories": tournament.categories,
            "status": tournament.status.rawValue,
            "ownerUID": ownerID,
            "updatedAt": Timestamp(date: .now),
            "players": players,
            "matches": matches,
            "standings": standings,
        ]

        let reference = Firestore.firestore().collection(collection).document(tournament.id.uuidString)
        try await withTimeout(seconds: 15) { try await reference.setData(data) }
    }

    func unpublish(_ tournament: Tournament) async throws {
        let reference = Firestore.firestore().collection(collection).document(tournament.id.uuidString)
        try await withTimeout(seconds: 15) { try await reference.delete() }
    }

    private func withTimeout(seconds: Double, _ work: @escaping @Sendable () async throws -> Void) async throws {
        try await withThrowingTaskGroup(of: Void.self) { group in
            group.addTask { try await work() }
            group.addTask {
                try await Task.sleep(for: .seconds(seconds))
                throw AuthServiceError(message: "It took too long. Check your internet and try again.")
            }
            try await group.next()
            group.cancelAll()
        }
    }
}
