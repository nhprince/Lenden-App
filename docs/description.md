# 🏪 Lenden App - Project Description

**Lenden** is a comprehensive, production-ready SaaS application designed for managing multiple retail businesses from a single account. It is built to serve small to medium-sized business owners in Bangladesh, offering a unified platform to handle sales, inventory, customers, and employees across various shop types (e.g., Bike Showrooms, Garage, General Stores).

## 🚀 Key Features

### 1. Multi-Shop Management (SaaS Core)
*   **Unified Account:** A single owner can create and manage unlimited shops.
*   **Seamless Switching:** Switch between shops instantly without re-logging.
*   **Data Isolation:** Strict separation of data (products, customers, transactions) per shop.
*   **Customizable Profiles:** Each shop has its own logo, contact details, and invoice settings.

### 2. Point of Sale (POS) & Billing
*   **Fast Checkout:** Optimized for speed with barcode/SKU search (future ready) and product auto-complete.
*   **Cart System:** Real-time subtotal, discount, and tax calculations.
*   **Flexible Payments:** Support for Cash, Card, Mobile Banking (bKash, Nagad), and Due/Credit sales.
*   **Invoice Generation:** Professional, printable invoices with QR codes and customizable footers.

### 3. Inventory Management
*   **Product Tracking:** Manage stock levels, cost prices, and selling prices.
*   **Low Stock Alerts:** Dashboard warnings when products fall below a specific quantity.
*   **Specialized Fields:** Support for Engine No., Chassis No., and Model Year (crucial for bike/vehicle shops).
*   **Categories:** Organize products into logical categories for better reporting.

### 4. Financial Management & Accounting
*   **Due Management (বাকি):** specialized ledger for tracking customer debts and collections.
*   **Expense Tracking:** Record daily operating expenses (rent, bill, salary) by category.
*   **Profit/Loss Analysis:** Real-time calculation of Gross and Net profit based on COGS (Cost of Goods Sold).
*   **Transaction History:** Complete audit trail of every sale, purchase, expense, and payment.

### 5. Staff & Security
*   **Role-Based Access Control (RBAC):**
    *   **Owner:** Full access to all shops and settings.
    *   **Staff:** Restricted access (assigned to specific shops, limited permissions).
*   **Granular Permissions:** Owners can enable/disable specific actions for staff (e.g., "Can delete products?", "Can view reports?").
*   **Activity Logs:** Track who performed which transaction.

### 6. Reporting & Analytics
*   **Visual Dashboard:** At-a-glance view of Today's Sales, Inventory Value, and Total Due.
*   **Interactive Charts:** 7-day sales trends, category distribution, and order volume.
*   **Exportable Reports:** Download detailed sales, expense, and inventory reports (Excel/PDF).
*   **Date Filtering:** Custom date ranges for all financial reports.

### 7. User Experience & Localization
*   **Dual Language Support:** Full interface translation for **English** and **Bangla**.
*   **Responsive Design:** Fully functional on Desktops, Tablets, and Mobiles.
*   **Dark Mode:** Built-in theme switching for comfortable usage in low light.
*   **Offline Resilience:** (Planned) Capability to work with intermittent internet.

---

## 🛠️ Technical Architecture

### Frontend (Client)
*   **Framework:** React 19 (Functional Components, Hooks) using Vite.
*   **Language:** TypeScript for robust type safety.
*   **Styling:** Tailwind CSS + Framer Motion for animations.
*   **State Management:** React Context API (StoreProvider) for global state (Auth, Shop, Theme).
*   **Routing:** React Router DOM (HashRouter for cPanel compatibility).
*   **HTTP Client:** Axios with interceptors for JWT token handling and error management.
*   **Build:** Optimized production build with code splitting and lazy loading.

### Backend (Server)
*   **Runtime:** Node.js with Express.js 5.
*   **Database:** MySQL 8.0 (Relational Data Model).
*   **Authentication:** JWT (JSON Web Tokens) with secure HTTP-only practices.
*   **Security:**
    *   `bcryptjs` for password hashing.
    *   `express-rate-limit` for DDoS protection.
    *   `helmet` & `cors` for HTTP security headers.
    *   Parameterized SQL queries to prevent Injection attacks.
*   **Email Service:** Nodemailer integrated with SMTP (cPanel) for verification and resets.
*   **Architecture:** MVC-like structure (Controllers, Routes, Utils).

### Database Schema (MySQL)
The application uses a normalized relational schema with 10+ core tables including:
*   `users` & `shops` (Tenancy management).
*   `products`, `stock`, `categories` (Inventory).
*   `transactions`, `transaction_items` (Financials - atomic ACID transactions).
*   `customers`, `vendors` (CRM).
*   `staff` (Employee management).

---

## 🔒 Security Measures
1.  **Input Validation:** Server-side validation using `express-validator`.
2.  **Access Control:** Middleware checks for valid JWT and ensures users only access shops they own/work for.
3.  **Data Integrity:** SQL Foreign Keys with CASCADE rules to maintain data consistency.
4.  **Rate Limiting:** Protects authentication endpoints from brute-force attacks.

## 🔮 Future Roadmap
*   **Mobile App:** Dedicated Flutter app for iOS and Android.
*   **Barcode Scanning:** Native camera integration for easier checkout.
*   **Advanced Analytics:** AI-driven insights for stock forecasting.
