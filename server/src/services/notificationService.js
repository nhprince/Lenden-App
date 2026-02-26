const db = require('../config/db');

/**
 * Notification Service
 * Handles creation, retrieval, and management of in-app notifications
 */

/**
 * Create a new notification
 * @param {Object} notificationData - Notification details
 * @returns {Promise<number>} - Notification ID
 */
async function createNotification({ shop_id, user_id = null, type, title, message, link = null, action_url = null, data = null, icon = 'notifications', scheduled_for = null }) {
    try {
        // Handle alias
        const finalLink = link || action_url;

        const [result] = await db.execute(
            `INSERT INTO notifications (shop_id, user_id, type, title, message, action_url, data, icon, scheduled_for) 
             VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)`,
            [shop_id, user_id, type, title, message, finalLink, JSON.stringify(data), icon, scheduled_for]
        );
        return result.insertId;
    } catch (error) {
        console.error('Failed to create notification:', error);
        // Don't throw, just log. Notifications shouldn't break main flow.
        return null;
    }
}

/**
 * Get notifications for a user
 */
async function getNotifications(shop_id, user_id = null, limit = 50) {
    try {
        let query = `
            SELECT * FROM notifications 
            WHERE shop_id = ? AND (user_id = ? OR user_id IS NULL)
            ORDER BY created_at DESC 
            LIMIT ?
        `;

        const [notifications] = await db.execute(query, [shop_id, user_id, limit]);
        return notifications;
    } catch (error) {
        console.error('Failed to get notifications:', error);
        throw error;
    }
}

/**
 * Get unread notification count
 */
async function getUnreadCount(shop_id, user_id = null) {
    try {
        const [result] = await db.execute(
            `SELECT COUNT(*) as count FROM notifications 
             WHERE shop_id = ? AND (user_id = ? OR user_id IS NULL) AND is_read = FALSE`,
            [shop_id, user_id]
        );
        return result[0].count;
    } catch (error) {
        console.error('Failed to get unread count:', error);
        return 0;
    }
}

/**
 * Mark notification as read
 */
async function markAsRead(notification_id, shop_id) {
    try {
        const [result] = await db.execute(
            `UPDATE notifications SET is_read = TRUE 
             WHERE id = ? AND shop_id = ?`,
            [notification_id, shop_id]
        );
        return result.affectedRows > 0;
    } catch (error) {
        console.error('Failed to mark notification as read:', error);
        return false;
    }
}

/**
 * Mark all notifications as read for a user
 */
async function markAllAsRead(shop_id, user_id = null) {
    try {
        const [result] = await db.execute(
            `UPDATE notifications SET is_read = TRUE 
             WHERE shop_id = ? AND (user_id = ? OR user_id IS NULL)`,
            [shop_id, user_id]
        );
        return result.affectedRows > 0;
    } catch (error) {
        console.error('Failed to mark all as read:', error);
        return false;
    }
}

/**
 * Delete notification
 */
async function deleteNotification(id, shop_id) {
    try {
        await db.execute('DELETE FROM notifications WHERE id = ? AND shop_id = ?', [id, shop_id]);
        return true;
    } catch (error) {
        console.error('Failed to delete notification:', error);
        return false;
    }
}

/**
 * Delete old read notifications (cleanup)
 */
async function deleteOldNotifications(days = 30) {
    try {
        const [result] = await db.execute(
            `DELETE FROM notifications 
             WHERE is_read = TRUE AND created_at < DATE_SUB(NOW(), INTERVAL ? DAY)`,
            [days]
        );
        return result.affectedRows;
    } catch (error) {
        console.error('Failed to delete old notifications:', error);
        return 0;
    }
}

// ==========================================
// Specialized Notification Functions
// ==========================================

/**
 * Create low stock notification
 */
async function createLowStockNotification({ shop_id, product_name, current_stock, min_stock, message, product_count, product_id }) {
    let title = 'Low Stock Alert';
    let msg = message;
    let data = null;

    if (!msg) {
        if (product_name) {
            title = `Low Stock Alert: ${product_name}`;
            msg = `${product_name} is running low. Current: ${current_stock}, Minimum: ${min_stock}`;
            data = { product_id, product_name };
        } else {
            msg = `You have ${product_count} products running low on stock.`;
        }
    }

    return createNotification({
        shop_id,
        user_id: null,
        type: 'low_stock',
        title: title,
        message: msg,
        link: '/products?low_stock=true',
        icon: 'inventory_2',
        data
    });
}

/**
 * Create overdue payment notification
 */
async function createOverdueNotification({ shop_id, transaction_id, customer_name, amount, due_date }) {
    const daysOverdue = Math.floor((new Date() - new Date(due_date)) / (1000 * 60 * 60 * 24));

    return createNotification({
        shop_id,
        user_id: null,
        type: 'overdue_payment',
        title: 'Overdue Payment Alert',
        message: `Payment from ${customer_name} is ${daysOverdue} day(s) overdue. Amount: ৳${amount.toLocaleString()}`,
        link: `/transactions?id=${transaction_id}`,
        icon: 'warning',
        data: {
            transaction_id,
            customer_name,
            amount,
            days_overdue: daysOverdue
        }
    });
}

/**
 * Create payment received notification
 */
async function createPaymentReceivedNotification({ shop_id, customer_name, amount }) {
    return createNotification({
        shop_id,
        user_id: null,
        type: 'payment_received',
        title: 'Payment Received',
        message: `Received ৳${amount.toLocaleString()} from ${customer_name}`,
        link: '/transactions',
        icon: 'payments'
    });
}

/**
 * Create new sale notification
 */
async function createNewSaleNotification({ shop_id, transaction }) {
    return createNotification({
        shop_id,
        user_id: null,
        type: 'transaction',
        title: 'New Sale Completed',
        message: `Sale of ৳${transaction.amount.toLocaleString()} completed successfully.`,
        link: `/transactions`,
        icon: 'shopping_cart',
        data: { transaction_id: transaction.id }
    });
}

/**
 * Create daily report notification
 */
async function createDailyReportNotification({ shop_id, reportData }) {
    return createNotification({
        shop_id,
        user_id: null,
        type: 'daily_report',
        title: 'Daily Report Available',
        message: `Today's sales: ৳${reportData.total_sales.toLocaleString()}. Net profit: ৳${reportData.net_profit.toLocaleString()}.`,
        link: '/reports',
        icon: 'assessment',
        data: reportData
    });
}

/**
 * Create password reset notification
 */
async function createPasswordResetNotification({ user_id, shop_id }) {
    return createNotification({
        shop_id,
        user_id,
        type: 'password_reset',
        title: 'Password Reset Successful',
        message: 'Your password has been reset successfully. If this wasn\'t you, please contact support immediately.',
        link: '/settings',
        icon: 'lock_reset'
    });
}

/**
 * Create onboarding notifications
 */
async function createOnboardingNotifications(shop_id) {
    const onboardingSteps = [
        { day: 0, title: '👋 Welcome to Lenden!', message: "Let's get your shop set up. Start by completing your shop profile.", link: '/settings', icon: 'waving_hand' },
        { day: 0, title: '📦 Add Your First Product', message: 'Build your inventory by adding products.', link: '/products', icon: 'inventory_2' },
        { day: 1, title: '💰 Ready to Make a Sale?', message: 'Open the POS to create your first transaction.', link: '/pos', icon: 'point_of_sale' },
        { day: 2, title: '👥 Add Staff Members', message: 'Growing your team? Add staff members.', link: '/staff', icon: 'group_add' },
        { day: 6, title: '📊 Explore Your Reports', message: 'View comprehensive business analytics.', link: '/reports', icon: 'assessment' }
    ];

    for (const step of onboardingSteps) {
        const scheduledDate = new Date();
        scheduledDate.setDate(scheduledDate.getDate() + step.day);

        await createNotification({
            shop_id,
            user_id: null,
            type: 'system',
            title: step.title,
            message: step.message,
            link: step.link,
            icon: step.icon,
            scheduled_for: scheduledDate
        });
    }
}

module.exports = {
    createNotification,
    getNotifications,
    getUnreadCount,
    markAsRead,
    markAllAsRead,
    deleteNotification,
    deleteOldNotifications,
    createLowStockNotification,
    createOverdueNotification,
    createPaymentReceivedNotification,
    createNewSaleNotification,
    createDailyReportNotification,
    createPasswordResetNotification,
    createOnboardingNotifications
};
