const db = require('../config/db');

exports.getSummary = async (req, res) => {
    try {
        const shop_id = req.shopId;
        if (!shop_id) return res.status(400).json({ message: 'Shop ID required' });

        // Default to today if no dates provided
        const today = new Date().toISOString().split('T')[0];
        const start_date = req.query.start_date || today;
        const end_date = req.query.end_date || today;

        // Basic date validation
        if (isNaN(new Date(start_date).getTime()) || isNaN(new Date(end_date).getTime())) {
            return res.status(400).json({ message: 'Invalid date format. Use YYYY-MM-DD' });
        }

        // Base query conditions
        let dateCondition = ' AND DATE(date) BETWEEN ? AND ?';
        const params = [shop_id, start_date, end_date];

        if (process.env.NODE_ENV === 'development') console.log(`📊 Fetching summary for shop ${shop_id} from ${start_date} to ${end_date}`);

        // 1. Total Sales (for date range)
        const [sales] = await db.execute(
            `SELECT SUM(amount) as total, COUNT(*) as count FROM transactions 
             WHERE shop_id = ? AND type = 'sale' ${dateCondition}`,
            params
        );

        // 2. Total Expenses (for date range) - includes regular expenses and vendor payments
        const [expenses] = await db.execute(
            `SELECT SUM(amount) as total FROM transactions 
             WHERE shop_id = ? AND (type = 'expense' OR type = 'payment_made') ${dateCondition}`,
            params
        );

        // 3. Total Due Collected (for date range)
        const [dueCollected] = await db.execute(
            `SELECT SUM(amount) as total FROM transactions 
             WHERE shop_id = ? AND type = 'payment_received' ${dateCondition}`,
            params
        );

        // 3.5 Total Purchases (Vendor Expenses)
        const [purchases] = await db.execute(
            `SELECT SUM(amount) as total FROM transactions 
             WHERE shop_id = ? AND type = 'purchase' ${dateCondition}`,
            params
        );

        // 4. Gross Profit (Sales Price - Cost Price) for items sold in date range
        const [profitData] = await db.execute(
            `SELECT SUM((ti.unit_price - COALESCE(ti.cost_price, 0)) * ti.quantity) as gross_profit
             FROM transaction_items ti
             JOIN transactions t ON ti.transaction_id = t.id
             WHERE t.shop_id = ? AND t.type = 'sale' ${dateCondition}`,
            params
        );

        // 5. Inventory Stats (Global snapshot, not date filtered)
        const [inventory] = await db.execute(
            `SELECT COUNT(*) as count, 
                    SUM(COALESCE(cost_price, 0) * stock_quantity) as value 
             FROM products 
             WHERE shop_id = ?`,
            [shop_id]
        );

        // 6. Customer Stats (Global snapshot)
        const [customers] = await db.execute(
            `SELECT COUNT(*) as count, 
                    SUM(COALESCE(total_due, 0)) as total_due 
             FROM customers 
             WHERE shop_id = ?`,
            [shop_id]
        );

        // 6.5 Pending Transaction Amounts (actual pending payments from transactions)
        const [pendingPayments] = await db.execute(
            `SELECT SUM(amount - paid_amount) as pending_amount
             FROM transactions
             WHERE shop_id = ? AND status = 'Pending' AND (amount - paid_amount) > 0`,
            [shop_id]
        );

        // 7. Active Trips (if table exists, handled by try-catch usually but here we assume structure)
        // We'll use a safe query or separate try/catch if strictly needed, but here we assume schema exists.
        const [trips] = await db.execute(
            `SELECT COUNT(*) as count FROM trips WHERE shop_id = ? AND status = 'ongoing'`,
            [shop_id]
        );

        // 8. Vendor Stats
        const [vendors] = await db.execute(
            `SELECT COUNT(*) as count FROM vendors WHERE shop_id = ?`,
            [shop_id]
        );

        const result = {
            total_sales: parseFloat(sales[0].total) || 0,
            sales_count: parseInt(sales[0].count) || 0,
            total_expenses: parseFloat(expenses[0].total) || 0,
            total_purchases: parseFloat(purchases[0].total) || 0,
            due_collected: parseFloat(dueCollected[0].total) || 0,
            gross_profit: parseFloat(profitData[0].gross_profit) || 0,
            net_profit: (parseFloat(profitData[0].gross_profit) || 0) - (parseFloat(expenses[0].total) || 0) - (parseFloat(purchases[0].total) || 0),
            product_count: parseInt(inventory[0].count) || 0,
            inventory_value: parseFloat(inventory[0].value) || 0,
            customer_count: parseInt(customers[0].count) || 0,
            total_due: parseFloat(customers[0].total_due) || 0,
            pending_amount: parseFloat(pendingPayments[0].pending_amount) || 0,
            active_trips: parseInt(trips[0].count) || 0,
            vendor_count: parseInt(vendors[0].count) || 0
        };

        // Filter out profit data for staff members
        const userRole = req.user?.role?.toLowerCase();
        if (userRole === 'staff') {
            delete result.gross_profit;
            delete result.net_profit;
        }

        if (process.env.NODE_ENV === 'development') console.log('✅ Summary calculated successfully');
        res.json(result);

    } catch (error) {
        console.error('❌ Summary error details:', {
            message: error.message,
            code: error.code,
            errno: error.errno,
            sql: error.sql,
            sqlState: error.sqlState
        });
        res.status(500).json({ message: 'Server error', error: error.message });
    }
};

exports.getSalesTrend = async (req, res) => {
    try {
        const shop_id = req.shopId;
        const days = parseInt(req.query.days) || 7;

        const [trend] = await db.execute(
            `SELECT DATE(date) as date, SUM(amount) as sales 
            FROM transactions 
            WHERE shop_id = ? AND type = 'sale' 
            AND date >= DATE_SUB(CURDATE(), INTERVAL ? DAY)
            GROUP BY DATE(date)
            ORDER BY date ASC`,
            [shop_id, days]
        );

        res.json(trend);
    } catch (error) {
        console.error(error);
        res.status(500).json({ message: 'Server error' });
    }
};

exports.getCategoryDistribution = async (req, res) => {
    try {
        const shop_id = req.shopId;

        const [distribution] = await db.execute(
            `SELECT category as name, COUNT(*) as value 
            FROM products 
            WHERE shop_id = ? 
            GROUP BY category`,
            [shop_id]
        );

        res.json(distribution);
    } catch (error) {
        console.error(error);
        res.status(500).json({ message: 'Server error' });
    }
};
