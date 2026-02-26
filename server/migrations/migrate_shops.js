const db = require('./src/config/db');

async function migrate() {
    try {
        console.log("Adding columns to shops table...");
        const columns = [
            { name: 'email', type: 'VARCHAR(255)' },
            { name: 'website', type: 'VARCHAR(255)' },
            { name: 'logo_url', type: 'TEXT' },
            { name: 'header_title', type: 'VARCHAR(255)' },
            { name: 'footer_note', type: 'TEXT' },
            { name: 'terms', type: 'TEXT' },
            { name: 'show_logo', type: 'BOOLEAN DEFAULT TRUE' }
        ];

        for (const col of columns) {
            try {
                const [existing] = await db.execute(`SHOW COLUMNS FROM shops LIKE '${col.name}'`);
                if (existing.length === 0) {
                    console.log(`Adding column ${col.name}...`);
                    await db.execute(`ALTER TABLE shops ADD COLUMN ${col.name} ${col.type}`);
                }
            } catch (e) {
                console.error(`Error adding column ${col.name}:`, e.message);
            }
        }

        console.log("Migration completed.");
    } catch (error) {
        console.error("Migration failed:", error);
    } finally {
        process.exit();
    }
}

migrate();
