//
//  VaultApp.swift
//  Vault
//
//  Created by Dzmitry Zaitsau2 on 18/10/2025.
//

import SwiftUI
import SwiftData

@main
struct VaultApp: App {
    @StateObject private var authViewModel = AuthenticationViewModel()
    @StateObject private var subscriptionManager = SubscriptionManager()

    let modelContainer: ModelContainer

    init() {
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
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(authViewModel)
                .environmentObject(subscriptionManager)
                .modelContainer(modelContainer)
        }
    }
}
