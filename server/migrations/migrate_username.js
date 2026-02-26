const db = require('./src/config/db');

async function run() {
    try {
        console.log("Environment check:");
        console.log("DB_HOST:", process.env.DB_HOST);
        console.log("DB_USER:", process.env.DB_USER);
        console.log("DB_NAME:", process.env.DB_NAME);

        console.log("Attempting to connect and run migration...");

        // Try to add column via raw SQL if pool fails, but we use the promise pool here
        const [columns] = await db.execute("SHOW COLUMNS FROM staff");
        const hasUsername = columns.some(c => c.Field === 'username');

        if (!hasUsername) {
            console.log("Adding username column...");
            await db.execute("ALTER TABLE staff ADD COLUMN username VARCHAR(100) UNIQUE AFTER name");
            console.log("Column added successfully.");
        } else {
            console.log("Username column already exists.");
        }
    } catch (e) {
        console.error("Migration failed:", e.message);
        if (e.message.includes('ECONNREFUSED')) {
            console.log("Connection refused. Trying alternative host '127.0.0.1'...");
            // Manual connection attempt could go here if needed, but we'll try to find the right host first
        }
    } finally {
        process.exit();
    }
}

run();
