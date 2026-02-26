-- Migration: Enhance notifications table for comprehensive notification system
-- This supports low stock, overdue payments, password resets, transactions, and system notifications

-- Check if notifications table exists, if not create it
CREATE TABLE IF NOT EXISTS notifications (
    id INT PRIMARY KEY AUTO_INCREMENT,
    shop_id INT NOT NULL,
    user_id INT NULL,
    type ENUM('low_stock', 'overdue_payment', 'daily_report', 'password_reset', 'transaction', 'system', 'account_activity') NOT NULL,
    title VARCHAR(255) NOT NULL,
    message TEXT NOT NULL,
    data JSON NULL,
    is_read BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    read_at TIMESTAMP NULL,
    FOREIGN KEY (shop_id) REFERENCES shops(id) ON DELETE CASCADE,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE SET NULL,
    INDEX idx_shop_user (shop_id, user_id),
    INDEX idx_is_read (is_read),
    INDEX idx_created_at (created_at),
    INDEX idx_type (type)
);

-- Add icon and action_url columns if they don't exist
ALTER TABLE notifications 
ADD COLUMN IF NOT EXISTS icon VARCHAR(50) DEFAULT 'notifications',
ADD COLUMN IF NOT EXISTS action_url VARCHAR(255) NULL;
