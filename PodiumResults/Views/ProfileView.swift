import SwiftUI
import SwiftData

struct ProfileView: View {
    @Environment(AuthViewModel.self) private var auth
    @Environment(\.dismiss) private var dismiss
    @Query private var tournaments: [Tournament]
    @State private var isShowingAbout = false
    @State private var comingSoonMessage: String?
    @State private var isScrolled = false

    private var totalMatchesPlayed: Int {
        tournaments.flatMap(\.matches).filter(\.isComplete).count
    }

    private var distinctPlayerCount: Int {
        Set(tournaments.flatMap(\.players).map(\.name)).count
    }

    private var recentTournaments: [Tournament] {
        tournaments.sorted { $0.date > $1.date }
    }

    let onExplore: () -> Void

    init(onExplore: @escaping () -> Void = {}) {
        self.onExplore = onExplore
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Color.podiumCharcoal.ignoresSafeArea()

                ChessboardBackdrop()
                    .frame(height: 430)
                    .frame(maxHeight: .infinity, alignment: .top)
                    .ignoresSafeArea(edges: .top)

                ScrollView {
                    VStack(spacing: 18) {
                        topBar
                        identityBlock
                        statsCard
                        activityCard
                        ProfileSettingsCard(onAbout: { isShowingAbout = true }, onComingSoon: { comingSoonMessage = $0 })
                        signOutButton
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 8)
                }
                .trackScrolled($isScrolled)
                .contentMargins(.bottom, 100, for: .scrollContent)
                .contentMargins(.bottom, 0, for: .scrollIndicators)

                LinearGradient(colors: [Color.podiumCharcoal, Color.podiumCharcoal, Color.podiumCharcoal.opacity(0)],
                               startPoint: .top, endPoint: .bottom)
                    .frame(height: 96)
                    .frame(maxHeight: .infinity, alignment: .top)
                    .ignoresSafeArea(edges: .top)
                    .opacity(isScrolled ? 1 : 0)
                    .animation(.easeOut(duration: 0.2), value: isScrolled)
                    .allowsHitTesting(false)
                .navigationDestination(for: Tournament.self) { tournament in
                    TournamentDetailView(tournament: tournament)
                }
            }
            .toolbar(.hidden, for: .navigationBar)
        }
        .tint(.podiumCopper)
        .sheet(isPresented: $isShowingAbout) {
            ProfileAboutSheet(isPresented: $isShowingAbout)
        }
        .alert("Coming Soon", isPresented: Binding(get: { comingSoonMessage != nil }, set: { if !$0 { comingSoonMessage = nil } })) {
            Button("OK") { comingSoonMessage = nil }
        } message: {
            Text(comingSoonMessage ?? "")
        }
    }

    private var topBar: some View {
        HStack {
            HStack(spacing: 8) {
                ChessKingShape()
                    .fill(Color.podiumCopper)
                    .frame(width: 22, height: 28)
                Text("PODIUM\nRESULTS")
                    .font(.caption.weight(.bold))
                    .tracking(1.5)
                    .foregroundStyle(Color.podiumBeige)
            }
            Spacer()
            Button {
                comingSoonMessage = "App preferences are coming in a future update."
            } label: {
                Image(systemName: "gearshape")
                    .font(.title3)
                    .foregroundStyle(.white)
            }
        }
    }

    private var identityBlock: some View {
        VStack(spacing: 12) {
            ZStack(alignment: .bottomTrailing) {
                Circle()
                    .fill(Color.white.opacity(0.04))
                    .overlay(Circle().stroke(Color.podiumCopper, lineWidth: 3))
                    .frame(width: 112, height: 112)
                    .overlay(
                        ChessKingView()
                            .frame(width: 58, height: 68)
                    )
                Button {
                    comingSoonMessage = "Personal profile fields will be available soon."
                } label: {
                    Image(systemName: "pencil")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.white)
                        .frame(width: 30, height: 30)
                        .background(Color.podiumCopper.opacity(0.7))
                        .clipShape(Circle())
                }
            }
            VStack(spacing: 4) {
                Text(auth.user?.name ?? "Guest Organizer")
                    .font(.title2.weight(.bold))
                    .foregroundStyle(.white)
                Text(auth.user?.email ?? "Not signed in")
                    .font(.subheadline)
                    .foregroundStyle(Color.podiumMuted)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 4)
    }

    private var statsCard: some View {
        HStack(spacing: 0) {
            statTile(icon: "trophy.fill", value: tournaments.count, label: "Tournaments")
            statDivider
            statTile(icon: "square.grid.3x3.fill", value: totalMatchesPlayed, label: "Matches Played")
            statDivider
            statTile(icon: "person.2.fill", value: distinctPlayerCount, label: "Unique Players")
        }
        .padding(.vertical, 16)
        .profileCard()
    }

    private var statDivider: some View {
        Rectangle()
            .fill(Color.podiumCopper.opacity(0.25))
            .frame(width: 1, height: 52)
    }

    private func statTile(icon: String, value: Int, label: String) -> some View {
        VStack(spacing: 6) {
            Image(systemName: icon)
                .font(.subheadline)
                .foregroundStyle(Color.podiumCopper)
            Text("\(value)")
                .font(.title2.weight(.bold))
                .foregroundStyle(.white)
            Text(label)
                .font(.caption)
                .foregroundStyle(Color.podiumMuted)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
    }

    private var activityCard: some View {
        VStack(spacing: 14) {
            HStack {
                Image(systemName: "waveform.path.ecg")
                    .foregroundStyle(Color.podiumCopper)
                Text("Your Activity")
                    .font(.headline)
                    .foregroundStyle(.white)
                Spacer()
                Button(action: onExplore) {
                    Text("View All \u{203A}")
                        .font(.subheadline.weight(.medium))
                        .foregroundStyle(Color.podiumCopper)
                }
            }

            if recentTournaments.isEmpty {
                VStack(spacing: 6) {
                    Image(systemName: "flag.checkered")
                        .font(.system(size: 34))
                        .foregroundStyle(Color.podiumBeige)
                    Text("No tournaments yet")
                        .font(.headline)
                        .foregroundStyle(.white)
                    Text("Create or join a tournament to get started!")
                        .font(.subheadline)
                        .foregroundStyle(Color.podiumMuted)
                        .multilineTextAlignment(.center)
                }
                .padding(.vertical, 8)

                Button(action: onExplore) {
                    Text("Explore Tournaments")
                        .font(.subheadline.weight(.bold))
                        .foregroundStyle(Color.podiumCharcoal)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(Color.podiumCopper)
                        .clipShape(Capsule())
                }
            } else {
                VStack(spacing: 0) {
                    ForEach(Array(recentTournaments.prefix(3).enumerated()), id: \.element.id) { index, tournament in
                        NavigationLink(value: tournament) {
                            TournamentRow(tournament: tournament)
                        }
                        .buttonStyle(.plain)
                        if index != min(recentTournaments.count, 3) - 1 {
                            Divider().overlay(.white.opacity(0.07))
                        }
                    }
                }
            }
        }
        .padding(16)
        .profileCard()
    }

    private var signOutButton: some View {
        Button {
            auth.signOut()
            dismiss()
        } label: {
            Label(auth.isLoggedIn ? "Sign Out" : "Back to Login", systemImage: "rectangle.portrait.and.arrow.right")
                .font(.headline)
                .foregroundStyle(.white)
                .padding(.horizontal, 40)
                .padding(.vertical, 14)
                .overlay(Capsule().stroke(Color.podiumCopper, lineWidth: 1.5))
        }
        .padding(.top, 4)
    }
}

#Preview {
    ProfileView()
        .environment(AuthViewModel())
        .modelContainer(for: [Tournament.self, Player.self, Match.self], inMemory: true)
}

private extension View {
    @ViewBuilder
    func trackScrolled(_ isScrolled: Binding<Bool>) -> some View {
        if #available(iOS 18.0, *) {
            onScrollGeometryChange(for: Bool.self) { geometry in
                geometry.contentOffset.y + geometry.contentInsets.top > 6
            } action: { _, scrolled in
                isScrolled.wrappedValue = scrolled
            }
        } else {
            onAppear { isScrolled.wrappedValue = true }
        }
    }
}
