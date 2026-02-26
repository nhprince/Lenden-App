# Quick Production Deployment Checklist

## Before Deployment
- [ ] Run `./build_for_cpanel.sh` to build production files
- [ ] Verify database `cybersla_lenden_database` exists
- [ ] Verify database user `cybersla_lenden_admin` has access

**Note**: Backend API will be at `https://api.lenden.cyberslayersagency.com/api/...` (routes have /api prefix)

## Backend Deployment (api.lenden.cyberslayersagency.com)

### Upload Files
- [ ] Upload entire `server/` folder to backend domain directory
- [ ] Verify `.env` file is uploaded with correct credentials

### cPanel Node.js Setup
- [ ] Create Node.js app in cPanel
- [ ] Set Node version: **20.x**
- [ ] Set Application Root: Path to `server/` folder
- [ ] Set Startup File: `src/index.js`
- [ ] Set Application Mode: **Production**

### Environment Variables (in cPanel)
- [ ] `PORT=5000`
- [ ] `DB_HOST=localhost`
- [ ] `DB_USER=cybersla_lenden_admin`
- [ ] `DB_PASS=sheisonlymine`
- [ ] `DB_NAME=cybersla_lenden_database`
- [ ] `JWT_SECRET=shtxx@1982`
- [ ] `NODE_ENV=production`
- [ ] `FRONTEND_ORIGIN=https://lenden.cyberslayersagency.com`

### Start Backend
- [ ] Click "Run NPM Install" in cPanel
- [ ] Wait for installation to complete
- [ ] Click "Restart" to start the API
- [ ] Test: Visit `https://api.lenden.cyberslayersagency.com/` (should show "Lenden App API")

## Frontend Deployment (lenden.cyberslayersagency.com)

### Upload Files
- [ ] Upload all files from `client/dist/` to `public_html/`
- [ ] Upload `client/.htaccess` to `public_html/`

### Verify Upload
- [ ] Check `index.html` is in `public_html/`
- [ ] Check `assets/` folder exists with JS and CSS files
- [ ] Check `.htaccess` file is present

### Test Frontend
- [ ] Visit `https://lenden.cyberslayersagency.com`
- [ ] Should see login page
- [ ] Open browser console (F12), check for errors

## Full Stack Testing

- [ ] Register new account
- [ ] Create a shop
- [ ] Login with account
- [ ] Create a product
- [ ] Make a test sale
- [ ] Check reports page
- [ ] Verify all API calls go to `api.lenden.cyberslayersagency.com`

## Troubleshooting

### CORS Errors
1. Check `FRONTEND_ORIGIN` matches exactly: `https://lenden.cyberslayersagency.com`
2. Restart Node.js app
3. Clear browser cache

### API Not Responding
1. Check Node.js app is "Running" in cPanel
2. Check logs in cPanel (stderr.log)
3. Verify Startup File is `src/index.js`

### Database Errors
1. Verify database exists in phpMyAdmin
2. Check user has permissions
3. Import `schema.sql` if tables missing

### Frontend Blank Page
1. Check all files uploaded from `dist/`
2. Verify `.htaccess` is uploaded
3. Check browser console for errors

---

**See PRODUCTION_DEPLOYMENT.md for detailed instructions**
