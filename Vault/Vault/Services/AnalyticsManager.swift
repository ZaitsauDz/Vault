import OSLog

struct AnalyticsEvent {
    let name: String
    let parameters: [String: String]
}

actor AnalyticsManager {
    static let shared = AnalyticsManager()
    private let logger = Logger(subsystem: "com.vault.app", category: "analytics")
    
    func logEvent(_ event: AnalyticsEvent) {
        // Log to OSLog (stays on device)
        logger.info("Event: \(event.name), Parameters: \(event.parameters.description)")
        
        // Optionally aggregate anonymized metrics locally
        // NO third-party analytics services
    }
    
    func logItemSaved(category: ContentCategory, sourceType: SourceType) {
        let event = AnalyticsEvent(
            name: "item_saved",
            parameters: [
                "category": category.rawValue,
                "source_type": sourceType.rawValue
            ]
        )
        Task {
            await logEvent(event)
        }
    }
    
    func logItemDeleted(category: ContentCategory) {
        let event = AnalyticsEvent(
            name: "item_deleted",
            parameters: [
                "category": category.rawValue
            ]
        )
        Task {
            await logEvent(event)
        }
    }
    
    func logSubscriptionPurchased(productId: String) {
        let event = AnalyticsEvent(
            name: "subscription_purchased",
            parameters: [
                "product_id": productId
            ]
        )
        Task {
            await logEvent(event)
        }
    }
    
    func logShareExtensionUsed() {
        let event = AnalyticsEvent(
            name: "share_extension_used",
            parameters: [:]
        )
        Task {
            await logEvent(event)
        }
    }
}
