# Lenden App: Security & SMTP Setup Guide

This guide explains how to set up professional email services using your cPanel hosting and how to manage fallback Recovery Codes.

## 1. Setting up SMTP on cPanel

To enable automatic "Forgot Password" emails, you need to configure your cPanel email and provide the credentials to the Lenden App.

### Step A: Create an Email Account in cPanel
1. Log in to your **cPanel**.
2. Search for **"Email Accounts"** and click it.
3. Click **"+ Create"**.
4. Enter a username (e.g., `noreply` or `support`).
5. Set a strong password.
6. Click **"Create"**.

### Step B: Get SMTP Settings
1. In the "Email Accounts" list, find your new email and click **"Connect Devices"**.
2. Look for the **"Mail Client Manual Settings"** section.
3. You will need the following details (use the **Secure SSL/TLS Settings**):
   - **Incoming/Outgoing Server**: (Usually `mail.yourdomain.com`)
   - **SMTP Port**: `465`
   - **Encryption**: `SSL/TLS`

### Step C: Update `.env` File
Once you have these details, update your `server/.env` file:
```env
EMAIL_HOST=mail.yourdomain.com
EMAIL_PORT=465
EMAIL_USER=noreply@yourdomain.com
EMAIL_PASS=your_email_password
```
*(Note: I have prepared the code to use these variables once you are ready).*

---

## 2. Recovery Codes (Owner Fallback)

Recovery Codes are a 8-character "Master Key" for the Shop Owner. If your email service is down or you lose access, you can use this code to reset your password.

### Where to find my Recovery Code?
1. Log in to the Lenden App as the **Owner**.
2. Go to **Settings** -> **Security**.
3. Under "Account Recovery", you will see your unique **Recovery Code**.
4. **Action Required**: Copy this code and store it in a safe place (like a notebook or a password manager).

### How to use it?
1. On the **Login Page**, click **"Forgot?"**.
2. Select the **"Recovery Code"** tab.
3. Enter your email and your 8-character code.
4. You will be redirected to set a new password immediately.

> [!WARNING]
> Do not share your Recovery Code with staff members. This code allows full access to the Owner account.
