import SwiftUI
import SwiftData

@main
struct PodiumResultsApp: App {
    var body: some Scene {
        WindowGroup {
            WelcomeView()
        }
        .modelContainer(for: [Tournament.self, Player.self, Match.self])
    }
}

