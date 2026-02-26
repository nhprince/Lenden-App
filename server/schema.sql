-- ====================================================
-- LENDEN APP PRODUCTION SCHEMA (V1.0)
-- Optimized for cPanel / MySQL 5.7+ / 8.0+
-- Database: cybersla_lenden_database
-- ====================================================

USE cybersla_lenden_database;

SET NAMES utf8mb4;
SET character_set_client = utf8mb4;

-- 1. Users (Owners)
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
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_email (email)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 2. Shops
CREATE TABLE shops (
    id INT AUTO_INCREMENT PRIMARY KEY,
    owner_id INT NOT NULL,
    name VARCHAR(255) NOT NULL,
    business_type ENUM('general', 'bike_sales', 'garage', 'furniture', 'showroom', 'pickup_rental') NOT NULL,
    address TEXT,
    phone VARCHAR(20),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_owner (owner_id),
    FOREIGN KEY (owner_id) REFERENCES users(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 3. Customers
CREATE TABLE customers (
    id INT AUTO_INCREMENT PRIMARY KEY,
    shop_id INT NOT NULL,
    name VARCHAR(255) NOT NULL,
    phone VARCHAR(20),
    address TEXT,
    total_due DECIMAL(10, 2) DEFAULT 0.00,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_shop (shop_id),
    INDEX idx_name (name),
    FOREIGN KEY (shop_id) REFERENCES shops(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 4. Vendors
CREATE TABLE vendors (
    id INT AUTO_INCREMENT PRIMARY KEY,
    shop_id INT NOT NULL,
    name VARCHAR(255) NOT NULL,
    phone VARCHAR(20),
    company_name VARCHAR(255),
    total_payable DECIMAL(10, 2) DEFAULT 0.00,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_shop (shop_id),
    INDEX idx_name (name),
    FOREIGN KEY (shop_id) REFERENCES shops(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 5. Products
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
    INDEX idx_shop (shop_id),
    INDEX idx_name (name),
    INDEX idx_sku (sku),
    FOREIGN KEY (shop_id) REFERENCES shops(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 6. Services
CREATE TABLE services (
    id INT AUTO_INCREMENT PRIMARY KEY,
    shop_id INT NOT NULL,
    name VARCHAR(255) NOT NULL,
    description TEXT,
    service_charge DECIMAL(10, 2) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_shop (shop_id),
    FOREIGN KEY (shop_id) REFERENCES shops(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 7. Transactions
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
    INDEX idx_shop (shop_id),
    INDEX idx_customer (customer_id),
    INDEX idx_vendor (vendor_id),
    INDEX idx_date (date),
    INDEX idx_type (type),
    FOREIGN KEY (shop_id) REFERENCES shops(id) ON DELETE CASCADE,
    FOREIGN KEY (customer_id) REFERENCES customers(id) ON DELETE SET NULL,
    FOREIGN KEY (vendor_id) REFERENCES vendors(id) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 8. Transaction Items
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
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 9. Trips
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
    FOREIGN KEY (shop_id) REFERENCES shops(id) ON DELETE CASCADE,
    FOREIGN KEY (customer_id) REFERENCES customers(id) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 10. Staff
CREATE TABLE staff (
    id INT AUTO_INCREMENT PRIMARY KEY,
    shop_id INT NOT NULL,
    name VARCHAR(255) NOT NULL,
    username VARCHAR(100) UNIQUE,
    email VARCHAR(255),
    password VARCHAR(255),
    phone VARCHAR(20),
    role VARCHAR(100) DEFAULT 'Staff',
    salary DECIMAL(10, 2),
    joining_date DATE,
    status ENUM('active', 'inactive') DEFAULT 'active',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_shop (shop_id),
    FOREIGN KEY (shop_id) REFERENCES shops(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 11. Notifications
CREATE TABLE notifications (
    id INT AUTO_INCREMENT PRIMARY KEY,
    shop_id INT NOT NULL,
    user_id INT DEFAULT NULL,
    type ENUM('low_stock', 'payment_due', 'new_sale', 'system', 'staff_action', 'onboarding') NOT NULL,
    title VARCHAR(255) NOT NULL,
    message TEXT NOT NULL,
    action_url VARCHAR(500) DEFAULT NULL,
    is_read BOOLEAN DEFAULT FALSE,
    data JSON DEFAULT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    scheduled_for TIMESTAMP NULL DEFAULT NULL,
    INDEX idx_shop_unread (shop_id, is_read, created_at),
    INDEX idx_scheduled (scheduled_for),
    FOREIGN KEY (shop_id) REFERENCES shops(id) ON DELETE CASCADE,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Success Message
SELECT '✅ Database Schema Created Successfully (10 Tables)' AS Status;
