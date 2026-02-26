const express = require('express');
const router = express.Router();
const controller = require('../controllers/serviceController');
const auth = require('../middleware/authMiddleware');
// const permission = require('../middleware/permissionMiddleware'); // Add when needed

router.get('/', auth, controller.getServices);
router.post('/', auth, controller.createService);
router.get('/:id', auth, controller.getServiceDetails);
router.put('/:id', auth, controller.updateService);
router.delete('/:id', auth, controller.deleteService);

module.exports = router;
