import UserNotifications
import SwiftUI
import SwiftData
import Combine

@MainActor
final class NotificationManager: ObservableObject {
    @Published var isAuthorized = false
    @Published var authorizationStatus: UNAuthorizationStatus = .notDetermined
    
    private let notificationCenter = UNUserNotificationCenter.current()
    
    init() {
        checkAuthorizationStatus()
    }
    
    func checkAuthorizationStatus() {
        notificationCenter.getNotificationSettings { [weak self] settings in
            DispatchQueue.main.async {
                self?.authorizationStatus = settings.authorizationStatus
                self?.isAuthorized = settings.authorizationStatus == .authorized
            }
        }
    }
    
    func requestAuthorization() async {
        do {
            let granted = try await notificationCenter.requestAuthorization(options: [.alert, .sound, .badge])
            isAuthorized = granted
            authorizationStatus = granted ? .authorized : .denied
        } catch {
            print("Failed to request notification authorization: \(error)")
        }
    }
    
    func scheduleRandomReminders(for items: [ContentItem], frequency: NotificationFrequency) {
        guard isAuthorized && !items.isEmpty else { return }
        
        // Remove existing notifications
        notificationCenter.removeAllPendingNotificationRequests()
        
        // Calculate number of notifications based on frequency
        let notificationCount = getNotificationCount(for: frequency)
        let selectedItems = items.shuffled().prefix(notificationCount)
        
        for (index, item) in selectedItems.enumerated() {
            scheduleNotification(for: item, delay: index)
        }
    }
    
    private func getNotificationCount(for frequency: NotificationFrequency) -> Int {
        switch frequency {
        case .daily:
            return 1
        case .weekly:
            return 3
        case .monthly:
            return 1
        }
    }
    
    private func scheduleNotification(for item: ContentItem, delay: Int) {
        let content = UNMutableNotificationContent()
        content.title = getNotificationTitle(for: item.category)
        content.body = item.title
        content.sound = .default
        content.userInfo = [
            "itemId": item.id.uuidString,
            "category": item.category.rawValue
        ]
        
        // Attach image if available
        if let imageURL = item.imageURL {
            Task {
                if let attachment = try? await createAttachment(from: imageURL) {
                    content.attachments = [attachment]
                }
            }
        }
        
        // Schedule notification based on frequency
        let trigger = createTrigger(for: delay)
        
        let request = UNNotificationRequest(
            identifier: "reminder-\(item.id.uuidString)-\(delay)",
            content: content,
            trigger: trigger
        )
        
        notificationCenter.add(request) { error in
            if let error = error {
                print("Failed to schedule notification: \(error)")
            }
        }
    }
    
    private func createTrigger(for delay: Int) -> UNNotificationTrigger {
        // Schedule notifications at different times
        let hour = 10 + (delay * 2) // 10 AM, 12 PM, 2 PM, etc.
        let minute = Int.random(in: 0...59)
        
        var dateComponents = DateComponents()
        dateComponents.hour = hour
        dateComponents.minute = minute
        
        return UNCalendarNotificationTrigger(
            dateMatching: dateComponents,
            repeats: true
        )
    }
    
    private func getNotificationTitle(for category: ContentCategory) -> String {
        switch category {
        case .watch:
            return "Remember to watch!"
        case .read:
            return "Remember to read!"
        case .buy:
            return "Remember to buy!"
        case .cook:
            return "Remember to cook!"
        }
    }
    
    private func createAttachment(from imageURL: URL) async throws -> UNNotificationAttachment {
        let (data, _) = try await URLSession.shared.data(from: imageURL)
        let tempDirectory = FileManager.default.temporaryDirectory
        let tempFile = tempDirectory.appendingPathComponent(UUID().uuidString + ".jpg")
        try data.write(to: tempFile)
        return try UNNotificationAttachment(
            identifier: UUID().uuidString,
            url: tempFile,
            options: nil
        )
    }
    
    func cancelAllNotifications() {
        notificationCenter.removeAllPendingNotificationRequests()
    }
    
    func getPendingNotifications() async -> [UNNotificationRequest] {
        return await notificationCenter.pendingNotificationRequests()
    }
}
