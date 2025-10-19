# Fix Run Scheme Issue - Vault App

## 🚨 Problem
Only ShareExtension is available in the run scheme, main Vault app is not runnable.

## 🔧 Solution

### Option 1: Quick Fix (Recommended)

1. **Close Xcode** if it's open

2. **Delete the current project file**:
   ```bash
   cd /Users/Dzmitry_Zaitsau2/Vault/Vault
   rm -rf Vault.xcodeproj
   ```

3. **Create a new Xcode project**:
   - Open Xcode
   - File → New → Project
   - Choose "iOS" → "App"
   - Product Name: `Vault`
   - Interface: `SwiftUI`
   - Language: `Swift`
   - Use Core Data: `No`
   - Include Tests: `Yes`
   - Minimum iOS Version: `17.0`
   - Save in: `/Users/Dzmitry_Zaitsau2/Vault/Vault/`

4. **Replace generated files**:
   - Replace `VaultApp.swift` with our implementation
   - Replace `ContentView.swift` with our implementation
   - Replace `Info.plist` with our implementation

5. **Add all source files**:
   - Drag and drop all files from the `Vault/` folder into Xcode
   - Make sure "Copy items if needed" is checked
   - Add to target: `Vault`

6. **Add Share Extension**:
   - File → New → Target
   - Choose "Share Extension"
   - Product Name: `ShareExtension`
   - Language: `Swift`
   - Replace generated ShareViewController with our implementation

7. **Run pod install**:
   ```bash
   pod install
   ```

8. **Open workspace**:
   ```bash
   open Vault.xcworkspace
   ```

### Option 2: Fix Current Project

If you want to keep the current project, you need to:

1. **Open Vault.xcworkspace in Xcode**

2. **Check Project Navigator**:
   - Look for the main `Vault` target
   - If it's missing, you need to add it

3. **Add Main App Target** (if missing):
   - Select the project in Navigator
   - Click "+" at the bottom of targets list
   - Choose "iOS" → "App"
   - Product Name: `Vault`
   - Bundle Identifier: `com.vault.digitalcontent`
   - Interface: `SwiftUI`
   - Language: `Swift`

4. **Configure Target Settings**:
   - Select the `Vault` target
   - General tab:
     - Display Name: `Vault`
     - Bundle Identifier: `com.vault.digitalcontent`
     - Version: `1.0`
     - Build: `1`
     - Minimum Deployments: `17.0`

5. **Add Source Files to Target**:
   - Select all Swift files in the project
   - In File Inspector, check "Vault" target membership
   - Uncheck "ShareExtension" target membership for main app files

6. **Set Main Target as Active**:
   - In the scheme selector (top left), choose "Vault" instead of "ShareExtension"
   - Or go to Product → Scheme → Manage Schemes
   - Make sure "Vault" scheme is set to "Shared"

## 🎯 Verification

After fixing, you should see:
- ✅ "Vault" scheme in the scheme selector
- ✅ "Vault" target in the project navigator
- ✅ Ability to run the main app (⌘+R)
- ✅ Both Vault and ShareExtension targets available

## 🚀 Next Steps

Once the main app is runnable:
1. Test basic functionality
2. Configure external services (Firebase, AdMob, StoreKit)
3. Test on device/simulator
4. Follow the complete setup instructions

## 📞 If Still Having Issues

If you're still having problems:
1. Try Option 1 (create new project) - it's more reliable
2. Check that all source files are properly added to the Vault target
3. Verify the scheme is set to "Vault" not "ShareExtension"
4. Make sure you're opening the `.xcworkspace` file, not `.xcodeproj`
