const db = require('../config/db');
const { logError, logRequest } = require('../utils/logger');
const { createLowStockNotification } = require('../services/notificationService');

// Create a new Sale (Transaction)
exports.createSale = async (req, res) => {
    const connection = await db.getConnection();
    try {
        await connection.beginTransaction();

        const shop_id = req.shopId;
        if (!shop_id) throw new Error('Shop ID required');

        const { customer_id, customer_name, items, paid_amount, payment_method, discount, notes, due_date } = req.body;

        // items = [{ product_id, quantity, unit_price, subtotal }]

        // 1. Calculate totals
        let total_amount = 0;
        if (!items || !Array.isArray(items)) {
            console.error('Items validation failed: No items array provided');
            throw new Error('At least one item is required in the cart');
        }

        items.forEach((item, index) => {
            total_amount += (parseFloat(item.subtotal) || 0);
        });

        const final_amount = total_amount - (discount || 0);
        const due_amount = final_amount - paid_amount;
        const status = due_amount <= 0 ? 'Completed' : 'Pending';

        // 2. Prepare Snapshot Data
        let snapshot_name = customer_name || '';
        let snapshot_phone = '';
        let snapshot_address = '';

        if (customer_id) {
            const [customer] = await connection.execute(
                'SELECT name, phone, address FROM customers WHERE id = ?',
                [customer_id]
            );
            if (customer.length > 0) {
                snapshot_name = customer[0].name;
                snapshot_phone = customer[0].phone;
                snapshot_address = customer[0].address;
            }
        }

        let description = notes || '';
        if (!customer_id && snapshot_name) {
            description = `Customer: ${snapshot_name}${notes ? ' - ' + notes : ''}`;
        }

        const [transResult] = await connection.execute(
            `INSERT INTO transactions 
            (shop_id, type, amount, paid_amount, payment_method, customer_id, description, status, customer_name_snapshot, customer_phone_snapshot, customer_address_snapshot, due_date) 
            VALUES (?, 'sale', ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)`,
            [shop_id, final_amount, paid_amount, payment_method, customer_id || null, description, status, snapshot_name, snapshot_phone, snapshot_address, due_date || null]
        );
        const transaction_id = transResult.insertId;


        // 3. Validate Stock Availability (Only for Products)
        for (const item of items) {
            // Bug #24: Validate quantity
            if (!item.quantity || item.quantity <= 0) {
                throw new Error(`Invalid quantity for item ${item.product_id || item.service_id}. Quantity must be greater than 0.`);
            }

            if (item.product_id) {
                const [product] = await connection.execute(
                    'SELECT stock_quantity, name, cost_price FROM products WHERE id = ? AND shop_id = ?',
                    [item.product_id, shop_id]
                );

                if (product.length === 0) {
                    throw new Error(`Product with ID ${item.product_id} not found`);
                }

                if (product[0].stock_quantity < item.quantity) {
                    throw new Error(`Insufficient stock for ${product[0].name}. Available: ${product[0].stock_quantity}, Requested: ${item.quantity}`);
                }
                // Bug #21: Attach cost price for the item storage
                item.cost_price = product[0].cost_price;
            } else if (item.service_id) {
                // Verify service exists (optional, but good for integrity)
                const [service] = await connection.execute(
                    'SELECT id FROM services WHERE id = ? AND shop_id = ?',
                    [item.service_id, shop_id]
                );
                if (service.length === 0) {
                    throw new Error(`Service with ID ${item.service_id} not found`);
                }
            }
        }

        // 4. Insert Sale Items and Update Stock
        for (const item of items) {
            await connection.execute(
                `INSERT INTO transaction_items (transaction_id, product_id, service_id, quantity, unit_price, cost_price, subtotal) 
                VALUES (?, ?, ?, ?, ?, ?, ?)`,
                [transaction_id, item.product_id || null, item.service_id || null, item.quantity, item.unit_price, item.cost_price || 0, item.subtotal]
            );

            // Deduct Stock (Only for Products)
            if (item.product_id) {
                const [updateResult] = await connection.execute(
                    'UPDATE products SET stock_quantity = stock_quantity - ? WHERE id = ? AND shop_id = ?',
                    [item.quantity, item.product_id, shop_id]
                );

                // Check for Low Stock Alert
                const [product] = await connection.execute(
                    'SELECT name, stock_quantity, min_stock_level FROM products WHERE id = ?',
                    [item.product_id]
                );

                if (product[0].stock_quantity <= product[0].min_stock_level) {
                    // Send low stock alert email (non-blocking)
                    try {
                        // Create in-app notification
                        await createLowStockNotification({
                            shop_id,
                            product_name: product[0].name,
                            current_stock: product[0].stock_quantity,
                            min_stock: product[0].min_stock_level
                        });

                        const { sendEmail, getEmailTemplate } = require('../utils/emailService');
                        const [owners] = await connection.execute(
                            'SELECT u.email, s.name as shop_name FROM users u JOIN shops s ON u.id = s.owner_id WHERE s.id = ?',
                            [shop_id]
                        );

                        if (owners.length > 0 && owners[0].email) {
                            const emailContent = `
                                <p>The stock for <strong>${product[0].name}</strong> in your shop <strong>${owners[0].shop_name}</strong> has reached or fallen below the minimum level.</p>
                                <p><strong>Current Stock:</strong> ${product[0].stock_quantity}</p>
                                <p><strong>Minimum Level:</strong> ${product[0].min_stock_level}</p>
                                <p>Please restock soon.</p>
                            `;

                            const html = getEmailTemplate(
                                `Low Stock Alert: ${product[0].name}`,
                                emailContent,
                                'View Inventory',
                                `${process.env.FRONTEND_ORIGIN || 'https://lenden.cyberslayersagency.com'}/#/products`
                            );

                            await sendEmail(owners[0].email, `Low Stock Alert: ${product[0].name}`, html);
                        }
                    } catch (emailError) {
                        // Log email error but don't fail the transaction
                        console.error('Low stock email failed:', emailError.message);
                    }
                }
            }
        }


        // 5. Update Customer Due and Total Spent (if applicable, Scoped to Shop)
        if (customer_id) {
            let updateQuery = 'UPDATE customers SET total_spent = total_spent + ?';
            const updateParams = [final_amount];

            if (due_amount > 0) {
                updateQuery += ', total_due = total_due + ?';
                updateParams.push(due_amount);
            }

            updateQuery += ' WHERE id = ? AND shop_id = ?';
            updateParams.push(customer_id, shop_id);

            await connection.execute(updateQuery, updateParams);
        }

        await connection.commit();

        // 6. Send In-App Notification (Async, don't block response)
        const { createNewSaleNotification } = require('../services/notificationService');
        createNewSaleNotification({
            shop_id,
            transaction: {
                id: transaction_id,
                amount: final_amount
            }
        }).catch(err => console.error('Failed to create sale notification:', err));

        res.status(201).json({ message: 'Sale completed successfully', transactionId: transaction_id });

    } catch (error) {
        await connection.rollback();

        // Log detailed error
        logError(error, {
            endpoint: '/transactions/sale',
            method: 'POST',
            userId: req.user?.id,
            shopId: req.shopId,
            customerId: req.body?.customer_id,
            itemCount: req.body?.items?.length
        });

        console.error('Sale transaction error:', error.message);
        console.error('Stack:', error.stack);

        // Return user-friendly error message
        res.status(500).json({
            message: error.message || 'Transaction failed',
            timestamp: new Date().toISOString()
        });
    } finally {
        connection.release();
    }
};

exports.createPurchase = async (req, res) => {
    const connection = await db.getConnection();
    try {
        await connection.beginTransaction();

        // Log request for debugging
        logRequest(req, 'PURCHASE_ORDER_START');

        const shop_id = req.shopId;
        if (!shop_id) throw new Error('Shop ID required');

        if (req.user.role === 'Staff') {
            return res.status(403).json({ message: 'Staff members are not authorized to record purchases' });
        }

        const { vendor_id, items, paid_amount, payment_method, discount, notes, due_date } = req.body;
        // items = [{ product_id, quantity, unit_price }]

        // Validation
        if (!vendor_id) throw new Error('Vendor is required');
        if (!items || !Array.isArray(items) || items.length === 0) throw new Error('At least one item is required');

        // 1. Calculate totals
        let total_amount = 0;
        items.forEach(item => total_amount += (item.quantity * item.unit_price));

        // Apply discount if any (usually purchase discount reduces the payable amount)
        const final_amount = total_amount - (discount || 0);
        const due_amount = final_amount - paid_amount;
        const status = due_amount <= 0 ? 'Completed' : 'Pending';

        // 2. Create Transaction Record
        const [transResult] = await connection.execute(
            `INSERT INTO transactions 
            (shop_id, type, amount, paid_amount, payment_method, vendor_id, description, status, due_date) 
            VALUES (?, 'purchase', ?, ?, ?, ?, ?, ?, ?)`,
            [shop_id, final_amount, paid_amount, payment_method || 'cash', vendor_id, notes || null, status, due_date || null]
        );
        const transaction_id = transResult.insertId;

        // 3. Process Items
        for (const item of items) {
            // Bug #24: Validate quantity
            if (!item.quantity || item.quantity <= 0) {
                throw new Error(`Invalid quantity for item ${item.product_id}. Quantity must be greater than 0.`);
            }

            // Verify product exists
            const [product] = await connection.execute(
                'SELECT id FROM products WHERE id = ? AND shop_id = ?',
                [item.product_id, shop_id]
            );

            if (product.length === 0) {
                throw new Error(`Product with ID ${item.product_id} not found`);
            }

            // Insert Transaction Item
            await connection.execute(
                `INSERT INTO transaction_items (transaction_id, product_id, quantity, unit_price, cost_price, subtotal) 
                VALUES (?, ?, ?, ?, ?, ?)`,
                [transaction_id, item.product_id, item.quantity, item.unit_price, item.unit_price, (item.quantity * item.unit_price)]
            );

            // Update Product Stock and Cost Price
            await connection.execute(
                'UPDATE products SET stock_quantity = stock_quantity + ?, cost_price = ? WHERE id = ? AND shop_id = ?',
                [item.quantity, item.unit_price, item.product_id, shop_id]
            );
        }

        // 4. Update Vendor Balance (Total Payable)
        if (due_amount > 0) {
            await connection.execute(
                'UPDATE vendors SET total_payable = total_payable + ? WHERE id = ? AND shop_id = ?',
                [due_amount, vendor_id, shop_id]
            );
        }

        await connection.commit();
        res.status(201).json({ message: 'Purchase recorded successfully', transactionId: transaction_id });

    } catch (error) {
        await connection.rollback();

        // Log detailed error information
        logError(error, {
            endpoint: '/transactions/purchase',
            method: 'POST',
            userId: req.user?.id,
            shopId: req.shopId,
            vendorId: req.body?.vendor_id,
            itemCount: req.body?.items?.length
        });

        console.error('Purchase order error:', error);
        res.status(500).json({
            message: error.message || 'Purchase failed',
            timestamp: new Date().toISOString()
        });
    } finally {
        connection.release();
    }
};

exports.createExpense = async (req, res) => {
    try {
        const shop_id = req.shopId;
        if (!shop_id) return res.status(400).json({ message: 'Shop ID required' });

        if (req.user.role === 'Staff') {
            return res.status(403).json({ message: 'Staff members are not authorized to record expenses' });
        }

        const { amount, description, payment_method } = req.body;

        await db.execute(
            `INSERT INTO transactions (shop_id, type, amount, paid_amount, payment_method, description) 
             VALUES (?, 'expense', ?, ?, ?, ?)`,
            [shop_id, amount, amount, payment_method, description]
        );

        res.status(201).json({ message: 'Expense recorded successfully' });
    } catch (error) {
        console.error(error);
        res.status(500).json({ message: 'Server error' });
    }
};

// Record a payment received from a customer (Due Collection)
exports.receivePayment = async (req, res) => {
    const connection = await db.getConnection();
    try {
        await connection.beginTransaction();

        const shop_id = req.shopId;
        if (!shop_id) throw new Error('Shop ID required');

        const { customer_id, amount, method } = req.body;

        // 1. Record Transaction
        await connection.execute(
            `INSERT INTO transactions (shop_id, type, amount, paid_amount, payment_method, customer_id, description) 
             VALUES (?, 'payment_received', ?, ?, ?, ?, 'Due Payment Collection')`,
            [shop_id, amount, amount, method, customer_id]
        );

        // 2. Update Customer Due Balance (Scoped to Shop)
        await connection.execute(
            'UPDATE customers SET total_due = total_due - ? WHERE id = ? AND shop_id = ?',
            [amount, customer_id, shop_id]
        );

        await connection.commit();
        res.status(201).json({ message: 'Payment received successfully' });

    } catch (error) {
        await connection.rollback();
        console.error(error);
        res.status(500).json({ message: 'Server error' });
    } finally {
        connection.release();
    }
};

// Get Recent Transactions (with pagination)
exports.getTransactions = async (req, res) => {
    try {
        const shop_id = req.shopId;
        if (!shop_id) return res.status(400).json({ message: 'Shop ID required' });

        // Pagination parameters
        const limit = Math.min(parseInt(req.query.limit) || 50, 100); // Max 100 items per page
        const offset = parseInt(req.query.offset) || 0;

        // Base query conditions
        let condition = 'WHERE t.shop_id = ?';
        const params = [shop_id];

        const type = req.query.type;
        if (type) {
            condition += ' AND t.type = ?';
            params.push(type);
        }

        // Get total count
        const [countResult] = await db.execute(
            `SELECT COUNT(*) as total FROM transactions t ${condition}`,
            params
        );
        const total = countResult[0].total;

        // Get paginated transactions
        params.push(limit, offset);
        const [transactions] = await db.execute(
            `SELECT t.*, c.name as customer_name, v.name as vendor_name 
            FROM transactions t 
            LEFT JOIN customers c ON t.customer_id = c.id 
            LEFT JOIN vendors v ON t.vendor_id = v.id 
            ${condition}
            ORDER BY 
                CASE 
                    WHEN (t.status = 'Pending' OR (t.amount - t.paid_amount) > 0) THEN 0 
                    ELSE 1 
                END,
                t.date DESC 
            LIMIT ? OFFSET ?`,
            params
        );

        res.json({
            transactions: transactions.map(t => ({
                ...t,
                status: t.status || ((t.amount - t.paid_amount) <= 0 ? 'Completed' : 'Pending')
            })),
            pagination: {
                total,
                limit,
                offset,
                hasMore: (offset + limit) < total
            }
        });
    } catch (error) {
        console.error(error);
        res.status(500).json({ message: 'Server error' });
    }
};

exports.getTransactionDetails = async (req, res) => {
    try {
        const shop_id = req.shopId;
        const { id } = req.params;

        const [transaction] = await db.execute(
            `SELECT t.*, 
            COALESCE(t.customer_name_snapshot, c.name) as customer_name, 
            COALESCE(t.customer_phone_snapshot, c.phone) as customer_phone, 
            COALESCE(t.customer_address_snapshot, c.address) as customer_address, 
            v.name as vendor_name 
            FROM transactions t 
            LEFT JOIN customers c ON t.customer_id = c.id 
            LEFT JOIN vendors v ON t.vendor_id = v.id 
            WHERE t.id = ? AND t.shop_id = ?`,
            [id, shop_id]
        );

        if (transaction.length === 0) {
            return res.status(404).json({ message: 'Transaction not found' });
        }

        const [items] = await db.execute(
            `SELECT ti.*, p.name as product_name, p.sku as product_sku, s.name as service_name 
            FROM transaction_items ti 
            LEFT JOIN products p ON ti.product_id = p.id 
            LEFT JOIN services s ON ti.service_id = s.id 
            WHERE ti.transaction_id = ?`,
            [id]
        );

        res.json({
            ...transaction[0],
            status: transaction[0].status || ((transaction[0].amount - transaction[0].paid_amount) <= 0 ? 'Completed' : 'Pending'),
            items
        });
    } catch (error) {
        console.error(error);
        res.status(500).json({ message: 'Server error' });
    }
};

exports.updateTransactionStatus = async (req, res) => {
    const connection = await db.getConnection();
    try {
        await connection.beginTransaction();

        const shop_id = req.shopId;
        const { id } = req.params;
        if (req.user.role === 'Staff') {
            return res.status(403).json({ message: 'Staff members are not authorized to update transaction status' });
        }

        const { status } = req.body;
        if (!status) return res.status(400).json({ message: 'Status is required' });

        // Get current transaction state
        const [trans] = await connection.execute(
            'SELECT * FROM transactions WHERE id = ? AND shop_id = ?',
            [id, shop_id]
        );

        if (trans.length === 0) {
            return res.status(404).json({ message: 'Transaction not found' });
        }

        const transaction = trans[0];

        // If marking as Completed, handle accounting
        if (status === 'Completed' && transaction.status !== 'Completed') {
            const due = transaction.amount - transaction.paid_amount;

            if (due > 0) {
                // 1. Update Transaction to fully paid
                await connection.execute(
                    'UPDATE transactions SET status = ?, paid_amount = ? WHERE id = ?',
                    ['Completed', transaction.amount, id]
                );

                // 2. Reduce Customer Due
                if (transaction.customer_id) {
                    await connection.execute(
                        'UPDATE customers SET total_due = total_due - ? WHERE id = ?',
                        [due, transaction.customer_id]
                    );

                    // 3. Update total_spent calculation if needed (already tracked, but ensure consistency)
                }
            } else {
                // Just update status
                await connection.execute(
                    'UPDATE transactions SET status = ? WHERE id = ?',
                    ['Completed', id]
                );
            }
        } else {
            // Just update status (e.g. Pending to Cancelled or similar)
            await connection.execute(
                'UPDATE transactions SET status = ? WHERE id = ?',
                [status, id]
            );
        }

        await connection.commit();
        res.json({ message: 'Transaction status updated successfully' });
    } catch (error) {
        await connection.rollback();
        console.error(error);
        res.status(500).json({ message: 'Server error' });
    } finally {
        connection.release();
    }
};

exports.makePayment = async (req, res) => {
    const connection = await db.getConnection();
    try {
        await connection.beginTransaction();

        // Log request for debugging
        logRequest(req, 'VENDOR_PAYMENT_START');

        const shop_id = req.shopId;
        if (!shop_id) throw new Error('Shop ID required');

        if (req.user.role === 'Staff') {
            return res.status(403).json({ message: 'Staff members are not authorized to record payments to vendors' });
        }

        const { vendor_id, amount, method, notes } = req.body;

        // 0. Verify Vendor Balance
        const [vendor] = await connection.execute(
            'SELECT total_payable FROM vendors WHERE id = ? AND shop_id = ?',
            [vendor_id, shop_id]
        );

        if (vendor.length === 0) {
            throw new Error('Vendor not found');
        }

        // Check for zero payable amount
        if (vendor[0].total_payable === 0 || vendor[0].total_payable === null) {
            throw new Error('No payable amount for this vendor');
        }

        if (vendor[0].total_payable < amount) {
            throw new Error(`Cannot pay more than payable amount. Current payable: ৳${vendor[0].total_payable.toLocaleString()}`);
        }

        // 1. Record Transaction
        const [result] = await connection.execute(
            `INSERT INTO transactions (shop_id, type, amount, paid_amount, payment_method, vendor_id, description, status) 
             VALUES (?, 'payment_made', ?, ?, ?, ?, ?, 'Completed')`,
            [shop_id, amount, amount, method, vendor_id, notes]
        );

        // 2. Update Vendor Balance (Reduce Payable)
        await connection.execute(
            'UPDATE vendors SET total_payable = total_payable - ? WHERE id = ? AND shop_id = ?',
            [amount, vendor_id, shop_id]
        );

        await connection.commit();
        res.json({ message: 'Payment recorded successfully', transactionId: result.insertId });

    } catch (error) {
        await connection.rollback();

        // Log detailed error information
        logError(error, {
            endpoint: '/transactions/payment',
            method: 'POST',
            userId: req.user?.id,
            shopId: req.shopId,
            vendorId: req.body?.vendor_id,
            amount: req.body?.amount
        });

        console.error('Vendor payment error:', error);
        res.status(500).json({
            message: error.message || 'Failed to record payment',
            timestamp: new Date().toISOString()
        });
    } finally {
        connection.release();
    }
};
