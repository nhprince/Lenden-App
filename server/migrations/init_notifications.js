const db = require('./src/config/db');

async function createTable() {
    try {
        console.log('🚧 Creating notifications table...');
        await db.execute(`
            CREATE TABLE IF NOT EXISTS notifications (
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
        `);
        console.log('✅ Notifications table created successfully!');
        console.log('✅ Notifications table initialized!');
    } catch (error) {
        console.error('❌ Failed to create table:', error);
    }
}

// Export the function instead of running it
module.exports = { createTable };

// Only run if called directly
if (require.main === module) {
    createTable().then(() => process.exit(0)).catch(() => process.exit(1));
}
