const db = require('../config/db');
const { createOverdueNotification } = require('./notificationService');
const { sendEmail, getEmailTemplate } = require('../utils/emailService');

/**
 * Due Date Checker Service
 * Checks for overdue transactions and sends notifications
 */

/**
 * Check for overdue transactions and create notifications
 * This should be run daily via cron job
 */
async function checkOverdueTransactions() {
    try {
        console.log('🔍 Checking for overdue transactions...');

        // Find all transactions that are past due date and still pending
        const [overdueTransactions] = await db.execute(`
            SELECT 
                t.id, t.shop_id, t.amount, t.paid_amount, t.due_date,
                t.customer_name_snapshot as customer_name,
                c.name as customer_db_name,
                s.name as shop_name,
                u.email as owner_email
            FROM transactions t
            LEFT JOIN customers c ON t.customer_id = c.id
            JOIN shops s ON t.shop_id = s.id
            JOIN users u ON s.owner_id = u.id
            WHERE t.due_date < CURDATE()
            AND t.status = 'Pending'
            AND (t.amount - t.paid_amount) > 0
        `);

        console.log(`📋 Found ${overdueTransactions.length} overdue transactions`);

        for (const transaction of overdueTransactions) {
            const customer_name = transaction.customer_name || transaction.customer_db_name || 'Walk-in Customer';
            const due_amount = transaction.amount - transaction.paid_amount;

            // Create in-app notification
            try {
                await createOverdueNotification({
                    shop_id: transaction.shop_id,
                    transaction_id: transaction.id,
                    customer_name,
                    amount: due_amount,
                    due_date: transaction.due_date
                });
                console.log(`✅ Created notification for transaction #${transaction.id}`);
            } catch (notifError) {
                console.error(`Failed to create notification for transaction #${transaction.id}:`, notifError);
            }

            // Send email to owner
            if (transaction.owner_email) {
                try {
                    await sendOverdueEmail({
                        email: transaction.owner_email,
                        shop_name: transaction.shop_name,
                        customer_name,
                        amount: due_amount,
                        due_date: transaction.due_date,
                        transaction_id: transaction.id
                    });
                    console.log(`📧 Sent overdue email for transaction #${transaction.id}`);
                } catch (emailError) {
                    console.error(`Failed to send email for transaction #${transaction.id}:`, emailError);
                }
            }

            // Update transaction status to 'Overdue' (optional)
            try {
                await db.execute(
                    `UPDATE transactions SET status = 'Overdue' WHERE id = ?`,
                    [transaction.id]
                );
            } catch (updateError) {
                console.error(`Failed to update status for transaction #${transaction.id}:`, updateError);
            }
        }

        console.log('✅ Overdue check completed');
        return overdueTransactions.length;
    } catch (error) {
        console.error('❌ Error checking overdue transactions:', error);
        throw error;
    }
}

/**
 * Send overdue payment email to owner
 */
async function sendOverdueEmail({ email, shop_name, customer_name, amount, due_date, transaction_id }) {
    const emailContent = `
        <p>You have an overdue payment in your shop <strong>${shop_name}</strong>.</p>
        <div style="background: #fff3cd; padding: 15px; border-radius: 8px; margin: 20px 0;">
            <p style="margin: 0;"><strong>Customer:</strong> ${customer_name}</p>
            <p style="margin: 5px 0;"><strong>Amount Due:</strong> ৳${amount.toLocaleString()}</p>
            <p style="margin: 5px 0;"><strong>Due Date:</strong> ${new Date(due_date).toLocaleDateString()}</p>
            <p style="margin: 5px 0;"><strong>Days Overdue:</strong> ${Math.floor((new Date() - new Date(due_date)) / (1000 * 60 * 60 * 24))} days</p>
        </div>
        <p>Please follow up with the customer to collect the payment.</p>
    `;

    const html = getEmailTemplate(
        `Overdue Payment Alert - ${customer_name}`,
        emailContent,
        'View Transaction',
        `${process.env.FRONTEND_ORIGIN || 'https://lenden.cyberslayersagency.com'}/#/transactions?id=${transaction_id}`
    );

    await sendEmail(email, `Overdue Payment Alert - ${shop_name}`, html);
}

/**
 * Get all overdue transactions for a shop
 * @param {number} shop_id - Shop ID
 * @returns {Promise<Array>} - Array of overdue transactions
 */
async function getOverdueTransactions(shop_id) {
    try {
        const [transactions] = await db.execute(`
            SELECT 
                t.*,
                c.name as customer_name,
                DATEDIFF(CURDATE(), t.due_date) as days_overdue
            FROM transactions t
            LEFT JOIN customers c ON t.customer_id = c.id
            WHERE t.shop_id = ?
            AND t.due_date < CURDATE()
            AND t.status IN ('Pending', 'Overdue')
            AND (t.amount - t.paid_amount) > 0
            ORDER BY t.due_date ASC
        `, [shop_id]);

        return transactions;
    } catch (error) {
        console.error('Error fetching overdue transactions:', error);
        return [];
    }
}

/**
 * Get count of overdue transactions for a shop
 * @param {number} shop_id - Shop ID
 * @returns {Promise<number>} - Count of overdue transactions
 */
async function getOverdueCount(shop_id) {
    try {
        const [result] = await db.execute(`
            SELECT COUNT(*) as count
            FROM transactions
            WHERE shop_id = ?
            AND due_date < CURDATE()
            AND status IN ('Pending', 'Overdue')
            AND (amount - paid_amount) > 0
        `, [shop_id]);

        return result[0].count;
    } catch (error) {
        console.error('Error getting overdue count:', error);
        return 0;
    }
}

module.exports = {
    checkOverdueTransactions,
    getOverdueTransactions,
    getOverdueCount,
    sendOverdueEmail
};
