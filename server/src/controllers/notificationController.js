const db = require('../config/db');
const notificationService = require('../services/notificationService');

// Get all notifications for current shop
exports.getNotifications = async (req, res) => {
    try {
        const shop_id = req.shopId;
        const user_id = req.user.id;
        const limit = parseInt(req.query.limit) || 50;

        const notifications = await notificationService.getNotifications(shop_id, user_id, limit);
        const unread_count = await notificationService.getUnreadCount(shop_id, user_id);

        res.json({
            notifications,
            unread_count
        });
    } catch (error) {
        console.error('Failed to fetch notifications:', error);
        // Return empty array instead of error to prevent UI breaking
        res.json({
            notifications: [],
            unread_count: 0
        });
    }
};

// Mark notification as read
exports.markAsRead = async (req, res) => {
    try {
        const { id } = req.params;
        const shop_id = req.shopId;

        const success = await notificationService.markAsRead(id, shop_id);

        if (success) {
            res.json({ message: 'Notification marked as read' });
        } else {
            res.status(404).json({ message: 'Notification not found' });
        }
    } catch (error) {
        console.error(error);
        res.status(500).json({ message: 'Server error' });
    }
};

// Mark all as read
exports.markAllAsRead = async (req, res) => {
    try {
        const shop_id = req.shopId;
        const user_id = req.user.id;

        await notificationService.markAllAsRead(shop_id, user_id);
        res.json({ message: 'All notifications marked as read' });
    } catch (error) {
        console.error(error);
        res.status(500).json({ message: 'Server error' });
    }
};

// Delete notification
exports.deleteNotification = async (req, res) => {
    try {
        const { id } = req.params;
        const shop_id = req.shopId;

        await db.execute(
            'DELETE FROM notifications WHERE id = ? AND shop_id = ?',
            [id, shop_id]
        );

        res.json({ message: 'Notification deleted' });
    } catch (error) {
        console.error(error);
        res.status(500).json({ message: 'Server error' });
    }
};
