const express = require('express');
const cors = require('cors');
const rateLimit = require('express-rate-limit');
require('dotenv').config();

const app = express();

// Trust proxy configuration for production reverse proxies (cPanel/Nginx)
app.set('trust proxy', true);

const PORT = process.env.PORT || 5000;

const path = require('path');

// CORS Configuration for Production
const corsOptions = {
  origin: function (origin, callback) {
    if (!origin) return callback(null, true);
    const allowedOrigins = [
      process.env.FRONTEND_ORIGIN || 'https://lenden.nhprince.dpdns.org',
      'https://lenden.cyberslayersagency.com'
    ];
    if (allowedOrigins.indexOf(origin) !== -1 || process.env.NODE_ENV === 'development') {
      callback(null, true);
    } else {
      callback(new Error('Not allowed by CORS'));
    }
  },
  credentials: true,
  methods: ['GET', 'POST', 'PUT', 'DELETE', 'OPTIONS'],
  allowedHeaders: ['Content-Type', 'Authorization', 'Shop-Id'],
  optionsSuccessStatus: 200
};

// Rate limiting (Disabled for debugging mobile connection)
const limiter = (req, res, next) => next();
const authLimiter = (req, res, next) => next();

// Middleware
app.use(cors()); // Allow all origins for debugging
app.use(express.json({ limit: '10mb' }));
app.use(express.urlencoded({ extended: true, limit: '10mb' }));

// Security headers
app.use((req, res, next) => {
  res.setHeader('X-Content-Type-Options', 'nosniff');
  res.setHeader('X-Frame-Options', 'DENY');
  res.setHeader('X-XSS-Protection', '1; mode=block');
  res.setHeader('Strict-Transport-Security', 'max-age=31536000; includeSubDomains');
  next();
});

// Apply rate limiting to all API routes
app.use('/api/', limiter);


// Serve uploaded files
app.use('/uploads', express.static(path.join(__dirname, '../uploads')));

// Routes
app.use('/api/auth', authLimiter, require('./routes/authRoutes'));
app.use('/api/shops', require('./routes/shopRoutes'));
app.use('/api/products', require('./routes/productRoutes'));
app.use('/api/customers', require('./routes/customerRoutes'));
app.use('/api/transactions', require('./routes/transactionRoutes'));
app.use('/api/vendors', require('./routes/vendorRoutes'));
app.use('/api/reports', require('./routes/reportRoutes'));
app.use('/api/staff', require('./routes/staffRoutes'));
app.use('/api/services', require('./routes/serviceRoutes'));
app.use('/api/trips', require('./routes/tripRoutes'));
app.use('/api/backup', require('./routes/backupRoutes'));
app.use('/api/notifications', require('./routes/notificationRoutes'));

// Error Handler Middleware
app.use(require('./middleware/errorMiddleware'));

// Health check endpoint
app.get('/', (req, res) => {
  res.json({
    message: "Lenden App API",
    status: "running",
    version: "1.0.0",
    environment: process.env.NODE_ENV || 'development'
  });
});

// 404 handler for undefined routes
app.use((req, res) => {
  res.status(404).json({ message: 'Route not found' });
});

// Start Server
const server = app.listen(PORT, () => {
  console.log(`✅ Lenden API Server running on port ${PORT}`);
  console.log(`🌍 Environment: ${process.env.NODE_ENV || 'development'}`);
  console.log(`🔒 CORS enabled for: ${process.env.FRONTEND_ORIGIN || 'https://lenden.nhprince.dpdns.org'}`);
});

// Initialize Database Tables if missing
const { createTable } = require('../init_notifications');
createTable();

// Initialize Cron Jobs
const initCronJobs = require('./utils/cronJobs');
initCronJobs();

module.exports = server;
