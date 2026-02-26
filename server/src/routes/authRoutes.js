const express = require('express');
const router = express.Router();
const { register, login, updateProfile } = require('../controllers/authController');
const auth = require('../middleware/authMiddleware');
const validators = require('../middleware/validators');

router.post('/register', validators.register, register);
router.post('/login', login); // Removed validator for login to support Email or Username flexibly
router.post('/forgot-password', (req, res, next) => {
    // If body contains token/recoveryCode, it's a reset attempt
    if (req.body.token || req.body.recoveryCode) {
        return require('../controllers/authController').resetPassword(req, res);
    }
    require('../controllers/authController').forgotPassword(req, res);
});
router.get('/verify-email/:token', require('../controllers/authController').verifyEmail);
router.post('/resend-verification', require('../controllers/authController').resendVerification);
router.post('/change-password', auth, require('../controllers/authController').changePassword);
router.get('/recovery-code', auth, require('../controllers/authController').getRecoveryCode);
const upload = require('../middleware/uploadMiddleware');
router.post('/upload-avatar', auth, upload.single('avatar'), require('../controllers/authController').uploadAvatar);
router.put('/profile', auth, updateProfile);

module.exports = router;
