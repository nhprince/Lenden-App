const express = require('express');
const router = express.Router();
const { getProducts, createProduct, updateStock, deleteProduct, updateProduct } = require('../controllers/productController');
const auth = require('../middleware/authMiddleware');
const { checkPermission } = require('../middleware/permissionMiddleware');
const validators = require('../middleware/validators');

router.get('/', auth, getProducts);
router.post('/', auth, validators.createProduct, createProduct);
router.put('/:id', auth, updateProduct);
router.put('/:id/stock', auth, updateStock);
router.delete('/:id', auth, checkPermission('delete_product'), deleteProduct);

module.exports = router;
