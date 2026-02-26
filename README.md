# Lenden App - Multi-Shop Business Management System

A comprehensive business management solution for owners with multiple shops (Bike Sales, Garage, Showroom, Rentals, etc.).

## 🚀 Quick Start (Local Development)

1.  **Install Dependencies:**
    ```bash
    npm install
    npm run install-all
    ```

2.  **Database Setup:**
    *   Ensure MySQL is running.
    *   Create a database named `lenden_db`.
    *   Import `server/schema.sql` into the database.
    *   Update `server/.env` with your DB credentials.

3.  **Run Application:**
    ```bash
    npm run dev
    ```
    *   Frontend: `http://localhost:5173`
    *   Backend: `http://localhost:5000`

## 🐳 Deployment (Docker)

The easiest way to deploy is using Docker Compose.

1.  **Run:**
    ```bash
    docker-compose up --build -d
    ```
2.  The application will be available at `http://localhost:5000`.

## 🏗 Features

*   **Multi-Shop Management:** Manage unlimited shops from one unified dashboard.
*   **Persistent Navigation:** Stable, non-reloading sidebar for seamless multitasking.
*   **Intelligent Inventory:** Track stock with Engine/Chassis number support and low-stock alerts.
*   **Advanced POS:** Real-time cart system, searchable customers (In Progress), and professional invoicing.
*   **Financial Tracking:** Integrated expense management and performance analytics.
*   **Dual Language Support:** Full Bangla and English localization.
*   **Specialized Modules:** Garage services and rental trip records included.
*   **Android Companion App:** Full-featured Flutter application for mobile business management.
## 🛠 Tech Stack

*   **Frontend:** React, Vite, Tailwind CSS, Lucide Icons
*   **Backend:** Node.js, Express.js, MySQL
*   **Mobile:** Flutter, Riverpod, GoRouter, Dio
*   **Auth:** JWT (JSON Web Tokens)
