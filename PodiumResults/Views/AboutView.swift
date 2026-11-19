import SwiftUI

struct AboutView: View {
    private var version: String {
        let info = Bundle.main.infoDictionary
        let short = info?["CFBundleShortVersionString"] as? String ?? "1.0"
        let build = info?["CFBundleVersion"] as? String ?? "1"
        return "\(short) (\(build))"
    }

    var body: some View {
        SettingsScreen(title: "About") {
            VStack(spacing: 10) {
                Image("PodiumLogo")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 130)
                Text("Version \(version)")
                    .font(.footnote)
                    .foregroundStyle(Color.podiumMuted)
                Text("Run chess tournaments from your phone: pairings, results and standings in one place.")
                    .font(.subheadline)
                    .foregroundStyle(.white.opacity(0.8))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 24)
                    .padding(.top, 4)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 8)

            SettingsGroup {
                SettingsValueRow(icon: "person.fill", title: "Developer", value: "Lenin Cortez")
                SettingsDivider()
                SettingsValueRow(icon: "hammer.fill", title: "Built with", value: "SwiftUI \u{00B7} SwiftData \u{00B7} Firebase")
                SettingsDivider()
                SettingsValueRow(icon: "checkmark.seal.fill", title: "Tiebreaks", value: "FIDE rules")
            }

            SettingsGroup {
                Link(destination: URL(string: "https://github.com/Elbaku16/Podium-Results")!) {
                    HStack(spacing: 12) {
                        SettingsIcon(name: "chevron.left.forwardslash.chevron.right")
                        Text("Source code on GitHub")
                            .font(.body)
                            .foregroundStyle(.white)
                        Spacer()
                        Image(systemName: "arrow.up.right")
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(Color.podiumMuted.opacity(0.6))
                    }
                    .padding(.vertical, 12)
                }
            }

            Text("\u{00A9} 2026 Lenin Cortez")
                .font(.caption)
                .foregroundStyle(Color.podiumMuted.opacity(0.7))
        }
    }
}
