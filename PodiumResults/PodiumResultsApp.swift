import SwiftUI
import SwiftData
import FirebaseCore

@main
struct PodiumResultsApp: App {
    @State private var authViewModel: AuthViewModel

    init() {
        FirebaseApp.configure()
        _authViewModel = State(initialValue: AuthViewModel())
    }

    var body: some Scene {
        WindowGroup {
            WelcomeView()
                .environment(authViewModel)
        }
        .modelContainer(for: [Tournament.self, Player.self, Match.self])
    }
}
