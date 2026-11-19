import SwiftUI
import SwiftData

struct NotificationsView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \AppNotification.date, order: .reverse) private var notifications: [AppNotification]
    @State private var alertsAllowed = true

    private let service: NotificationServiceProtocol = LocalNotificationService()

    var body: some View {
        NavigationStack {
            ZStack {
                Color.podiumCharcoal.ignoresSafeArea()

                if notifications.isEmpty {
                    emptyState
                } else {
                    ScrollView {
                        VStack(spacing: 0) {
                            if !alertsAllowed { alertsBanner }
                            ForEach(notifications) { item in
                                row(item)
                                if item.id != notifications.last?.id {
                                    Divider().overlay(.white.opacity(0.07))
                                }
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 8)
                    }
                }
            }
            .navigationTitle("Notifications")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(Color.podiumCharcoal, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    if !notifications.isEmpty {
                        Button("Clear") { notifications.forEach(modelContext.delete) }
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }
                }
            }
            .task {
                alertsAllowed = await service.isAllowed()
                notifications.filter { !$0.isRead }.forEach { $0.isRead = true }
            }
        }
        .tint(.podiumCopper)
    }

    private var emptyState: some View {
        VStack(spacing: 10) {
            Image(systemName: "bell.fill")
                .font(.system(size: 38))
                .foregroundStyle(Color.podiumCopper)
            Text("No Notifications Yet")
                .font(.headline)
                .foregroundStyle(.white)
            Text("When a round ends, a tournament finishes, or a player joins late, you will see it here.")
                .font(.subheadline)
                .foregroundStyle(.white.opacity(0.5))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
            if !alertsAllowed { alertsButton.padding(.top, 8) }
        }
    }

    private var alertsBanner: some View {
        HStack {
            Text("Get alerts on your phone too")
                .font(.subheadline)
                .foregroundStyle(.white)
            Spacer()
            alertsButton
        }
        .padding(14)
        .background(Color.white.opacity(0.06))
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
        .padding(.bottom, 8)
    }

    private var alertsButton: some View {
        Button {
            Task { alertsAllowed = await service.requestPermission() }
        } label: {
            Text("Turn On")
                .font(.subheadline.weight(.bold))
                .foregroundStyle(Color.podiumCharcoal)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(Color.podiumCopper)
                .clipShape(Capsule())
        }
    }

    private func row(_ item: AppNotification) -> some View {
        HStack(alignment: .top, spacing: 12) {
            ZStack {
                Circle().fill(Color.podiumCopper.opacity(0.16))
                Image(systemName: item.icon)
                    .font(.system(size: 14))
                    .foregroundStyle(Color.podiumCopper)
            }
            .frame(width: 36, height: 36)
            VStack(alignment: .leading, spacing: 3) {
                Text(item.title)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.white)
                Text(item.message)
                    .font(.footnote)
                    .foregroundStyle(Color.podiumMuted)
                Text(item.date.formatted(.relative(presentation: .named)))
                    .font(.caption2)
                    .foregroundStyle(Color.podiumMuted.opacity(0.7))
            }
            Spacer(minLength: 0)
        }
        .padding(.vertical, 12)
    }
}

#Preview {
    NotificationsView()
        .modelContainer(for: [AppNotification.self], inMemory: true)
}
