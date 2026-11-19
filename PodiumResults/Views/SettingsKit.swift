import SwiftUI

struct SettingsScreen<Content: View>: View {
    let title: String
    @ViewBuilder let content: Content

    var body: some View {
        ZStack {
            Color.podiumCharcoal.ignoresSafeArea()

            ScrollView {
                VStack(spacing: 22) { content }
                    .padding(.horizontal, 20)
                    .padding(.top, 12)
            }
            .contentMargins(.bottom, 110, for: .scrollContent)
        }
        .navigationTitle(title)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar(.visible, for: .navigationBar)
        .toolbarBackground(Color.podiumCharcoal, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .toolbarColorScheme(.dark, for: .navigationBar)
    }
}

struct SettingsGroup<Content: View>: View {
    var title: String? = nil
    var footer: String? = nil
    @ViewBuilder let content: Content

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            if let title {
                Text(title.uppercased())
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(Color.podiumMuted)
                    .padding(.leading, 4)
            }
            VStack(spacing: 0) { content }
                .padding(.horizontal, 16)
                .profileCard()
            if let footer {
                Text(footer)
                    .font(.caption)
                    .foregroundStyle(Color.podiumMuted)
                    .padding(.horizontal, 4)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

struct SettingsIcon: View {
    let name: String
    var tint: Color = .podiumCopper

    var body: some View {
        Image(systemName: name)
            .font(.system(size: 14, weight: .semibold))
            .foregroundStyle(tint)
            .frame(width: 30, height: 30)
            .background(tint.opacity(0.16))
            .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
    }
}

struct SettingsValueRow: View {
    let icon: String
    let title: String
    let value: String

    var body: some View {
        HStack(spacing: 12) {
            SettingsIcon(name: icon)
            Text(title)
                .font(.body)
                .foregroundStyle(.white)
            Spacer(minLength: 12)
            Text(value)
                .font(.subheadline)
                .foregroundStyle(Color.podiumMuted)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
        }
        .padding(.vertical, 12)
    }
}

struct SettingsDivider: View {
    var inset: CGFloat = 42

    var body: some View {
        Divider().overlay(.white.opacity(0.07)).padding(.leading, inset)
    }
}
