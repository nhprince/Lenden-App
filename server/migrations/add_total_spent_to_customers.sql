-- Migration: Add total_spent column to customers table
-- This column will track the total amount a customer has spent

ALTER TABLE customers 
ADD COLUMN IF NOT EXISTS total_spent DECIMAL(10, 2) DEFAULT 0.00 AFTER total_due;

-- Update existing customers with calculated total_spent from transactions
UPDATE customers c
SET total_spent = (
    SELECT COALESCE(SUM(t.amount), 0)
    FROM transactions t
    WHERE t.customer_id = c.id 
    AND t.type = 'sale'
    AND c.shop_id = t.shop_id
)
WHERE c.shop_id IS NOT NULL;
