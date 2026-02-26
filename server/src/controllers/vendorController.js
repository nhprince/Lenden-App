const db = require('../config/db');

exports.getVendors = async (req, res) => {
    try {
        const shop_id = req.shopId;
        if (!shop_id) return res.status(400).json({ message: 'Shop ID required' });

        const [vendors] = await db.execute('SELECT * FROM vendors WHERE shop_id = ? ORDER BY name ASC', [shop_id]);
        res.json(vendors);
    } catch (error) {
        console.error(error);
        res.status(500).json({ message: 'Server error' });
    }
};

exports.createVendor = async (req, res) => {
    try {
        const shop_id = req.shopId;
        if (!shop_id) return res.status(400).json({ message: 'Shop ID required' });

        const { name, company_name, phone } = req.body;

        if (!name || name.trim() === '') {
            return res.status(400).json({ message: 'Vendor name is required' });
        }

        // Sanitize helper
        const sanitize = (str) => str ? str.toString().trim().replace(/[<>]/g, '') : null;

        const [result] = await db.execute(
            'INSERT INTO vendors (shop_id, name, company_name, phone) VALUES (?, ?, ?, ?)',
            [shop_id, sanitize(name), sanitize(company_name), sanitize(phone)]
        );

        res.status(201).json({ message: 'Vendor added', vendorId: result.insertId });
    } catch (error) {
        console.error(error);
        res.status(500).json({ message: 'Server error' });
    }
};

exports.getVendorDetails = async (req, res) => {
    try {
        const shop_id = req.shopId;
        if (!shop_id) return res.status(400).json({ message: 'Shop ID required' });

        const { id } = req.params;
        const [vendor] = await db.execute('SELECT * FROM vendors WHERE id = ? AND shop_id = ?', [id, shop_id]);

        if (vendor.length === 0) return res.status(404).json({ message: 'Vendor not found' });

        // Get transaction history (purchases, payments)
        const [transactions] = await db.execute(
            'SELECT * FROM transactions WHERE vendor_id = ? AND shop_id = ? ORDER BY date DESC',
            [id, shop_id]
        );

        res.json({ ...vendor[0], history: transactions });
    } catch (error) {
        console.error(error);
        res.status(500).json({ message: 'Server error' });
    }
};

exports.updateVendor = async (req, res) => {
    try {
        const shop_id = req.shopId;
        const { id } = req.params;
        const { name, company_name, phone } = req.body;

        // Sanitize helper
        const sanitize = (str) => str ? str.toString().trim().replace(/[<>]/g, '') : null;

        const [result] = await db.execute(
            'UPDATE vendors SET name = ?, company_name = ?, phone = ? WHERE id = ? AND shop_id = ?',
            [sanitize(name), sanitize(company_name), sanitize(phone), id, shop_id]
        );

        if (result.affectedRows === 0) return res.status(404).json({ message: 'Vendor not found' });

        res.json({ message: 'Vendor updated successfully' });
    } catch (error) {
        console.error(error);
        res.status(500).json({ message: 'Server error' });
    }
};

exports.deleteVendor = async (req, res) => {
    try {
        const shop_id = req.shopId;
        const { id } = req.params;

        const [result] = await db.execute('DELETE FROM vendors WHERE id = ? AND shop_id = ?', [id, shop_id]);

        if (result.affectedRows === 0) return res.status(404).json({ message: 'Vendor not found' });

        res.json({ message: 'Vendor deleted successfully' });
    } catch (error) {
        console.error(error);
        res.status(500).json({ message: 'Server error' });
    }
};
