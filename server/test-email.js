require('dotenv').config();
const nodemailer = require('nodemailer');

async function testEmail() {
    console.log('📧 Testing Email Configuration...');
    console.log('--------------------------------');
    console.log(`Host: ${process.env.EMAIL_HOST}`);
    console.log(`Port: ${process.env.EMAIL_PORT}`);
    console.log(`User: ${process.env.EMAIL_USER}`);
    console.log(`Secure: ${process.env.EMAIL_SECURE}`);
    console.log(`From: ${process.env.EMAIL_FROM_ADDRESS || process.env.EMAIL_USER}`);
    console.log('--------------------------------');

    if (!process.env.EMAIL_PASS) {
        console.error('❌ Error: EMAIL_PASS is missing in .env');
        process.exit(1);
    }

    try {
        const transporter = nodemailer.createTransport({
            host: process.env.EMAIL_HOST,
            port: parseInt(process.env.EMAIL_PORT || '465'),
            secure: process.env.EMAIL_SECURE === 'true' || process.env.EMAIL_PORT === '465',
            auth: {
                user: process.env.EMAIL_USER,
                pass: process.env.EMAIL_PASS
            },
            tls: {
                rejectUnauthorized: false
            },
            debug: true // Enable debug output
        });

        // Verify connection configuration
        console.log('🔄 Verifying SMTP connection...');
        await transporter.verify();
        console.log('✅ SMTP Connection verified successfully!');

        // Send test email
        console.log('📨 Sending test email...');
        const info = await transporter.sendMail({
            from: `"${process.env.EMAIL_FROM_NAME || 'Test'}" <${process.env.EMAIL_FROM_ADDRESS || process.env.EMAIL_USER}>`,
            to: process.env.EMAIL_USER, // Send to self
            subject: "Lenden App - SMTP Test",
            text: "If you receive this, your email configuration is working correctly!",
            html: "<b>If you receive this, your email configuration is working correctly!</b>"
        });

        console.log('✅ Email sent successfully!');
        console.log(`🆔 Message ID: ${info.messageId}`);
        console.log(`📤 Response: ${info.response}`);

    } catch (error) {
        console.error('❌ Email Test Failed!');
        console.error('Error:', error.message);
        if (error.code) console.error('Code:', error.code);
        if (error.command) console.error('Command:', error.command);
    }
}

testEmail();
