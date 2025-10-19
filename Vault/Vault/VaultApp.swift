//
//  VaultApp.swift
//  Vault
//
//  Created by Dzmitry Zaitsau2 on 18/10/2025.
//

import AppTrackingTransparency
import FirebaseCore
import GoogleMobileAds
import SwiftData
import SwiftUI

@main
struct VaultApp: App {
    @StateObject private var authViewModel: AuthenticationViewModel
    @StateObject private var subscriptionManager: SubscriptionManager

    let modelContainer: ModelContainer

    init() {
        FirebaseApp.configure()
        MobileAds.shared.start()

        let authVM = AuthenticationViewModel()
        let subManager = SubscriptionManager()
        _authViewModel = StateObject(wrappedValue: authVM)
        _subscriptionManager = StateObject(wrappedValue: subManager)

        do {
            let configuration = ModelConfiguration(
                groupContainer: .identifier("group.com.vault.digitalcontent")
            )
            modelContainer = try ModelContainer(
                for: ContentItem.self, UserPreferences.self,
                configurations: configuration
            )
        } catch {
            fatalError("Failed to initialize ModelContainer: \(error)")
        }
        requestAppTrackingConsent(completion: nil)
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(authViewModel)
                .environmentObject(subscriptionManager)
                .modelContainer(modelContainer)
        }
    }

    public func requestAppTrackingConsent(completion: ((Bool) -> Void)?) {
        ATTrackingManager.requestTrackingAuthorization(completionHandler: { status in
            completion?(status == .authorized)
        })
    }
}
