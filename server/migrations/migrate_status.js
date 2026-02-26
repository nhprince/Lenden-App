const db = require('./src/config/db');

async function migrate() {
    try {
        console.log("Checking transactions table for status column...");
        const [columns] = await db.execute("SHOW COLUMNS FROM transactions LIKE 'status'");

        if (columns.length === 0) {
            console.log("Adding status column to transactions table...");
            await db.execute("ALTER TABLE transactions ADD COLUMN status ENUM('Completed', 'Pending', 'Cancelled') DEFAULT 'Pending'");
            console.log("Status column added successfully.");
        } else {
            console.log("Status column already exists.");
        }

    } catch (error) {
        console.error("Migration failed:", error);
    } finally {
        process.exit();
    }
}

migrate();
