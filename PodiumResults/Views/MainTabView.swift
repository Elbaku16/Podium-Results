import SwiftUI
import SwiftData

struct MainTabView: View {
    var body: some View {
        TabView {
            HomeDashboardView()
                .tabItem { Label("Home", systemImage: "house.fill") }

            ContentView()
                .tabItem { Label("Tournaments", systemImage: "trophy.fill") }

            PlayersDirectoryView()
                .tabItem { Label("Players", systemImage: "person.2.fill") }

            ProfileView()
                .tabItem { Label("Profile", systemImage: "person.crop.circle.fill") }
        }
        .tint(.podiumCopper)
        .toolbarBackground(Color.podiumCharcoal, for: .tabBar)
        .toolbarBackground(.visible, for: .tabBar)
        .toolbarColorScheme(.dark, for: .tabBar)
    }
}

#Preview {
    MainTabView()
        .modelContainer(for: [Tournament.self, Player.self, Match.self], inMemory: true)
}

