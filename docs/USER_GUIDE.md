# NexxStore User Guide

## Overview

NexxStore is a modern inventory management application designed to streamline stock tracking, sales processing, and invoice generation. This guide will help you get started with the application and perform day-to-day operations.

## Table of Contents

1. [Installation](#installation)
2. [Getting Started](#getting-started)
3. [Core Features](#core-features)
4. [User Management](#user-management)
5. [Inventory Management](#inventory-management)
6. [Sales & Stock-Out Operations](#sales--stock-out-operations)
7. [Invoice Generation](#invoice-generation)
8. [Device Synchronization](#device-synchronization)
9. [Troubleshooting](#troubleshooting)

## Installation

### For Windows Users
Refer to the [Windows Setup Guide](SETUP_GUIDE_WINDOWS) for detailed installation instructions.

### For Android Users
Refer to the [Android Setup Guide](SETUP_GUIDE_ANDROID) for detailed installation instructions.

### Downloading NexxStore
- **Windows & Android:** Download from [GitHub Releases](https://github.com/Genocadio/PharmacyApp/releases)

## Getting Started

### Initial Login
1. Launch NexxStore
2. Enter your provided credentials (username/email and password)
3. If this is your first login, you may be prompted to activate your device
4. Follow the on-screen prompts for device activation

### Device Activation
- Your pharmacy device must be activated to sync with the backend
- You'll receive an activation code from your administrator
- The activation process is secure and requires authentication
- Once activated, your device can synchronize data with the NexxStore backend

### First-Time Setup
1. Configure your pharmacy details in Settings
2. Set your preferred invoice format (A4, 80mm, or 57mm receipt)
3. Import your initial product catalog (if applicable)
4. Verify your network connectivity for synchronization

## Core Features

### Dashboard
- View quick statistics on inventory levels
- See recent transactions
- Access quick-action buttons for common operations

### Inventory Management
- **View Products:** Browse your pharmacy catalog with stock levels
- **Search:** Quickly find products by name, code, or category
- **Categories:** Organize products by type or therapeutic class
- **Stock Updates:** Track stock movements in real-time

### Sales Processing
The app supports three distinct inventory management modes:

#### Retail Mode
- Process individual customer sales
- Track discounts and pricing adjustments
- Generate retail receipts

#### Wholesale Mode
- Handle bulk orders and distributor sales
- Apply wholesale pricing automatically
- Manage large quantity transactions and invoices

#### Clinic Mode
- Process internal clinic consumption
- Track medication distribution within facility
- Maintain clinic inventory records

### Insurance Management
The system can handle insurance-split transactions where applicable, allowing you to track which portions of sales are covered by insurance or paid out-of-pocket.

## User Management

### User Roles
NexxStore supports different user roles with varying permissions:
- **Administrator:** Full system access, user management, configuration
- **Staff:** Standard operations, sales processing, inventory viewing
- **Viewer:** Read-only access to reports and statistics

### Managing Users (Administrator only)
1. Navigate to Settings → User Management
2. Click "Add User"
3. Enter user details (name, email, role, permissions)
4. Set initial password
5. Assign to pharmacy location/device

### Changing Your Password
1. Go to Settings → Account
2. Click "Change Password"
3. Enter current password
4. Enter new password (min 8 characters, include uppercase, lowercase, numbers)
5. Confirm new password

## Inventory Management

### Adding Products
1. Navigate to Inventory → Products
2. Click "Add Product"
3. Fill in required information:
   - Product name
   - SKU/Medicine code
   - Category
   - Cost price
   - Selling price
   - Initial stock quantity
4. Click "Save"

### Stock-In (Receiving Stock)
1. Go to Inventory → Stock In
2. Click "New Stock In"
3. Select supplier (if applicable)
4. Click "Add Item"
5. Select product and enter quantity
6. Review purchase details
7. Click "Confirm Stock In"
8. Stock levels update immediately

### Stock-Out (Sales Transactions)
See the [Sales & Stock-Out Operations](#sales--stock-out-operations) section below.

### Low Stock Alerts
- Products below minimum stock level show warnings
- Configure minimum stock levels in Product settings
- Receive notifications when stock is low
- Dashboard highlights at-risk items

## Sales & Stock-Out Operations

### Processing a Sale

1. Go to Sales → New Sale
2. Select the inventory mode:
   - **Retail:** For individual customer sales
   - **Wholesale:** For bulk/distributor orders
   - **Clinic:** For internal facility consumption
3. Click "Add Item" to add products:
   - Search for product by name or code
   - Enter quantity sold
   - System shows stock availability
4. Review transaction details:
   - Total amount
   - Any applicable discounts
   - Insurance split (if applicable)
5. Select customer (if applicable)
6. Choose payment method
7. Click "Complete Sale"
8. System generates invoice/receipt automatically

### Applying Discounts
1. In the sales screen, click "Add Discount"
2. Choose discount type:
   - Percentage (e.g., 10%)
   - Fixed amount
   - Loyalty/customer discount
3. Enter discount value
4. Review updated total
5. Complete sale

### Refunds and Adjustments
1. Navigate to Sales → History
2. Find the transaction to adjust
3. Click "Options" → "Create Return"
4. Enter return quantity
5. Confirm return
6. Stock and accounts automatically adjusted

## Invoice Generation

### Understanding Invoice Formats

**A4 Format**
- Full-page invoice
- Detailed transaction information
- Suitable for records and customer copies
- Includes company header and terms

**80mm Receipt**
- Standard receipt paper width
- Compact format for retail
- Ideal for quick printouts
- Includes basic transaction details

**57mm Receipt**
- Smaller receipt paper width
- Minimal information
- Used for mobility/portability

### Generating an Invoice
1. After completing a sale, you'll see "Generate Invoice" option
2. Select desired format (A4, 80mm, or 57mm)
3. Click "Preview" to review before printing
4. Click "Print" to send to printer
5. Click "Download" to save as PDF

### Invoice Contents
- Pharmacy details (name, address, phone)
- Transaction date and time
- Itemized product list with quantities and prices
- Subtotal, taxes (if applicable), and total amount
- Payment method
- Customer details (if applicable)
- Receipt/Invoice number

## Device Synchronization

### What Gets Synchronized
- Sales transactions
- Stock movements
- User activity logs
- Inventory updates
- Device status reports

### Manual Synchronization
1. Go to Settings → Sync
2. Click "Sync Now"
3. Wait for sync to complete
4. Confirm successful sync message

### Automatic Synchronization
- Runs periodically (default: every 15 minutes)
- Requires internet connectivity
- Can be disabled in Settings if needed
- Battery-friendly on mobile devices

### Checking Sync Status
1. Go to Settings → Device Status
2. View last sync time
3. See any pending items
4. Check connectivity status

### Offline Mode
- NexxStore continues working offline
- All transactions are stored locally
- Data syncs automatically when connection returns
- No data loss in offline mode

## Troubleshooting

### Login Issues
**Problem:** Cannot log in
- **Solution 1:** Verify username and password are correct
- **Solution 2:** Check internet connection
- **Solution 3:** Reset password via "Forgot Password" link
- **Solution 4:** Contact administrator if device not activated

### Sync Issues
**Problem:** Data not syncing
- **Check List:**
  - Verify internet connection is active
  - Go to Settings → Sync → Retry
  - Check if device is still activated
  - Restart the application
  - Check system logs for errors

### Printing Issues
**Problem:** Cannot print invoices
- **Solution 1:** Verify printer is connected and powered on
- **Solution 2:** Check printer settings in Settings → Printing
- **Solution 3:** Try printing in different format (A4, 80mm, 57mm)
- **Solution 4:** Download PDF and print manually
- **Solution 5:** Check printer drivers are up to date



### Performance Issues
**Problem:** App is slow or unresponsive
- **Solution 1:** Restart the application
- **Solution 2:** Clear cache (Settings → Advanced → Clear Cache)
- **Solution 3:** Ensure device has sufficient free storage
- **Solution 4:** Update to latest version
- **Solution 5:** Contact support if problems continue

## Support

For additional help:
- Request activation credentials: yvesgeno@outlook.com
- Check the [Programming Guide](PROGRAMMING_GUIDE.md) for technical details
- Review the [Database Architecture](DATABASE_ARCHITECTURE.md) for data structure information
- Repository: [GitHub](https://github.com/Genocadio/PharmacyApp)

---

**NexxStore v1.0.0** | Last Updated: March 2026
