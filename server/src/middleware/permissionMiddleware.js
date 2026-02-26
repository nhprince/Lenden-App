// Permission-based middleware to restrict certain actions for staff members
// Owners have full access to all features

const STAFF_RESTRICTIONS = {
    'delete_customer': true,
    'view_reports': false, // Allow staff to view reports (but not profits)
    'view_profits': true,
    'manage_vendors': true,
    'manage_staff': true,
    'manage_shop_settings': true,
    'delete_product': true,
    'delete_transaction': true,
    'delete_expense': true,
    'edit_product_price': false // Staff CAN edit product prices (at least for now)
};

/**
 * Middleware to check if the current user has permission to perform an action
 * @param {string} action - The action to check permission for (key from STAFF_RESTRICTIONS)
 * @returns {Function} Express middleware function
 */
const checkPermission = (action) => {
    return (req, res, next) => {
        const userRole = req.user?.role;

        // Owners have full access to everything
        if (userRole === 'Owner' || userRole === 'owner') {
            return next();
        }

        // Check if the action is restricted for staff
        if ((userRole === 'Staff' || userRole === 'staff') && STAFF_RESTRICTIONS[action]) {
            return res.status(403).json({
                message: 'Permission denied',
                detail: `Staff members cannot ${action.replace('_', ' ')}`
            });
        }

        next();
    };
};

/**
 * Middleware to ensure only owners can access a route
 */
const ownerOnly = (req, res, next) => {
    const userRole = req.user?.role;

    if (userRole !== 'Owner' && userRole !== 'owner') {
        return res.status(403).json({
            message: 'Access denied',
            detail: 'This action is only available to shop owners'
        });
    }

    next();
};

module.exports = { checkPermission, ownerOnly, STAFF_RESTRICTIONS };
