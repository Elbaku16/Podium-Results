import SwiftUI

struct SectionHeading: View {
    let title: String
    var seeAllAction: (() -> Void)? = nil

    var body: some View {
        HStack {
            Text(title.uppercased())
                .font(.caption.weight(.semibold))
                .foregroundStyle(Color.podiumMuted)
            Spacer()
            if let seeAllAction {
                Button("See all", action: seeAllAction)
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(Color.podiumCopper)
            }
        }
    }
}

struct StatusLabel: View {
    let status: TournamentStatus

    var body: some View {
        Text(status.rawValue)
            .font(.caption2.weight(.bold))
            .padding(.horizontal, 8)
            .padding(.vertical, 3)
            .foregroundStyle(status == .live ? .white : Color.podiumMuted)
            .background(status == .live ? Color.podiumCopper : Color.white.opacity(0.08))
            .clipShape(Capsule())
    }
}

struct EmptyStateView: View {
    let icon: String
    let title: String
    let message: String

    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 36))
                .foregroundStyle(Color.podiumCopper)
            Text(title)
                .font(.headline)
                .foregroundStyle(.white)
            Text(message)
                .font(.subheadline)
                .foregroundStyle(Color.podiumMuted)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 20)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 30)
    }
}

struct TournamentRow: View {
    let tournament: Tournament

    var body: some View {
        HStack(spacing: 14) {
            ZStack {
                Image("ChessBackdrop")
                    .resizable()
                    .scaledToFill()
                Color.black.opacity(0.35)
                Image(systemName: tournament.icon)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.white)
            }
            .frame(width: 50, height: 50)
            .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))

            VStack(alignment: .leading, spacing: 5) {
                HStack(alignment: .top, spacing: 8) {
                    Text(tournament.name)
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(.white)
                        .lineLimit(1)
                    Spacer(minLength: 8)
                    StatusLabel(status: tournament.status)
                }
                HStack(spacing: 10) {
                    if !tournament.location.isEmpty {
                        Label(tournament.location, systemImage: "mappin.and.ellipse")
                    }
                    Label(tournament.date.formatted(date: .abbreviated, time: .omitted), systemImage: "calendar")
                }
                .font(.caption2)
                .foregroundStyle(Color.podiumMuted)
                .lineLimit(1)
            }

            Image(systemName: "chevron.right")
                .font(.caption.weight(.semibold))
                .foregroundStyle(Color.podiumMuted.opacity(0.5))
        }
        .padding(.vertical, 14)
        .contentShape(Rectangle())
    }
}

