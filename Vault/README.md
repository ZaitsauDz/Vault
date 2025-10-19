# Vault of Digital Content iOS App

A modern iOS application for organizing digital content across four categories: Watch Later, Read Later, Buy Later, and Cook Later.

## Features

### MVP (Free Tier)
- **Four Content Categories**: Organize content into Watch, Read, Buy, and Cook Later
- **URL Parsing**: Automatic metadata extraction for YouTube, Instagram, Amazon, and Apple Books
- **Share Extension**: Save content directly from other apps
- **Search & Filter**: Find your saved content quickly
- **Item Limits**: 10 items per category for free users
- **AdMob Integration**: Non-intrusive banner ads
- **Bilingual Support**: English and Russian localization
- **Authentication**: Sign in with Apple, Google, or Email

### Pro Features
- **Unlimited Storage**: No item limits
- **Ad-Free Experience**: Remove all advertisements
- **Extended Sources**: Support for all content sources
- **iCloud Sync**: Cross-device synchronization
- **Family Sharing**: Share Pro features with family

## Technical Architecture

### Technology Stack
- **iOS Version**: 17.0+
- **UI Framework**: SwiftUI
- **Data Persistence**: SwiftData
- **Authentication**: Firebase Auth
- **Monetization**: AdMob + StoreKit 2
- **Concurrency**: Structured Concurrency (async/await)
- **Localization**: Native Russian/English support

### Architecture Pattern
- **MVVM + Repository Pattern**
- **Feature-based modules**
- **SwiftData reactive data binding**
- **Repository pattern for data abstraction**

## Project Structure

```
VaultApp/
├── App/
│   ├── VaultApp.swift
│   ├── ContentView.swift
│   └── Info.plist
│
├── Features/
│   ├── Authentication/
│   │   ├── Views/
│   │   ├── ViewModels/
│   │   └── Services/
│   │
│   ├── Onboarding/
│   │   └── Views/
│   │
│   ├── ContentManagement/
│   │   ├── Views/
│   │   ├── ViewModels/
│   │   └── Models/
│   │
│   ├── Settings/
│   │   ├── Views/
│   │   └── ViewModels/
│   │
│   └── Subscription/
│       ├── Views/
│       └── Managers/
│
├── Core/
│   ├── Models/
│   │   ├── ContentItem.swift
│   │   └── UserPreferences.swift
│   │
│   ├── Services/
│   │   ├── MetadataParser/
│   │   │   ├── MetadataParserService.swift
│   │   │   ├── YouTubeParser.swift
│   │   │   ├── InstagramParser.swift
│   │   │   ├── AmazonParser.swift
│   │   │   └── AppleBooksParser.swift
│   │   │
│   │   ├── NotificationManager.swift
│   │   └── AnalyticsManager.swift
│   │
│   └── Extensions/
│       ├── String+Localization.swift
│       └── Color+Extensions.swift
│
├── ShareExtension/
│   ├── ShareViewController.swift
│   ├── ShareExtensionView.swift
│   └── Info.plist
│
├── Resources/
│   ├── Assets.xcassets/
│   ├── Localizations/
│   │   ├── en.lproj/
│   │   │   └── Localizable.strings
│   │   └── ru.lproj/
│   │       └── Localizable.strings
│   ├── GoogleService-Info.plist
│   └── Fonts/
│
├── Tests/
│   ├── VaultTests/
│   │   ├── ParserTests.swift
│   │   ├── ModelTests.swift
│   │   └── ViewModelTests.swift
│   │
│   └── VaultUITests/
│       └── NavigationTests.swift
│
└── Podfile
```

## Setup Instructions

### Prerequisites
- Xcode 15.0+
- iOS 17.0+ target device
- Apple Developer account
- Firebase project
- AdMob account

### Installation

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd Vault
   ```

2. **Install dependencies**
   ```bash
   pod install
   ```

3. **Configure Firebase**
   - Add `GoogleService-Info.plist` to the project
   - Enable Authentication in Firebase Console
   - Configure Sign-in providers (Apple, Google, Email)

4. **Configure AdMob**
   - Add your AdMob App ID to Info.plist
   - Update ad unit IDs in `AdBannerView.swift`

5. **Configure App Groups**
   - Enable App Groups capability
   - Set group identifier: `group.com.vault.digitalcontent`

6. **Build and Run**
   - Open `Vault.xcworkspace`
   - Select target device
   - Build and run

## Configuration

### Firebase Setup
1. Create a new Firebase project
2. Add iOS app with bundle identifier
3. Download `GoogleService-Info.plist`
4. Enable Authentication and configure providers

### AdMob Setup
1. Create AdMob account
2. Add app and get App ID
3. Create ad units for banner ads
4. Update configuration in code

### StoreKit Configuration
1. Create in-app purchase products in App Store Connect
2. Configure subscription groups
3. Set up sandbox testing

## Development

### Adding New Content Sources
1. Create new parser class implementing `MetadataParser`
2. Add to `MetadataParserService` parsers array
3. Update `SourceType` enum if needed
4. Add to Pro features if required

### Localization
1. Add strings to `Localizable.strings` files
2. Use `String.localized()` extension
3. Test in both languages

### Testing
- Unit tests for parsers and models
- UI tests for critical user flows
- TestFlight beta testing

## Deployment

### App Store Submission
1. Archive the app
2. Upload to App Store Connect
3. Configure app metadata
4. Submit for review

### Beta Testing
1. Upload to TestFlight
2. Invite beta testers
3. Collect feedback
4. Iterate based on feedback

## Contributing

1. Fork the repository
2. Create feature branch
3. Make changes
4. Add tests
5. Submit pull request

## License

[Add your license here]

## Support

For support, email [your-email@domain.com] or create an issue in the repository.