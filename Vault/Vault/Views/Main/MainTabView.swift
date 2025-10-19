import SwiftUI
import _SwiftData_SwiftUI

struct MainTabView: View {
    @EnvironmentObject var subscriptionManager: SubscriptionManager
    @Query private var userPreferences: [UserPreferences]
    
    var body: some View {
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
        .overlay(alignment: .bottom) {
            if !subscriptionManager.isPro {
                AdBannerView()
                    .frame(height: 50)
            }
        }
    }
}
