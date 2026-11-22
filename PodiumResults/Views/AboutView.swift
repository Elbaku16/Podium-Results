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
                BrandLogo(width: 150)
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
                SettingsValueRow(icon: "hammer.fill", title: "Built with", value: "SwiftUI \u{00B7} SwiftData")
                SettingsDivider()
                SettingsValueRow(icon: "checkmark.seal.fill", title: "Tie-breaks", value: "FIDE C.07")
            }

            Text("\u{00A9} 2026 Lenin Cortez")
                .font(.caption)
                .foregroundStyle(Color.podiumMuted.opacity(0.7))
        }
    }
}
