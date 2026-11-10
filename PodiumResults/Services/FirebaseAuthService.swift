import Foundation
import FirebaseAuth

struct FirebaseAuthService: AuthServiceProtocol {
    var currentUser: AuthUser? {
        guard let user = Auth.auth().currentUser else { return nil }
        return makeUser(from: user)
    }

    func signUp(name: String, email: String, password: String) async throws -> AuthUser {
        do {
            let result = try await Auth.auth().createUser(withEmail: email, password: password)
            let change = result.user.createProfileChangeRequest()
            change.displayName = name
            try await change.commitChanges()
            return makeUser(from: result.user)
        } catch {
            throw AuthServiceError(message: friendlyMessage(for: error))
        }
    }

    func signIn(email: String, password: String) async throws -> AuthUser {
        do {
            let result = try await Auth.auth().signIn(withEmail: email, password: password)
            return makeUser(from: result.user)
        } catch {
            throw AuthServiceError(message: friendlyMessage(for: error))
        }
    }

    func signOut() throws {
        try Auth.auth().signOut()
    }

    private func makeUser(from user: User) -> AuthUser {
        let email = user.email ?? ""
        let name = user.displayName ?? ""
        return AuthUser(email: email, name: name.isEmpty ? email : name)
    }

    private func friendlyMessage(for error: Error) -> String {
        guard let code = AuthErrorCode(rawValue: (error as NSError).code) else {
            return "Something went wrong. Try again."
        }
        switch code {
        case .emailAlreadyInUse: return "That email already has an account."
        case .invalidEmail: return "That email doesn't look right."
        case .weakPassword: return "Password is too weak. Use at least 6 characters."
        case .wrongPassword, .invalidCredential, .userNotFound: return "Email or password is wrong."
        case .networkError: return "No internet connection."
        case .tooManyRequests: return "Too many attempts. Wait a bit and try again."
        default: return "Something went wrong. Try again."
        }
    }
}
