require('dotenv').config();
const mysql = require('mysql2/promise');

async function migrate() {
    let connection;
    try {
        console.log('🔄 Starting product image_url migration...');

        // Create database connection
        connection = await mysql.createConnection({
            host: process.env.DB_HOST,
            user: process.env.DB_USER,
            password: process.env.DB_PASS,
            database: process.env.DB_NAME
        });

        console.log('✅ Connected to database');

        // Check if column already exists
        const [columns] = await connection.execute(
            "SELECT COLUMN_NAME FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_SCHEMA = ? AND TABLE_NAME = 'products' AND COLUMN_NAME = 'image_url'",
            [process.env.DB_NAME]
        );

        if (columns.length > 0) {
            console.log('ℹ️  Column image_url already exists in products table');
        } else {
            // Add image_url column
            console.log('➕ Adding image_url column to products table...');
            await connection.execute(
                `ALTER TABLE products ADD COLUMN image_url VARCHAR(500) DEFAULT NULL AFTER selling_price`
            );
            console.log('✅ Column image_url added successfully');
        }

        console.log('✅ Migration completed successfully!');

    } catch (error) {
        console.error('❌ Migration failed:', error.message);
        process.exit(1);
    } finally {
        if (connection) {
            await connection.end();
            console.log('🔌 Database connection closed');
        }
    }
}

migrate();
