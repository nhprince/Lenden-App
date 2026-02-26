🧠 PROJECT OVERVIEW

This project is a complete multi-shop business management application designed for a single business owner who operates multiple different businesses under one account.

Each business is managed as a separate shop, with completely isolated data, while allowing the owner to switch between shops instantly.

The system is built to simplify হিসাব (accounts), স্টক (inventory), লেনদেন (transactions), এবং রিপোর্টিং, even when the businesses are of different types such as bike sales, garage service, furniture manufacturing, showroom sales, and pickup rental.

🎯 CORE GOAL

Create a simple, powerful, and reliable business management system that allows:

One owner account

Multiple shops under that account

Each shop having its own business type

Separate stock, customers, vendors, and reports per shop

Easy switching between shops

Clear financial visibility per business

প্রতিটি দোকান আলাদা থাকবে, কিন্তু সবগুলো এক অ্যাকাউন্ট থেকেই ম্যানেজ করা যাবে।

👤 USER & ROLE STRUCTURE
Owner (Primary User)

Can create and manage multiple shops

Can switch between shops

Full access to all data of owned shops

Staff / Seller

Assigned per shop

Can only access the shop they are assigned to

Permissions:

Sales

Stock updates

Service entries (as allowed)

🏗️ SHOP & DATA STRUCTURE
Multi-Shop Model

One user account → many shops

Each shop has:

Unique shop name

Business type (bike sales, garage, furniture, etc.)

Completely separate data

Data Isolation (Very Important)

Each shop maintains its own:

Products & services

Stock

Customers

Vendors

Transactions

Reports

Due & payments

No data is shared between shops.

🔄 SHOP SWITCHING SYSTEM

Owner sees a shop switcher in header/sidebar

Switching a shop:

Instantly loads that shop’s dashboard

Changes all data context (sales, stock, reports)

Staff users do not see shop switcher unless assigned to multiple shops

📊 DASHBOARD (PER SHOP)

Each shop has its own dashboard, showing:

Today’s income & expense

Cash vs Due (বাকি)

Total transactions

Vendor payable

Low stock alerts

Business-specific indicators
(e.g., service jobs for garage, trips for pickup rental)

🧩 BUSINESS MODULES (CLIENT REQUIREMENTS)

Each shop can be configured with one or more of the following modules, depending on the business type.

1️⃣ Reconditioned Bike Sales Shop

Bike inventory (engine no, chassis no, cost, selling price)

Purchase & sales records

Profit per bike

Due / installment support

Customer ledger

2️⃣ Bike Garage & Parts Shop

Service booking & service history

Parts stock (oil, brake, chain, etc.)

Labor + parts invoice

Vendor parts purchase

Service reminders

3️⃣ Board Furniture Factory

Raw material stock

Finished product inventory

Production cost tracking

Sales & delivery records

Profit calculation

4️⃣ Showroom Shop

Product categories (TV, fridge, mobile, fan, rack, furniture)

Stock management

Sales invoice (print/share)

Due / installment selling

Customer management

5️⃣ Due / Credit (ঢাব) Handling

Customer due tracking

Payment collection records

Due history

Reminder alerts

(Used across all shops where credit sales exist)

6️⃣ Pickup Rental / Service Shop

Vehicle list

Trip records

Rental charges

Fuel & maintenance expenses

Customer & due tracking

🧾 SALES, INVOICE & TRANSACTIONS

Fast sales entry

Cash / Due / Partial payment

Auto invoice generation

Print & share options

Accurate stock deduction

Transaction history per shop

📦 STOCK & VENDOR MANAGEMENT

Separate stock per shop

Vendor accounts per shop

Purchase & payable tracking

Low stock alerts

🔔 REMINDERS & NOTIFICATIONS

Due payment reminders

Service follow-ups

Stock shortage alerts

Pickup service reminders

📑 REPORTING & EXPORT

Daily / Monthly / Custom reports

Sales, profit, due, expense, vendor reports

Export to Excel / PDF

Filter by date & category

Reports are shop-specific

🛠 TECHNICAL ARCHITECTURE (CLIENT APP)
Backend

Node.js + Express.js

MySQL

JWT Authentication

Shop-scoped API structure

Clean separation of shop data

Frontend

React + Vite

Tailwind CSS

Modern, minimal UI

Desktop-first, POS-friendly

📱 FUTURE ANDROID SUPPORT (PLANNED)

Backend APIs designed to be Flutter-ready

Same endpoints for Web & Android

Token-based authentication

No browser-only dependency

🧠 DESIGN PHILOSOPHY

Simple & professional

Easy for non-technical users

No unnecessary features

Fast daily operations

Trustworthy financial interface

🏁 FINAL RESULT

A single, unified application where:

One owner manages multiple different businesses

Each business is handled as a separate shop

Data never mixes

Switching between shops is easy

All core accounting, stock, and operations are covered

একটা অ্যাপ – অনেকগুলো দোকান – সব হিসাব ক্লিয়ার।

