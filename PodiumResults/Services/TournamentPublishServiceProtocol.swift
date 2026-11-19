import Foundation

struct PublishedStanding {
    let name: String
    let points: Double
    let sonnebornBerger: Double
    let koya: Double
    let wins: Int
}

protocol TournamentPublishServiceProtocol {
    func publish(_ tournament: Tournament, ownerID: String) async throws
    func unpublish(_ tournament: Tournament) async throws
}
