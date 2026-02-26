const express = require('express');
const router = express.Router();
const { getVendors, createVendor, getVendorDetails, updateVendor, deleteVendor } = require('../controllers/vendorController');
const auth = require('../middleware/authMiddleware');
const { checkPermission } = require('../middleware/permissionMiddleware');

router.get('/', auth, checkPermission('manage_vendors'), getVendors);
router.post('/', auth, checkPermission('manage_vendors'), createVendor);
router.get('/:id', auth, checkPermission('manage_vendors'), getVendorDetails);
router.put('/:id', auth, checkPermission('manage_vendors'), updateVendor);
router.delete('/:id', auth, checkPermission('manage_vendors'), deleteVendor);

module.exports = router;
