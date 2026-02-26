-- Migration: Add icon and action_url columns to notifications table
ALTER TABLE notifications 
ADD COLUMN IF NOT EXISTS icon VARCHAR(50) DEFAULT 'notifications',
ADD COLUMN IF NOT EXISTS action_url VARCHAR(255) NULL;

-- Update existing notification types map
UPDATE notifications SET icon = 'inventory_2' WHERE type = 'low_stock';
UPDATE notifications SET icon = 'warning' WHERE type = 'overdue_payment';
UPDATE notifications SET icon = 'shopping_cart' WHERE type = 'transaction';
