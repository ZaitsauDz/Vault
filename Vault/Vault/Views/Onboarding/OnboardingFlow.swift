import SwiftUI
import _SwiftData_SwiftUI

struct OnboardingFlow: View {
    let onComplete: () -> Void
    @State private var currentStep = 0
    @State private var selectedLanguage: AppLanguage = .english
    @State private var notificationsEnabled = false
    @State private var notificationFrequency: NotificationFrequency = .weekly
    @Environment(\.modelContext) private var modelContext
    @Query private var userPreferences: [UserPreferences]
    
    private let totalSteps = 3
    
    var body: some View {
        VStack {
            // Progress Indicator
            HStack {
                ForEach(0..<totalSteps, id: \.self) { step in
                    Circle()
                        .fill(step <= currentStep ? Color.blue : Color.gray.opacity(0.3))
                        .frame(width: 8, height: 8)
                }
            }
            .padding(.top, 20)
            
            Spacer()
            
            // Content
            TabView(selection: $currentStep) {
                // Step 1: Welcome
                WelcomeStep()
                    .tag(0)
                
                // Step 2: Language Selection
                LanguageSelectionStep(selectedLanguage: $selectedLanguage)
                    .tag(1)
                
                // Step 3: Notification Preferences
                NotificationPreferencesStep(
                    notificationsEnabled: $notificationsEnabled,
                    notificationFrequency: $notificationFrequency
                )
                    .tag(2)
            }
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
            
            Spacer()
            
            // Navigation Buttons
            HStack {
                if currentStep > 0 {
                    Button("Back") {
                        withAnimation {
                            currentStep -= 1
                        }
                    }
                    .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Button(currentStep == totalSteps - 1 ? "Get Started" : "Next") {
                    if currentStep == totalSteps - 1 {
                        savePreferences()
                        onComplete()
                    } else {
                        withAnimation {
                            currentStep += 1
                        }
                    }
                }
                .fontWeight(.semibold)
                .foregroundColor(.white)
                .frame(width: 120, height: 44)
                .background(Color.blue)
                .cornerRadius(22)
            }
            .padding(.horizontal, 32)
            .padding(.bottom, 40)
        }
        .navigationBarHidden(true)
    }
    
    private func savePreferences() {
        let preferences = userPreferences.first ?? UserPreferences()
        preferences.language = selectedLanguage
        preferences.notificationsEnabled = notificationsEnabled
        preferences.notificationFrequency = notificationFrequency
        preferences.hasCompletedOnboarding = true
        
        if userPreferences.isEmpty {
            modelContext.insert(preferences)
        }
        
        try? modelContext.save()
    }
}

struct WelcomeStep: View {
    var body: some View {
        VStack(spacing: 32) {
            Image(systemName: "square.stack.3d.up.fill")
                .font(.system(size: 100))
                .foregroundColor(.blue)
            
            VStack(spacing: 16) {
                Text("Welcome to Vault")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .multilineTextAlignment(.center)
                
                Text("Organize your digital content across four categories: Watch Later, Read Later, Buy Later, and Cook Later.")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
            }
            
            VStack(spacing: 16) {
                FeatureRow(icon: "play.rectangle", title: "Watch Later", description: "Save videos, movies, and shows")
                FeatureRow(icon: "book", title: "Read Later", description: "Save articles, books, and posts")
                FeatureRow(icon: "cart", title: "Buy Later", description: "Save products and shopping items")
                FeatureRow(icon: "fork.knife", title: "Cook Later", description: "Save recipes and cooking content")
            }
            .padding(.horizontal, 32)
        }
    }
}

struct LanguageSelectionStep: View {
    @Binding var selectedLanguage: AppLanguage
    
    var body: some View {
        VStack(spacing: 32) {
            Image(systemName: "globe")
                .font(.system(size: 80))
                .foregroundColor(.blue)
            
            VStack(spacing: 16) {
                Text("Choose Your Language")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .multilineTextAlignment(.center)
                
                Text("Select your preferred language for the app interface.")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
            }
            
            VStack(spacing: 16) {
                ForEach(AppLanguage.allCases, id: \.self) { language in
                    LanguageOption(
                        language: language,
                        isSelected: selectedLanguage == language
                    ) {
                        selectedLanguage = language
                    }
                }
            }
            .padding(.horizontal, 32)
        }
    }
}

struct NotificationPreferencesStep: View {
    @Binding var notificationsEnabled: Bool
    @Binding var notificationFrequency: NotificationFrequency
    
    var body: some View {
        VStack(spacing: 32) {
            Image(systemName: "bell")
                .font(.system(size: 80))
                .foregroundColor(.blue)
            
            VStack(spacing: 16) {
                Text("Notification Preferences")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .multilineTextAlignment(.center)
                
                Text("Get gentle reminders to engage with your saved content.")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
            }
            
            VStack(spacing: 24) {
                Toggle("Enable Notifications", isOn: $notificationsEnabled)
                    .font(.headline)
                
                if notificationsEnabled {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Reminder Frequency")
                            .font(.headline)
                        
                        ForEach(NotificationFrequency.allCases, id: \.self) { frequency in
                            FrequencyOption(
                                frequency: frequency,
                                isSelected: notificationFrequency == frequency
                            ) {
                                notificationFrequency = frequency
                            }
                        }
                    }
                }
            }
            .padding(.horizontal, 32)
        }
    }
}

struct FeatureRow: View {
    let icon: String
    let title: String
    let description: String
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(.blue)
                .frame(width: 30)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                Text(description)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
        }
    }
}

struct LanguageOption: View {
    let language: AppLanguage
    let isSelected: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack {
                Text(language.flag)
                    .font(.title)
                
                VStack(alignment: .leading) {
                    Text(language.displayName)
                        .font(.headline)
                        .foregroundColor(.primary)
                }
                
                Spacer()
                
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.blue)
                        .font(.title2)
                }
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(isSelected ? Color.blue.opacity(0.1) : Color(.systemGray6))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(isSelected ? Color.blue : Color.clear, lineWidth: 2)
                    )
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct FrequencyOption: View {
    let frequency: NotificationFrequency
    let isSelected: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack {
                Text(frequency.displayName)
                    .font(.body)
                    .foregroundColor(.primary)
                
                Spacer()
                
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.blue)
                }
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(isSelected ? Color.blue.opacity(0.1) : Color(.systemGray6))
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    OnboardingFlow(onComplete: {})
}
