const express = require('express');
const router = express.Router();
const { createShop, getShops, getShopById, updateShopDetails } = require('../controllers/shopController');
const auth = require('../middleware/authMiddleware');
const validators = require('../middleware/validators');
const { checkPermission } = require('../middleware/permissionMiddleware');

router.post('/', auth, validators.createShop, createShop);
router.get('/', auth, getShops);
router.get('/:id', auth, getShopById);
router.put('/:id', auth, checkPermission('manage_shop_settings'), updateShopDetails);

module.exports = router;
