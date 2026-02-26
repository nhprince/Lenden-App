const db = require('../config/db');

/**
 * Create a notification
 */
exports.createNotification = async ({ shop_id, user_id = null, type, title, message, action_url = null, data = null, scheduled_for = null, icon = 'notifications' }) => {
    try {
        await db.execute(
            `INSERT INTO notifications (shop_id, user_id, type, title, message, action_url, data, scheduled_for, icon)
             VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)`,
            [shop_id, user_id, type, title, message, action_url, JSON.stringify(data), scheduled_for, icon]
        );
        console.log(`✅ Notification created: ${title}`);
    } catch (error) {
        console.error('Failed to create notification:', error);
    }
};

/**
 * Generate low stock notification
 */
exports.notifyLowStock = async (shop_id, product) => {
    await exports.createNotification({
        shop_id,
        type: 'low_stock',
        title: 'Low Stock Alert',
        message: `${product.name} is running low (${product.stock_quantity} units left). Reorder now to avoid stockouts.`,
        action_url: '/products',
        icon: 'inventory_2',
        data: { product_id: product.id, product_name: product.name }
    });
};

/**
 * Generate overdue payment notification
 */
exports.notifyOverduePayment = async (shop_id, transaction) => {
    const daysOverdue = transaction.days_overdue || 0;
    await exports.createNotification({
        shop_id,
        type: 'overdue_payment',
        title: 'Overdue Payment Alert',
        message: `Payment from ${transaction.customer_name} is ${daysOverdue} day(s) overdue. Amount: ৳${transaction.due_amount.toLocaleString()}`,
        action_url: '/transactions',
        icon: 'warning',
        data: {
            transaction_id: transaction.id,
            customer_name: transaction.customer_name,
            amount: transaction.due_amount,
            days_overdue: daysOverdue
        }
    });
};

/**
 * Generate payment due notification
 */
exports.notifyPaymentDue = async (shop_id, customer) => {
    await exports.createNotification({
        shop_id,
        type: 'overdue_payment',
        title: 'Payment Reminder',
        message: `${customer.name} has ৳${customer.total_due.toLocaleString()} due payment. Follow up today.`,
        action_url: '/customers',
        icon: 'payments',
        data: { customer_id: customer.id, amount: customer.total_due }
    });
};

/**
 * Generate daily report notification
 */
exports.notifyDailyReport = async (shop_id, reportData) => {
    await exports.createNotification({
        shop_id,
        type: 'daily_report',
        title: 'Daily Report Available',
        message: `Today's sales: ৳${reportData.total_sales.toLocaleString()}. Net profit: ৳${reportData.net_profit.toLocaleString()}. View full report.`,
        action_url: '/reports',
        icon: 'assessment',
        data: reportData
    });
};

/**
 * Generate password reset notification
 */
exports.notifyPasswordReset = async (user_id, shop_id) => {
    await exports.createNotification({
        shop_id,
        user_id,
        type: 'password_reset',
        title: 'Password Reset Successful',
        message: 'Your password has been reset successfully. If this wasn\'t you, please contact support immediately.',
        action_url: '/settings',
        icon: 'lock_reset'
    });
};

/**
 * Generate account activity notification
 */
exports.notifyAccountActivity = async (shop_id, user_id, activity) => {
    await exports.createNotification({
        shop_id,
        user_id,
        type: 'account_activity',
        title: 'Account Activity',
        message: activity,
        action_url: '/settings',
        icon: 'account_circle'
    });
};

/**
 * Generate new sale notification
 */
exports.notifyNewSale = async (shop_id, transaction) => {
    await exports.createNotification({
        shop_id,
        type: 'transaction',
        title: 'New Sale Completed',
        message: `Sale of ৳${transaction.amount.toLocaleString()} completed successfully.`,
        action_url: `/transactions`,
        icon: 'shopping_cart',
        data: { transaction_id: transaction.id }
    });
};

/**
 * Generate staff action notification
 */
exports.notifyStaffAction = async (shop_id, staff_name, action) => {
    await exports.createNotification({
        shop_id,
        type: 'system',
        title: 'Staff Activity',
        message: `${staff_name} ${action}`,
        action_url: '/staff',
        icon: 'group'
    });
};

/**
 * Create onboarding notifications for new users
 */
exports.createOnboardingNotifications = async (shop_id) => {
    const onboardingSteps = [
        {
            day: 0,
            title: '👋 Welcome to Lenden!',
            message: "Let's get your shop set up. Start by completing your shop profile and customizing invoice settings.",
            action_url: '/settings',
            icon: 'waving_hand'
        },
        {
            day: 0,
            title: '📦 Add Your First Product',
            message: 'Build your inventory by adding products. Include details like SKU, pricing, and stock levels.',
            action_url: '/products',
            icon: 'inventory_2'
        },
        {
            day: 1,
            title: '💰 Ready to Make a Sale?',
            message: 'Open the Point of Sale (POS) to create your first transaction. It\'s fast and easy!',
            action_url: '/pos',
            icon: 'point_of_sale'
        },
        {
            day: 2,
            title: '👥 Add Staff Members',
            message: 'Growing your team? Add staff members and assign roles to manage permissions.',
            action_url: '/staff',
            icon: 'group_add'
        },
        {
            day: 4,
            title: '⚙️ Customize Your Settings',
            message: 'Personalize your invoice templates, shop details, and system preferences.',
            action_url: '/settings',
            icon: 'settings'
        },
        {
            day: 6,
            title: '📊 Explore Your Reports',
            message: 'View comprehensive business analytics, sales trends, and inventory insights.',
            action_url: '/reports',
            icon: 'assessment'
        }
    ];

    for (const step of onboardingSteps) {
        const scheduledDate = new Date();
        scheduledDate.setDate(scheduledDate.getDate() + step.day);

        await exports.createNotification({
            shop_id,
            type: 'system',
            title: step.title,
            message: step.message,
            action_url: step.action_url,
            icon: step.icon,
            scheduled_for: scheduledDate
        });
    }

    console.log(`✅ Created ${onboardingSteps.length} onboarding notifications for shop ${shop_id}`);
};
