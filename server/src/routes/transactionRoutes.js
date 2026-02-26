const express = require('express');
const router = express.Router();
const { createSale, getTransactions, createExpense, receivePayment, getTransactionDetails, updateTransactionStatus, createPurchase, makePayment } = require('../controllers/transactionController');
const auth = require('../middleware/authMiddleware');
const validators = require('../middleware/validators');

router.post('/sale', auth, validators.createSale, createSale);
router.post('/purchase', auth, createPurchase);
router.post('/payment-made', auth, makePayment);
router.post('/expense', auth, validators.createExpense, createExpense);
router.post('/payment-received', auth, validators.receivePayment, receivePayment);
router.get('/', auth, getTransactions);
router.get('/:id', auth, getTransactionDetails);
router.put('/:id/status', auth, updateTransactionStatus);

module.exports = router;
