const db = require('../config/db');
const { createLowStockNotification } = require('./notificationService');
const { sendEmail, getEmailTemplate } = require('../utils/emailService');

/**
 * Stock Checker Service
 * Checks for low stock products and sends notifications
 */

/**
 * Check for low stock products and create notifications
 * This should be run daily via cron job
 */
async function checkLowStockProducts() {
    try {
        console.log('🔍 Checking for low stock products...');

        // Find all products that are low on stock
        // Assuming min_stock_level is a column, defaulting to 5 if null or 0 is often 0
        // We will check where stock_quantity <= min_stock_level (if set) or <= 5 (default)

        const [shops] = await db.execute('SELECT id, name, owner_id FROM shops');

        let totalLowStock = 0;

        for (const shop of shops) {
            // Get Owner Email
            const [users] = await db.execute('SELECT email FROM users WHERE id = ?', [shop.owner_id]);
            if (users.length === 0) continue;
            const ownerEmail = users[0].email;

            // Get low stock products for this shop
            // Using COALESCE to use default 5 if min_stock_level is null or 0 (optional logic, but safer)
            // But let's stick to the controller logic: stock_quantity <= min_stock_level
            // If min_stock_level is not set, we might miss it. Let's assume schema has it.
            // If the controller uses `stock_quantity <= min_stock_level`, then min_stock_level must exist.

            const [lowStockProducts] = await db.execute(`
                SELECT * FROM products 
                WHERE shop_id = ? 
                AND stock_quantity <= COALESCE(NULLIF(min_stock_level, 0), 5)
                AND stock_quantity > 0
            `, [shop.id]);

            if (lowStockProducts.length === 0) continue;

            console.log(`📋 Found ${lowStockProducts.length} low stock products for shop ${shop.name}`);
            totalLowStock += lowStockProducts.length;

            // 1. Create In-App Notification (One summary notification per shop usually better than 50 notifications)
            // Or one per product? One per product might flood.
            // Let's create a summary notification.
            try {
                await createLowStockNotification({
                    shop_id: shop.id,
                    product_count: lowStockProducts.length,
                    message: `You have ${lowStockProducts.length} products running low on stock.`
                });
            } catch (notifError) {
                console.error(`Failed to create low stock notification for shop ${shop.id}:`, notifError);
            }

            // 2. Send Email Summary
            const productListHtml = lowStockProducts.map(p =>
                `<li><strong>${p.name}</strong>: ${p.stock_quantity} remaining (Min: ${p.min_stock_level || 5})</li>`
            ).join('');

            const emailContent = `
                <p>The following products in <strong>${shop.name}</strong> are running low on stock:</p>
                <div style="background: #fff3cd; padding: 15px; border-radius: 8px; margin: 20px 0;">
                    <ul style="margin: 0; padding-left: 20px;">
                        ${productListHtml}
                    </ul>
                </div>
                <p>Please restock these items soon to avoid running out.</p>
            `;

            const html = getEmailTemplate(
                `Low Stock Alert - ${shop.name}`,
                emailContent,
                'Manage Inventory',
                `${process.env.FRONTEND_ORIGIN || 'https://lenden.cyberslayersagency.com'}/#/products?low_stock=true`
            );

            try {
                await sendEmail(ownerEmail, `Low Stock Alert - ${shop.name}`, html);
                console.log(`📧 Sent low stock email to ${ownerEmail}`);
            } catch (emailError) {
                console.error(`Failed to send low stock email to ${ownerEmail}:`, emailError);
            }
        }

        console.log('✅ Low stock check completed');
        return totalLowStock;
    } catch (error) {
        console.error('❌ Error checking low stock:', error);
        throw error;
    }
}

module.exports = {
    checkLowStockProducts
};
