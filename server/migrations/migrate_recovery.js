const db = require('./src/config/db');
const crypto = require('crypto');

async function migrate() {
    try {
        console.log('--- Starting Password Security Migration ---');

        // 1. Add columns to users table
        console.log('Adding reset_token, reset_expires, and recovery_code columns...');
        try {
            await db.execute('ALTER TABLE users ADD COLUMN reset_token VARCHAR(255) AFTER role');
            await db.execute('ALTER TABLE users ADD COLUMN reset_expires DATETIME AFTER reset_token');
            await db.execute('ALTER TABLE users ADD COLUMN recovery_code VARCHAR(20) AFTER reset_expires');
            console.log('✅ Columns added successfully.');
        } catch (err) {
            if (err.code === 'ER_DUP_COLUMN_NAMES') {
                console.log('ℹ️ Columns already exist, skipping addition.');
            } else {
                throw err;
            }
        }

        // 2. Generate recovery codes for existing users who don't have one
        console.log('Generating recovery codes for existing users...');
        const [users] = await db.execute('SELECT id FROM users WHERE recovery_code IS NULL');

        for (const user of users) {
            const recoveryCode = crypto.randomBytes(4).toString('hex').toUpperCase(); // 8 char hex code
            await db.execute('UPDATE users SET recovery_code = ? WHERE id = ?', [recoveryCode, user.id]);
            console.log(`✅ Generated recovery code for user ID ${user.id}`);
        }

        console.log('--- Migration Completed Successfully ---');
        process.exit(0);
    } catch (error) {
        console.error('❌ Migration failed:', error);
        process.exit(1);
    }
}

migrate();
