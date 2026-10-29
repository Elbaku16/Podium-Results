import SwiftUI
import SwiftData

struct ProfileView: View {
    @Query private var tournaments: [Tournament]
    @State private var isShowingAbout = false
    @State private var comingSoonMessage: String?

    private var totalMatchesPlayed: Int {
        tournaments.flatMap(\.matches).filter(\.isComplete).count
    }

    private var distinctPlayerCount: Int {
        Set(tournaments.flatMap(\.players).map(\.name)).count
    }

    private var recentTournaments: [Tournament] {
        tournaments.sorted { $0.date > $1.date }
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Color.podiumCharcoal.ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 24) {
                        identityBlock
                        statsRow
                        if !recentTournaments.isEmpty {
                            tournamentsSection
                        }
                        settingsSection
                        signOutButton
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 16)
                    .padding(.bottom, 60)
                }
                .navigationDestination(for: Tournament.self) { tournament in
                    TournamentDetailView(tournament: tournament)
                }
            }
            .navigationTitle("Profile")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(Color.podiumCharcoal, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
        }
        .tint(.podiumCopper)
        .sheet(isPresented: $isShowingAbout) {
            aboutSheet
        }
        .alert("Coming Soon", isPresented: Binding(get: { comingSoonMessage != nil }, set: { if !$0 { comingSoonMessage = nil } })) {
            Button("OK") { comingSoonMessage = nil }
        } message: {
            Text(comingSoonMessage ?? "")
        }
    }

    private var identityBlock: some View {
        VStack(spacing: 10) {
            ZStack {
                Circle()
                    .stroke(Color.podiumCopper, lineWidth: 1.5)
                    .frame(width: 88, height: 88)
                Image(systemName: "person.fill")
                    .font(.system(size: 32))
                    .foregroundStyle(Color.podiumCopper)
            }
            VStack(spacing: 2) {
                Text("Guest Organizer")
                    .font(.title3.weight(.bold))
                    .foregroundStyle(.white)
                Text("Sign in coming soon")
                    .font(.caption)
                    .foregroundStyle(Color.podiumMuted)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 8)
    }

    private var statsRow: some View {
        VStack(spacing: 8) {
            HStack(spacing: 0) {
                statTile(value: tournaments.count, label: "Tournaments")
                statDivider
                statTile(value: totalMatchesPlayed, label: "Matches Played")
                statDivider
                statTile(value: distinctPlayerCount, label: "Unique Players")
            }
            Text("From tournaments stored on this device")
                .font(.caption2)
                .foregroundStyle(Color.podiumMuted.opacity(0.7))
        }
    }

    private var statDivider: some View {
        Rectangle()
            .fill(.white.opacity(0.08))
            .frame(width: 1, height: 36)
    }

    private func statTile(value: Int, label: String) -> some View {
        VStack(spacing: 4) {
            Text("\(value)")
                .font(.title3.weight(.bold))
                .foregroundStyle(.white)
            Text(label)
                .font(.caption2)
                .foregroundStyle(Color.podiumMuted)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
    }

    private var tournamentsSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            SectionHeading(title: "My Tournaments")
            VStack(spacing: 0) {
                ForEach(Array(recentTournaments.enumerated()), id: \.element.id) { index, tournament in
                    NavigationLink(value: tournament) {
                        TournamentRow(tournament: tournament)
                    }
                    .buttonStyle(.plain)
                    if index != recentTournaments.count - 1 {
                        Divider().overlay(.white.opacity(0.07))
                    }
                }
            }
        }
    }

    private var settingsSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            SectionHeading(title: "Settings")
            VStack(spacing: 0) {
                settingsRow(icon: "person.text.rectangle", title: "Personal Information") {
                    comingSoonMessage = "Personal profile fields will be available once accounts are live."
                }
                Divider().overlay(.white.opacity(0.07))
                settingsRow(icon: "slider.horizontal.3", title: "Preferences") {
                    comingSoonMessage = "App preferences are coming in a future update."
                }
                Divider().overlay(.white.opacity(0.07))
                settingsRow(icon: "questionmark.circle", title: "Help & Support") {
                    comingSoonMessage = "Support channels aren't set up yet, but they're on the roadmap."
                }
                Divider().overlay(.white.opacity(0.07))
                settingsRow(icon: "info.circle", title: "About Podium Results") {
                    isShowingAbout = true
                }
            }
        }
    }

    private func settingsRow(icon: String, title: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.subheadline)
                    .foregroundStyle(Color.podiumCopper)
                    .frame(width: 22)
                Text(title)
                    .font(.subheadline)
                    .foregroundStyle(.white)
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(Color.podiumMuted.opacity(0.5))
            }
            .padding(.vertical, 12)
        }
        .buttonStyle(.plain)
    }

    private var signOutButton: some View {
        Button {
            comingSoonMessage = "You're browsing as a guest, there's no account to sign out of yet."
        } label: {
            Text("Sign Out")
                .font(.headline)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
        }
        .foregroundStyle(.white)
        .background(Color.white.opacity(0.08))
        .clipShape(Capsule())
    }

    private var aboutSheet: some View {
        NavigationStack {
            ZStack {
                Color.podiumCharcoal.ignoresSafeArea()
                VStack(spacing: 10) {
                    Image(systemName: "crown.fill")
                        .font(.system(size: 34))
                        .foregroundStyle(Color.podiumCopper)
                    Text("PODIUM RESULTS")
                        .font(.caption.weight(.semibold))
                        .tracking(3)
                        .foregroundStyle(Color.podiumCopper)
                    Text("Version 1.0")
                        .font(.caption2)
                        .foregroundStyle(.white.opacity(0.4))
                    Text("A tournament app for chess: automatic schedules, real FIDE tiebreak standings, and a simple way for local clubs to run their events.")
                        .font(.footnote)
                        .foregroundStyle(Color.podiumMuted)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 30)
                        .padding(.top, 4)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { isShowingAbout = false }
                }
            }
        }
        .presentationDetents([.medium])
    }
}

#Preview {
    ProfileView()
        .modelContainer(for: [Tournament.self, Player.self, Match.self], inMemory: true)
}

