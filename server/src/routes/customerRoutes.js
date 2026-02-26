const express = require('express');
const router = express.Router();
const { getCustomers, createCustomer, getCustomerDetails, updateCustomer, deleteCustomer } = require('../controllers/customerController');
const auth = require('../middleware/authMiddleware');
const validators = require('../middleware/validators');
const { checkPermission } = require('../middleware/permissionMiddleware');

router.get('/', auth, getCustomers);
router.post('/', auth, validators.createCustomer, createCustomer);
router.get('/:id', auth, getCustomerDetails);
router.put('/:id', auth, updateCustomer);
router.delete('/:id', auth, checkPermission('delete_customer'), deleteCustomer);

module.exports = router;
