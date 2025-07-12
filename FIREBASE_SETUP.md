# Firebase Setup Instructions for EcoHero App

## ❗ IMPORTANT: You must complete these steps for the app to work properly

### 1. Enable Firestore Database
1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Select your `eco-hero-app` project
3. Click on **"Firestore Database"** in the left sidebar
4. Click **"Create database"**
5. Choose **"Start in production mode"**
6. Select your preferred region (closest to your users)
7. Click **"Enable"**

### 2. Set Up Firebase Storage
1. In Firebase Console, click on **"Storage"** in the left sidebar
2. Click **"Get started"**
3. Choose **"Start in production mode"** 
4. Select the same region as your Firestore
5. Click **"Done"**

### 3. Configure Storage Security Rules
1. In Storage, go to the **"Rules"** tab
2. Replace the default rules with:

```javascript
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    // Allow authenticated users to upload profile images
    match /profile_images/{userId}/{allPaths=**} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
    
    // Allow authenticated users to upload waste images
    match /waste_images/{userId}/{allPaths=**} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
    
    // Allow read access to all authenticated users (for viewing images)
    match /{allPaths=**} {
      allow read: if request.auth != null;
    }
  }
}
```

3. Click **"Publish"**

### 4. Enable Authentication Methods
1. Click on **"Authentication"** in the left sidebar
2. Go to **"Sign-in method"** tab
3. Enable **"Email/Password"**
4. Enable **"Google"** (optional but recommended)

### 5. Add Android App to Firebase Project (if not done)
1. In Project Overview, click **"Add app"** → **"Android"**
2. Enter package name: `com.example.eco_hero_app`
3. Download `google-services.json`
4. Place it in `android/app/` directory
5. Follow the setup instructions

### 6. Test the Setup
After completing these steps:
- ✅ Profile image upload should work
- ✅ Waste scanner should classify images
- ✅ Tasks should save and update points
- ✅ All data should persist across app restarts

### 🔍 Troubleshooting

**Error: "Permission denied"**
- Check that Authentication is enabled
- Verify Storage rules are published
- Ensure user is signed in

**Error: "Storage bucket not found"**
- Enable Firebase Storage in console
- Check project configuration

**Error: "Firestore API not enabled"**
- Enable Firestore Database in console
- Wait a few minutes for activation

**Error: "Object does not exist"**
- Check Storage rules
- Verify file paths in code
- Ensure Storage is properly initialized

### 📱 App Features Requiring Firebase

1. **Profile Management**
   - Profile image upload → Firebase Storage
   - User data → Firestore Database
   - EnvPoints tracking → Firestore Database

2. **Tasks System**
   - Task submission → Firestore Database
   - Points calculation → Firestore Database
   - Task history → Firestore Database

3. **Waste Scanner**
   - Image upload → Firebase Storage
   - Classification results → Firestore Database

4. **News & AI Features**
   - Works without Firebase (uses external APIs)

---

**✅ Once all steps are completed, restart the app and all features should work!**
