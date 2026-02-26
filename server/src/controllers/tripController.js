const db = require('../config/db');

exports.getTrips = async (req, res) => {
    try {
        const shop_id = req.shopId;
        const [trips] = await db.execute(
            `SELECT t.*, c.name as customer_name 
            FROM trips t 
            LEFT JOIN customers c ON t.customer_id = c.id 
            WHERE t.shop_id = ? 
            ORDER BY t.id DESC`,
            [shop_id]
        );
        res.json(trips);
    } catch (error) {
        console.error(error);
        res.status(500).json({ message: 'Server error' });
    }
};

exports.createTrip = async (req, res) => {
    try {
        const shop_id = req.shopId;
        const { vehicle_no, driver_name, destination, start_date, trip_fare, expenses, customer_id } = req.body;

        await db.execute(
            'INSERT INTO trips (shop_id, vehicle_no, driver_name, destination, start_date, trip_fare, expenses, customer_id, status) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)',
            [shop_id, vehicle_no, driver_name, destination, start_date || new Date(), trip_fare, expenses || 0, customer_id || null, 'ongoing']
        );

        res.status(201).json({ message: 'Trip recorded successfully' });
    } catch (error) {
        console.error(error);
        res.status(500).json({ message: 'Server error' });
    }
};

// Complete a trip and generate transactions
exports.completeTrip = async (req, res) => {
    const connection = await db.getConnection();
    try {
        await connection.beginTransaction();

        const shop_id = req.shopId; // From authMiddleware
        const { id } = req.params;

        // 1. Get Trip Details
        const [trip] = await connection.execute(
            'SELECT * FROM trips WHERE id = ? AND shop_id = ?',
            [id, shop_id]
        );

        if (trip.length === 0) {
            throw new Error('Trip not found');
        }

        const tripData = trip[0];
        if (tripData.status === 'completed') {
            throw new Error('Trip already completed');
        }

        // 2. Create Income Transaction (Trip Fare)
        if (tripData.trip_fare > 0) {
            await connection.execute(
                `INSERT INTO transactions (shop_id, type, amount, paid_amount, payment_method, customer_id, description) 
                VALUES (?, 'sale', ?, ?, 'cash', ?, ?)`,
                [shop_id, tripData.trip_fare, 0, tripData.customer_id, `Trip Fare: ${tripData.destination}`] // Assuming due initially, or cash? Context implies due tracking. Let's assume due (paid_amount=0) unless specified. But for simplicity, let's mark as DUE so it shows in customer ledger.
            );

            // Update Customer Due
            if (tripData.customer_id) {
                await connection.execute(
                    'UPDATE customers SET total_due = total_due + ? WHERE id = ?',
                    [tripData.trip_fare, tripData.customer_id]
                );
            }
        }

        // 3. Create Expense Transaction (Fuel/Other)
        if (tripData.expenses > 0) {
            await connection.execute(
                `INSERT INTO transactions (shop_id, type, amount, paid_amount, payment_method, description) 
                VALUES (?, 'expense', ?, ?, 'cash', ?)`,
                [shop_id, tripData.expenses, tripData.expenses, `Trip Expense: ${tripData.destination}`]
            );
        }

        // 4. Mark Trip as Completed
        await connection.execute(
            'UPDATE trips SET status = ?, end_date = NOW() WHERE id = ? AND shop_id = ?',
            ['completed', id, shop_id]
        );

        await connection.commit();
        res.json({ message: 'Trip completed and transactions generated' });

    } catch (error) {
        await connection.rollback();
        console.error(error);
        res.status(500).json({ message: error.message || 'Server error' });
    } finally {
        connection.release();
    }
};
