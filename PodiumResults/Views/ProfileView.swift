import SwiftUI
import SwiftData

struct ProfileView: View {
    @Environment(AuthViewModel.self) private var auth
    @Environment(\.dismiss) private var dismiss
    @Query private var tournaments: [Tournament]
    @State private var isScrolled = false
    @State private var photo = ProfilePhotoViewModel()

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
                        ProfileSettingsCard()
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
            }
            .toolbar(.hidden, for: .navigationBar)
            .navigationDestination(for: Tournament.self) { tournament in
                TournamentDetailView(tournament: tournament)
            }
            .navigationDestination(for: ProfileDestination.self) { destination in
                switch destination {
                case .personal: PersonalInformationView(onAccountClosed: { dismiss() })
                case .preferences: PreferencesView()
                case .help: HelpSupportView()
                case .about: AboutView()
                }
            }
        }
        .tint(.podiumCopper)
        .onAppear { photo.load(for: auth.user?.uid) }
        .onChange(of: auth.user?.uid) { _, uid in photo.load(for: uid) }
    }

    private var topBar: some View {
        HStack {
            HStack(spacing: 10) {
                Image("BrandMark")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 30, height: 32)
                Text("\(AppInfo.firstWord.uppercased())\n\(AppInfo.secondWord.uppercased())")
                    .font(.caption.weight(.bold))
                    .tracking(1.5)
                    .foregroundStyle(Color.podiumBeige)
            }
            Spacer()
            NavigationLink(value: ProfileDestination.preferences) {
                Image(systemName: "gearshape")
                    .font(.title3)
                    .foregroundStyle(.white)
                    .frame(width: 44, height: 44)
            }
        }
    }

    private var identityBlock: some View {
        VStack(spacing: 12) {
            ProfileAvatarView(photo: photo, name: auth.user?.name)
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
            statTile(value: tournaments.count, label: "Tournaments")
            statDivider
            statTile(value: totalMatchesPlayed, label: "Games Played")
            statDivider
            statTile(value: distinctPlayerCount, label: "Players")
        }
        .padding(.vertical, 16)
        .profileCard()
    }

    private var statDivider: some View {
        Rectangle()
            .fill(Color.podiumCopper.opacity(0.25))
            .frame(width: 1, height: 52)
    }

    private func statTile(value: Int, label: String) -> some View {
        VStack(spacing: 4) {
            Text("\(value)")
                .font(.system(size: 30, weight: .bold, design: .rounded))
                .foregroundStyle(.white)
            Text(label.uppercased())
                .font(.caption2.weight(.semibold))
                .tracking(0.8)
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
