import SwiftUI
import SwiftData
import UIKit

struct PreferencesView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var notifications: [AppNotification]
    @AppStorage("missedRoundPoints") private var missedRoundPoints = 0.5
    @State private var alertsAllowed = false
    @State private var didAskForAlerts = false

    private let service: NotificationServiceProtocol = LocalNotificationService()

    var body: some View {
        SettingsScreen(title: "Preferences") {
            SettingsGroup(title: "Notifications",
                          footer: "Get an alert on your phone when a round or a tournament ends.") {
                HStack(spacing: 12) {
                    SettingsIcon(name: "bell.badge.fill")
                    Text("Phone alerts")
                        .font(.body)
                        .foregroundStyle(.white)
                    Spacer()
                    if alertsAllowed {
                        Text("On").font(.subheadline).foregroundStyle(Color.podiumMuted)
                    } else {
                        Button(didAskForAlerts ? "Open Settings" : "Turn On") { turnOnAlerts() }
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(Color.podiumCopper)
                    }
                }
                .padding(.vertical, 12)
                SettingsDivider()
                Button(role: .destructive) {
                    notifications.forEach(modelContext.delete)
                } label: {
                    HStack(spacing: 12) {
                        SettingsIcon(name: "trash.fill", tint: Color(hex: 0xE8907A))
                        Text("Clear notification history")
                            .font(.body)
                            .foregroundStyle(.white)
                        Spacer()
                        Text("\(notifications.count)")
                            .font(.subheadline)
                            .foregroundStyle(Color.podiumMuted)
                    }
                    .padding(.vertical, 12)
                }
                .disabled(notifications.isEmpty)
            }

            SettingsGroup(title: "Late players",
                          footer: "Points a player gets for the rounds he missed when he joins after the tournament started. You can still change it each time you add a player.") {
                VStack(alignment: .leading, spacing: 10) {
                    HStack(spacing: 12) {
                        SettingsIcon(name: "person.badge.plus")
                        Text("Missed rounds")
                            .font(.body)
                            .foregroundStyle(.white)
                    }
                    Picker("Points for missed rounds", selection: $missedRoundPoints) {
                        Text("Half point").tag(0.5)
                        Text("No points").tag(0.0)
                    }
                    .pickerStyle(.segmented)
                    .environment(\.colorScheme, .dark)
                }
                .padding(.vertical, 12)
            }
        }
        .task { alertsAllowed = await service.isAllowed() }
    }

    private func turnOnAlerts() {
        Task {
            if didAskForAlerts, let url = URL(string: UIApplication.openSettingsURLString) {
                await UIApplication.shared.open(url)
                return
            }
            alertsAllowed = await service.requestPermission()
            didAskForAlerts = true
        }
    }
}
