const db = require('../config/db');

exports.getCustomers = async (req, res) => {
    try {
        const shop_id = req.shopId;
        if (!shop_id) return res.status(400).json({ message: 'Shop ID required' });

        const [customers] = await db.execute('SELECT * FROM customers WHERE shop_id = ? ORDER BY name ASC', [shop_id]);
        res.json(customers);
    } catch (error) {
        console.error(error);
        res.status(500).json({ message: 'Server error' });
    }
};

exports.createCustomer = async (req, res) => {
    try {
        const shop_id = req.shopId;
        if (!shop_id) return res.status(400).json({ message: 'Shop ID required' });

        const { name, phone, address } = req.body;

        const [result] = await db.execute(
            'INSERT INTO customers (shop_id, name, phone, address) VALUES (?, ?, ?, ?)',
            [shop_id, name, phone, address]
        );

        res.status(201).json({ message: 'Customer added', customerId: result.insertId });
    } catch (error) {
        console.error(error);
        res.status(500).json({ message: 'Server error' });
    }
};

exports.getCustomerDetails = async (req, res) => {
    try {
        const shop_id = req.shopId;
        if (!shop_id) return res.status(400).json({ message: 'Shop ID required' });

        const { id } = req.params;
        const [customer] = await db.execute('SELECT * FROM customers WHERE id = ? AND shop_id = ?', [id, shop_id]);

        if (customer.length === 0) return res.status(404).json({ message: 'Customer not found' });

        // Get transaction history
        const [transactions] = await db.execute(
            'SELECT * FROM transactions WHERE customer_id = ? AND shop_id = ? ORDER BY date DESC',
            [id, shop_id]
        );

        res.json({ ...customer[0], history: transactions });
    } catch (error) {
        console.error(error);
        res.status(500).json({ message: 'Server error' });
    }
};

exports.updateCustomer = async (req, res) => {
    try {
        const shop_id = req.shopId;
        const { id } = req.params;
        const { name, phone, address, email } = req.body;

        await db.execute(
            'UPDATE customers SET name = ?, phone = ?, address = ?, email = ? WHERE id = ? AND shop_id = ?',
            [name, phone, address, email, id, shop_id]
        );

        res.json({ message: 'Customer updated successfully' });
    } catch (error) {
        console.error(error);
        res.status(500).json({ message: 'Server error' });
    }
};

exports.deleteCustomer = async (req, res) => {
    try {
        const shop_id = req.shopId;
        const { id } = req.params;

        // Note: Ideally check for transactions before deleting or use soft delete
        await db.execute('DELETE FROM customers WHERE id = ? AND shop_id = ?', [id, shop_id]);

        res.json({ message: 'Customer deleted successfully' });
    } catch (error) {
        console.error(error);
        res.status(500).json({ message: 'Server error' });
    }
};
