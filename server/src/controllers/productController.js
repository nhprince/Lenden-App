const db = require('../config/db');

// Get all products for the authenticated shop (with pagination)
exports.getProducts = async (req, res) => {
    try {
        const shop_id = req.header('Shop-Id');
        if (!shop_id) return res.status(400).json({ message: 'Shop ID required' });

        // Pagination parameters
        const limit = Math.min(parseInt(req.query.limit) || 50, 200); // Max 200 items per page
        const offset = parseInt(req.query.offset) || 0;
        const low_stock = req.query.low_stock === 'true';
        const search = req.query.search;

        // Base query
        let query = 'SELECT * FROM products WHERE shop_id = ?';
        let countQuery = 'SELECT COUNT(*) as total FROM products WHERE shop_id = ?';
        const params = [shop_id];

        if (low_stock) {
            const condition = ' AND stock_quantity <= min_stock_level';
            query += condition;
            countQuery += condition;
        }

        if (search) {
            const condition = ' AND (name LIKE ? OR sku LIKE ?)';
            const searchParam = `%${search}%`;
            query += condition;
            countQuery += condition;
            params.push(searchParam, searchParam);
        }

        query += ' ORDER BY id DESC LIMIT ? OFFSET ?';

        // Get total count (using params excluding limit/offset)
        const [countResult] = await db.execute(countQuery, params);
        const total = countResult[0].total;

        // Get paginated products
        params.push(limit, offset);
        const [products] = await db.execute(query, params);

        // Filter out cost_price for staff and managers (only owners should see cost)
        const userRole = req.user.role?.toLowerCase();
        const processedProducts = (userRole === 'owner' || userRole === 'admin')
            ? products
            : products.map(({ cost_price, material_cost, ...rest }) => rest);

        res.json({
            products: processedProducts,
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

// Create a new product
// Create a new product
exports.createProduct = async (req, res) => {
    try {
        const shop_id = req.header('Shop-Id');
        if (!shop_id) return res.status(400).json({ message: 'Shop ID required' });

        let {
            name, category, sku, cost_price, selling_price, stock_quantity, unit,
            engine_no, chassis_no, model_year, min_stock_level, material_cost, image_url
        } = req.body;

        // Validation
        if (!name || name.trim() === '') {
            return res.status(400).json({ message: 'Product name is required' });
        }
        if (!sku || sku.trim() === '') {
            return res.status(400).json({ message: 'SKU is required' });
        }

        // Ensure numeric values
        selling_price = parseFloat(selling_price);
        if (isNaN(selling_price) || selling_price < 0) {
            return res.status(400).json({ message: 'Valid selling price is required' });
        }

        // Validate image URL length (increased limit to support base64 images up to ~5MB)
        if (image_url && image_url.length > 7000000) {
            return res.status(400).json({ message: 'Image size is too large. Please use a smaller image or compress it.' });
        }

        // Prevent staff from setting cost-related fields
        if (req.user.role === 'Staff') {
            cost_price = 0;
            material_cost = 0;
        }

        // Sanitize string inputs (basic prevention)
        const sanitize = (str) => str ? str.toString().trim().replace(/[<>]/g, '') : null;

        // Default values for optional fields (with sanitization)
        const productData = {
            shop_id,
            name: sanitize(name), // Required and sanitized
            category: sanitize(category) || 'General',
            sku: sanitize(sku), // Required and sanitized
            cost_price: parseFloat(cost_price) || 0,
            selling_price: selling_price,
            stock_quantity: parseInt(stock_quantity) || 0,
            unit: sanitize(unit) || 'pcs',
            engine_no: sanitize(engine_no),
            chassis_no: sanitize(chassis_no),
            model_year: model_year ? sanitize(model_year) : null,
            min_stock_level: parseInt(min_stock_level) || 5,
            material_cost: material_cost ? parseFloat(material_cost) : null,
            image_url: image_url || null // URLs are harder to sanitize simply, trusting multer/client for now but checked length earlier
        };

        if (process.env.NODE_ENV === 'development') console.log('📦 Creating product:', productData);

        const [result] = await db.execute(
            `INSERT INTO products 
            (shop_id, name, category, sku, cost_price, selling_price, stock_quantity, unit, engine_no, chassis_no, model_year, min_stock_level, material_cost, image_url) 
            VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)`,
            [
                productData.shop_id,
                productData.name,
                productData.category,
                productData.sku,
                productData.cost_price,
                productData.selling_price,
                productData.stock_quantity,
                productData.unit,
                productData.engine_no,
                productData.chassis_no,
                productData.model_year,
                productData.min_stock_level,
                productData.material_cost,
                productData.image_url
            ]
        );

        if (process.env.NODE_ENV === 'development') console.log('✅ Product created with ID:', result.insertId);
        res.status(201).json({ message: 'Product added successfully', productId: result.insertId });
    } catch (error) {
        console.error('❌ Product creation error:', error.message);
        console.error('Error code:', error.code);

        // Handle specific SQL errors
        if (error.code === 'ER_DUP_ENTRY') {
            return res.status(400).json({ message: 'Product with this SKU already exists' });
        }
        if (error.code === 'ER_DATA_TOO_LONG') {
            return res.status(400).json({ message: 'Data too long for one of the fields (check image URL or description)' });
        }

        res.status(500).json({
            message: 'Failed to create product',
            error: process.env.NODE_ENV === 'development' ? error.message : 'Server error'
        });
    }
};

// Update product details
exports.updateProduct = async (req, res) => {
    try {
        const { id } = req.params;
        const shop_id = req.header('Shop-Id');
        if (!shop_id) return res.status(400).json({ message: 'Shop ID required' });

        let {
            name, category, sku, cost_price, selling_price, stock_quantity, unit,
            engine_no, chassis_no, model_year, min_stock_level, image_url
        } = req.body;

        // Validation
        if (name !== undefined && name.trim() === '') {
            return res.status(400).json({ message: 'Product name cannot be empty' });
        }
        if (sku !== undefined && sku.trim() === '') {
            return res.status(400).json({ message: 'SKU cannot be empty' });
        }

        // Prevent staff from updating cost_price
        if (req.user.role === 'Staff') {
            // Keep existing cost_price if staff is updating
            const [existing] = await db.execute('SELECT cost_price FROM products WHERE id = ?', [id]);
            if (existing.length > 0) {
                cost_price = existing[0].cost_price;
            }
        }

        await db.execute(
            `UPDATE products SET 
            name=?, category=?, sku=?, cost_price=?, selling_price=?, stock_quantity=?, unit=?, 
            engine_no=?, chassis_no=?, model_year=?, min_stock_level=?, image_url=?
            WHERE id=? AND shop_id=?`,
            [
                name ? name.toString().trim().replace(/[<>]/g, '') : '',
                category ? category.toString().trim().replace(/[<>]/g, '') : null,
                sku ? sku.toString().trim().replace(/[<>]/g, '') : null,
                cost_price || 0,
                selling_price || 0,
                stock_quantity || 0,
                unit ? unit.toString().trim().replace(/[<>]/g, '') : null,
                engine_no ? engine_no.toString().trim().replace(/[<>]/g, '') : null,
                chassis_no ? chassis_no.toString().trim().replace(/[<>]/g, '') : null,
                model_year ? model_year.toString().trim().replace(/[<>]/g, '') : null,
                min_stock_level || 0,
                image_url || null,
                id,
                shop_id
            ]
        );

        // Check for Low Stock Alert
        if (stock_quantity <= min_stock_level) {
            const { sendEmail } = require('../utils/emailService');
            const { notifyLowStock } = require('../utils/notificationHelper');

            // Create in-app notification
            await notifyLowStock(shop_id, { id, name, stock_quantity });

            // Send email notification
            const [owners] = await db.execute('SELECT u.email, s.name as shop_name FROM users u JOIN shops s ON u.id = s.owner_id WHERE s.id = ?', [shop_id]);
            if (owners.length > 0) {
                const html = `<h3>Low Stock Alert: ${name}</h3><p>Current Stock: ${stock_quantity}</p><p>Min Level: ${min_stock_level}</p>`;
                await sendEmail(owners[0].email, `Low Stock Alert: ${name}`, html);
            }
        }

        res.json({ message: 'Product updated successfully' });
    } catch (error) {
        console.error('Update Product Error:', error);

        if (error.code === 'ER_DUP_ENTRY') {
            return res.status(400).json({ message: 'Product with this SKU already exists' });
        }

        res.status(500).json({ message: 'Server error' });
    }
};

// Update product stock (simple adjustment)
exports.updateStock = async (req, res) => {
    try {
        const { id } = req.params;
        const { quantity } = req.body; // Can be positive (add) or negative (deduct)
        const shop_id = req.header('Shop-Id');
        if (!shop_id) return res.status(400).json({ message: 'Shop ID required' });

        await db.execute('UPDATE products SET stock_quantity = stock_quantity + ? WHERE id = ? AND shop_id = ?', [quantity, id, shop_id]);

        // Check for Low Stock Alert if quantity was deducted
        if (quantity < 0) {
            const [product] = await db.execute('SELECT name, stock_quantity, min_stock_level FROM products WHERE id = ?', [id]);
            if (product[0].stock_quantity <= product[0].min_stock_level) {
                const { sendEmail } = require('../utils/emailService');
                const { notifyLowStock } = require('../utils/notificationHelper');

                // Create in-app notification
                await notifyLowStock(shop_id, { id, name: product[0].name, stock_quantity: product[0].stock_quantity });

                // Send email notification
                const [owners] = await db.execute('SELECT u.email, s.name as shop_name FROM users u JOIN shops s ON u.id = s.owner_id WHERE s.id = ?', [shop_id]);
                if (owners.length > 0) {
                    const html = `<h3>Low Stock Alert: ${product[0].name}</h3><p>Current Stock: ${product[0].stock_quantity}</p><p>Min Level: ${product[0].min_stock_level}</p>`;
                    await sendEmail(owners[0].email, `Low Stock Alert: ${product[0].name}`, html);
                }
            }
        }

        res.json({ message: 'Stock updated successfully' });
    } catch (error) {
        console.error(error);
        res.status(500).json({ message: 'Server error' });
    }
};

// Delete product
exports.deleteProduct = async (req, res) => {
    try {
        const { id } = req.params;
        const shop_id = req.header('Shop-Id');
        if (!shop_id) return res.status(400).json({ message: 'Shop ID required' });

        if (req.user.role === 'Staff') {
            return res.status(403).json({ message: 'Access denied: Staff members cannot delete products' });
        }

        await db.execute('DELETE FROM products WHERE id = ? AND shop_id = ?', [id, shop_id]);
        res.json({ message: 'Product deleted' });
    } catch (error) {
        console.error(error);
        res.status(500).json({ message: 'Server error' });
    }
};
