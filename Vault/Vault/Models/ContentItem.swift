import Foundation
import SwiftData

@Model
final class ContentItem {
    @Attribute(.unique) var id: UUID
    var title: String
    var itemDescription: String?
    var imageURL: URL?
    var sourceURL: URL
    var category: String
    var sourceType: String
    var dateAdded: Date
    var dateModified: Date
    var isCompleted: Bool
    var customNotes: String?
    var subcategory: String?
    
    init(title: String,
         sourceURL: URL,
         category: String,
         sourceType: String)
    {
        self.id = UUID()
        self.title = title
        self.sourceURL = sourceURL
        self.category = category
        self.sourceType = sourceType
        self.dateAdded = Date()
        self.dateModified = Date()
        self.isCompleted = false
    }
}

enum ContentCategory: String, Codable, CaseIterable {
    case watch
    case read
    case buy
    case cook
    
    var displayName: String {
        switch self {
        case .watch: return "Watch Later"
        case .read: return "Read Later"
        case .buy: return "Buy Later"
        case .cook: return "Cook Later"
        }
    }
    
    var icon: String {
        switch self {
        case .watch: return "play.rectangle"
        case .read: return "book"
        case .buy: return "cart"
        case .cook: return "fork.knife"
        }
    }
}

enum SourceType: String, Codable, CaseIterable {
    case youtube
    case instagram
    case amazon
    case appleBooks
    case unknown
    
    var displayName: String {
        switch self {
        case .youtube: return "YouTube"
        case .instagram: return "Instagram"
        case .amazon: return "Amazon"
        case .appleBooks: return "Apple Books"
        case .unknown: return "Unknown"
        }
    }
    
    var icon: String {
        switch self {
        case .youtube: return "play.rectangle.fill"
        case .instagram: return "camera.fill"
        case .amazon: return "cart.fill"
        case .appleBooks: return "book.fill"
        case .unknown: return "link"
        }
    }
    
    var isFreeSource: Bool {
        switch self {
        case .youtube, .instagram, .amazon, .appleBooks:
            return true
        case .unknown:
            return false
        }
    }
}
