import SwiftUI

enum ProfileDestination: Hashable {
    case personal, preferences, help, about
}

struct ProfileSettingsCard: View {
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

            row(.personal, icon: "person.fill", title: "Personal Information")
            SettingsDivider()
            row(.preferences, icon: "slider.horizontal.3", title: "Preferences")
            SettingsDivider()
            row(.help, icon: "questionmark.circle", title: "Help & Support")
            SettingsDivider()
            row(.about, icon: "info.circle", title: "About Podium Results")
        }
        .padding(16)
        .profileCard()
    }

    private func row(_ destination: ProfileDestination, icon: String, title: String) -> some View {
        NavigationLink(value: destination) {
            HStack(spacing: 12) {
                SettingsIcon(name: icon)
                Text(title)
                    .font(.body)
                    .foregroundStyle(.white)
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(Color.podiumMuted.opacity(0.6))
            }
            .padding(.vertical, 10)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}

extension View {
    func profileCard() -> some View {
        background(Color.white.opacity(0.05))
            .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
            .overlay(RoundedRectangle(cornerRadius: 18, style: .continuous).stroke(Color.podiumCopper.opacity(0.3), lineWidth: 1))
    }
}
