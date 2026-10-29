import SwiftUI

struct HomeActivityItem: Identifiable {
    let tournament: Tournament
    let icon: String
    let message: String
    var id: UUID { tournament.id }
}

struct HomeRecentActivityView: View {
    let items: [HomeActivityItem]

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            SectionHeading(title: "Recent Activity")
            VStack(spacing: 0) {
                ForEach(Array(items.enumerated()), id: \.element.id) { index, item in
                    NavigationLink(value: item.tournament) {
                        row(item)
                    }
                    .buttonStyle(.plain)
                    if index != items.count - 1 {
                        Divider().overlay(.white.opacity(0.07))
                    }
                }
            }
        }
    }

    private func row(_ item: HomeActivityItem) -> some View {
        HStack(spacing: 12) {
            ZStack {
                Circle().fill(Color.podiumCopper.opacity(0.16))
                Image(systemName: item.icon)
                    .font(.system(size: 14))
                    .foregroundStyle(Color.podiumCopper)
            }
            .frame(width: 34, height: 34)
            VStack(alignment: .leading, spacing: 1) {
                Text(item.tournament.name)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.white)
                    .lineLimit(1)
                Text(item.message)
                    .font(.caption)
                    .foregroundStyle(Color.podiumMuted)
            }
            Spacer()
            Image(systemName: "chevron.right")
                .font(.caption.weight(.semibold))
                .foregroundStyle(Color.podiumMuted.opacity(0.5))
        }
        .padding(.vertical, 10)
    }
}
