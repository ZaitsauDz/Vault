import SwiftUI
import SwiftData
import FirebaseAuth

struct SettingsView: View {
    @EnvironmentObject var authViewModel: AuthenticationViewModel
    @EnvironmentObject var subscriptionManager: SubscriptionManager
    @Query private var userPreferences: [UserPreferences]
    @State private var showingSubscriptionView = false
    @State private var showingLanguageSelector = false
    @State private var showingNotificationSettings = false
    
    var body: some View {
        NavigationView {
            List {
                // Profile Section
                Section {
                    HStack {
                        AsyncImage(url: authViewModel.currentUser?.photoURL) { image in
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                        } placeholder: {
                            Image(systemName: "person.circle.fill")
                                .font(.system(size: 50))
                                .foregroundColor(.gray)
                        }
                        .frame(width: 50, height: 50)
                        .clipShape(Circle())
                        
                        VStack(alignment: .leading) {
                            Text(authViewModel.currentUser?.displayName ?? "User")
                                .font(.headline)
                            Text(authViewModel.currentUser?.email ?? "")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                        
                        if subscriptionManager.isPro {
                            Text("PRO")
                                .font(.caption)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(Color.blue)
                                .cornerRadius(4)
                        } else {
                            Button("Upgrade to Pro") {
                                showingSubscriptionView = true
                            }
                            .font(.caption)
                            .foregroundColor(.blue)
                        }
                    }
                    .padding(.vertical, 8)
                }
                
                // App Settings
                Section("App Settings") {
                    Button(action: {
                        showingLanguageSelector = true
                    }) {
                        HStack {
                            Image(systemName: "globe")
                                .foregroundColor(.blue)
                            Text("Language")
                            Spacer()
                            Text(currentLanguage.displayName)
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    Button(action: {
                        showingNotificationSettings = true
                    }) {
                        HStack {
                            Image(systemName: "bell")
                                .foregroundColor(.blue)
                            Text("Notifications")
                            Spacer()
                            Image(systemName: "chevron.right")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                }
                
                // Subscription Section
                Section("Subscription") {
                    if subscriptionManager.isPro {
                        HStack {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.green)
                            Text("Pro Active")
                        }
                    } else {
                        Button(action: {
                            showingSubscriptionView = true
                        }) {
                            HStack {
                                Image(systemName: "crown")
                                    .foregroundColor(.blue)
                                Text("Upgrade to Pro")
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                    
                    Button("Restore Purchases") {
                        Task {
                            await subscriptionManager.restorePurchases()
                        }
                    }
                }
                
                // Account Section
                Section("Account") {
                    Button("Sign Out") {
                        Task {
                            await authViewModel.signOut()
                        }
                    }
                    .foregroundColor(.red)
                }
                
                // App Info
                Section("About") {
                    HStack {
                        Text("Version")
                        Spacer()
                        Text("1.0.0")
                            .foregroundColor(.secondary)
                    }
                    
                    HStack {
                        Text("Build")
                        Spacer()
                        Text("1")
                            .foregroundColor(.secondary)
                    }
                }
            }
            .navigationTitle("Settings")
        }
        .sheet(isPresented: $showingSubscriptionView) {
            SubscriptionView()
        }
        .sheet(isPresented: $showingLanguageSelector) {
            LanguageSelectorView()
        }
        .sheet(isPresented: $showingNotificationSettings) {
            NotificationSettingsView()
        }
    }
    
    private var currentLanguage: AppLanguage {
        userPreferences.first?.language ?? .english
    }
}

struct LanguageSelectorView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Query private var userPreferences: [UserPreferences]
    @State private var selectedLanguage: AppLanguage
    
    init() {
        // This is a workaround for @Query initialization in sheet
        self._selectedLanguage = State(initialValue: .english)
    }
    
    var body: some View {
        NavigationView {
            List {
                ForEach(AppLanguage.allCases, id: \.self) { language in
                    Button(action: {
                        selectedLanguage = language
                        saveLanguagePreference()
                    }) {
                        HStack {
                            Text(language.flag)
                                .font(.title)
                            
                            VStack(alignment: .leading) {
                                Text(language.displayName)
                                    .font(.headline)
                                    .foregroundColor(.primary)
                            }
                            
                            Spacer()
                            
                            if selectedLanguage == language {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(.blue)
                                    .font(.title2)
                            }
                        }
                        .padding(.vertical, 4)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
            .navigationTitle("Language")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
        .onAppear {
            selectedLanguage = userPreferences.first?.language ?? .english
        }
    }
    
    private func saveLanguagePreference() {
        let preferences = userPreferences.first ?? UserPreferences()
        preferences.language = selectedLanguage
        
        if userPreferences.isEmpty {
            modelContext.insert(preferences)
        }
        
        try? modelContext.save()
        dismiss()
    }
}

struct NotificationSettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Query private var userPreferences: [UserPreferences]
    @State private var notificationsEnabled: Bool
    @State private var notificationFrequency: NotificationFrequency
    
    init() {
        self._notificationsEnabled = State(initialValue: false)
        self._notificationFrequency = State(initialValue: .weekly)
    }
    
    var body: some View {
        NavigationView {
            List {
                Section {
                    Toggle("Enable Notifications", isOn: $notificationsEnabled)
                } header: {
                    Text("Notifications")
                } footer: {
                    Text("Get gentle reminders to engage with your saved content.")
                }
                
                if notificationsEnabled {
                    Section {
                        ForEach(NotificationFrequency.allCases, id: \.self) { frequency in
                            Button(action: {
                                notificationFrequency = frequency
                            }) {
                                HStack {
                                    Text(frequency.displayName)
                                    Spacer()
                                    if notificationFrequency == frequency {
                                        Image(systemName: "checkmark.circle.fill")
                                            .foregroundColor(.blue)
                                    }
                                }
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    } header: {
                        Text("Frequency")
                    }
                }
            }
            .navigationTitle("Notifications")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        saveNotificationPreferences()
                    }
                }
            }
        }
        .onAppear {
            notificationsEnabled = userPreferences.first?.notificationsEnabled ?? false
            notificationFrequency = userPreferences.first?.notificationFrequency ?? .weekly
        }
    }
    
    private func saveNotificationPreferences() {
        let preferences = userPreferences.first ?? UserPreferences()
        preferences.notificationsEnabled = notificationsEnabled
        preferences.notificationFrequency = notificationFrequency
        
        if userPreferences.isEmpty {
            modelContext.insert(preferences)
        }
        
        try? modelContext.save()
        dismiss()
    }
}

#Preview {
    SettingsView()
        .environmentObject(AuthenticationViewModel())
        .environmentObject(SubscriptionManager())
}
