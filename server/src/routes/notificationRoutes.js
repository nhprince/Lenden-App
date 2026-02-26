const express = require('express');
const router = express.Router();
const auth = require('../middleware/authMiddleware');
const notificationController = require('../controllers/notificationController');

// All routes require auth
router.use(auth);

router.get('/', notificationController.getNotifications);
router.patch('/:id/read', notificationController.markAsRead);
router.patch('/mark-all-read', notificationController.markAllAsRead);
router.delete('/:id', notificationController.deleteNotification);

module.exports = router;
