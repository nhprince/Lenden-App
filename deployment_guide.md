# Lenden Deployment & Release Guide

This guide provides step-by-step instructions for deploying the Lenden Backend to a production server (cPanel) and generating the final Android APK for the Flutter application using Google IDX.

---

## 🚀 Part 1: GitHub to IDX Sync (Build Preparations)

Since local builds can be hardware-intensive, follow these steps to push your fixes and build in the cloud.

### 1. Push Fixes from Local Machine
Run these in your local terminal:
```bash
# Verify your changes
git status

# Add and commit (I have already done this for you)
# git add .
# git commit -m "Finalize IDX build fixes"

# Push to GitHub
git push origin main
```

### 2. Pull Changes in Google IDX
In your Google IDX workspace terminal:
```bash
# Navigate to the project root
cd ~/Lenden-App

# Pull the latest fixes
git pull origin main

# Navigate to the Flutter directory
cd lenden_flutter

# Refresh dependencies
flutter pub get

# Generate localizations (if needed)
flutter gen-l10n
```

---

## 📱 Part 2: Generate the Production APK (Google IDX)

### 1. Update API Constants (Production)
In IDX, ensure [constants.dart](file:///home/nhprince/Workspace/Lenden-App/lenden_flutter/lib/core/app/constants.dart) points to your production backend:
```dart
static const String apiBaseUrl = 'https://api.yourdomain.com';
```

### 2. Build the APK
In the IDX terminal (inside `lenden_flutter` folder):
```bash
flutter build apk --release
```
- **Location**: `lenden_flutter/build/app/outputs/flutter-apk/app-release.apk`
- **Download**: Right-click the `.apk` file in the IDX file explorer and select **Download**.

---

## 🌐 Part 3: Backend Deployment (cPanel)

### 1. Build and Upload
- Run `./build-production.sh` in the root.
- Compress the `dist/` folder into `backend.zip`.
- Upload and extract to your cPanel folder.

### 2. cPanel Node.js App Setup
- **Version**: 18.x or 20.x.
- **Startup File**: `index.js`.
- **Environment Variables**:
  - `DB_HOST`: `localhost`
  - `DB_USER`: `[Your_DB_User]`
  - `DB_PASS`: `[Your_DB_Pass]`
  - `DB_NAME`: `[Your_DB_Name]`
  - `JWT_SECRET`: `[Secure_Random_Key]`
  - `NODE_ENV`: `production`
- **Install**: Click "Run NPM Install" in the cPanel Node.js interface.

---

## ✅ Verification Checklist
- [ ] Visit `https://api.yourdomain.com/api/health` -> Success.
- [ ] Install APK on Android -> Verify Login.
- [ ] POS Sale -> Verify PDF generation and currency (`BTDT`).
- [ ] Navigation -> Check if "Offline" bar appears when data is off.
