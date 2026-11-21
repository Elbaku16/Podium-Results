import SwiftUI
import SwiftData
import FirebaseCore
import UserNotifications

@main
struct PodiumResultsApp: App {
    @State private var authViewModel: AuthViewModel
    @State private var showLaunch = true

    init() {
        FirebaseApp.configure()
        UNUserNotificationCenter.current().delegate = NotificationPresenter.shared
        _authViewModel = State(initialValue: AuthViewModel())
    }

    var body: some Scene {
        WindowGroup {
            ZStack {
                if showLaunch {
                    LaunchView()
                        .transition(.opacity)
                } else {
                    WelcomeView()
                        .transition(.opacity)
                }
            }
            .environment(authViewModel)
            .seedDemoDataIfRequested()
            .task {
                try? await Task.sleep(for: .seconds(1.6))
                withAnimation(.easeInOut(duration: 0.5)) { showLaunch = false }
            }
        }
        .modelContainer(for: [Tournament.self, Player.self, Match.self, AppNotification.self])
    }
}
