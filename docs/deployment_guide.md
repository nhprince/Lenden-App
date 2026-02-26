# Lenden App: Production Deployment & Implementation Guide

This guide provides step-by-step instructions for deploying the Lenden Backend to a production cPanel environment and preparing the Android application for release.

## 1. Backend Deployment (cPanel)

### Prerequisites
- A cPanel hosting account with Node.js support (Setup Node.js App).
- MySQL database and user created in cPanel.
- SSL Certificate (AutoSSL) enabled for the domain.

### Deployment Steps
1. **Prepare ZIP for Upload**:
   - Navigate to the `server/` directory.
   - Compress all files into a ZIP (exclude `node_modules` and `.env`).
   
2. **Setup Node.js App in cPanel**:
   - Open "Setup Node.js App" in cPanel.
   - Create a new application:
     - **Node.js version**: 16.x or higher.
     - **Application mode**: Production.
     - **Application root**: `lenden_backend` (or similar).
     - **Application URL**: `https://api.yourdomain.com`.
     - **Startup file**: `src/index.js`.
   - Click "Create".

3. **Upload and Extract**:
   - Use cPanel File Manager to upload your ZIP to the Application Root.
   - Extract the files.

4. **Environment Configuration**:
   - Create a `.env` file in the Application Root.
   - Add the following production variables:
     ```env
     NODE_ENV=production
     PORT=3000
     JWT_SECRET=your_very_secure_random_secret
     DB_HOST=localhost
     DB_USER=cpaneluser_lenden
     DB_PASS=your_db_password
     DB_NAME=cpaneluser_lenden_db
     FRONTEND_ORIGIN=https://lenden.yourdomain.com
     ```
   - **Note**: Ensure `FRONTEND_ORIGIN` matches your web app URL.

5. **Install Dependencies**:
   - Navigate back to "Setup Node.js App".
   - Click "Run npm install".

6. **Database Setup**:
   - Import `server/FINAL_SCHEMA.sql` into your primary database using phpMyAdmin.
   - This schema is consolidated and optimized for cPanel MySQL.

## 2. Android App Production

### Build Process
The Android app is built using the Flutter `release` command. This optimizes the code for performance and security.

**Build Command**:
```bash
flutter build apk --release
```

**Artifact Path**:
`lenden_flutter/build/app/outputs/flutter-apk/app-release.apk`

### Versioning
To update the version for future releases:
1. Open `lenden_flutter/pubspec.yaml`.
2. Update the `version: 1.0.0+1` (Version Number + Build Number).
3. Re-run the build command.

## 3. Testing Guide

### Connection Test
1. Open the app on an Android device.
2. Attempt to sign up or log in.
3. If the app shows "Network Error", verify if the `FRONTEND_ORIGIN` in the backend `.env` allows the request and that `ApiClient` is pointing to the correct production URL.

### POS & Receipt Test
1. Add items to the cart in the **POS Screen**.
2. Complete a sale.
3. Tap "Download Receipt" to verify PDF generation works correctly.
4. Check **Reports** to see if the transaction is reflected in the charts.

### Image Test
1. Add a new product with an image.
2. Verify the image appears in the product grid and POS screen.
3. **Important**: cPanel has file limit restrictions. Use base64 for small logos or configure AWS S3 for product images to avoid hitting cPanel inode limits.

## 4. Maintenance
- **Backups**: Use the "Backup" feature in Settings to export SQL and JSON data regularly.
- **Logs**: Monitor Node.js logs in cPanel’s "Setup Node.js App" if any API errors occur.
