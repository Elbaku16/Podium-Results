import Foundation
import Observation

@MainActor
@Observable
final class AuthViewModel {
    private let service: AuthServiceProtocol

    var user: AuthUser?
    var errorMessage: String?
    var isLoading = false

    var isLoggedIn: Bool { user != nil }

    init(service: AuthServiceProtocol = FirebaseAuthService()) {
        self.service = service
        self.user = service.currentUser
    }

    func signIn(email: String, password: String) async -> Bool {
        await run { try await service.signIn(email: email, password: password) }
    }

    func signUp(name: String, email: String, password: String) async -> Bool {
        await run { try await service.signUp(name: name, email: email, password: password) }
    }

    func signOut() {
        try? service.signOut()
        user = nil
    }

    private func run(_ action: () async throws -> AuthUser) async -> Bool {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }
        do {
            user = try await action()
            return true
        } catch {
            errorMessage = error.localizedDescription
            return false
        }
    }
}
