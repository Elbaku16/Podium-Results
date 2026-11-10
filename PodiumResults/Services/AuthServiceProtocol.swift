import Foundation

struct AuthUser {
    let email: String
    let name: String
}

struct AuthServiceError: LocalizedError {
    let message: String
    var errorDescription: String? { message }
}

protocol AuthServiceProtocol {
    var currentUser: AuthUser? { get }
    func signUp(name: String, email: String, password: String) async throws -> AuthUser
    func signIn(email: String, password: String) async throws -> AuthUser
    func signOut() throws
}
