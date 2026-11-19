import SwiftUI
import SwiftData

struct MainTabView: View {
    @State private var selectedTab = 0

    var body: some View {
        TabView(selection: $selectedTab) {
            HomeDashboardView()
                .tabItem { Label("Home", systemImage: "house.fill") }
                .tag(0)

            ContentView()
                .tabItem { Label("Tournaments", systemImage: "trophy.fill") }
                .tag(1)

            PlayersDirectoryView()
                .tabItem { Label("Players", systemImage: "person.2.fill") }
                .tag(2)

            ProfileView(onExplore: { selectedTab = 1 })
                .tabItem { Label("Profile", systemImage: "person.crop.circle.fill") }
                .tag(3)
        }
        .tint(.podiumCopper)
        .toolbarBackground(Color.podiumCharcoal, for: .tabBar)
        .toolbarBackground(.visible, for: .tabBar)
        .toolbarColorScheme(.dark, for: .tabBar)
    }
}

#Preview {
    MainTabView()
        .environment(AuthViewModel())
        .modelContainer(for: [Tournament.self, Player.self, Match.self], inMemory: true)
}

