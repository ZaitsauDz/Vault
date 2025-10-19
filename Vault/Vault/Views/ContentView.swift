import SwiftData
import SwiftUI

struct ContentView: View {
    @EnvironmentObject var authViewModel: AuthenticationViewModel
    @EnvironmentObject var subscriptionManager: SubscriptionManager
    @Query private var userPreferences: [UserPreferences]
    
    var body: some View {
        Group {
            switch authViewModel.authState {
            case .authenticated where hasCompletedOnboarding:
                MainTabView()
            case .authenticated:
                OnboardingFlow(onComplete: {
                    markOnboardingComplete()
                })
            case .authenticating:
                ProgressView("Authenticating...")
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color.vaultBackground)
            case .unauthenticated:
                AuthenticationView()
            case .guest:
                MainTabView()
            }
        }
        .onAppear {
            setupUserPreferences()
        }
    }
    
    private var hasCompletedOnboarding: Bool {
        userPreferences.first?.hasCompletedOnboarding ?? false
    }
    
    private func setupUserPreferences() {
        if userPreferences.isEmpty {
            let preferences = UserPreferences()
            // This will be saved when the model context is available
        }
    }
    
    private func markOnboardingComplete() {
        if let preferences = userPreferences.first {
            preferences.hasCompletedOnboarding = true
        }
    }
}
