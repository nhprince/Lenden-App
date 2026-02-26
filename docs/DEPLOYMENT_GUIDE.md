# 🚀 Complete Deployment Guide for Lenden-App

## Overview

This is a step-by-step guide to deploy Lenden-App on cPanel with:
- **Frontend**: `lenden.cyberslayersagency.com` (React SPA)
- **Backend**: `api.lenden.cyberslayersagency.com` (Node.js API)

**Important**: The backend will be at the ROOT of `api.lenden.cyberslayersagency.com/`, not in a subdirectory.

---

## 📋 Pre-Deployment Checklist

Before you begin, ensure you have:
- ✅ cPanel login credentials
- ✅ Node.js support enabled in cPanel (version 18+ or 20+)
- ✅ MySQL database access
- ✅ FTP/File Manager access
- ✅ Both domains/subdomains configured in cPanel

---

## Part 1: Local Build (On Your Computer)

### Step 1: Navigate to Project Directory

```bash
cd /home/nh-prince/Workspace/Lenden-App
```

### Step 2: Run Build Script

```bash
chmod +x build_for_cpanel.sh
./build_for_cpanel.sh
```

This will:
1. Build React frontend → Output: `client/dist/`
2. Install backend dependencies → `server/node_modules/`

**Expected Output**:
```
✅ Frontend build complete!
✅ Backend dependencies installed!
✅ Build Complete!
```

---

## Part 2: Database Setup

### Step 1: Verify Database Exists

Your database is already configured:
- **Name**: `cybersla_lenden_database`
- **User**: `cybersla_lenden_admin`
- **Password**: `sheisonlymine`

### Step 2: Import Database Schema

1. Login to **cPanel**
2. Go to **phpMyAdmin**
3. Click on database `cybersla_lenden_database` in left sidebar
4. Click **Import** tab at the top
5. Click **Choose File** → Select `server/schema.sql` from your computer
6. Scroll down → Click **Go** button
7. Wait for success message: "Import has been successfully finished"

**Verify**: You should now see 9 tables:
- users
- shops
- customers
- vendors
- products
- services
- transactions
- transaction_items
- trips

---

## Part 3: Backend Deployment (api.lenden.cyberslayersagency.com)

### Step 1: Prepare Backend Files for Upload

You'll upload the entire `server/` folder to your backend domain.

**Directory to upload**: `/home/nh-prince/Workspace/Lenden-App/server/`

**Important files to include**:
```
server/
├── node_modules/        ← Created by build script
├── src/
│   ├── config/
│   │   └── db.js
│   ├── controllers/     ← 10 files
│   ├── middleware/      ← 3 files
│   ├── routes/          ← 10 files
│   └── index.js         ← Main server file
├── .env                 ← CRITICAL: Contains database credentials
├── package.json
├── package-lock.json
└── schema.sql
```

### Step 2: Upload Backend to cPanel

**Option A: Using File Manager** (Recommended for first-time users)

1. Login to **cPanel**
2. Open **File Manager**
3. Navigate to the root of `api.lenden.cyberslayersagency.com`
   - Usually: `/home/cybersla/api.lenden.cyberslayersagency.com/` or
   - `/home/cybersla/public_html/api/` (depends on your cPanel setup)
4. **Upload the entire `server/` folder**:
   - Click **Upload** button
   - Select all files from local `/home/nh-prince/Workspace/Lenden-App/server/`
   - Wait for upload to complete

**Option B: Using FTP** (Faster for large files)

1. Connect to your cPanel via FTP (use FileZilla or similar)
2. Navigate to `/home/cybersla/api.lenden.cyberslayersagency.com/`
3. Upload the entire `server/` folder
4. Ensure all files transferred successfully

### Step 3: Verify .env File

After upload, verify `.env` file exists in the server folder:

1. In File Manager, navigate to server folder
2. Click `.env` to view/edit
3. Verify contents:

```env
PORT=5000
DB_HOST=localhost
DB_USER=cybersla_lenden_admin
DB_PASS=sheisonlymine
DB_NAME=cybersla_lenden_database
JWT_SECRET=shtxx@1982
NODE_ENV=production
FRONTEND_ORIGIN=https://lenden.cyberslayersagency.com
```

**Important**: If `.env` is missing, create it with the above content.

### Step 4: Configure Node.js Application in cPanel

1. In cPanel, find **"Setup Node.js App"** (or "Node.js Selector")
2. Click **"Create Application"**

3. **Fill in the form**:

   | Field | Value |
   |-------|-------|
   | **Node.js version** | `20.x` (or latest available) |
   | **Application mode** | `Production` |
   | **Application root** | Path where you uploaded server folder<br>Example: `/home/cybersla/api.lenden.cyberslayersagency.com/` |
   | **Application URL** | `https://api.lenden.cyberslayersagency.com` |
   | **Application startup file** | `src/index.js` |
   | **Application passenger log file** | Leave default |

4. Click **"Create"**

### Step 5: Add Environment Variables in cPanel

After creating the app, you'll see environment variables section:

Click **"Add Variable"** for each of these:

| Variable Name | Value |
|--------------|-------|
| `PORT` | `5000` |
| `DB_HOST` | `localhost` |
| `DB_USER` | `cybersla_lenden_admin` |
| `DB_PASS` | `sheisonlymine` |
| `DB_NAME` | `cybersla_lenden_database` |
| `JWT_SECRET` | `shtxx@1982` |
| `NODE_ENV` | `production` |
| `FRONTEND_ORIGIN` | `https://lenden.cyberslayersagency.com` |

**Note**: Some hosting providers read from `.env` file instead, so your `.env` file is the backup.

### Step 6: Install Dependencies

1. In the Node.js App interface, find **"Run NPM Install"** button
2. Click it and wait (may take 2-5 minutes)
3. Watch for success message

**Alternative (if button doesn't work)**:
1. Use Terminal in cPanel or SSH
2. Navigate to server folder: `cd /home/cybersla/api.lenden.cyberslayersagency.com/`
3. Run: `npm install --production`

### Step 7: Start the Application

1. In Node.js App interface, click **"Restart"** button
2. Status should change to **"Running"**

### Step 8: Test Backend API

Open your browser and visit:
```
https://api.lenden.cyberslayersagency.com/
```

**Expected Response**:
```json
{
  "message": "Lenden App API",
  "status": "running",
  "version": "1.0.0",
  "environment": "production"
}
```

If you see this, **Backend is working! ✅**

**If you see an error**:
1. Go back to cPanel → Node.js App
2. Click **"View Log"** or check `stderr.log`
3. Fix any issues shown in logs
4. Click "Restart" again

---

## Part 4: Frontend Deployment (lenden.cyberslayersagency.com)

### Step 1: Prepare Frontend Files

After running the build script, you have `client/dist/` folder with:
```
dist/
├── index.html
├── assets/
│   ├── index-[hash].js
│   ├── index-[hash].css
│   └── vendor-[hash].js
└── vite.svg
```

### Step 2: Access Frontend Domain Directory

1. In cPanel File Manager
2. Navigate to `lenden.cyberslayersagency.com` directory
   - Usually: `/home/cybersla/lenden.cyberslayersagency.com/public_html/`
   - Or: `/home/cybersla/public_html/` (if it's your main domain)

**IMPORTANT**: Make sure you're in the `public_html` folder of the frontend domain.

### Step 3: Clear Existing Files (First-time deployment)

If this is a fresh deployment:
1. Select all existing files in `public_html`
2. Delete them (backup first if needed)

**Common files to remove**: index.html, cgi-bin, error pages, etc.

### Step 4: Upload Frontend Files

**Upload ALL contents of `client/dist/` folder**:

1. Click **"Upload"** in File Manager
2. Select all files from `/home/nh-prince/Workspace/Lenden-App/client/dist/`
3. Upload them to `public_html/`

**Files should now be**:
```
public_html/
├── index.html
├── assets/
│   ├── index-...js
│   ├── index-...css
│   └── vendor-...js
└── vite.svg
```

### Step 5: Upload .htaccess File

1. Upload `client/.htaccess` to the same `public_html/` directory
2. **Critical**: This file enables React Router and adds security

**Verify .htaccess is uploaded**:
```
public_html/
├── .htaccess          ← Must be here
├── index.html
└── ...
```

**If you can't see .htaccess**:
- In File Manager, click "Settings" (top right)
- Check "Show Hidden Files (dotfiles)"
- Click "Save"

### Step 6: Set Correct Permissions

1. Select `.htaccess` file
2. Right-click → Permissions
3. Set to `644` (or `rw-r--r--`)
4. Click "Change Permissions"

### Step 7: Test Frontend

Open your browser and visit:
```
https://lenden.cyberslayersagency.com
```

**Expected Result**: You should see the Lenden App **Login Page**

**If you see a blank page**:
1. Press `F12` to open Developer Tools
2. Go to "Console" tab
3. Check for errors
4. Go to "Network" tab
5. Refresh page and check which files are loading

---

## Part 5: Full System Testing

### Test 1: Registration Flow

1. Go to `https://lenden.cyberslayersagency.com/register`
2. Fill in:
   - Name: Test User
   - Email: test@example.com
   - Password: test123
3. Click "Register"
4. Should redirect to `/shops` (Shop Selector page)

**If registration fails**:
- Check browser console for API errors
- Verify backend is running
- Check CORS settings

### Test 2: Create a Shop

1. On Shop Selector page, click **"Add New Shop"**
2. Fill in:
   - Shop Name: Test Shop
   - Business Type: Showroom
   - Phone: 01712345678
   - Address: Dhaka
3. Click **"Create Shop"**
4. Shop card should appear

### Test 3: Select Shop and Access Dashboard

1. Click on the shop card you just created
2. Should redirect to `/dashboard`
3. Dashboard should load with stats (all zeros initially)

### Test 4: Create a Product

1. Go to **"Inventory"** from sidebar
2. Click **"Add Product"**
3. Fill in:
   - Name: Test Product
   - Cost Price: 100
   - Selling Price: 150
   - Stock: 10
4. Product should appear in list

### Test 5: Make a Sale

1. Go to **"Sales & Invoice"** from sidebar
2. Click on the product to add to cart
3. Enter Paid Amount: 150
4. Click **"Complete Sale"**
5. Should show success message

### Test 6: Verify API Calls

1. Press `F12` → Network tab
2. Perform any action (e.g., create product)
3. **Verify**: All API calls go to `https://api.lenden.cyberslayersagency.com/api/...`

**Example URLs you should see**:
- `https://api.lenden.cyberslayersagency.com/api/products`
- `https://api.lenden.cyberslayersagency.com/api/transactions/sale`
- `https://api.lenden.cyberslayersagency.com/api/shops`

---

## 🔧 Troubleshooting Guide

### Problem 1: CORS Error in Browser Console

**Symptom**: 
```
Access to XMLHttpRequest at 'https://api...' from origin 'https://lenden...' has been blocked by CORS policy
```

**Solutions**:
1. Check `FRONTEND_ORIGIN` in backend `.env` file
   - Must be EXACTLY: `https://lenden.cyberslayersagency.com`
   - No trailing slash
2. Restart Node.js app in cPanel
3. Clear browser cache: `Ctrl + Shift + Delete`
4. Hard refresh: `Ctrl + F5`

### Problem 2: API Returns 404

**Symptom**: All API calls return "Not Found"

**Solutions**:
1. Check Node.js app is "Running" in cPanel
2. Verify **Application Startup File** is `src/index.js` (not just `index.js`)
3. Check Application Root path is correct
4. View logs in cPanel → Node.js App → stderr.log
5. Restart the app

### Problem 3: Database Connection Error

**Symptom**: "Server error" or "Cannot connect to database"

**Solutions**:
1. Verify database exists in phpMyAdmin
2. Check database name is exactly: `cybersla_lenden_database`
3. Verify user `cybersla_lenden_admin` has privileges:
   - Go to phpMyAdmin → User Accounts
   - Check user has "All privileges" for the database
4. Check `DB_HOST` is `localhost` (not IP address)
5. Restart Node.js app

### Problem 4: Frontend Shows Blank White Page

**Symptom**: White screen, nothing visible

**Solutions**:
1. Check `.htaccess` file is uploaded to `public_html/`
2. Verify all files from `dist/` are uploaded
3. Check file permissions (should be 644 for files, 755 for directories)
4. Press `F12` → Console → Check for JavaScript errors
5. Try accessing: `https://lenden.cyberslayersagency.com/index.html` directly

### Problem 5: React Router Not Working (404 on Refresh)

**Symptom**: Direct URLs like `/dashboard` return 404

**Solutions**:
1. Verify `.htaccess` file exists in `public_html/`
2. Check if `mod_rewrite` is enabled on server (most cPanel hosts have it)
3. Verify `.htaccess` content includes:
   ```apache
   RewriteEngine On
   RewriteCond %{REQUEST_FILENAME} !-f
   RewriteCond %{REQUEST_FILENAME} !-d
   RewriteRule ^(.*)$ /index.html [L]
   ```

### Problem 6: "Shop-Id required" Error

**Symptom**: API returns "Shop ID required" for most operations

**Solutions**:
1. Logout completely
2. Login again
3. Go to `/shops` and select a shop
4. Check browser's localStorage:
   - Press `F12` → Application → Local Storage
   - Should see `currentShop` with shop data

### Problem 7: Rate Limiting Error

**Symptom**: "Too many requests" after few attempts

**Solutions**:
- This is normal security feature
- Wait 15 minutes
- For testing, you can temporarily increase limits in `server/src/index.js`

---

## 🔒 Security Checklist

After deployment, verify:

- ✅ Both domains use HTTPS (not HTTP)
- ✅ `.env` file is NOT publicly accessible
  - Try: `https://api.lenden.cyberslayersagency.com/.env` → Should show 404
- ✅ CORS is restricted to your frontend domain
- ✅ Rate limiting is active
- ✅ Security headers are set (check browser DevTools → Network → Response Headers)
- ✅ Database credentials are not exposed in frontend code

---

## 📊 Monitoring & Maintenance

### Check Backend Logs

1. cPanel → Setup Node.js App
2. Find your app → Click "View Logs"
3. Check `stderr.log` for errors
4. Check `stdout.log` for console output

### Monitor Database

1. phpMyAdmin → Select database
2. Check table sizes
3. Monitor slow queries (if available)

### Regular Backups

**Database Backup**:
1. phpMyAdmin → Export → Quick export → Go
2. Download SQL file
3. Store safely (recommended: weekly backups)

**Code Backup**:
- Keep Git repository updated
- Backup `.env` file separately (securely)

---

## 🔄 How to Update Application

### Update Backend Code

1. Make changes locally
2. Test locally with `npm run dev`
3. Upload modified files to server via FTP/File Manager
4. In cPanel → Node.js App → Click "Restart"

**No need to run NPM install again** unless you added new dependencies.

### Update Frontend Code

1. Make changes locally
2. Run `cd client && npm run build`
3. Upload new `dist/` contents to `public_html/`
4. Clear browser cache

---

## 📞 Support Contacts

If issues persist:
1. Contact cPanel hosting support
2. Provide them with:
   - Error messages from logs
   - Steps to reproduce
   - Node.js app configuration details

---

## ✅ Deployment Complete!

If all tests pass, your application is now live:

- **Frontend**: https://lenden.cyberslayersagency.com
- **Backend API**: https://api.lenden.cyberslayersagency.com

**Next Steps**:
1. Create your first real shop
2. Add products/services
3. Test with real transactions
4. Share with users!

---

## 📝 Quick Command Reference

```bash
# Local build
./build_for_cpanel.sh

# Rebuild frontend only
cd client && npm run build

# Backend dependencies (if needed)
cd server && npm install --production

# Run locally for testing
npm run dev
```

**Deployment is complete! Your Lenden-App is now live! 🎉**
