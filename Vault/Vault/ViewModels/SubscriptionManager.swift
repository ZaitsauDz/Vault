import StoreKit
import SwiftUI
import Combine

@MainActor
final class SubscriptionManager: ObservableObject {
    @Published private(set) var isPro: Bool = false
    @Published private(set) var products: [Product] = []
    @Published private(set) var purchasedProductIDs: Set<String> = []
    @Published private(set) var isLoading: Bool = false
    
    private let productIDs: [String] = [
        "com.vault.pro.monthly",
        "com.vault.pro.yearly",
        "com.vault.pro.lifetime"
    ]
    
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        Task {
            await loadProducts()
            await updatePurchasedProducts()
        }
        
        // Listen for transaction updates
        Task {
            for await result in Transaction.updates {
                do {
                    let transaction = try checkVerified(result)
                    await updatePurchasedProducts()
                    await transaction.finish()
                } catch {
                    print("Transaction verification failed: \(error)")
                }
            }
        }
    }
    
    func loadProducts() async {
        do {
            products = try await Product.products(for: productIDs)
        } catch {
            print("Failed to load products: \(error)")
        }
    }
    
    func purchase(_ product: Product) async throws -> StoreKit.Transaction? {
        isLoading = true
        defer { isLoading = false }
        
        let result = try await product.purchase()
        
        switch result {
        case .success(let verification):
            let transaction = try checkVerified(verification)
            await updatePurchasedProducts()
            await transaction.finish()
            return transaction
            
        case .userCancelled:
            return nil
            
        case .pending:
            return nil
            
        @unknown default:
            return nil
        }
    }
    
    func updatePurchasedProducts() async {
        var purchasedIDs: Set<String> = []
        
        for await result in Transaction.currentEntitlements {
            guard case .verified(let transaction) = result else {
                continue
            }
            
            if transaction.revocationDate == nil {
                purchasedIDs.insert(transaction.productID)
            }
        }
        
        self.purchasedProductIDs = purchasedIDs
        self.isPro = !purchasedIDs.isEmpty
    }
    
    func restorePurchases() async {
        isLoading = true
        defer { isLoading = false }
        
        try? await AppStore.sync()
        await updatePurchasedProducts()
    }
    
    private func checkVerified<T>(_ result: VerificationResult<T>) throws -> T {
        switch result {
        case .unverified:
            throw StoreError.failedVerification
        case .verified(let safe):
            return safe
        }
    }
    
    // Helper methods for UI
    func getProduct(for id: String) -> Product? {
        return products.first { $0.id == id }
    }
    
    func getMonthlyProduct() -> Product? {
        return getProduct(for: "com.vault.pro.monthly")
    }
    
    func getYearlyProduct() -> Product? {
        return getProduct(for: "com.vault.pro.yearly")
    }
    
    func getLifetimeProduct() -> Product? {
        return getProduct(for: "com.vault.pro.lifetime")
    }
}

enum StoreError: Error {
    case failedVerification
    case purchaseFailed
    case restoreFailed
    
    var localizedDescription: String {
        switch self {
        case .failedVerification:
            return "Purchase verification failed"
        case .purchaseFailed:
            return "Purchase failed"
        case .restoreFailed:
            return "Restore purchases failed"
        }
    }
}
