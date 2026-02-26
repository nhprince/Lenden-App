# 🚀 Production Deployment Guide - Split Domain Setup

## Overview

This guide covers deploying Lenden-App with:
- **Frontend**: `lenden.cyberslayersagency.com` (Static React App)
- **Backend**: `api.lenden.cyberslayersagency.com` (Node.js API)

---

## Prerequisites

- ✅ cPanel access with:
  - Node.js app support (Node 18+ or 20+)
  - MySQL database access
  - Two domains/subdomains configured
- ✅ Database credentials (already in `server/.env`)
- ✅ SSH/FTP access (for file upload)

---

## Part 1: Database Setup

### Step 1: Database is Already Created

According to your `.env` file:
- **Database Name**: `cybersla_lenden_database`
- **Database User**: `cybersla_lenden_admin`
- **Password**: `sheisonlymine`

If tables are not yet created, import the schema:

1. Go to **phpMyAdmin** in cPanel
2. Select database `cybersla_lenden_database`
3. Click **Import**
4. Choose `server/schema.sql` from your local project
5. Click **Go**

---

## Part 2: Backend Deployment (api.lenden.cyberslayersagency.com)

### Step 1: Build Production Backend

On your local machine:
```bash
cd /home/nh-prince/Workspace/Lenden-App
./build_for_cpanel.sh
```

### Step 2: Upload Backend Files

Upload the **entire `server` folder** to `api.lenden.cyberslayersagency.com`:

**Upload to**: `/home/cybersla/api.lenden.cyberslayersagency.com/` (or similar path)

**Files to upload**:
```
server/
├── node_modules/     (will be installed by cPanel)
├── src/
│   ├── config/
│   ├── controllers/
│   ├── middleware/
│   ├── routes/
│   └── index.js
├── .env             (IMPORTANT: Upload this!)
├── package.json
└── schema.sql
```

### Step 3: Configure Node.js App in cPanel

1. Go to **Setup Node.js App** in cPanel
2. Click **Create Application**
3. Configure:
   - **Node.js Version**: `20.x` (or latest available)
   - **Application Mode**: `Production`
   - **Application Root**: Path to server folder (e.g., `/home/cybersla/api.lenden.cyberslayersagency.com/`)
   - **Application URL**: `https://api.lenden.cyberslayersagency.com`
   - **Application Startup File**: `src/index.js`
   - **Passenger Log File**: (leave default)

4. Click **Create**

### Step 4: Set Environment Variables

In the Node.js App interface, add these variables (should match your `.env`):

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

### Step 5: Install Dependencies & Start

1. Click **Run NPM Install** in cPanel
2. Wait for installation to complete
3. Click **Restart** to start the API server

### Step 6: Test Backend

Visit: `https://api.lenden.cyberslayersagency.com/`

Expected response:
```json
{
  "message": "Welcome to Lenden App API"
}
```

---

## Part 3: Frontend Deployment (lenden.cyberslayersagency.com)

### Step 1: Build Production Frontend

Already done if you ran `build_for_cpanel.sh`. The build output is in `client/dist/`.

### Step 2: Upload Frontend Files

Upload contents of `client/dist/` to `lenden.cyberslayersagency.com`:

**Upload to**: `/home/cybersla/lenden.cyberslayersagency.com/public_html/`

**Files to upload**:
```
public_html/
├── index.html
├── assets/
│   ├── index-[hash].js
│   ├── index-[hash].css
│   └── vendor-[hash].js
└── vite.svg
```

### Step 3: Upload .htaccess

Upload `client/.htaccess` to the same directory:

**Upload to**: `/home/cybersla/lenden.cyberslayersagency.com/public_html/.htaccess`

This file handles:
- React Router (SPA routing)
- HTTPS redirect
- Asset caching
- Security headers

### Step 4: Verify Frontend

Visit: `https://lenden.cyberslayersagency.com`

You should see the Lenden App login page.

---

## Part 4: Testing the Full Stack

### Test 1: Registration
1. Go to `https://lenden.cyberslayersagency.com/register`
2. Create a new account
3. Should redirect to shop selector

### Test 2: Create Shop
1. Click "Add New Shop"
2. Fill in details
3. Should successfully create shop

### Test 3: Login
1. Go to `https://lenden.cyberslayersagency.com/login`
2. Login with created account
3. Should access dashboard

### Test 4: API Communication
1. Open Developer Console (F12)
2. Go to Network tab
3. Perform actions (create product, make sale)
4. Verify requests go to `https://api.lenden.cyberslayersagency.com/api/...`

---

## Troubleshooting

### Issue: CORS Error

**Symptom**: Console shows "CORS policy blocked"

**Solution**:
1. Verify `FRONTEND_ORIGIN` in backend `.env` is exactly: `https://lenden.cyberslayersagency.com`
2. Restart Node.js app in cPanel
3. Clear browser cache

### Issue: API 404 Errors

**Symptom**: API calls return 404

**Solution**:
1. Check Node.js app is running in cPanel
2. Verify Application Startup File is `src/index.js`
3. Check logs in cPanel → Node.js App → "stderr.log"

### Issue: Database Connection Error

**Symptom**: "Server error" or "Database connection failed"

**Solution**:
1. Verify database credentials in cPanel environment variables
2. Check database exists in phpMyAdmin
3. Ensure user has "All Privileges" on database
4. Check Node.js app logs

### Issue: Frontend Shows Blank Page

**Symptom**: White screen, no errors in console

**Solution**:
1. Check `.htaccess` is uploaded
2. Verify all files from `client/dist/` are uploaded
3. Check browser console for errors
4. Try hard refresh (Ctrl+F5)

### Issue: "Shop-Id required" Errors

**Symptom**: API returns "Shop ID required" for all requests

**Solution**:
1. Logout and login again
2. Select a shop from shop selector
3. Check localStorage in browser (should have `currentShop`)

---

## Security Checklist

- ✅ HTTPS enabled for both domains
- ✅ CORS configured with specific origin (not wildcard)
- ✅ Rate limiting enabled (100 req/15min, 5 for auth)
- ✅ Security headers set (HSTS, X-Frame-Options, etc.)
- ✅ JWT_SECRET is strong and unique
- ✅ Database credentials not exposed in frontend code
- ✅ `.env` file not publicly accessible
- ✅ Input validation on all API endpoints

---

## Performance Optimizations Applied

- ✅ Frontend assets cached (1 year for static, no-cache for HTML)
- ✅ Gzip compression enabled via .htaccess
- ✅ Pagination on products and transactions
- ✅ React code splitting (vendor chunk separate)
- ✅ Database connection pooling (10 connections)
- ✅ Rate limiting to prevent abuse

---

## Maintenance

### Updating the Application

**Frontend Update**:
1. Make changes locally
2. Run `npm run build` in `client` folder
3. Upload new `dist/` contents to `public_html/`

**Backend Update**:
1. Make changes locally
2. Upload modified files to server folder
3. Click "Restart" in cPanel Node.js App

### Monitoring

- **Backend Logs**: cPanel → Node.js App → View logs
- **Database**: phpMyAdmin → Monitor queries
- **Frontend Errors**: Browser console + network tab

### Backups

Regular backups recommended:
- Database: Export via phpMyAdmin weekly
- Backend code: Keep Git repository updated
- Frontend: Build artifacts stored locally

---

## Environment Variables Reference

### Backend (api.lenden.cyberslayersagency.com)

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

### Frontend (lenden.cyberslayersagency.com)

Set during build via `.env.production`:
```env
VITE_API_URL=https://api.lenden.cyberslayersagency.com/api
```

---

## Support

If you encounter issues:
1. Check logs in cPanel
2. Verify all environment variables
3. Test API directly: `https://api.lenden.cyberslayersagency.com/`
4. Check browser console for frontend errors

---

## Quick Reference Commands

```bash
# Build for production
./build_for_cpanel.sh

# Frontend only rebuild
cd client && npm run build

# Backend dependencies
cd server && npm install --production

# Development mode (local)
npm run dev
```

---

**Deployment Complete!** 🎉

Your Lenden-App should now be live at:
- Frontend: https://lenden.cyberslayersagency.com
- Backend API: https://api.lenden.cyberslayersagency.com
