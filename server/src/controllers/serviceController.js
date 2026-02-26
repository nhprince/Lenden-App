const db = require('../config/db');
// Note: image_url column is defined in FINAL_SCHEMA.sql

exports.getServices = async (req, res) => {
    try {
        const shop_id = req.shopId;
        const [services] = await db.execute(
            'SELECT * FROM services WHERE shop_id = ? ORDER BY name ASC',
            [shop_id]
        );
        res.json(services);
    } catch (error) {
        console.error(error);
        res.status(500).json({ message: 'Server error' });
    }
};

exports.createService = async (req, res) => {
    try {
        const shop_id = req.shopId;
        const { name, description, service_charge, image_url } = req.body;

        if (!name || service_charge === undefined) {
            return res.status(400).json({ message: 'Name and Service Charge are required' });
        }

        const [result] = await db.execute(
            'INSERT INTO services (shop_id, name, description, service_charge, image_url) VALUES (?, ?, ?, ?, ?)',
            [shop_id, name, description, service_charge, image_url || null]
        );

        res.status(201).json({
            message: 'Service created successfully',
            id: result.insertId,
            name, description, service_charge, image_url
        });
    } catch (error) {
        console.error(error);
        res.status(500).json({ message: 'Server error' });
    }
};

exports.updateService = async (req, res) => {
    try {
        const shop_id = req.shopId;
        const { id } = req.params;
        const { name, description, service_charge, image_url } = req.body;

        await db.execute(
            'UPDATE services SET name = ?, description = ?, service_charge = ?, image_url = ? WHERE id = ? AND shop_id = ?',
            [name, description, service_charge, image_url || null, id, shop_id]
        );

        res.json({ message: 'Service updated successfully' });
    } catch (error) {
        console.error(error);
        res.status(500).json({ message: 'Server error' });
    }
};

exports.deleteService = async (req, res) => {
    try {
        const shop_id = req.shopId;
        const { id } = req.params;

        await db.execute(
            'DELETE FROM services WHERE id = ? AND shop_id = ?',
            [id, shop_id]
        );

        res.json({ message: 'Service deleted successfully' });
    } catch (error) {
        console.error(error);
        res.status(500).json({ message: 'Server error' });
    }
};

exports.getServiceDetails = async (req, res) => {
    try {
        const shop_id = req.shopId;
        const { id } = req.params;

        const [service] = await db.execute(
            'SELECT * FROM services WHERE id = ? AND shop_id = ?',
            [id, shop_id]
        );

        if (service.length === 0) {
            return res.status(404).json({ message: 'Service not found' });
        }

        // Fetch history (transactions where this service was used)
        const [history] = await db.execute(
            `SELECT t.*, ti.quantity, ti.unit_price, ti.subtotal 
             FROM transactions t 
             JOIN transaction_items ti ON t.id = ti.transaction_id 
             WHERE ti.service_id = ? AND t.shop_id = ? 
             ORDER BY t.date DESC LIMIT 50`,
            [id, shop_id]
        );

        res.json({
            ...service[0],
            history
        });
    } catch (error) {
        console.error(error);
        res.status(500).json({ message: 'Server error' });
    }
};
