import SwiftUI

struct TournamentInfoTabView: View {
    let tournament: Tournament
    let rounds: [Int]
    let currentRound: Int
    let onGenerateSchedule: () -> Void
    let onPairNextRound: () -> Void
    let onViewPairings: () -> Void
    let onAddPlayer: () -> Void
    let publishState: PublishViewModel.State
    let onPublish: () -> Void
    let onUnpublish: () -> Void
    let onExport: () -> Void

    var body: some View {
        VStack(spacing: 16) {
            if tournament.status == .live {
                liveRoundCard
            }
            infoCard
            actionButton
            publishSection
            if !tournament.matches.isEmpty {
                Button(action: onExport) {
                    Label("Export Results (PDF)", systemImage: "square.and.arrow.up")
                        .font(.subheadline.weight(.semibold))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                }
                .foregroundStyle(.white)
                .background(Color.white.opacity(0.1))
                .clipShape(Capsule())
            }
            if tournament.acceptsPlayers {
                Button(action: onAddPlayer) {
                    Label("Add Player", systemImage: "person.badge.plus")
                        .font(.subheadline.weight(.semibold))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                }
                .foregroundStyle(Color.podiumCopper)
                .overlay(Capsule().stroke(Color.podiumCopper.opacity(0.6), lineWidth: 1))
            }
        }
    }

    private var publishSection: some View {
        let isPublished = tournament.publishedAt != nil
        return VStack(spacing: 8) {
            Button(action: onPublish) {
                Label(isPublished ? "Update Online" : "Publish Online",
                      systemImage: isPublished ? "checkmark.icloud" : "icloud.and.arrow.up")
                    .font(.subheadline.weight(.semibold))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
            }
            .foregroundStyle(.white)
            .background(Color.white.opacity(0.1))
            .clipShape(Capsule())
            .disabled(tournament.matches.isEmpty || publishState == .publishing)

            if publishState == .publishing {
                Text("Publishing...").font(.caption).foregroundStyle(Color.podiumMuted)
            } else if case .failed(let message) = publishState {
                Text(message).font(.caption).foregroundStyle(Color.podiumCopper)
            } else if let publishedAt = tournament.publishedAt {
                Text("Online \u{00B7} updated \(publishedAt.formatted(.relative(presentation: .named)))")
                    .font(.caption).foregroundStyle(Color.podiumMuted)
            }

            if isPublished && publishState != .publishing {
                Button("Remove from Online", role: .destructive, action: onUnpublish)
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(Color.podiumCopper)
            } else if tournament.matches.isEmpty {
                Text("Generate the schedule first to publish.").font(.caption).foregroundStyle(Color.podiumMuted)
            }
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
                    .foregroundStyle(.white)
                Text(tournament.nextSwissRound.map { "Finished. Round \($0) is ready to pair." } ?? "In progress")
                    .font(.caption)
                    .foregroundStyle(Color.podiumCopper)
            }
            Spacer()
        }
        .padding(14)
        .background(Color.white.opacity(0.06))
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
    }

    private var infoCard: some View {
        VStack(spacing: 0) {
            infoRow(icon: "square.grid.3x3.fill", label: "Format", value: tournament.format)
            Divider().overlay(.white.opacity(0.07))
            infoRow(icon: "number", label: "Rounds", value: roundsText)
            if !tournament.timeControl.isEmpty {
                Divider().overlay(.white.opacity(0.07))
                infoRow(icon: "clock.fill", label: "Time Control", value: tournament.timeControl)
            }
            if !tournament.categories.isEmpty {
                Divider().overlay(.white.opacity(0.07))
                infoRow(icon: "person.3.fill", label: "Categories", value: tournament.categories)
            }
            if !tournament.arbiter.isEmpty {
                Divider().overlay(.white.opacity(0.07))
                infoRow(icon: "person.fill.checkmark", label: "Arbiter", value: tournament.arbiter)
            }
        }
        .background(Color.white.opacity(0.06))
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
    }

    private var roundsText: String {
        if tournament.isSwiss {
            return tournament.matches.isEmpty ? "\(tournament.totalRounds)" : "\(tournament.latestRound) of \(tournament.totalRounds)"
        }
        return "\(max(rounds.count, 1))"
    }

    private var actionButton: some View {
        VStack(spacing: 10) {
            if tournament.matches.isEmpty {
                primaryButton(tournament.isSwiss ? "Pair Round 1" : "Generate Schedule",
                              icon: "calendar.badge.clock",
                              isEnabled: tournament.players.count >= 2,
                              action: onGenerateSchedule)
            } else if let next = tournament.nextSwissRound {
                primaryButton("Pair Round \(next)", icon: "arrow.triangle.2.circlepath", isEnabled: true, action: onPairNextRound)
                Button(action: onViewPairings) {
                    Text("View Pairings")
                        .font(.subheadline.weight(.semibold))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                }
                .foregroundStyle(Color.podiumCopper)
                .overlay(Capsule().stroke(Color.podiumCopper.opacity(0.6), lineWidth: 1))
            } else {
                primaryButton("View Pairings", icon: nil, isEnabled: true, action: onViewPairings)
            }
        }
    }

    private func primaryButton(_ title: String, icon: String?, isEnabled: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Group {
                if let icon { Label(title, systemImage: icon) } else { Text(title) }
            }
            .font(.headline)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
        }
        .foregroundStyle(.white)
        .background(isEnabled ? Color.podiumCopper : Color.podiumCopper.opacity(0.4))
        .clipShape(Capsule())
        .disabled(!isEnabled)
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
                    .foregroundStyle(Color.podiumMuted)
                Text(value)
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(.white)
            }
            Spacer()
        }
        .padding(14)
    }
}
