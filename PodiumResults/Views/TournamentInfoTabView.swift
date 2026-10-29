import SwiftUI

struct TournamentInfoTabView: View {
    let tournament: Tournament
    let rounds: [Int]
    let currentRound: Int
    let onGenerateSchedule: () -> Void
    let onViewPairings: () -> Void

    var body: some View {
        VStack(spacing: 16) {
            if tournament.status == .live {
                liveRoundCard
            }
            infoCard
            actionButton
        }
    }

    private var liveRoundCard: some View {
        HStack(spacing: 12) {
            Image(systemName: "flag.checkered")
                .font(.headline)
                .foregroundStyle(Color.podiumCopper)
                .frame(width: 20)
            VStack(alignment: .leading, spacing: 2) {
                Text("Round \(currentRound)")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(Color.podiumEspresso)
                Text("In progress")
                    .font(.caption)
                    .foregroundStyle(Color.podiumCopper)
            }
            Spacer()
        }
        .padding(14)
        .background(Color.podiumCream)
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
    }

    private var infoCard: some View {
        VStack(spacing: 0) {
            infoRow(icon: "square.grid.3x3.fill", label: "Format", value: tournament.format)
            Divider().overlay(Color.podiumEspresso.opacity(0.1))
            infoRow(icon: "number", label: "Rounds", value: "\(max(rounds.count, 1))")
            if !tournament.timeControl.isEmpty {
                Divider().overlay(Color.podiumEspresso.opacity(0.1))
                infoRow(icon: "clock.fill", label: "Time Control", value: tournament.timeControl)
            }
            if !tournament.categories.isEmpty {
                Divider().overlay(Color.podiumEspresso.opacity(0.1))
                infoRow(icon: "person.3.fill", label: "Categories", value: tournament.categories)
            }
            if !tournament.arbiter.isEmpty {
                Divider().overlay(Color.podiumEspresso.opacity(0.1))
                infoRow(icon: "person.fill.checkmark", label: "Arbiter", value: tournament.arbiter)
            }
        }
        .background(Color.podiumCream)
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
    }

    private var actionButton: some View {
        Group {
            if tournament.matches.isEmpty {
                Button(action: onGenerateSchedule) {
                    Label("Generate Schedule", systemImage: "calendar.badge.clock")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                }
                .foregroundStyle(.white)
                .background(tournament.players.count < 2 ? Color.podiumCopper.opacity(0.4) : Color.podiumCopper)
                .clipShape(Capsule())
                .disabled(tournament.players.count < 2)
            } else {
                Button(action: onViewPairings) {
                    Text("View Pairings")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                }
                .foregroundStyle(.white)
                .background(Color.podiumCopper)
                .clipShape(Capsule())
            }
        }
    }

    private func infoRow(icon: String, label: String, value: String) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.subheadline)
                .foregroundStyle(Color.podiumCopper)
                .frame(width: 20)
            VStack(alignment: .leading, spacing: 2) {
                Text(label)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Text(value)
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(Color.podiumEspresso)
            }
            Spacer()
        }
        .padding(14)
    }
}
