import SwiftUI

struct ProfileSettingsCard: View {
    let onAbout: () -> Void
    let onComingSoon: (String) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Image(systemName: "slider.horizontal.3")
                    .foregroundStyle(Color.podiumCopper)
                Text("Settings")
                    .font(.headline)
                    .foregroundStyle(.white)
            }
            .padding(.bottom, 4)
            settingsRow(icon: "person.fill", title: "Personal Information") {
                onComingSoon("Personal profile fields will be available soon.")
            }
            Divider().overlay(.white.opacity(0.07))
            settingsRow(icon: "slider.horizontal.3", title: "Preferences") {
                onComingSoon("App preferences are coming in a future update.")
            }
            Divider().overlay(.white.opacity(0.07))
            settingsRow(icon: "questionmark.circle", title: "Help & Support") {
                onComingSoon("Support channels aren't set up yet, but they're on the roadmap.")
            }
            Divider().overlay(.white.opacity(0.07))
            settingsRow(icon: "info.circle", title: "About Podium Results") {
                onAbout()
            }
        }
        .padding(16)
        .profileCard()
    }

    private func settingsRow(icon: String, title: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: 14) {
                Image(systemName: icon)
                    .font(.body)
                    .foregroundStyle(Color.podiumCopper)
                    .frame(width: 24)
                Text(title)
                    .font(.body)
                    .foregroundStyle(.white)
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(Color.podiumMuted.opacity(0.6))
            }
            .padding(.vertical, 11)
        }
        .buttonStyle(.plain)
    }
}

struct ProfileAboutSheet: View {
    @Binding var isPresented: Bool

    var body: some View {
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
                    Button("Done") { isPresented = false }
                }
            }
        }
        .presentationDetents([.medium])
    }
}

extension View {
    func profileCard() -> some View {
        background(Color.white.opacity(0.05))
            .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
            .overlay(RoundedRectangle(cornerRadius: 18, style: .continuous).stroke(Color.podiumCopper.opacity(0.3), lineWidth: 1))
    }
}
