import SwiftUI
import StoreKit

struct SubscriptionView: View {
    @EnvironmentObject var subscriptionManager: SubscriptionManager
    @Environment(\.dismiss) private var dismiss
    @State private var isPurchasing = false
    @State private var showingError = false
    @State private var errorMessage = ""
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 32) {
                    // Header
                    VStack(spacing: 16) {
                        Image(systemName: "crown.fill")
                            .font(.system(size: 60))
                            .foregroundColor(.blue)
                        
                        Text("Upgrade to Pro")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                        
                        Text("Unlock unlimited storage and premium features")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .padding(.top, 20)
                    
                    // Features
                    VStack(spacing: 16) {
                        ProFeatureRow(icon: "infinity", text: "Unlimited items")
                        ProFeatureRow(icon: "nosign", text: "No advertisements")
                        ProFeatureRow(icon: "link", text: "Support for all sources")
                        ProFeatureRow(icon: "icloud", text: "iCloud sync")
                        ProFeatureRow(icon: "person.2", text: "Family sharing")
                    }
                    .padding(.horizontal, 32)
                    
                    // Pricing Options
                    VStack(spacing: 16) {
                        if let monthlyProduct = subscriptionManager.getMonthlyProduct() {
                            SubscriptionProductCard(
                                product: monthlyProduct,
                                isPopular: false,
                                isPurchasing: $isPurchasing
                            )
                        }
                        
                        if let yearlyProduct = subscriptionManager.getYearlyProduct() {
                            SubscriptionProductCard(
                                product: yearlyProduct,
                                isPopular: true,
                                isPurchasing: $isPurchasing
                            )
                        }
                        
                        if let lifetimeProduct = subscriptionManager.getLifetimeProduct() {
                            SubscriptionProductCard(
                                product: lifetimeProduct,
                                isPopular: false,
                                isPurchasing: $isPurchasing
                            )
                        }
                    }
                    .padding(.horizontal, 32)
                    
                    // Restore Purchases
                    Button("Restore Purchases") {
                        Task {
                            await subscriptionManager.restorePurchases()
                        }
                    }
                    .font(.subheadline)
                    .foregroundColor(.blue)
                    
                    Spacer(minLength: 20)
                }
            }
            .navigationTitle("Pro Features")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") {
                        dismiss()
                    }
                }
            }
            .alert("Error", isPresented: $showingError) {
                Button("OK") { }
            } message: {
                Text(errorMessage)
            }
        }
    }
}

struct ProFeatureRow: View {
    let icon: String
    let text: String
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(.blue)
                .frame(width: 30)
            
            Text(text)
                .font(.body)
            
            Spacer()
        }
    }
}

struct SubscriptionProductCard: View {
    let product: Product
    let isPopular: Bool
    @Binding var isPurchasing: Bool
    @EnvironmentObject var subscriptionManager: SubscriptionManager
    
    var body: some View {
        VStack(spacing: 12) {
            if isPopular {
                Text("MOST POPULAR")
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 4)
                    .background(Color.blue)
                    .cornerRadius(12)
            }
            
            VStack(spacing: 8) {
                Text(product.displayName)
                    .font(.headline)
                    .fontWeight(.semibold)
                
                Text(product.description)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                
                Text(product.displayPrice)
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.blue)
            }
            
            Button(action: purchase) {
                if isPurchasing {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                } else {
                    Text("Subscribe")
                        .fontWeight(.semibold)
                }
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .frame(height: 44)
            .background(Color.blue)
            .cornerRadius(22)
            .disabled(isPurchasing)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemGray6))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(isPopular ? Color.blue : Color.clear, lineWidth: 2)
                )
        )
    }
    
    private func purchase() {
        isPurchasing = true
        Task {
            do {
                _ = try await subscriptionManager.purchase(product)
                // Purchase successful - UI will update automatically
            } catch {
                // Handle error
            }
            isPurchasing = false
        }
    }
}

#Preview {
    SubscriptionView()
        .environmentObject(SubscriptionManager())
}
