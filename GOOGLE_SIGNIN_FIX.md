# Google Sign-In Configuration Fix

## Issue
The Google Sign-In is failing with a PlatformException because the Firebase project is not properly configured with SHA-1 fingerprints.

## Solution
To fix Google Sign-In, you need to add SHA-1 fingerprints to your Firebase project:

### 1. Get your SHA-1 fingerprint
Run this command in your terminal:
```bash
cd android
./gradlew signingReport
```

Or for debug keystore:
```bash
keytool -list -v -keystore ~/.android/debug.keystore -alias androiddebugkey -storepass android -keypass android
```

### 2. Add SHA-1 to Firebase Console
1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Select your "eco-hero-app" project
3. Go to Project Settings (gear icon)
4. Under "Your apps", find the Android app
5. Click "Add fingerprint"
6. Paste the SHA1 fingerprint from step 1
7. Download the new `google-services.json` file
8. Replace the existing file in `android/app/google-services.json`

### 3. Current OAuth Client Status
The current `google-services.json` has an empty `oauth_client` array, which indicates Google Sign-In is not configured.

### 4. Temporary Workaround
Until you fix the Firebase configuration:
- Users can still use email/password authentication
- The app shows a helpful error message for Google Sign-In
- All other features work normally

### 5. Test After Fix
After updating the SHA-1 fingerprints:
1. Clean and rebuild the app: `flutter clean && flutter build apk`
2. Test Google Sign-In on a physical device or properly configured emulator
3. New Google users will be taken to the profile setup screen

## Alternative Solution
If you don't want to use Google Sign-In, you can:
1. Remove the Google Sign-In button from the login screen
2. Use only email/password authentication
3. This will still provide full app functionality
