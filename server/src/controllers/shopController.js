const db = require('../config/db');

exports.createShop = async (req, res) => {
    try {
        const { name, business_type, address, phone } = req.body;
        const owner_id = req.user.id;

        const [result] = await db.execute(
            'INSERT INTO shops (owner_id, name, business_type, address, phone) VALUES (?, ?, ?, ?, ?)',
            [owner_id, name, business_type, address, phone]
        );

        res.status(201).json({ message: 'Shop created successfully', shopId: result.insertId });
    } catch (error) {
        console.error(error);
        res.status(500).json({ message: 'Server error' });
    }
};

exports.getShops = async (req, res) => {
    try {
        const owner_id = req.user.id;
        const [shops] = await db.execute('SELECT * FROM shops WHERE owner_id = ?', [owner_id]);
        res.json(shops);
    } catch (error) {
        console.error(error);
        res.status(500).json({ message: 'Server error' });
    }
};

exports.getShopById = async (req, res) => {
    try {
        const { id } = req.params;
        const user_id = req.user.id;
        const user_role = req.user.role;

        if (process.env.NODE_ENV === 'development') console.log(`[getShopById] User: ${user_id}, Role: ${user_role}, Target Shop: ${id}`);

        let query = 'SELECT * FROM shops WHERE id = ?';
        let params = [id];

        // For owners, verify ownership
        if (user_role?.toLowerCase() === 'owner') {
            query += ' AND owner_id = ?';
            params.push(user_id);
        }
        // For staff, verify shop assignment through staff table
        else if (user_role?.toLowerCase() === 'staff') {
            const [staff] = await db.execute(
                'SELECT shop_id FROM staff WHERE user_id = ? AND shop_id = ?',
                [user_id, id]
            );
            if (process.env.NODE_ENV === 'development') console.log(`[getShopById] Staff Check Result:`, staff);
            if (staff.length === 0) {
                console.warn(`[getShopById] Access denied for staff member ${user_id} to shop ${id}`);
                return res.status(403).json({ message: 'Access denied to this shop' });
            }
        }

        const [shop] = await db.execute(query, params);
        if (process.env.NODE_ENV === 'development') console.log(`[getShopById] DB Result Count:`, shop.length);

        if (shop.length === 0) {
            console.warn(`[getShopById] Shop ${id} not found for user ${user_id}`);
            return res.status(404).json({ message: 'Shop not found' });
        }

        res.json(shop[0]);
    } catch (error) {
        console.error(error);
        res.status(500).json({ message: 'Server error' });
    }
};

exports.updateShopDetails = async (req, res) => {
    try {
        const owner_id = req.user.id;
        const { id } = req.params;
        const { name, business_type, address, phone, email, website, logoUrl, logo_url, header_title, footer_note, terms, show_logo } = req.body;
        const logoPath = logo_url || logoUrl;

        await db.execute(
            `UPDATE shops SET 
                name = ?, address = ?, phone = ?, email = ?, website = ?, 
                logo_url = ?, header_title = ?, footer_note = ?, terms = ?, show_logo = ? 
            WHERE id = ? AND owner_id = ?`,
            [
                name || '',
                address || null,
                phone || null,
                email || null,
                website || null,
                logoPath || null,
                header_title || null,
                footer_note || null,
                terms || null,
                show_logo !== undefined ? show_logo : true,
                id,
                owner_id
            ]
        );

        res.json({ message: 'Shop details updated successfully' });
    } catch (error) {
        console.error(error);
        res.status(500).json({ message: 'Server error' });
    }
};
