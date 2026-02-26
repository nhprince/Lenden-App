const path = require('path');
// Load .env from the current directory
require('dotenv').config();
// Adjust path to point directly to src
const db = require('./src/config/db');

async function migrate() {
    try {
        console.log('🔌 Connecting to database...');
        const connection = await db.getConnection();
        console.log('✅ Connected.');

        const columns = [
            'ADD COLUMN customer_name_snapshot VARCHAR(255) NULL',
            'ADD COLUMN customer_phone_snapshot VARCHAR(50) NULL',
            'ADD COLUMN customer_address_snapshot TEXT NULL'
        ];

        for (const col of columns) {
            try {
                await connection.execute(`ALTER TABLE transactions ${col}`);
                console.log(`✅ Executed: ${col}`);
            } catch (error) {
                if (error.code === 'ER_DUP_FIELDNAME') {
                    console.log(`⚠️  Column already exists (skip): ${col}`);
                } else {
                    console.error(`❌ Failed: ${col}`, error.message);
                }
            }
        }

        connection.release();
        console.log('🎉 Migration completed.');
        process.exit(0);
    } catch (error) {
        console.error('❌ Migration failed:', error);
        process.exit(1);
    }
}

migrate();