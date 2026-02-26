const db = require('./src/config/db');

async function migrate() {
    console.log("🚀 Starting Phase 4 Database Migration...");

    try {
        // 1. Add Verification columns to users
        console.log("Adding is_verified and verification_token to users table...");
        await db.execute(`
            ALTER TABLE users 
            ADD COLUMN is_verified TINYINT(1) DEFAULT 0 AFTER role,
            ADD COLUMN verification_token VARCHAR(255) AFTER is_verified
        `).catch(err => {
            if (err.code === 'ER_DUP_COLUMN_NAMES') console.log("Verification columns already exist.");
            else throw err;
        });

        // 2. Add cost_price to transaction_items
        console.log("Adding cost_price to transaction_items table...");
        await db.execute(`
            ALTER TABLE transaction_items 
            ADD COLUMN cost_price DECIMAL(10, 2) AFTER unit_price
        `).catch(err => {
            if (err.code === 'ER_DUP_COLUMN_NAMES') console.log("cost_price column already exists.");
            else throw err;
        });

        // 3. Backfill cost_price for existing sale items (using current product cost)
        console.log("Backfilling cost_price for existing items...");
        await db.execute(`
            UPDATE transaction_items ti
            JOIN products p ON ti.product_id = p.id
            SET ti.cost_price = p.cost_price
            WHERE ti.cost_price IS NULL AND ti.product_id IS NOT NULL
        `);

        console.log("✅ Phase 4 Migration Completed Successfully!");
        process.exit(0);
    } catch (error) {
        console.error("❌ Migration failed:", error);
        process.exit(1);
    }
}

migrate();
