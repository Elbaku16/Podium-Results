import Foundation
import SwiftData

@Model
final class AppNotification {
    var id: UUID
    var title: String
    var message: String
    var icon: String
    var date: Date
    var isRead: Bool

    init(title: String, message: String, icon: String) {
        self.id = UUID()
        self.title = title
        self.message = message
        self.icon = icon
        self.date = .now
        self.isRead = false
    }
}
