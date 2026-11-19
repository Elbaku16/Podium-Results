import SwiftUI
import SwiftData

struct NotificationBell: View {
    @Query(filter: #Predicate<AppNotification> { !$0.isRead }) private var unread: [AppNotification]
    @State private var isShowing = false

    var body: some View {
        Button {
            isShowing = true
        } label: {
            Image(systemName: "bell.fill")
                .font(.system(size: 15))
                .foregroundStyle(.white.opacity(0.85))
                .frame(width: 36, height: 36)
                .background(Color.white.opacity(0.06))
                .clipShape(Circle())
                .overlay(alignment: .topTrailing) {
                    if !unread.isEmpty {
                        Circle()
                            .fill(Color.podiumCopper)
                            .frame(width: 10, height: 10)
                            .overlay(Circle().stroke(Color.podiumCharcoal, lineWidth: 2))
                    }
                }
        }
        .sheet(isPresented: $isShowing) {
            NotificationsView()
        }
    }
}
