const jwt = require('jsonwebtoken');
const db = require('../config/db');

module.exports = async (req, res, next) => {
    const token = req.header('Authorization')?.split(' ')[1];

    if (!token) {
        return res.status(401).json({ message: 'No token, authorization denied' });
    }

    try {
        const decoded = jwt.verify(token, process.env.JWT_SECRET);
        req.user = decoded;

        // Check if Shop-Id header is present
        const shopId = req.header('Shop-Id');

        if (shopId) {
            // RBAC Verification
            if (req.user.role === 'Staff') {
                // For Staff: Check if the shopId in token matches the Shop-Id header
                if (String(req.user.shopId) !== String(shopId)) {
                    return res.status(403).json({ message: 'Access denied: You are not assigned to this shop' });
                }
            } else {
                // For Owners/Admins: Verify shop ownership
                const [shops] = await db.execute('SELECT id FROM shops WHERE id = ? AND owner_id = ?', [shopId, req.user.id]);
                if (shops.length === 0) {
                    return res.status(403).json({ message: 'Access denied: You do not own this shop' });
                }
            }
            req.shopId = shopId;
        }

        next();
    } catch (err) {
        console.error('Auth Middleware Error:', err);
        res.status(401).json({ message: 'Token is not valid' });
    }
};
