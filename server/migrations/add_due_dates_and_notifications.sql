-- Migration: Add Due Dates and Notifications System
-- Run this SQL on your database

-- Step 1: Add due_date column to transactions table
ALTER TABLE transactions 
ADD COLUMN due_date DATE NULL AFTER date,
ADD INDEX idx_due_date (due_date),
ADD INDEX idx_status_due_date (status, due_date);

-- Step 2: Add notification preferences to users table
ALTER TABLE users
ADD COLUMN notification_preferences JSON DEFAULT '{"email": true, "inApp": true, "lowStock": true, "overdue": true}';

-- Step 3: Create notifications table
CREATE TABLE IF NOT EXISTS notifications (
    id INT AUTO_INCREMENT PRIMARY KEY,
    shop_id INT NOT NULL,
    user_id INT NULL,
    type ENUM('low_stock', 'overdue_payment', 'payment_received', 'new_order', 'system') NOT NULL,
    title VARCHAR(255) NOT NULL,
    message TEXT NOT NULL,
    link VARCHAR(500) NULL,
    is_read BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_shop_user (shop_id, user_id),
    INDEX idx_read_created (is_read, created_at),
    INDEX idx_type (type),
    FOREIGN KEY (shop_id) REFERENCES shops(id) ON DELETE CASCADE,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Step 4: Add overdue status to transactions (optional enhancement)
-- This allows explicit marking of overdue transactions
ALTER TABLE transactions 
MODIFY COLUMN status ENUM('Pending', 'Completed', 'Cancelled', 'Overdue') DEFAULT 'Pending';
