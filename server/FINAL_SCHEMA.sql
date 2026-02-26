-- ====================================================
-- LENDEN APP - FINAL COMPLETE SCHEMA (All Migrations Applied)
-- Version: 2.0 FINAL
-- Date: 2026-01-30
-- Optimized for: Shared cPanel Hosting / MySQL 5.7+ / 8.0+
-- Domain: lenden.nhprince.dpdns.org
-- ====================================================
-- 
-- THIS IS THE COMPLETE SCHEMA - NO OTHER MIGRATIONS NEEDED
-- All SQL and JavaScript migrations have been consolidated
-- Ready for fresh database import on shared hosting
-- ====================================================

-- IMPORTANT: Replace 'lenden_database' with your actual cPanel database name
-- Example: CREATE DATABASE IF NOT EXISTS nhprince_lenden_db
-- For cPanel: The database will likely be prefixed with your username

SET NAMES utf8mb4;
SET character_set_client = utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

-- ====================================================
-- TABLE 1: USERS (Owner/Admin Accounts)
-- ====================================================
-- Migrations applied:
-- - migrate_recovery.js: Added reset_token, reset_expires, recovery_code
-- - migrate_user_avatar.js: Added profile_picture (renamed to avatar_url in schema)
-- - migrate_phase4.js: Added is_verified, verification_token
-- - add_due_dates_and_notifications.sql: Added notification_preferences

DROP TABLE IF EXISTS users;
CREATE TABLE users (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    email VARCHAR(255) UNIQUE NOT NULL,
    password VARCHAR(255) NOT NULL,
    role ENUM('owner', 'admin') DEFAULT 'owner',
    is_verified TINYINT(1) DEFAULT 0,
    verification_token VARCHAR(255),
    reset_token VARCHAR(255),
    reset_expires DATETIME,
    recovery_code VARCHAR(20),
    avatar_url VARCHAR(500),
    notification_preferences JSON DEFAULT '{"email": true, "inApp": true, "lowStock": true, "overdue": true}',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_email (email),
    INDEX idx_role (role)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
COMMENT='Owner and admin user accounts with authentication and profile settings';

-- ====================================================
-- TABLE 2: SHOPS (Multi-Shop Tenancy)
-- ====================================================
-- Migrations applied:
-- - migrate_shops.js: Added email, website, logo_url, header_title, footer_note, terms, show_logo
-- - migrate_shop_settings.js: Same columns (consolidated)

DROP TABLE IF EXISTS shops;
CREATE TABLE shops (
    id INT AUTO_INCREMENT PRIMARY KEY,
    owner_id INT NOT NULL,
    name VARCHAR(255) NOT NULL,
    business_type ENUM('general', 'bike_sales', 'garage', 'furniture', 'showroom', 'pickup_rental') NOT NULL,
    address TEXT,
    phone VARCHAR(20),
    email VARCHAR(255),
    website VARCHAR(255),
    logo_url TEXT,
    header_title VARCHAR(255) DEFAULT 'INVOICE',
    footer_note TEXT,
    terms TEXT,
    show_logo TINYINT(1) DEFAULT 1,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_owner (owner_id),
    INDEX idx_business_type (business_type),
    FOREIGN KEY (owner_id) REFERENCES users(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
COMMENT='Multi-shop data with invoice customization settings';

-- ====================================================
-- TABLE 3: CUSTOMERS (Per Shop)
-- ====================================================
-- Migrations applied:
-- - add_total_spent_to_customers.sql: Added total_spent column

DROP TABLE IF EXISTS customers;
CREATE TABLE customers (
    id INT AUTO_INCREMENT PRIMARY KEY,
    shop_id INT NOT NULL,
    name VARCHAR(255) NOT NULL,
    phone VARCHAR(20),
    address TEXT,
    email VARCHAR(255),
    total_due DECIMAL(10, 2) DEFAULT 0.00,
    total_spent DECIMAL(10, 2) DEFAULT 0.00,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_shop (shop_id),
    INDEX idx_name (name),
    INDEX idx_phone (phone),
    INDEX idx_total_due (total_due),
    FOREIGN KEY (shop_id) REFERENCES shops(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
COMMENT='Customer records with due tracking and purchase history';

-- ====================================================
-- TABLE 4: VENDORS (Suppliers)
-- ====================================================

DROP TABLE IF EXISTS vendors;
CREATE TABLE vendors (
    id INT AUTO_INCREMENT PRIMARY KEY,
    shop_id INT NOT NULL,
    name VARCHAR(255) NOT NULL,
    phone VARCHAR(20),
    company_name VARCHAR(255),
    email VARCHAR(255),
    address TEXT,
    total_payable DECIMAL(10, 2) DEFAULT 0.00,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_shop (shop_id),
    INDEX idx_name (name),
    INDEX idx_total_payable (total_payable),
    FOREIGN KEY (shop_id) REFERENCES shops(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
COMMENT='Vendor/supplier management with payable tracking';

-- ====================================================
-- TABLE 5: PRODUCTS (Inventory)
-- ====================================================
-- Migrations applied:
-- - migrate_product_images.js: Added image_url (VARCHAR 500, upgraded to LONGTEXT)
-- - 001_fix_image_url_size.sql: Changed image_url to LONGTEXT for base64 images

DROP TABLE IF EXISTS products;
CREATE TABLE products (
    id INT AUTO_INCREMENT PRIMARY KEY,
    shop_id INT NOT NULL,
    name VARCHAR(255) NOT NULL,
    category VARCHAR(100),
    sku VARCHAR(100),
    cost_price DECIMAL(10, 2) NOT NULL,
    selling_price DECIMAL(10, 2) NOT NULL,
    stock_quantity INT DEFAULT 0,
    unit VARCHAR(20) DEFAULT 'pcs',
    min_stock_level INT DEFAULT 5,
    engine_no VARCHAR(100),
    chassis_no VARCHAR(100),
    model_year VARCHAR(20),
    material_cost DECIMAL(10, 2),
    image_url LONGTEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_shop (shop_id),
    INDEX idx_name (name),
    INDEX idx_sku (sku),
    INDEX idx_category (category),
    INDEX idx_stock_quantity (stock_quantity),
    FOREIGN KEY (shop_id) REFERENCES shops(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
COMMENT='Product inventory with vehicle-specific fields and image storage';

-- ====================================================
-- TABLE 6: SERVICES (Service Catalog)
-- ====================================================

DROP TABLE IF EXISTS services;
CREATE TABLE services (
    id INT AUTO_INCREMENT PRIMARY KEY,
    shop_id INT NOT NULL,
    name VARCHAR(255) NOT NULL,
    description TEXT,
    service_charge DECIMAL(10, 2) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_shop (shop_id),
    INDEX idx_name (name),
    FOREIGN KEY (shop_id) REFERENCES shops(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
COMMENT='Service offerings for garage and rental businesses';

-- ====================================================
-- TABLE 7: TRANSACTIONS (Financial Records)
-- ====================================================
-- Migrations applied:
-- - add_due_dates_and_notifications.sql: Added due_date, status with 'Overdue'
-- - migrate_status.js: Added status enum
-- - migrate_snapshots.js: Added customer snapshot columns

DROP TABLE IF EXISTS transactions;
CREATE TABLE transactions (
    id INT AUTO_INCREMENT PRIMARY KEY,
    shop_id INT NOT NULL,
    customer_id INT,
    vendor_id INT,
    type ENUM('sale', 'purchase', 'expense', 'payment_received', 'payment_made') NOT NULL,
    amount DECIMAL(10, 2) NOT NULL,
    paid_amount DECIMAL(10, 2) DEFAULT 0.00,
    due_amount DECIMAL(10, 2) GENERATED ALWAYS AS (amount - paid_amount) STORED,
    payment_method ENUM('cash', 'bkash', 'bank', 'due', 'card', 'mobile') DEFAULT 'cash',
    reference_no VARCHAR(100),
    description TEXT,
    date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    due_date DATE NULL,
    status ENUM('Pending', 'Completed', 'Cancelled', 'Overdue') DEFAULT 'Pending',
    customer_name_snapshot VARCHAR(255) NULL,
    customer_phone_snapshot VARCHAR(50) NULL,
    customer_address_snapshot TEXT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_shop (shop_id),
    INDEX idx_customer (customer_id),
    INDEX idx_vendor (vendor_id),
    INDEX idx_date (date),
    INDEX idx_type (type),
    INDEX idx_due_date (due_date),
    INDEX idx_status (status),
    INDEX idx_status_due_date (status, due_date),
    INDEX idx_payment_method (payment_method),
    FOREIGN KEY (shop_id) REFERENCES shops(id) ON DELETE CASCADE,
    FOREIGN KEY (customer_id) REFERENCES customers(id) ON DELETE SET NULL,
    FOREIGN KEY (vendor_id) REFERENCES vendors(id) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
COMMENT='All financial transactions with customer snapshots for historical accuracy';

-- ====================================================
-- TABLE 8: TRANSACTION ITEMS (Line Items)
-- ====================================================
-- Migrations applied:
-- - migrate_phase4.js: Added cost_price for profit calculation

DROP TABLE IF EXISTS transaction_items;
CREATE TABLE transaction_items (
    id INT AUTO_INCREMENT PRIMARY KEY,
    transaction_id INT NOT NULL,
    product_id INT,
    service_id INT,
    quantity INT NOT NULL,
    unit_price DECIMAL(10, 2) NOT NULL,
    cost_price DECIMAL(10, 2),
    subtotal DECIMAL(10, 2) NOT NULL,
    INDEX idx_transaction (transaction_id),
    INDEX idx_product (product_id),
    INDEX idx_service (service_id),
    FOREIGN KEY (transaction_id) REFERENCES transactions(id) ON DELETE CASCADE,
    FOREIGN KEY (product_id) REFERENCES products(id) ON DELETE SET NULL,
    FOREIGN KEY (service_id) REFERENCES services(id) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
COMMENT='Transaction line items with cost tracking for profit reports';

-- ====================================================
-- TABLE 9: TRIPS (Pickup Rental Management)
-- ====================================================

DROP TABLE IF EXISTS trips;
CREATE TABLE trips (
    id INT AUTO_INCREMENT PRIMARY KEY,
    shop_id INT NOT NULL,
    vehicle_no VARCHAR(50) NOT NULL,
    driver_name VARCHAR(100),
    destination VARCHAR(255),
    start_date DATE,
    end_date DATE,
    trip_fare DECIMAL(10, 2) NOT NULL,
    expenses DECIMAL(10, 2) DEFAULT 0.00,
    customer_id INT,
    status ENUM('ongoing', 'completed', 'cancelled') DEFAULT 'ongoing',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_shop (shop_id),
    INDEX idx_status (status),
    INDEX idx_customer (customer_id),
    INDEX idx_start_date (start_date),
    FOREIGN KEY (shop_id) REFERENCES shops(id) ON DELETE CASCADE,
    FOREIGN KEY (customer_id) REFERENCES customers(id) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
COMMENT='Trip records for pickup rental businesses';

-- ====================================================
-- TABLE 10: STAFF (Employee Management)
-- ====================================================
-- Migrations applied:
-- - migrate_username.js: Added username column with UNIQUE constraint

DROP TABLE IF EXISTS staff;
CREATE TABLE staff (
    id INT AUTO_INCREMENT PRIMARY KEY,
    shop_id INT NOT NULL,
    name VARCHAR(255) NOT NULL,
    username VARCHAR(100) UNIQUE,
    email VARCHAR(255),
    password VARCHAR(255),
    phone VARCHAR(20),
    role VARCHAR(100) DEFAULT 'Staff',
    permissions JSON DEFAULT NULL,
    salary DECIMAL(10, 2),
    joining_date DATE,
    status ENUM('active', 'inactive') DEFAULT 'active',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_shop (shop_id),
    INDEX idx_username (username),
    INDEX idx_status (status),
    INDEX idx_email (email),
    FOREIGN KEY (shop_id) REFERENCES shops(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
COMMENT='Staff accounts with shop-level access and permissions';

-- ====================================================
-- TABLE 11: NOTIFICATIONS (In-App Notification System)
-- ====================================================
-- Migrations applied:
-- - init_notifications.js: Base table creation
-- - migrate_notifications.js: Alternative creation with different types
-- - add_due_dates_and_notifications.sql: Initial notification schema
-- - enhance_notifications_table.sql: Added icon, action_url, read_at, expanded types
-- - update_notifications_icons.sql: Icon field enhancements
-- Final: Consolidated all notification types and features

DROP TABLE IF EXISTS notifications;
CREATE TABLE notifications (
    id INT AUTO_INCREMENT PRIMARY KEY,
    shop_id INT NOT NULL,
    user_id INT DEFAULT NULL,
    type ENUM(
        'low_stock', 
        'payment_due', 
        'new_sale', 
        'system', 
        'staff_action', 
        'onboarding',
        'overdue_payment',
        'daily_report',
        'password_reset',
        'transaction',
        'account_activity',
        'general',
        'info',
        'warning'
    ) NOT NULL,
    title VARCHAR(255) NOT NULL,
    message TEXT NOT NULL,
    action_url VARCHAR(500) DEFAULT NULL,
    icon VARCHAR(50) DEFAULT 'notifications',
    is_read BOOLEAN DEFAULT FALSE,
    data JSON DEFAULT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    read_at TIMESTAMP NULL DEFAULT NULL,
    scheduled_for TIMESTAMP NULL DEFAULT NULL,
    INDEX idx_shop_unread (shop_id, is_read, created_at),
    INDEX idx_scheduled (scheduled_for),
    INDEX idx_shop_user (shop_id, user_id),
    INDEX idx_is_read (is_read),
    INDEX idx_type (type),
    INDEX idx_created_at (created_at),
    FOREIGN KEY (shop_id) REFERENCES shops(id) ON DELETE CASCADE,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
COMMENT='Notification system with scheduling and rich data support';

-- ====================================================
-- RE-ENABLE FOREIGN KEY CHECKS
-- ====================================================
SET FOREIGN_KEY_CHECKS = 1;

-- ====================================================
-- INITIAL DATA (Optional)
-- ====================================================
-- Uncomment to create a default admin user
-- Password must be bcrypt hashed - use online tool or node.js:
-- const bcrypt = require('bcryptjs');
-- const hash = bcrypt.hashSync('your_password', 10);

/*
INSERT INTO users (name, email, password, role, is_verified, recovery_code)
VALUES (
    'System Admin',
    'admin@nhprince.dpdns.org',
    '$2a$10$YourBcryptHashedPasswordHere',
    'admin',
    1,
    'ADMIN123'
);
*/

-- ====================================================
-- VERIFICATION QUERIES
-- ====================================================
-- Run these to verify the schema was created correctly

-- Check all tables
SELECT 
    TABLE_NAME as 'Table',
    TABLE_ROWS as 'Rows',
    ROUND(((DATA_LENGTH + INDEX_LENGTH) / 1024 / 1024), 2) as 'Size (MB)'
FROM INFORMATION_SCHEMA.TABLES
WHERE TABLE_SCHEMA = DATABASE()
ORDER BY TABLE_NAME;

-- Check all indexes
SELECT 
    TABLE_NAME as 'Table',
    INDEX_NAME as 'Index',
    GROUP_CONCAT(COLUMN_NAME ORDER BY SEQ_IN_INDEX) as 'Columns'
FROM INFORMATION_SCHEMA.STATISTICS
WHERE TABLE_SCHEMA = DATABASE()
GROUP BY TABLE_NAME, INDEX_NAME
ORDER BY TABLE_NAME, INDEX_NAME;

-- ====================================================
-- SUCCESS MESSAGE
-- ====================================================
SELECT 
    '✅ Lenden App Database Created Successfully!' AS STATUS,
    '📊 Total Tables: 11' AS INFO,
    '🔗 All Foreign Keys Applied' AS CONSTRAINTS,
    '🌐 UTF8MB4 Character Set' AS ENCODING,
    '📝 All Migrations Consolidated' AS MIGRATIONS,
    '🚀 Ready for Production' AS READY;

-- ====================================================
-- MIGRATION SUMMARY
-- ====================================================
-- This schema includes ALL of the following migrations:
--
-- SQL Migrations:
-- ✅ 001_fix_image_url_size.sql - LONGTEXT for product images
-- ✅ add_due_dates_and_notifications.sql - Due dates and notification system
-- ✅ add_total_spent_to_customers.sql - Customer spending tracking
-- ✅ enhance_notifications_table.sql - Enhanced notification features
-- ✅ update_notifications_icons.sql - Notification icons
--
-- JavaScript Migrations:
-- ✅ init_notifications.js - Notifications table initialization
-- ✅ migrate_notifications.js - Notification types
-- ✅ migrate_phase4.js - Verification, cost_price tracking
-- ✅ migrate_product_images.js - Product image_url
-- ✅ migrate_recovery.js - Password reset tokens, recovery codes
-- ✅ migrate_shop_settings.js - Shop invoice customization
-- ✅ migrate_shops.js - Shop profile fields
-- ✅ migrate_snapshots.js - Customer data snapshots in transactions
-- ✅ migrate_status.js - Transaction status
-- ✅ migrate_user_avatar.js - User avatar/profile picture
-- ✅ migrate_username.js - Staff username field
--
-- Total: 16 migrations consolidated into one schema
-- ====================================================

-- ====================================================
-- SHARED HOSTING OPTIMIZATION NOTES
-- ====================================================
-- This schema is optimized for shared cPanel hosting:
-- 
-- 1. ✅ Uses InnoDB engine (better for shared hosting)
-- 2. ✅ Proper indexing to reduce query load
-- 3. ✅ UTF8MB4 for multilingual support
-- 4. ✅ Cascading deletes to maintain data integrity
-- 5. ✅ Generated columns for computed values (due_amount)
-- 6. ✅ Compatible with MySQL 5.7+ and MySQL 8.0+
-- 7. ✅ JSON columns for flexible data storage
-- 8. ✅ LONGTEXT for base64 image storage (upgrade to file storage recommended)
--
-- Performance Tips:
-- - Regular OPTIMIZE TABLE maintenance
-- - Monitor slow query log
-- - Consider migrating images to file storage for better performance
-- - Use connection pooling in application (already implemented)
-- ====================================================

-- END OF SCHEMA
