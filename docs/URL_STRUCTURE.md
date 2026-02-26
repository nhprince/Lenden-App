# 🎯 URL Structure & API Routing

## Understanding the Deployment Architecture

### Domain Setup

```
Frontend: lenden.cyberslayersagency.com/
Backend:  api.lenden.cyberslayersagency.com/
```

### How API Calls Work

#### Frontend Configuration
```javascript
// client/.env.production
VITE_API_URL=https://api.lenden.cyberslayersagency.com

// client/src/utils/api.js
const api = axios.create({
  baseURL: 'https://api.lenden.cyberslayersagency.com'
});
```

#### Backend Routes (server/src/index.js)
```javascript
app.use('/api/auth', ...)      // Handles /api/auth/*
app.use('/api/shops', ...)     // Handles /api/shops/*
app.use('/api/products', ...)  // Handles /api/products/*
// etc...
```

### Complete URL Examples

When frontend calls `api.post('/shops')`:
```
Base URL: https://api.lenden.cyberslayersagency.com
Route:    /api/shops
Full URL: https://api.lenden.cyberslayersagency.com/api/shops ✅
```

### All API Endpoints

| Frontend Call | Full Backend URL |
|--------------|------------------|
| `api.post('/auth/register')` | `https://api.lenden.cyberslayersagency.com/api/auth/register` |
| `api.post('/auth/login')` | `https://api.lenden.cyberslayersagency.com/api/auth/login` |
| `api.get('/shops')` | `https://api.lenden.cyberslayersagency.com/api/shops` |
| `api.post('/shops')` | `https://api.lenden.cyberslayersagency.com/api/shops` |
| `api.get('/products')` | `https://api.lenden.cyberslayersagency.com/api/products` |
| `api.post('/products')` | `https://api.lenden.cyberslayersagency.com/api/products` |
| `api.get('/customers')` | `https://api.lenden.cyberslayersagency.com/api/customers` |
| `api.post('/transactions/sale')` | `https://api.lenden.cyberslayersagency.com/api/transactions/sale` |
| `api.get('/reports/summary')` | `https://api.lenden.cyberslayersagency.com/api/reports/summary` |

### Directory Structure on cPanel

#### Backend Domain (api.lenden.cyberslayersagency.com)
```
/home/cybersla/api.lenden.cyberslayersagency.com/
├── src/
│   ├── index.js          ← Startup file: src/index.js
│   ├── config/
│   ├── controllers/
│   ├── middleware/
│   └── routes/
├── .env                  ← Database credentials
├── package.json
├── package-lock.json
└── schema.sql
```

#### Frontend Domain (lenden.cyberslayersagency.com)
```
/home/cybersla/lenden.cyberslayersagency.com/public_html/
├── .htaccess             ← React Router support
├── index.html
├── assets/
│   ├── index-[hash].js
│   ├── index-[hash].css
│   └── vendor-[hash].js
└── vite.svg
```

### Testing API Routes

```bash
# Health check
curl https://api.lenden.cyberslayersagency.com/

# Test auth endpoint (should return validation error)
curl -X POST https://api.lenden.cyberslayersagency.com/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"test","password":"test"}'

# Test CORS
curl -H "Origin: https://lenden.cyberslayersagency.com" \
  -I https://api.lenden.cyberslayersagency.com/api/shops
```

### Important Notes

✅ **Correct Configuration**:
- Frontend calls: `api.post('/shops')`
- Backend serves: `/api/shops`
- Full URL: `https://api.lenden.cyberslayersagency.com/api/shops`

❌ **Common Mistake**:
```javascript
// WRONG - Don't do this:
VITE_API_URL=https://api.lenden.cyberslayersagency.com/api  // ❌ Extra /api

// This would result in:
// https://api.lenden.cyberslayersagency.com/api/api/shops  // ❌ Duplicate /api
```

✅ **Correct**:
```javascript
VITE_API_URL=https://api.lenden.cyberslayersagency.com      // ✅ No /api suffix
```

The `/api` prefix is already in the backend routes!
