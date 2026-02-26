const db = require('../config/db');
const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');
const crypto = require('crypto');
const { sendEmail, getEmailTemplate } = require('../utils/emailService');

exports.register = async (req, res) => {
    const connection = await db.getConnection();
    try {
        await connection.beginTransaction();

        const { name, email, password, shopName } = req.body;

        // Check if user exists
        const [users] = await connection.execute('SELECT * FROM users WHERE email = ?', [email]);
        if (users.length > 0) {
            await connection.rollback();
            return res.status(400).json({ message: 'User already exists' });
        }

        // Hash password
        const salt = await bcrypt.genSalt(10);
        const hashedPassword = await bcrypt.hash(password, salt);

        // Verification token
        const verificationToken = crypto.randomBytes(32).toString('hex');

        // Insert user
        const [result] = await connection.execute(
            'INSERT INTO users (name, email, password, verification_token) VALUES (?, ?, ?, ?)',
            [name, email, hashedPassword, verificationToken]
        );

        const userId = result.insertId;

        // Create Shop
        const [shopResult] = await connection.execute(
            'INSERT INTO shops (name, owner_id, business_type) VALUES (?, ?, ?)',
            [shopName || `${name}'s Shop`, userId, 'bike_sales'] // Default to bike_sales since it is valid in enum
        );

        const shopId = shopResult.insertId;

        await connection.commit();

        // Create onboarding notifications for new user
        const { createOnboardingNotifications } = require('../utils/notificationHelper');
        await createOnboardingNotifications(shopId);

        // Send Verification Email
        const frontendUrl = process.env.FRONTEND_ORIGIN || 'https://lenden.cyberslayersagency.com';
        const verificationLink = `${frontendUrl}/#/verify-email/${verificationToken}`;

        const emailBody = getEmailTemplate(
            'Confirm Your Registration',
            `<p>Hello <strong>${name}</strong>,</p>
             <p>Welcome to Lenden! We're excited to help you manage your shop <strong>${shopName || "more efficiently"}</strong>.</p>
             <p>To get started, please confirm your email address by clicking the button below.</p>`,
            'Verify Email Address',
            verificationLink,
            'If you did not sign up for a Lenden account, you can safely ignore this email.'
        );

        await sendEmail(email, 'Verify your Lenden Account', emailBody);

        res.status(201).json({
            message: 'User registered successfully. Please check your email to verify your account.',
            userId: userId,
            debugToken: process.env.NODE_ENV === 'development' ? verificationToken : undefined
        });
    } catch (error) {
        await connection.rollback();
        console.error(error);
        res.status(500).json({ message: 'Server error' });
    } finally {
        connection.release();
    }
};

exports.login = async (req, res) => {
    try {
        const { email, password } = req.body; // email field now takes either email or username

        // Find user in users (owners) or staff table
        let [users] = await db.execute('SELECT * FROM users WHERE email = ?', [email]);
        let user = null;
        let userType = 'owner';

        if (users.length > 0) {
            user = users[0];
        } else {
            // Check staff table: Search by email OR username
            const [staff] = await db.execute(
                'SELECT * FROM staff WHERE (email = ? OR username = ?) AND status = "active"',
                [email, email]
            );
            if (staff.length > 0) {
                user = staff[0];
                userType = 'Staff';
            }
        }

        if (!user) {
            return res.status(400).json({ message: 'Invalid credentials' });
        }

        // Check if verified (Only for owners)
        if (userType === 'owner' && !user.is_verified) {
            return res.status(403).json({
                message: 'Please verify your email address before logging in.',
                needsVerification: true,
                email: user.email
            });
        }

        // Check password
        const isMatch = await bcrypt.compare(password, user.password);
        if (!isMatch) {
            return res.status(400).json({ message: 'Invalid credentials' });
        }

        // Create token payload
        const payload = {
            id: user.id,
            role: user.role || userType
        };

        // If it's a staff member, include shop_id in token
        if (userType === 'Staff' || user.role === 'Staff') {
            payload.shopId = user.shop_id;
        }

        // Create token
        const token = jwt.sign(
            payload,
            process.env.JWT_SECRET,
            { expiresIn: '1d' }
        );

        res.json({
            token,
            user: {
                id: user.id,
                name: user.name,
                username: user.username || null,
                email: user.email,
                role: user.role || userType,
                shopId: user.shop_id || null
            }
        });
    } catch (error) {
        console.error(error);
        res.status(500).json({ message: 'Server error' });
    }
};
exports.updateProfile = async (req, res) => {
    try {
        const userId = req.user.id;
        const { name, email, profile_picture } = req.body;

        await db.execute(
            'UPDATE users SET name = ?, email = ?, profile_picture = ? WHERE id = ?',
            [name, email, profile_picture || null, userId]
        );

        res.json({ message: 'Profile updated successfully' });
    } catch (error) {
        console.error(error);
        res.status(500).json({ message: 'Server error' });
    }
};

exports.forgotPassword = async (req, res) => {
    try {
        const { email } = req.body;
        const [users] = await db.execute('SELECT id FROM users WHERE email = ?', [email]);

        if (users.length === 0) {
            // Send same message for security
            return res.json({ message: 'If an account exists, a reset link/code has been activated.' });
        }

        const token = crypto.randomBytes(20).toString('hex');
        const expires = new Date(Date.now() + 3600000); // 1 hour

        await db.execute(
            'UPDATE users SET reset_token = ?, reset_expires = ? WHERE email = ?',
            [token, expires, email]
        );

        const frontendUrl = process.env.FRONTEND_ORIGIN || 'https://lenden.cyberslayersagency.com';
        const resetLink = `${frontendUrl}/#/reset-password?email=${email}&token=${token}`;

        const emailBody = getEmailTemplate(
            'Reset Password Request',
            `<p>We received a request to reset the password for your Lenden account.</p>
             <p>If you made this request, click the button below to set a new password. This link will expire in 1 hour.</p>`,
            'Reset My Password',
            resetLink,
            'If you did not request a password reset, no further action is required and your account remains secure.'
        );

        await sendEmail(email, 'Reset your Lenden Password', emailBody);

        res.json({
            message: 'Reset link/code activated.',
            debugToken: process.env.NODE_ENV === 'development' ? token : undefined
        });
    } catch (error) {
        console.error(error);
        res.status(500).json({ message: 'Server error' });
    }
};

exports.resetPassword = async (req, res) => {
    try {
        const { email, token, recoveryCode, newPassword } = req.body;
        let query = '';
        let params = [];

        if (token) {
            query = 'SELECT * FROM users WHERE email = ? AND reset_token = ? AND reset_expires > NOW()';
            params = [email, token];
        } else if (recoveryCode) {
            query = 'SELECT * FROM users WHERE email = ? AND recovery_code = ?';
            params = [email, recoveryCode];
        } else {
            return res.status(400).json({ message: 'Token or recovery code required' });
        }

        const [users] = await db.execute(query, params);
        if (users.length === 0) {
            return res.status(400).json({ message: 'Invalid or expired reset credentials' });
        }

        const salt = await bcrypt.genSalt(10);
        const hashedPassword = await bcrypt.hash(newPassword, salt);

        await db.execute(
            'UPDATE users SET password = ?, reset_token = NULL, reset_expires = NULL WHERE id = ?',
            [hashedPassword, users[0].id]
        );

        // Send in-app notification
        const { createPasswordResetNotification } = require('../services/notificationService');
        try {
            // Find shop id for the user
            const [shops] = await db.execute('SELECT id FROM shops WHERE owner_id = ?', [users[0].id]);
            if (shops.length > 0) {
                await createPasswordResetNotification({ user_id: users[0].id, shop_id: shops[0].id });
            }
        } catch (notifError) {
            console.error('Failed to create password reset notification:', notifError);
        }

        res.json({ message: 'Password reset successfully' });
    } catch (error) {
        console.error(error);
        res.status(500).json({ message: 'Server error' });
    }
};

exports.changePassword = async (req, res) => {
    try {
        const userId = req.user.id;
        const userRole = req.user.role;
        const { oldPassword, newPassword } = req.body;

        const table = userRole === 'owner' || userRole === 'admin' ? 'users' : 'staff';
        const [users] = await db.execute(`SELECT password FROM ${table} WHERE id = ?`, [userId]);

        if (users.length === 0) return res.status(404).json({ message: 'User not found' });

        const isMatch = await bcrypt.compare(oldPassword, users[0].password);
        if (!isMatch) return res.status(400).json({ message: 'Current password incorrect' });

        const salt = await bcrypt.genSalt(10);
        const hashedPassword = await bcrypt.hash(newPassword, salt);

        await db.execute(`UPDATE ${table} SET password = ? WHERE id = ?`, [hashedPassword, userId]);

        res.json({ message: 'Password changed successfully' });
    } catch (error) {
        console.error(error);
        res.status(500).json({ message: 'Server error' });
    }
};

exports.verifyEmail = async (req, res) => {
    try {
        const { token } = req.params;
        const [users] = await db.execute('SELECT id FROM users WHERE verification_token = ?', [token]);

        if (users.length === 0) {
            return res.status(400).json({ message: 'Invalid or expired verification token.' });
        }

        await db.execute(
            'UPDATE users SET is_verified = 1, verification_token = NULL WHERE id = ?',
            [users[0].id]
        );

        res.json({ message: 'Email verified successfully! You can now log in.' });
    } catch (error) {
        console.error(error);
        res.status(500).json({ message: 'Server error' });
    }
};

exports.resendVerification = async (req, res) => {
    try {
        const { email } = req.body;
        const [users] = await db.execute('SELECT id, is_verified FROM users WHERE email = ?', [email]);

        if (users.length === 0) return res.status(404).json({ message: 'User not found' });
        if (users[0].is_verified) return res.status(400).json({ message: 'Account already verified' });

        const token = crypto.randomBytes(32).toString('hex');
        await db.execute('UPDATE users SET verification_token = ? WHERE id = ?', [token, users[0].id]);

        // Send Verification Email
        const frontendUrl = process.env.FRONTEND_ORIGIN || 'https://lenden.cyberslayersagency.com';
        const verificationLink = `${frontendUrl}/#/verify-email/${token}`;

        const emailBody = getEmailTemplate(
            'New Verification Link',
            `<p>Hello,</p>
             <p>As requested, here is a new link to verify your Lenden account.</p>
             <p>Click the button below to complete your verification and start managing your shop.</p>`,
            'Verify Now',
            verificationLink
        );

        await sendEmail(email, 'Verify your Lenden Account', emailBody);

        res.json({
            message: 'Verification email resent.',
            debugToken: process.env.NODE_ENV === 'development' ? token : undefined
        });
    } catch (error) {
        console.error(error);
        res.status(500).json({ message: 'Server error' });
    }
};

exports.getRecoveryCode = async (req, res) => {
    try {
        const userId = req.user.id;
        const [users] = await db.execute('SELECT recovery_code FROM users WHERE id = ?', [userId]);

        if (users.length === 0) return res.status(404).json({ message: 'User not found' });

        let code = users[0].recovery_code;

        // If no code exists (legacy user), generate one now
        if (!code) {
            code = Math.random().toString(36).substring(2, 10).toUpperCase();
            await db.execute('UPDATE users SET recovery_code = ? WHERE id = ?', [code, userId]);
        }

        res.json({ recovery_code: code });
    } catch (error) {
        console.error(error);
        res.status(500).json({ message: 'Server error' });
    }
};

exports.uploadAvatar = async (req, res) => {
    try {
        if (!req.file) {
            return res.status(400).json({ message: 'No file uploaded' });
        }

        const userId = req.user.id;
        const avatarUrl = `/uploads/avatars/${req.file.filename}`;

        // Update user avatar in database
        await db.execute(
            'UPDATE users SET avatar_url = ? WHERE id = ?',
            [avatarUrl, userId]
        );

        res.json({
            message: 'Avatar uploaded successfully',
            avatarUrl
        });
    } catch (error) {
        console.error('Avatar upload error:', error);
        res.status(500).json({ message: 'Failed to upload avatar' });
    }
};
