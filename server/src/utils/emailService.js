const nodemailer = require('nodemailer');
require('dotenv').config();

const transporter = nodemailer.createTransport({
    host: process.env.EMAIL_HOST,
    port: parseInt(process.env.EMAIL_PORT || '465'),
    secure: process.env.EMAIL_SECURE === 'true' || process.env.EMAIL_PORT === '465',
    auth: {
        user: process.env.EMAIL_USER,
        pass: process.env.EMAIL_PASS
    },
    tls: {
        // Do not fail on invalid certs (common in shared hosting)
        rejectUnauthorized: false
    }
});

const getEmailTemplate = (title, content, buttonText, buttonLink, footerNote = '') => {
    return `
    <!DOCTYPE html>
    <html>
    <head>
        <meta charset="utf-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>${title}</title>
        <style>
            body { font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; line-height: 1.6; color: #1e293b; margin: 0; padding: 0; background-color: #f8fafc; }
            .container { max-width: 600px; margin: 40px auto; background: #ffffff; border-radius: 16px; overflow: hidden; shadow: 0 4px 6px -1px rgb(0 0 0 / 0.1); border: 1px solid #e2e8f0; }
            .header { background: linear-gradient(135deg, #2563eb 0%, #1d4ed8 100%); padding: 40px 20px; text-align: center; color: #ffffff; }
            .logo-icon { font-size: 48px; margin-bottom: 10px; }
            .content { padding: 40px; }
            .title { font-size: 24px; font-weight: 700; color: #0f172a; margin-bottom: 20px; }
            .message { color: #475569; margin-bottom: 30px; font-size: 16px; }
            .button-container { text-align: center; margin: 35px 0; }
            .button { background-color: #2563eb; color: #ffffff !important; padding: 14px 32px; border-radius: 10px; text-decoration: none; font-weight: 600; font-size: 16px; display: inline-block; transition: background-color 0.2s; }
            .footer { background-color: #f1f5f9; padding: 25px; text-align: center; font-size: 13px; color: #64748b; }
            .link-fallback { font-size: 12px; color: #94a3b8; margin-top: 20px; word-break: break-all; }
            .social-links { margin-top: 15px; }
            .hr { border: 0; border-top: 1px solid #e2e8f0; margin: 20px 0; }
        </style>
    </head>
    <body>
        <div class="container">
            <div class="header">
                <div class="logo-icon">🏪</div>
                <h1 style="margin: 0; font-size: 28px; letter-spacing: -0.5px;">Lenden</h1>
                <p style="margin: 5px 0 0 0; opacity: 0.9; font-size: 14px;">Premium Shop Management</p>
            </div>
            <div class="content">
                <div class="title">${title}</div>
                <div class="message">${content}</div>
                
                ${buttonText ? `
                <div class="button-container">
                    <a href="${buttonLink}" class="button">${buttonText}</a>
                </div>
                ` : ''}

                <div class="hr"></div>
                <p style="font-size: 14px; color: #64748b;">${footerNote || 'If you have any questions, feel free to reply to this email or contact our support team.'}</p>
                
                <div class="link-fallback">
                    Trouble clicking the button? Copy and paste this link into your browser:<br>
                    <a href="${buttonLink}" style="color: #2563eb;">${buttonLink}</a>
                </div>
            </div>
            <div class="footer">
                <p>&copy; ${new Date().getFullYear()} Lenden POS. All rights reserved.</p>
                <div class="social-links">
                    <a href="#" style="color: #64748b; text-decoration: none; margin: 0 10px;">Terms</a>
                    <a href="#" style="color: #64748b; text-decoration: none; margin: 0 10px;">Privacy</a>
                    <a href="#" style="color: #64748b; text-decoration: none; margin: 0 10px;">Support</a>
                </div>
            </div>
        </div>
    </body>
    </html>
    `;
};

/**
 * Send an email with improved error handling
 */
const sendEmail = async (to, subject, html) => {
    // Validate email address
    if (!to || !to.includes('@')) {
        console.error('❌ Invalid email address:', to);
        return false;
    }

    // Validate SMTP configuration
    if (!process.env.EMAIL_USER || !process.env.EMAIL_PASS || !process.env.EMAIL_HOST) {
        console.error('❌ Email configuration missing in .env file');
        console.error('Required: EMAIL_HOST, EMAIL_USER, EMAIL_PASS');

        // In development, log email content instead of failing
        if (process.env.NODE_ENV === 'development') {
            console.log('\n📧 [DEV MODE] Email would be sent:');
            console.log('To:', to);
            console.log('Subject:', subject);
            console.log('Preview:', html.substring(0, 200) + '...');
            return true; // Return true in dev mode for testing
        }

        return false;
    }

    try {
        console.log(`📧 Attempting to send email to: ${to}`);
        console.log(`📬 Subject: ${subject}`);

        const info = await transporter.sendMail({
            from: `"${process.env.EMAIL_FROM_NAME || 'Lenden Support'}" <${process.env.EMAIL_FROM_ADDRESS || process.env.EMAIL_USER}>`,
            to,
            subject,
            html
        });

        console.log('✅ Email sent successfully!');
        console.log('📨 Message ID:', info.messageId);
        console.log('📤 Response:', info.response);

        return true;
    } catch (error) {
        console.error('❌ Email send error:');
        console.error('Error message:', error.message);
        console.error('Error code:', error.code);

        // Log specific SMTP errors
        if (error.code === 'EAUTH') {
            console.error('⚠️  Authentication failed - check EMAIL_USER and EMAIL_PASS');
        } else if (error.code === 'ECONNECTION') {
            console.error('⚠️  Connection failed - check EMAIL_HOST and EMAIL_PORT');
        } else if (error.code === 'ETIMEDOUT') {
            console.error('⚠️  Connection timeout - check network/firewall settings');
        }

        // In development, don't fail completely
        if (process.env.NODE_ENV === 'development') {
            console.log('⚠️  [DEV MODE] Email failed but continuing...');
            return true;
        }

        return false;
    }
};

module.exports = { sendEmail, getEmailTemplate };
