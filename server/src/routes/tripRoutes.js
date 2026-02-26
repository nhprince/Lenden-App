const express = require('express');
const router = express.Router();
const { getTrips, createTrip } = require('../controllers/tripController');
const auth = require('../middleware/authMiddleware');

router.get('/', auth, getTrips);
router.post('/', auth, createTrip);
router.post('/:id/complete', auth, require('../controllers/tripController').completeTrip);

module.exports = router;
