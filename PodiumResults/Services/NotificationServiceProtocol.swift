import Foundation

protocol NotificationServiceProtocol {
    func isAllowed() async -> Bool
    func requestPermission() async -> Bool
    func deliver(title: String, body: String)
}
