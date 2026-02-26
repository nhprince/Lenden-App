const db = require('../config/db');

exports.exportShopData = async (req, res) => {
    try {
        const shop_id = req.shopId;
        if (!shop_id) return res.status(400).json({ message: 'Shop ID required' });

        const data = {};

        // Fetch all related tables
        const [products] = await db.execute('SELECT * FROM products WHERE shop_id = ?', [shop_id]);
        const [customers] = await db.execute('SELECT * FROM customers WHERE shop_id = ?', [shop_id]);
        const [vendors] = await db.execute('SELECT * FROM vendors WHERE shop_id = ?', [shop_id]);
        const [services] = await db.execute('SELECT * FROM services WHERE shop_id = ?', [shop_id]);
        const [transactions] = await db.execute('SELECT * FROM transactions WHERE shop_id = ?', [shop_id]);

        // Fetch transaction items for all fetched transactions
        const transactionIds = transactions.map(t => t.id);
        let transactionItems = [];
        if (transactionIds.length > 0) {
            const placeholders = transactionIds.map(() => '?').join(',');
            const [items] = await db.execute(
                `SELECT * FROM transaction_items WHERE transaction_id IN (${placeholders})`,
                transactionIds
            );
            transactionItems = items;
        }

        data.shop_id = shop_id;
        data.export_date = new Date().toISOString();
        data.products = products;
        data.customers = customers;
        data.vendors = vendors;
        data.services = services;
        data.transactions = transactions;
        data.transaction_items = transactionItems;

        res.setHeader('Content-disposition', `attachment; filename=lenden_backup_${shop_id}_${new Date().getTime()}.json`);
        res.setHeader('Content-type', 'application/json');
        res.write(JSON.stringify(data, null, 2));
        res.end();

    } catch (error) {
        console.error('Backup Export Failed:', error);
        res.status(500).json({ message: 'Backup failed', error: error.message });
    }
};

exports.importShopData = async (req, res) => {
    const connection = await db.getConnection();
    try {
        const shop_id = req.shopId;
        const { backupData } = req.body;

        if (!backupData || backupData.shop_id != shop_id) {
            return res.status(400).json({ message: 'Invalid backup file or shop mismatch' });
        }

        await connection.beginTransaction();

        const tables = ['products', 'customers', 'vendors', 'services', 'transactions', 'transaction_items'];
        const results = {};

        // Helper to insert data
        const insertData = async (tableName, items) => {
            if (!items || items.length === 0) return 0;
            let count = 0;

            // Get columns from the first item
            // Filter out keys that might not exist in schema or are not needed
            // This is a simplified approach. In prod, we'd use a strict schema definition.

            for (const item of items) {
                // Ensure shop_id is correct for the table if it has it
                if (item.shop_id && item.shop_id != shop_id) {
                    continue; // Skip items from other shops if any mixed in
                }

                const keys = Object.keys(item);
                const values = Object.values(item);

                // Construct query: INSERT IGNORE INTO table (col1, col2) VALUES (?, ?)
                const placeholders = values.map(() => '?').join(',');
                const columns = keys.map(k => `\`${k}\``).join(',');

                try {
                    await connection.execute(
                        `INSERT IGNORE INTO ${tableName} (${columns}) VALUES (${placeholders})`,
                        values
                    );
                    count++;
                } catch (err) {
                    console.warn(`Failed to insert into ${tableName}:`, err.message);
                }
            }
            return count;
        };

        // Import in order of dependency
        // Master data first
        results.products = await insertData('products', backupData.products);
        results.customers = await insertData('customers', backupData.customers);
        results.vendors = await insertData('vendors', backupData.vendors);
        results.services = await insertData('services', backupData.services);

        // Transactions and items
        results.transactions = await insertData('transactions', backupData.transactions);
        results.transaction_items = await insertData('transaction_items', backupData.transaction_items);

        await connection.commit();

        res.status(200).json({
            message: 'Backup imported successfully',
            results
        });

    } catch (error) {
        await connection.rollback();
        console.error('Backup Import Failed:', error);
        res.status(500).json({ message: 'Import failed', error: error.message });
    } finally {
        connection.release();
    }
};
