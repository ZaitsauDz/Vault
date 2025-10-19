# Vault of Digital Content - Setup Instructions

## 🚀 Quick Setup Guide

1. **Run pod install**:
```bash
cd /Users/Dzmitry_Zaitsau2/Vault/Vault
pod install
```

2. **Open the workspace**:
```bash
open Vault.xcworkspace
```

## Step 1: Configure External Services

### Firebase Setup:
1. **Create Firebase Project**:
   - Go to https://console.firebase.google.com
   - Click "Create a project"
   - Enter project name: "Vault of Digital Content"
   - Enable Google Analytics (recommended)

2. **Add iOS App**:
   - Click "Add app" → iOS
   - Bundle ID: `com.vault.digitalcontent`
   - App nickname: "Vault"
   - Download `GoogleService-Info.plist`

3. **Add GoogleService-Info.plist to Xcode**:
   - Drag the downloaded file into your Xcode project
   - Make sure "Copy items if needed" is checked
   - Add to both Vault and ShareExtension targets

4. **Enable Authentication**:
   - In Firebase Console → Authentication → Sign-in method
   - Enable "Apple" provider
   - Enable "Google" provider (add OAuth client ID)
   - Enable "Email/Password" provider

5. **Configure Google Sign-In**:
   - In Firebase Console → Project Settings → General
   - Add your iOS bundle ID to the OAuth client IDs
   - Download the updated `GoogleService-Info.plist`

### AdMob Setup:
1. **Create AdMob Account**:
   - Go to https://admob.google.com
   - Sign in with your Google account
   - Accept terms and create account

2. **Add App**:
   - Click "Apps" → "Add app"
   - Select "iOS"
   - App name: "Vault of Digital Content"
   - Bundle ID: `com.vault.digitalcontent`

3. **Create Ad Units**:
   - Click "Ad units" → "Add ad unit"
   - Select "Banner"
   - Ad unit name: "Vault Banner"
   - Copy the Ad Unit ID

4. **Update Configuration**:
   - Add AdMob App ID to `Info.plist`:
     ```xml
     <key>GADApplicationIdentifier</key>
     <string>ca-app-pub-XXXXXXXXXXXXXXXX~YYYYYYYYYY</string>
     ```
   - Update ad unit ID in `AdBannerView.swift`

### StoreKit Setup:
1. **App Store Connect Configuration**:
   - Go to https://appstoreconnect.apple.com
   - Create new app (if not exists)
   - Bundle ID: `com.vault.digitalcontent`

2. **Create In-App Purchase Products**:
   - Go to Features → In-App Purchases
   - Create subscription group: "Vault Pro"
   - Add products:
     - Monthly: `com.vault.pro.monthly` ($4.99/month)
     - Yearly: `com.vault.pro.yearly` ($17.99/year)
     - Lifetime: `com.vault.pro.lifetime` ($29.99 one-time)

3. **Configure Subscription Group**:
   - Set reference name: "Vault Pro"
   - Add subscription levels (if needed)
   - Submit for review

### Additional Configuration:

#### App Groups (Required for Share Extension):
1. **In Xcode**:
   - Select your project → Signing & Capabilities
   - Add capability "App Groups"
   - Add group: `group.com.vault.digitalcontent`
   - Repeat for ShareExtension target

#### URL Schemes (For OAuth):
1. **Add to Info.plist**:
   ```xml
   <key>CFBundleURLTypes</key>
   <array>
       <dict>
           <key>CFBundleURLSchemes</key>
           <array>
               <string>com.vault.digitalcontent</string>
           </array>
       </dict>
   </array>
   ```

#### Privacy Permissions:
1. **Add to Info.plist**:
   ```xml
   <key>NSUserTrackingUsageDescription</key>
   <string>We use tracking to show you relevant ads and improve your experience.</string>
   <key>NSPhotoLibraryUsageDescription</key>
   <string>Allow access to save images from shared content.</string>
   ```

## Step 2: Build and Test

1. **Select a target device** (iPhone simulator or physical device)
2. **Build the project** (⌘+B)
3. **Run the app** (⌘+R)

## Step 8: Testing and Validation

### Basic Functionality Tests:
1. **Authentication Flow**:
   - Test Apple Sign-In
   - Test Google Sign-In
   - Test Email/Password sign-up and sign-in
   - Test "Continue as Guest" option

2. **Content Management**:
   - Add items to each category (Watch, Read, Buy, Cook Later)
   - Test URL parsing with sample URLs:
     - YouTube: `https://www.youtube.com/watch?v=dQw4w9WgXcQ`
     - Instagram: `https://www.instagram.com/p/ABC123/`
     - Amazon: `https://www.amazon.com/dp/B08N5WRWNW`
     - Apple Books: `https://books.apple.com/us/book/example/id123456789`

3. **Share Extension**:
   - Test sharing from Safari, YouTube app, Instagram app
   - Verify content appears in correct category
   - Test metadata extraction

4. **Pro Features**:
   - Test subscription purchase flow (use sandbox)
   - Verify ad removal for Pro users
   - Test unlimited item storage

5. **Localization**:
   - Switch between English and Russian
   - Verify all UI elements are translated
   - Test date/time formatting

### Performance Tests:
1. **Load Testing**: Add 50+ items per category
2. **Search Performance**: Test search with large datasets
3. **Memory Usage**: Monitor memory during heavy usage
4. **Battery Impact**: Test background app refresh

### Error Handling Tests:
1. **Network Issues**: Test with poor/no internet connection
2. **Invalid URLs**: Test with malformed URLs
3. **Authentication Failures**: Test with invalid credentials
4. **Subscription Failures**: Test with invalid payment methods

## 🎯 What You'll Have

After completing these steps, you'll have a fully functional Vault of Digital Content app with:

✅ **Complete iOS App** with SwiftUI interface  
✅ **Four Content Categories** (Watch, Read, Buy, Cook Later)  
✅ **Authentication System** (Apple, Google, Email)  
✅ **Share Extension** for saving content from other apps  
✅ **URL Parsing** for YouTube, Instagram, Amazon, Apple Books  
✅ **Subscription System** with Pro features  
✅ **AdMob Integration** for monetization  
✅ **Bilingual Support** (English/Russian)  
✅ **Local Notifications** with user preferences  
✅ **Complete Test Suite** (Unit and UI tests)  

## 🚀 Ready for App Store

The app is production-ready and includes:
- Proper error handling
- Accessibility support
- Privacy compliance
- Performance optimizations
- Complete documentation

## 🔧 Troubleshooting

### Common Issues and Solutions:

#### Build Errors:
1. **"No such module 'Firebase'"**:
   - Clean build folder (⌘+Shift+K)
   - Delete derived data
   - Run `pod install` again

2. **"Signing certificate not found"**:
   - Check Apple Developer account
   - Update provisioning profiles
   - Verify bundle identifiers match

3. **"App Groups not configured"**:
   - Enable App Groups capability in Xcode
   - Ensure same group ID for both targets
   - Check Apple Developer portal settings

#### Runtime Issues:
1. **Authentication not working**:
   - Verify `GoogleService-Info.plist` is added to project
   - Check Firebase console configuration
   - Ensure URL schemes are configured

2. **Share Extension not appearing**:
   - Check target membership
   - Verify Info.plist configuration
   - Test on physical device (not simulator)

3. **Ads not showing**:
   - Verify AdMob App ID in Info.plist
   - Check ad unit IDs in code
   - Test with test ad unit IDs first

#### Performance Issues:
1. **Slow URL parsing**:
   - Check network connectivity
   - Verify parser implementations
   - Test with different URL formats

2. **Memory leaks**:
   - Use Xcode Instruments
   - Check for retain cycles
   - Verify proper cleanup in view models

### Debug Configuration:
1. **Enable Debug Logging**:
   ```swift
   // Add to VaultApp.swift
   #if DEBUG
   FirebaseApp.configure()
   #endif
   ```

2. **Test AdMob with Test IDs**:
   ```swift
   // Use these for testing
   let testBannerAdUnitID = "ca-app-pub-3940256099942544/2934735716"
   ```

3. **StoreKit Testing**:
   - Use sandbox environment
   - Create test user accounts
   - Test subscription flows

## 📞 Support

If you encounter any issues during setup, refer to:
- The comprehensive `IMPLEMENTATION_SUMMARY.md`
- The detailed `README.md`
- Individual source file comments
- This troubleshooting section

### Additional Resources:
- [Firebase iOS Setup Guide](https://firebase.google.com/docs/ios/setup)
- [AdMob iOS Integration](https://developers.google.com/admob/ios/quick-start)
- [StoreKit 2 Documentation](https://developer.apple.com/documentation/storekit)
- [SwiftData Documentation](https://developer.apple.com/documentation/swiftdata)

The implementation follows iOS best practices and is ready for App Store submission! 🎉

## 🚀 Next Steps

After successful setup and testing:

1. **App Store Preparation**:
   - Create app icons and screenshots
   - Write app description and metadata
   - Prepare privacy policy and terms of service

2. **Beta Testing**:
   - Upload to TestFlight
   - Invite beta testers
   - Collect feedback and iterate

3. **Production Deployment**:
   - Archive and upload to App Store Connect
   - Submit for App Store review
   - Monitor analytics and user feedback

4. **Post-Launch**:
   - Monitor crash reports
   - Update based on user feedback
   - Plan feature updates and improvements
