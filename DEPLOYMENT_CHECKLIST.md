# 🚀 Lenden App - Quick Deployment Checklist

## New Hosting Details
- **Frontend**: https://lenden.nhprince.dpdns.org
- **Backend**: https://api.lenden.nhprince.dpdns.org
- **Version**: 2.0.0

---

## ✅ Pre-Deployment (Local)

### 1. Update Environment Files
- [ ] Copy `server/.env.example` to `server/.env`
- [ ] Update database credentials in `server/.env`
- [ ] Generate JWT secret: `node -e "console.log(require('crypto').randomBytes(64).toString('hex'))"`
- [ ] Update email settings in `server/.env`
- [ ] Copy `client/.env.production` to `client/.env`

### 2. Build Frontend
```bash
cd client
npm install
npm run build
```
- [ ] Build completes without errors
- [ ] `dist/` folder created

---

## 📊 Database Setup (cPanel)

### Create Database (5 min)
- [ ] Login to cPanel
- [ ] MySQL Databases → Create database: `lenden_db`
- [ ] Create user: `lenden_user` with strong password
- [ ] Add user to database with ALL PRIVILEGES
- [ ] Note credentials for `.env`

### Import Schema (2 min)
- [ ] phpMyAdmin → Select database
- [ ] Import → Choose `server/FINAL_SCHEMA.sql`
- [ ] Verify 11 tables created:
  - users, shops, customers, vendors, products
  - services, transactions, transaction_items
  - trips, staff, notifications

---

## 🔧 Backend Deployment (15 min)

### Create Subdomain
- [ ] cPanel → Subdomains
- [ ] Create: `api.lenden.nhprince.dpdns.org`
- [ ] Document root: `~/api.lenden`

### Upload Files
Via File Manager or FTP to `/home/username/api.lenden/`:
- [ ] `package.json` & `package-lock.json`
- [ ] `/src/` folder (entire)
- [ ] Create `.env` file with production settings

### Configure .env
```env
DB_HOST=localhost
DB_USER=nhprince_lenden_user
DB_PASS=[your_password]
DB_NAME=nhprince_lenden_db
PORT=5000
NODE_ENV=production
JWT_SECRET=[generated_secret]
FRONTEND_ORIGIN=https://lenden.nhprince.dpdns.org
EMAIL_HOST=mail.nhprince.dpdns.org
EMAIL_PORT=465
EMAIL_SECURE=true
EMAIL_USER=noreply@nhprince.dpdns.org
EMAIL_PASS=[email_password]
```

### Setup Node.js App
- [ ] cPanel → Setup Node.js App
- [ ] Node version: 18.x or higher
- [ ] Application root: `api.lenden`
- [ ] Application URL: `api.lenden.nhprince.dpdns.org`
- [ ] Startup file: `src/index.js`
- [ ] Click "Create" → "Run NPM Install" → "Start App"

### Create .htaccess
In `/home/username/api.lenden/.htaccess`:
```apache
Header always set Access-Control-Allow-Origin "https://lenden.nhprince.dpdns.org"
Header always set Access-Control-Allow-Methods "GET, POST, PUT, DELETE, OPTIONS"
Header always set Access-Control-Allow-Headers "Content-Type, Authorization, Shop-Id"
Header always set Access-Control-Allow-Credentials "true"

PassengerEnabled on
PassengerAppRoot /home/username/api.lenden
PassengerAppType node
PassengerStartupFile src/index.js
```

### Test API
- [ ] Visit: https://api.lenden.nhprince.dpdns.org/
- [ ] Should return JSON with "status": "running"

---

## 🎨 Frontend Deployment (10 min)

### Create Subdomain/Main Domain
- [ ] cPanel → Subdomains or Domains
- [ ] Create: `lenden.nhprince.dpdns.org`
- [ ] Document root: `~/public_html/lenden` or `~/lenden`

### Upload Build Files
Via File Manager or FTP to frontend directory:
- [ ] Upload entire contents of `client/dist/`
  - index.html
  - /assets/ folder
  - favicon.ico
  - all other files

### Create .htaccess
In frontend directory:
```apache
<IfModule mod_rewrite.c>
  RewriteEngine On
  RewriteBase /
  
  # Force HTTPS
  RewriteCond %{HTTPS} off
  RewriteRule ^(.*)$ https://%{HTTP_HOST%}/$1 [R=301,L]
  
  # Handle React Router
  RewriteCond %{REQUEST_FILENAME} !-f
  RewriteCond %{REQUEST_FILENAME} !-d
  RewriteRule . /index.html [L]
</IfModule>

# Security Headers
<IfModule mod_headers.c>
  Header set X-Content-Type-Options "nosniff"
  Header set X-Frame-Options "SAMEORIGIN"
  Header set X-XSS-Protection "1; mode=block"
</IfModule>

# Compression
<IfModule mod_deflate.c>
  AddOutputFilterByType DEFLATE text/html text/css application/javascript
</IfModule>

Options -Indexes
ErrorDocument 404 /index.html
```

### Test Frontend
- [ ] Visit: https://lenden.nhprince.dpdns.org
- [ ] Login page loads
- [ ] No console errors (F12)

---

## 📧 Email Setup (5 min)

### Create Email Account
- [ ] cPanel → Email Accounts
- [ ] Create: `noreply@nhprince.dpdns.org`
- [ ] Strong password
- [ ] Storage: 100MB

### Update Backend .env
- [ ] Update EMAIL_USER and EMAIL_PASS
- [ ] Restart Node.js app

---

## 🔒 SSL Certificate (5 min)

### Install SSL
- [ ] cPanel → SSL/TLS Status
- [ ] Select both domains:
  - lenden.nhprince.dpdns.org
  - api.lenden.nhprince.dpdns.org
- [ ] Run AutoSSL
- [ ] Wait for completion

### Verify SSL
- [ ] Visit both URLs with https://
- [ ] Check for padlock icon

---

## 🧪 Testing (10 min)

### Functional Tests
- [ ] **Registration**: Create new account
- [ ] **Email**: Receive verification email
- [ ] **Login**: Login with credentials
- [ ] **Shop Creation**: Create first shop
- [ ] **Dashboard**: Data loads correctly
- [ ] **Products**: Add test product
- [ ] **POS**: Make test sale
- [ ] **Reports**: View dashboard analytics

### Technical Tests
- [ ] No 404 errors on page refresh
- [ ] No CORS errors in console
- [ ] API responses return 200 status
- [ ] Images upload successfully
- [ ] PDF generation works

---

## 🔐 Post-Deployment Security

### Immediate Actions
- [ ] Change default admin password (if created)
- [ ] Verify JWT_SECRET is strong and unique
- [ ] Test email delivery
- [ ] Review cPanel security settings
- [ ] Enable 2FA on cPanel

### Backup Setup
- [ ] Schedule automated database backup (cPanel Backup Wizard)
- [ ] Test manual database export
- [ ] Save `.env` file securely offline
- [ ] Document all credentials

---

## 📊 Monitoring

### Daily
- [ ] Check if Node.js app is running
- [ ] Review error logs
- [ ] Verify email delivery

### Weekly
- [ ] Database backup download
- [ ] Review access logs
- [ ] Check storage usage

---

## 🐛 Quick Troubleshooting

### API not loading
```bash
# Check Node.js app status in cPanel
# Restart app if needed
# Check error logs
```

### CORS errors
- Verify FRONTEND_ORIGIN in backend `.env`
- Check `.htaccess` CORS headers
- Restart Node.js app

### Database connection failed
- Verify credentials in `.env`
- Check database user permissions
- Test via phpMyAdmin

### Frontend blank page
- Clear browser cache
- Check console for errors
- Verify API URL in production build
- Rebuild frontend if needed

---

## 📞 Support Resources

### Documentation
- Full Guide: `CPANEL_DEPLOYMENT_GUIDE.md`
- Database Schema: `server/FINAL_SCHEMA.sql`
- API Docs: `docs/URL_STRUCTURE.md`

### Commands
```bash
# Generate JWT secret
node -e "console.log(require('crypto').randomBytes(64).toString('hex'))"

# Build frontend
cd client && npm run build

# Test API locally
cd server && npm run dev
```

---

## ✅ Final Verification

- [ ] ✅ Database: 11 tables created
- [ ] ✅ Backend: API responding at https://api.lenden.nhprince.dpdns.org/
- [ ] ✅ Frontend: App loading at https://lenden.nhprince.dpdns.org
- [ ] ✅ SSL: Active on both domains
- [ ] ✅ Email: Verification emails sending
- [ ] ✅ Auth: Login/registration working
- [ ] ✅ Shop: Can create and manage shops
- [ ] ✅ Data: All CRUD operations functional
- [ ] ✅ Security: All credentials secured
- [ ] ✅ Backup: Automated backup scheduled

---

## 🎉 Deployment Complete!

Your Lenden App is now live at:
- **App**: https://lenden.nhprince.dpdns.org
- **API**: https://api.lenden.nhprince.dpdns.org

**Next Steps**:
1. Create your first business account
2. Set up shop details
3. Add initial inventory
4. Train staff on the system
5. Monitor for issues

---

**Version**: 2.0.0  
**Date**: January 30, 2026  
**Domain**: nhprince.dpdns.org
