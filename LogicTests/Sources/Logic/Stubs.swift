import Foundation
struct LocalNotificationService: NotificationServiceProtocol {
    func isAllowed() async -> Bool { false }
    func requestPermission() async -> Bool { false }
    func deliver(title: String, body: String) {}
}
struct FirebaseAuthService: AuthServiceProtocol {
    var currentUser: AuthUser? { nil }
    func signUp(name: String, email: String, password: String) async throws -> AuthUser { AuthUser(uid: "u", email: email, name: name) }
    func signIn(email: String, password: String) async throws -> AuthUser { AuthUser(uid: "u", email: email, name: email) }
    func updateName(_ name: String) async throws -> AuthUser { AuthUser(uid: "u", email: "e", name: name) }
    func deleteAccount() async throws {}
    func signOut() throws {}
}
