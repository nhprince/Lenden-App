const db = require('./src/config/db');

async function migrate() {
    try {
        console.log("Checking for notifications table...");

        // Check if table exists
        const [tables] = await db.execute("SHOW TABLES LIKE 'notifications'");

        if (tables.length === 0) {
            console.log("Creating notifications table...");
            await db.execute(`
                CREATE TABLE notifications (
                    id INT AUTO_INCREMENT PRIMARY KEY,
                    shop_id INT NOT NULL,
                    type ENUM('low_stock', 'overdue_payment', 'general', 'info', 'warning') DEFAULT 'info',
                    title VARCHAR(255) NOT NULL,
                    message TEXT NOT NULL,
                    link VARCHAR(255),
                    is_read BOOLEAN DEFAULT FALSE,
                    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                    INDEX idx_shop (shop_id),
                    INDEX idx_read (is_read),
                    FOREIGN KEY (shop_id) REFERENCES shops(id) ON DELETE CASCADE
                ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
            `);
            console.log("✅ Notifications table created successfully.");
        } else {
            console.log("ℹ️ Notifications table already exists.");
        }

    } catch (error) {
        console.error("❌ Migration failed:", error);
    } finally {
        process.exit();
    }
}

migrate();
