const express = require('express');
const router = express.Router();
const { getSummary, getSalesTrend, getCategoryDistribution } = require('../controllers/reportController');
const auth = require('../middleware/authMiddleware');
const { checkPermission } = require('../middleware/permissionMiddleware');

router.get('/summary', auth, checkPermission('view_reports'), getSummary);
router.get('/trend', auth, checkPermission('view_reports'), getSalesTrend);
router.get('/distribution', auth, checkPermission('view_reports'), getCategoryDistribution);

module.exports = router;
