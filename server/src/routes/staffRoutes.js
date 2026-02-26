const express = require('express');
const router = express.Router();
const { getStaff, createStaff, updateStaff, deleteStaff } = require('../controllers/staffController');
const auth = require('../middleware/authMiddleware');
const { checkPermission } = require('../middleware/permissionMiddleware');

router.get('/', auth, checkPermission('manage_staff'), getStaff);
router.post('/', auth, checkPermission('manage_staff'), createStaff);
router.put('/:id', auth, checkPermission('manage_staff'), updateStaff);
router.delete('/:id', auth, checkPermission('manage_staff'), deleteStaff);

module.exports = router;
