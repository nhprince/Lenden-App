const db = require('../config/db');
const bcrypt = require('bcryptjs');

exports.getStaff = async (req, res) => {
    try {
        const shopId = req.header('Shop-Id');
        if (!shopId) return res.status(400).json({ message: 'Shop ID required' });

        const [staff] = await db.execute(
            'SELECT id, shop_id, name, username, email, phone, role, salary, joining_date, status, created_at FROM staff WHERE shop_id = ? ORDER BY created_at DESC',
            [shopId]
        );
        res.json(staff);
    } catch (error) {
        console.error(error);
        res.status(500).json({ message: 'Server error' });
    }
};

exports.createStaff = async (req, res) => {
    try {
        const shopId = req.header('Shop-Id');
        const { name, username, email, password, phone, role, salary, joining_date } = req.body;

        if (!shopId) return res.status(400).json({ message: 'Shop ID required' });
        if (!name) return res.status(400).json({ message: 'Staff name is required' });

        let hashedPassword = null;
        if (password) {
            const salt = await bcrypt.genSalt(10);
            hashedPassword = await bcrypt.hash(password, salt);
        }

        const [result] = await db.execute(
            'INSERT INTO staff (shop_id, name, username, email, password, phone, role, salary, joining_date) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)',
            [shopId, name, username || null, email || null, hashedPassword, phone || null, role || 'Staff', salary || 0, joining_date || null]
        );

        res.status(201).json({ message: 'Staff added successfully', id: result.insertId });
    } catch (error) {
        console.error(error);
        res.status(500).json({ message: 'Server error' });
    }
};

exports.updateStaff = async (req, res) => {
    try {
        const { id } = req.params;
        const shopId = req.header('Shop-Id');
        if (!shopId) return res.status(400).json({ message: 'Shop ID required' });

        const { name, username, email, password, phone, role, salary, joining_date, status } = req.body;

        let query = 'UPDATE staff SET name=?, username=?, email=?, phone=?, role=?, salary=?, joining_date=?, status=?';
        let params = [name, username, email, phone, role, salary, joining_date, status];

        if (password && password.trim() !== '') {
            const salt = await bcrypt.genSalt(10);
            const hashedPassword = await bcrypt.hash(password, salt);
            query += ', password=?';
            params.push(hashedPassword);
        }

        query += ' WHERE id=? AND shop_id=?';
        params.push(id, shopId);

        await db.execute(query, params);

        res.json({ message: 'Staff updated successfully' });
    } catch (error) {
        console.error(error);
        res.status(500).json({ message: 'Server error' });
    }
};

exports.deleteStaff = async (req, res) => {
    try {
        const { id } = req.params;
        const shopId = req.header('Shop-Id');
        if (!shopId) return res.status(400).json({ message: 'Shop ID required' });

        await db.execute('DELETE FROM staff WHERE id = ? AND shop_id = ?', [id, shopId]);
        res.json({ message: 'Staff deleted successfully' });
    } catch (error) {
        console.error(error);
        res.status(500).json({ message: 'Server error' });
    }
};
