const cron = require('node-cron');
const db = require('../config/db');
const { sendEmail, getEmailTemplate } = require('./emailService');
const { checkOverdueTransactions } = require('../services/dueDateChecker');
const { checkLowStockProducts } = require('../services/stockChecker');
const { createDailyReportNotification } = require('../services/notificationService');

const initCronJobs = () => {
    // Run every day at 10:00 PM
    cron.schedule('0 22 * * *', async () => {
        console.log('Running Daily Sales Summary Cron Job...');

        try {
            const [shops] = await db.execute('SELECT id, name, owner_id FROM shops');

            for (const shop of shops) {
                // Get Owner Email
                const [users] = await db.execute('SELECT email FROM users WHERE id = ?', [shop.owner_id]);
                if (users.length === 0) continue;
                const ownerEmail = users[0].email;

                // Calculate Daily Stats
                const today = new Date().toISOString().split('T')[0];

                const [sales] = await db.execute(
                    `SELECT SUM(amount) as total_sales, COUNT(*) as count 
                     FROM transactions 
                     WHERE shop_id = ? AND type = 'sale' AND DATE(date) = ?`,
                    [shop.id, today]
                );

                const [expenses] = await db.execute(
                    `SELECT SUM(amount) as total_expenses 
                     FROM transactions 
                     WHERE shop_id = ? AND type = 'expense' AND DATE(date) = ?`,
                    [shop.id, today]
                );

                const [purchases] = await db.execute(
                    `SELECT SUM(amount) as total_purchases 
                     FROM transactions 
                     WHERE shop_id = ? AND type = 'purchase' AND DATE(date) = ?`,
                    [shop.id, today]
                );

                const totalSales = parseFloat(sales[0].total_sales) || 0;
                const totalTxns = parseInt(sales[0].count) || 0;
                const totalExpenses = parseFloat(expenses[0].total_expenses) || 0;
                const totalPurchases = parseFloat(purchases[0].total_purchases) || 0;
                const profit = totalSales - totalExpenses - totalPurchases;

                const reportData = {
                    total_sales: totalSales,
                    sales_count: totalTxns,
                    total_expenses: totalExpenses,
                    total_purchases: totalPurchases,
                    net_profit: profit
                };

                // Send In-App Notification if there was activity
                if (totalTxns > 0 || totalExpenses > 0 || totalPurchases > 0) {
                    await createDailyReportNotification({ shop_id: shop.id, reportData });
                }

                const emailContent = `
                    <p>Here is your daily business summary for <strong>${today}</strong>.</p>
                    <div style="background-color: #f1f5f9; padding: 15px; border-radius: 8px; margin: 20px 0;">
                        <p style="margin: 5px 0;"><strong>Total Sales:</strong> ৳${totalSales.toLocaleString()}</p>
                        <p style="margin: 5px 0;"><strong>Transactions:</strong> ${totalTxns}</p>
                        <p style="margin: 5px 0;"><strong>Expenses:</strong> ৳${totalExpenses.toLocaleString()}</p>
                        <hr style="border: 0; border-top: 1px solid #e2e8f0; margin: 10px 0;"/>
                        <p style="margin: 5px 0; font-size: 16px;"><strong>Net Profit:</strong> ৳${profit.toLocaleString()}</p>
                    </div>
                    <p>Keep up the great work!</p>
                `;

                const html = getEmailTemplate(
                    `Daily Summary - ${shop.name}`,
                    emailContent,
                    'View Dashboard',
                    `${process.env.FRONTEND_ORIGIN || 'https://lenden.nhprince.dpdns.org'}/#/dashboard`
                );

                await sendEmail(ownerEmail, `Daily Summary - ${shop.name}`, html);
            }
        } catch (error) {
            console.error('Cron Job Failed:', error);
        }

        // Run overdue check daily
        console.log('Running Overdue Transaction Check...');
        try {
            await checkOverdueTransactions();
        } catch (error) {
            console.error('Overdue Check Failed:', error);
        }

        // Run low stock check daily
        console.log('Running Low Stock Check...');
        try {
            await checkLowStockProducts();
        } catch (error) {
            console.error('Low Stock Check Failed:', error);
        }
    });

    // Run on the 1st of every month at 9:00 AM
    cron.schedule('0 9 1 * *', async () => {
        console.log('Running Monthly Report Cron Job...');
        try {
            const [shops] = await db.execute('SELECT id, name, owner_id FROM shops');

            for (const shop of shops) {
                const [users] = await db.execute('SELECT email FROM users WHERE id = ?', [shop.owner_id]);
                if (users.length === 0) continue;
                const ownerEmail = users[0].email;

                // Calculate Previous Month Range
                const date = new Date();
                date.setMonth(date.getMonth() - 1);
                const monthName = date.toLocaleString('default', { month: 'long', year: 'numeric' });

                // First day of previous month
                const startParams = new Date(date.getFullYear(), date.getMonth(), 1).toISOString().split('T')[0];
                // Last day of previous month
                const endParams = new Date(date.getFullYear(), date.getMonth() + 1, 0).toISOString().split('T')[0];

                const [sales] = await db.execute(
                    `SELECT SUM(amount) as total_sales, COUNT(*) as count 
                     FROM transactions 
                     WHERE shop_id = ? AND type = 'sale' AND DATE(date) BETWEEN ? AND ?`,
                    [shop.id, startParams, endParams]
                );

                const [expenses] = await db.execute(
                    `SELECT SUM(amount) as total_expenses 
                     FROM transactions 
                     WHERE shop_id = ? AND type = 'expense' AND DATE(date) BETWEEN ? AND ?`,
                    [shop.id, startParams, endParams]
                );

                const totalSales = sales[0].total_sales || 0;
                const totalTxns = sales[0].count || 0;
                const totalExpenses = expenses[0].total_expenses || 0;
                const profit = totalSales - totalExpenses;

                const emailContent = `
                    <p>Here is your monthly business report for <strong>${monthName}</strong>.</p>
                    <div style="background-color: #f1f5f9; padding: 15px; border-radius: 8px; margin: 20px 0;">
                        <p style="margin: 5px 0;"><strong>Total Sales:</strong> ৳${totalSales.toLocaleString()}</p>
                        <p style="margin: 5px 0;"><strong>Transactions:</strong> ${totalTxns}</p>
                        <p style="margin: 5px 0;"><strong>Expenses:</strong> ৳${totalExpenses.toLocaleString()}</p>
                        <hr style="border: 0; border-top: 1px solid #e2e8f0; margin: 10px 0;"/>
                        <p style="margin: 5px 0; font-size: 16px;"><strong>Net Profit:</strong> ৳${profit.toLocaleString()}</p>
                    </div>
                    <p>Login to view detailed analytics and download PDF reports.</p>
                `;

                const html = getEmailTemplate(
                    `Monthly Report - ${monthName}`,
                    emailContent,
                    'View Reports',
                    `${process.env.FRONTEND_ORIGIN || 'https://lenden.nhprince.dpdns.org'}/#/reports`
                );

                await sendEmail(ownerEmail, `Monthly Report - ${monthName}`, html);
            }
        } catch (error) {
            console.error('Monthly Cron Job Failed:', error);
        }
    });
};

module.exports = initCronJobs;
