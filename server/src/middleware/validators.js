const { body, param, query, validationResult } = require('express-validator');

// Middleware to check validation result
const handleValidationErrors = (req, res, next) => {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
        return res.status(400).json({
            message: 'Validation failed',
            errors: errors.array().map(err => ({
                field: err.path,
                message: err.msg
            }))
        });
    }
    next();
};

// Common validation rules
const validators = {
    // Auth validations
    register: [
        body('name').trim().notEmpty().withMessage('Name is required'),
        body('email').isEmail().withMessage('Valid email is required'),
        body('password').isLength({ min: 8 }).withMessage('Password must be at least 8 characters'), // Changed from 6 to 8
        handleValidationErrors
    ],

    login: [
        body('email').notEmpty().withMessage('Email or Username is required'),
        body('password').notEmpty().withMessage('Password is required'),
        handleValidationErrors
    ],

    // Shop validations
    createShop: [
        body('name').trim().notEmpty().withMessage('Shop name is required'),
        body('business_type').isIn(['general', 'bike_sales', 'garage', 'furniture', 'showroom', 'pickup_rental']) // Added 'general'
            .withMessage('Invalid business type'),
        body('phone').optional().isMobilePhone().withMessage('Invalid phone number'),
        handleValidationErrors
    ],

    // Product validations
    createProduct: [
        body('name').trim().notEmpty().withMessage('Product name is required'),
        body('cost_price').isFloat({ min: 0 }).withMessage('Cost price must be a positive number'),
        body('selling_price').isFloat({ min: 0 }).withMessage('Selling price must be a positive number'),
        body('stock_quantity').isInt({ min: 0 }).withMessage('Stock quantity must be a non-negative integer'),
        body('unit').optional().trim(),
        body('category').optional().trim(),
        handleValidationErrors
    ],

    // Customer validations
    createCustomer: [
        body('name').trim().notEmpty().withMessage('Customer name is required'),
        body('phone').optional().trim(),
        body('address').optional().trim(),
        handleValidationErrors
    ],

    // Transaction validations
    createSale: [
        body('items').isArray({ min: 1 }).withMessage('At least one item is required'),
        body('items.*.product_id').optional().isInt({ min: 1 }).withMessage('Valid product ID is required'),
        body('items.*.service_id').optional().isInt({ min: 1 }).withMessage('Valid service ID is required'),
        body('items.*.quantity').isInt({ min: 1 }).withMessage('Quantity must be at least 1'),
        body('items.*.unit_price').isFloat({ min: 0 }).withMessage('Unit price must be positive'),
        body('items.*.subtotal').isFloat({ min: 0 }).withMessage('Subtotal must be positive'),
        body('paid_amount').isFloat({ min: 0 }).withMessage('Paid amount must be non-negative'),
        body('payment_method').isIn(['cash', 'bkash', 'bank', 'due', 'card', 'mobile']).withMessage('Invalid payment method'),
        body('customer_id').optional({ nullable: true }).isInt({ min: 1 }), // Allow null or valid ID
        handleValidationErrors
    ],

    createExpense: [
        body('amount').isFloat({ min: 0.01 }).withMessage('Amount must be greater than 0'),
        body('description').trim().notEmpty().withMessage('Description is required'),
        body('payment_method').isIn(['cash', 'bkash', 'bank', 'due', 'card', 'mobile']).withMessage('Invalid payment method'),
        handleValidationErrors
    ],

    receivePayment: [
        body('customer_id').isInt({ min: 1 }).withMessage('Valid customer ID is required'),
        body('amount').isFloat({ min: 0.01 }).withMessage('Amount must be greater than 0'),
        body('method').isIn(['cash', 'bkash', 'bank', 'card', 'mobile']).withMessage('Invalid payment method'),
        handleValidationErrors
    ],

    // Report validations
    reportSummary: [
        query('start_date').optional().isISO8601().withMessage('Invalid start date format'),
        query('end_date').optional().isISO8601().withMessage('Invalid end date format'),
        handleValidationErrors
    ]
};

module.exports = validators;
