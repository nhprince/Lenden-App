const mysql = require('mysql2/promise');
require('dotenv').config();

/**
 * Safe Migration Script for Shop Settings
 * Adds invoice and shop profile columns to shops table
 * Uses IF NOT EXISTS to avoid errors on already-migrated databases
 */

async function migrate() {
    const connection = await mysql.createConnection({
        host: process.env.DB_HOST,
        user: process.env.DB_USER,
        password: process.env.DB_PASS,
        database: process.env.DB_NAME
    });

    try {
        console.log('🔄 Starting shop settings migration...');

        // Check which columns already exist
        const [columns] = await connection.execute(
            "SELECT COLUMN_NAME FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_SCHEMA = ? AND TABLE_NAME = 'shops'",
            [process.env.DB_NAME]
        );

        const existingColumns = columns.map(col => col.COLUMN_NAME);
        console.log('📋 Existing columns:', existingColumns);

        // Add columns only if they don't exist
        const columnsToAdd = [
            { name: 'email', type: 'VARCHAR(255)' },
            { name: 'website', type: 'VARCHAR(255)' },
            { name: 'logo_url', type: 'TEXT' },
            { name: 'header_title', type: 'VARCHAR(255) DEFAULT "INVOICE"' },
            { name: 'footer_note', type: 'TEXT' },
            { name: 'terms', type: 'TEXT' },
            { name: 'show_logo', type: 'TINYINT(1) DEFAULT 1' }
        ];

        for (const col of columnsToAdd) {
            if (!existingColumns.includes(col.name)) {
                const sql = `ALTER TABLE shops ADD COLUMN ${col.name} ${col.type}`;
                console.log(`➕ Adding column: ${col.name}`);
                await connection.execute(sql);
            } else {
                console.log(`✓ Column already exists: ${col.name}`);
            }
        }

        console.log('✅ Migration completed successfully!');
        console.log('\n📊 Final shop table structure:');

        const [finalColumns] = await connection.execute('DESCRIBE shops');
        console.table(finalColumns);

    } catch (error) {
        console.error('❌ Migration failed:', error.message);
        throw error;
    } finally {
        await connection.end();
    }
}

// Run migration
migrate()
    .then(() => {
        console.log('\n🎉 All done!');
        process.exit(0);
    })
    .catch((error) => {
        console.error('\n💥 Migration error:', error);
        process.exit(1);
    });
