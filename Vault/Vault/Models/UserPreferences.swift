import SwiftData
import Foundation

@Model
final class UserPreferences {
    var language: AppLanguage
    var notificationsEnabled: Bool
    var notificationFrequency: NotificationFrequency
    var isPro: Bool
    var subscriptionExpiryDate: Date?
    var hasCompletedOnboarding: Bool
    
    init() {
        self.language = .english
        self.notificationsEnabled = false
        self.notificationFrequency = .weekly
        self.isPro = false
        self.hasCompletedOnboarding = false
    }
}

enum AppLanguage: String, Codable, CaseIterable {
    case english = "en"
    case russian = "ru"
    
    var displayName: String {
        switch self {
        case .english: return "English"
        case .russian: return "Русский"
        }
    }
    
    var flag: String {
        switch self {
        case .english: return "🇺🇸"
        case .russian: return "🇷🇺"
        }
    }
}

enum NotificationFrequency: String, Codable, CaseIterable {
    case daily = "daily"
    case weekly = "weekly"
    case monthly = "monthly"
    
    var displayName: String {
        switch self {
        case .daily: return "Daily"
        case .weekly: return "Weekly"
        case .monthly: return "Monthly"
        }
    }
}
