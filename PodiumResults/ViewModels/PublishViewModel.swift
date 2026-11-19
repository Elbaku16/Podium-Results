import Foundation
import Observation

@MainActor
@Observable
final class PublishViewModel {
    enum State: Equatable {
        case idle
        case publishing
        case published
        case failed(String)
    }

    private let service: TournamentPublishServiceProtocol

    var state: State = .idle

    init(service: TournamentPublishServiceProtocol = FirestoreTournamentService()) {
        self.service = service
    }

    func publish(_ tournament: Tournament, user: AuthUser?) async {
        guard let user else {
            state = .failed("Log in to publish a tournament.")
            return
        }
        state = .publishing
        do {
            try await service.publish(tournament, ownerID: user.uid)
            tournament.publishedAt = .now
            state = .published
        } catch {
            state = .failed(message(for: error))
        }
    }

    func refreshIfPublished(_ tournament: Tournament, user: AuthUser?) async {
        guard tournament.publishedAt != nil, let user else { return }
        try? await service.publish(tournament, ownerID: user.uid)
        tournament.publishedAt = .now
    }

    private func message(for error: Error) -> String {
        if let known = error as? AuthServiceError { return known.message }
        return "Couldn't publish. Check your internet and try again."
    }
}
