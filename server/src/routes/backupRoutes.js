const express = require('express');
const router = express.Router();
const backupController = require('../controllers/backupController');
const auth = require('../middleware/authMiddleware');

router.get('/export', auth, backupController.exportShopData);
router.post('/import', auth, backupController.importShopData);

module.exports = router;
