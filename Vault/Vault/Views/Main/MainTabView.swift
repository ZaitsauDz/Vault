import SwiftUI
import _SwiftData_SwiftUI
import GoogleMobileAds

struct MainTabView: View {
    @EnvironmentObject var subscriptionManager: SubscriptionManager
    @Query private var userPreferences: [UserPreferences]
    
    var body: some View {
        VStack {
            TabView {
                ContentListView(category: .watch)
                    .tabItem {
                        Label("Watch", systemImage: "play.rectangle")
                    }

                ContentListView(category: .read)
                    .tabItem {
                        Label("Read", systemImage: "book")
                    }

                ContentListView(category: .buy)
                    .tabItem {
                        Label("Buy", systemImage: "cart")
                    }

                ContentListView(category: .cook)
                    .tabItem {
                        Label("Cook", systemImage: "fork.knife")
                    }

                SettingsView()
                    .tabItem {
                        Label("Settings", systemImage: "gear")
                    }
            }
            if !subscriptionManager.isPro {
                let adSize = currentOrientationAnchoredAdaptiveBanner(width: 375)
                AdBannerView(adSize)
                    .frame(width: adSize.size.width, height: adSize.size.height)
            }
        }
    }
}
