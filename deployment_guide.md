# Lenden Deployment & Release Guide

This guide provides step-by-step instructions for deploying the Lenden Backend to a production server (cPanel) and generating the final Android APK using **GitHub Actions** (Automated build).

---

## 🚀 Part 1: Generate the APK (GitHub Actions)

Since local machines and IDX can have hardware/disk constraints, we use GitHub's servers to build the app for you.

### 1. Trigger the Build
- Push your latest changes to GitHub:
  ```bash
  git add .
  git commit -m "Trigger GitHub Build"
  git push origin main
  ```
- Alternatively, go to your GitHub Repository -> **Actions** tab -> **Build Flutter APK** -> **Run workflow**.

### 2. Download the APK
1.  Go to your GitHub repository on the web.
2.  Click on the **Actions** tab.
3.  Click on the latest "Build Flutter APK" run (it will take ~5-7 minutes to finish).
4.  Scroll down to the **Artifacts** section at the bottom.
5.  Click on **app-release** to download your production APK.

---

## 📱 Part 2: Backend Deployment (cPanel)

### 1. Build and Upload
- Run `./build-production.sh` in the local root folder.
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

## ✅ Post-Deployment Verification

1.  **Health Check**: Visit `https://api.yourdomain.com/api/health`.
2.  **App Login**: Install the APK downloaded from GitHub Actions and log in.
3.  **POS Sale**: Verify PDF generation and currency (`BTDT`).
4.  **Language Test**: Toggle English/Bengali in Settings.
