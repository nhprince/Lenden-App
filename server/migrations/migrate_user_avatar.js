const db = require('./src/config/db');

async function migrate() {
    try {
        console.log("Checking for profile_picture column in users table...");

        const [columns] = await db.execute("SHOW COLUMNS FROM users LIKE 'profile_picture'");

        if (columns.length === 0) {
            console.log("Adding profile_picture column...");
            await db.execute("ALTER TABLE users ADD COLUMN profile_picture TEXT");
            console.log("✅ profile_picture column added successfully.");
        } else {
            console.log("ℹ️ profile_picture column already exists.");
        }

    } catch (error) {
        console.error("❌ Migration failed:", error);
    } finally {
        process.exit();
    }
}

migrate();
