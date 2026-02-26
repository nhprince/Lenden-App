import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_bn.dart';
import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('bn'),
    Locale('en'),
  ];

  /// No description provided for @dashboard.
  ///
  /// In en, this message translates to:
  /// **'Dashboard'**
  String get dashboard;

  /// No description provided for @pos.
  ///
  /// In en, this message translates to:
  /// **'POS'**
  String get pos;

  /// No description provided for @inventory.
  ///
  /// In en, this message translates to:
  /// **'Inventory'**
  String get inventory;

  /// No description provided for @transactions.
  ///
  /// In en, this message translates to:
  /// **'Transactions'**
  String get transactions;

  /// No description provided for @customers.
  ///
  /// In en, this message translates to:
  /// **'Customers'**
  String get customers;

  /// No description provided for @vendors.
  ///
  /// In en, this message translates to:
  /// **'Vendors'**
  String get vendors;

  /// No description provided for @reports.
  ///
  /// In en, this message translates to:
  /// **'Reports'**
  String get reports;

  /// No description provided for @expenses.
  ///
  /// In en, this message translates to:
  /// **'Expenses'**
  String get expenses;

  /// No description provided for @services.
  ///
  /// In en, this message translates to:
  /// **'Services'**
  String get services;

  /// No description provided for @trips.
  ///
  /// In en, this message translates to:
  /// **'Rental Trips'**
  String get trips;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @staff.
  ///
  /// In en, this message translates to:
  /// **'Staff'**
  String get staff;

  /// No description provided for @purchases.
  ///
  /// In en, this message translates to:
  /// **'Purchases'**
  String get purchases;

  /// No description provided for @logout.
  ///
  /// In en, this message translates to:
  /// **'Log out'**
  String get logout;

  /// No description provided for @name.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get name;

  /// No description provided for @customer.
  ///
  /// In en, this message translates to:
  /// **'Customer'**
  String get customer;

  /// No description provided for @addNew.
  ///
  /// In en, this message translates to:
  /// **'Add New'**
  String get addNew;

  /// No description provided for @edit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @view.
  ///
  /// In en, this message translates to:
  /// **'View'**
  String get view;

  /// No description provided for @search.
  ///
  /// In en, this message translates to:
  /// **'Search...'**
  String get search;

  /// No description provided for @export.
  ///
  /// In en, this message translates to:
  /// **'Export'**
  String get export;

  /// No description provided for @print.
  ///
  /// In en, this message translates to:
  /// **'Print'**
  String get print;

  /// No description provided for @confirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get confirm;

  /// No description provided for @back.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get back;

  /// No description provided for @actions.
  ///
  /// In en, this message translates to:
  /// **'Actions'**
  String get actions;

  /// No description provided for @submit.
  ///
  /// In en, this message translates to:
  /// **'Submit'**
  String get submit;

  /// No description provided for @update.
  ///
  /// In en, this message translates to:
  /// **'Update'**
  String get update;

  /// No description provided for @searchOrType.
  ///
  /// In en, this message translates to:
  /// **'Search or type...'**
  String get searchOrType;

  /// No description provided for @newCustomerEntry.
  ///
  /// In en, this message translates to:
  /// **'New Customer Entry'**
  String get newCustomerEntry;

  /// No description provided for @allItems.
  ///
  /// In en, this message translates to:
  /// **'All Items'**
  String get allItems;

  /// No description provided for @stockValue.
  ///
  /// In en, this message translates to:
  /// **'Stock Value'**
  String get stockValue;

  /// No description provided for @profitPerUnit.
  ///
  /// In en, this message translates to:
  /// **'Profit Per Unit'**
  String get profitPerUnit;

  /// No description provided for @margin.
  ///
  /// In en, this message translates to:
  /// **'Margin'**
  String get margin;

  /// No description provided for @completeRegistration.
  ///
  /// In en, this message translates to:
  /// **'Complete Registration'**
  String get completeRegistration;

  /// No description provided for @newSale.
  ///
  /// In en, this message translates to:
  /// **'New Sale'**
  String get newSale;

  /// No description provided for @viewAll.
  ///
  /// In en, this message translates to:
  /// **'View All'**
  String get viewAll;

  /// No description provided for @walkInCustomer.
  ///
  /// In en, this message translates to:
  /// **'Walk-in Customer'**
  String get walkInCustomer;

  /// No description provided for @searchProduct.
  ///
  /// In en, this message translates to:
  /// **'Search products...'**
  String get searchProduct;

  /// No description provided for @cart.
  ///
  /// In en, this message translates to:
  /// **'Cart'**
  String get cart;

  /// No description provided for @subtotal.
  ///
  /// In en, this message translates to:
  /// **'Subtotal'**
  String get subtotal;

  /// No description provided for @discount.
  ///
  /// In en, this message translates to:
  /// **'Discount'**
  String get discount;

  /// No description provided for @tax.
  ///
  /// In en, this message translates to:
  /// **'Tax'**
  String get tax;

  /// No description provided for @total.
  ///
  /// In en, this message translates to:
  /// **'Total'**
  String get total;

  /// No description provided for @checkout.
  ///
  /// In en, this message translates to:
  /// **'Checkout'**
  String get checkout;

  /// No description provided for @payNow.
  ///
  /// In en, this message translates to:
  /// **'Pay Now'**
  String get payNow;

  /// No description provided for @paymentMethod.
  ///
  /// In en, this message translates to:
  /// **'Payment Method'**
  String get paymentMethod;

  /// No description provided for @mobilePayment.
  ///
  /// In en, this message translates to:
  /// **'Mobile Pay'**
  String get mobilePayment;

  /// No description provided for @card.
  ///
  /// In en, this message translates to:
  /// **'Card'**
  String get card;

  /// No description provided for @cash.
  ///
  /// In en, this message translates to:
  /// **'Cash'**
  String get cash;

  /// No description provided for @due.
  ///
  /// In en, this message translates to:
  /// **'Due'**
  String get due;

  /// No description provided for @paid.
  ///
  /// In en, this message translates to:
  /// **'Paid'**
  String get paid;

  /// No description provided for @change.
  ///
  /// In en, this message translates to:
  /// **'Change'**
  String get change;

  /// No description provided for @receipt.
  ///
  /// In en, this message translates to:
  /// **'Receipt'**
  String get receipt;

  /// No description provided for @saleComplete.
  ///
  /// In en, this message translates to:
  /// **'Sale Completed'**
  String get saleComplete;

  /// No description provided for @items.
  ///
  /// In en, this message translates to:
  /// **'Items'**
  String get items;

  /// No description provided for @quantity.
  ///
  /// In en, this message translates to:
  /// **'Qty'**
  String get quantity;

  /// No description provided for @price.
  ///
  /// In en, this message translates to:
  /// **'Price'**
  String get price;

  /// No description provided for @stock.
  ///
  /// In en, this message translates to:
  /// **'Stock'**
  String get stock;

  /// No description provided for @outOfStock.
  ///
  /// In en, this message translates to:
  /// **'Out of Stock'**
  String get outOfStock;

  /// No description provided for @lowStock.
  ///
  /// In en, this message translates to:
  /// **'Low Stock'**
  String get lowStock;

  /// No description provided for @addToCart.
  ///
  /// In en, this message translates to:
  /// **'Add to Cart'**
  String get addToCart;

  /// No description provided for @clearCart.
  ///
  /// In en, this message translates to:
  /// **'Clear Cart'**
  String get clearCart;

  /// No description provided for @note.
  ///
  /// In en, this message translates to:
  /// **'Note'**
  String get note;

  /// No description provided for @completed.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get completed;

  /// No description provided for @pending.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get pending;

  /// No description provided for @cancelled.
  ///
  /// In en, this message translates to:
  /// **'Cancelled'**
  String get cancelled;

  /// No description provided for @bkash.
  ///
  /// In en, this message translates to:
  /// **'bKash'**
  String get bkash;

  /// No description provided for @bank.
  ///
  /// In en, this message translates to:
  /// **'Bank Transfer'**
  String get bank;

  /// No description provided for @addProduct.
  ///
  /// In en, this message translates to:
  /// **'Add Product'**
  String get addProduct;

  /// No description provided for @editProduct.
  ///
  /// In en, this message translates to:
  /// **'Edit Product'**
  String get editProduct;

  /// No description provided for @productName.
  ///
  /// In en, this message translates to:
  /// **'Product Name'**
  String get productName;

  /// No description provided for @sku.
  ///
  /// In en, this message translates to:
  /// **'SKU / Barcode'**
  String get sku;

  /// No description provided for @category.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get category;

  /// No description provided for @costPrice.
  ///
  /// In en, this message translates to:
  /// **'Cost Price'**
  String get costPrice;

  /// No description provided for @sellingPrice.
  ///
  /// In en, this message translates to:
  /// **'Selling Price'**
  String get sellingPrice;

  /// No description provided for @stockQuantity.
  ///
  /// In en, this message translates to:
  /// **'Stock Quantity'**
  String get stockQuantity;

  /// No description provided for @unit.
  ///
  /// In en, this message translates to:
  /// **'Unit'**
  String get unit;

  /// No description provided for @description.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get description;

  /// No description provided for @image.
  ///
  /// In en, this message translates to:
  /// **'Image'**
  String get image;

  /// No description provided for @lowStockAlert.
  ///
  /// In en, this message translates to:
  /// **'Low Stock Alert'**
  String get lowStockAlert;

  /// No description provided for @supplier.
  ///
  /// In en, this message translates to:
  /// **'Supplier'**
  String get supplier;

  /// No description provided for @brand.
  ///
  /// In en, this message translates to:
  /// **'Brand'**
  String get brand;

  /// No description provided for @model.
  ///
  /// In en, this message translates to:
  /// **'Model'**
  String get model;

  /// No description provided for @addCustomer.
  ///
  /// In en, this message translates to:
  /// **'Add Customer'**
  String get addCustomer;

  /// No description provided for @editCustomer.
  ///
  /// In en, this message translates to:
  /// **'Edit Customer'**
  String get editCustomer;

  /// No description provided for @customerName.
  ///
  /// In en, this message translates to:
  /// **'Customer Name'**
  String get customerName;

  /// No description provided for @phone.
  ///
  /// In en, this message translates to:
  /// **'Phone'**
  String get phone;

  /// No description provided for @email.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// No description provided for @address.
  ///
  /// In en, this message translates to:
  /// **'Address'**
  String get address;

  /// No description provided for @totalSpent.
  ///
  /// In en, this message translates to:
  /// **'Total Spent'**
  String get totalSpent;

  /// No description provided for @totalDue.
  ///
  /// In en, this message translates to:
  /// **'Total Due'**
  String get totalDue;

  /// No description provided for @lastVisit.
  ///
  /// In en, this message translates to:
  /// **'Last Visit'**
  String get lastVisit;

  /// No description provided for @customerHistory.
  ///
  /// In en, this message translates to:
  /// **'Customer History'**
  String get customerHistory;

  /// No description provided for @makePayment.
  ///
  /// In en, this message translates to:
  /// **'Make Payment'**
  String get makePayment;

  /// No description provided for @collectDue.
  ///
  /// In en, this message translates to:
  /// **'Collect Due'**
  String get collectDue;

  /// No description provided for @addVendor.
  ///
  /// In en, this message translates to:
  /// **'Add Vendor'**
  String get addVendor;

  /// No description provided for @editVendor.
  ///
  /// In en, this message translates to:
  /// **'Edit Vendor'**
  String get editVendor;

  /// No description provided for @vendorName.
  ///
  /// In en, this message translates to:
  /// **'Vendor Name'**
  String get vendorName;

  /// No description provided for @companyName.
  ///
  /// In en, this message translates to:
  /// **'Company Name'**
  String get companyName;

  /// No description provided for @payable.
  ///
  /// In en, this message translates to:
  /// **'Payable'**
  String get payable;

  /// No description provided for @totalPurchases.
  ///
  /// In en, this message translates to:
  /// **'Total Purchases'**
  String get totalPurchases;

  /// No description provided for @recordPurchase.
  ///
  /// In en, this message translates to:
  /// **'Record Purchase'**
  String get recordPurchase;

  /// No description provided for @payVendor.
  ///
  /// In en, this message translates to:
  /// **'Pay Vendor'**
  String get payVendor;

  /// No description provided for @vendorHistory.
  ///
  /// In en, this message translates to:
  /// **'Vendor History'**
  String get vendorHistory;

  /// No description provided for @recordExpense.
  ///
  /// In en, this message translates to:
  /// **'Record Expense'**
  String get recordExpense;

  /// No description provided for @expenseType.
  ///
  /// In en, this message translates to:
  /// **'Expense Type'**
  String get expenseType;

  /// No description provided for @amount.
  ///
  /// In en, this message translates to:
  /// **'Amount'**
  String get amount;

  /// No description provided for @date.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get date;

  /// No description provided for @expenseCategory.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get expenseCategory;

  /// No description provided for @salesReport.
  ///
  /// In en, this message translates to:
  /// **'Sales Report'**
  String get salesReport;

  /// No description provided for @expenseReport.
  ///
  /// In en, this message translates to:
  /// **'Expense Report'**
  String get expenseReport;

  /// No description provided for @profitReport.
  ///
  /// In en, this message translates to:
  /// **'Profit & Loss'**
  String get profitReport;

  /// No description provided for @inventoryReport.
  ///
  /// In en, this message translates to:
  /// **'Inventory Report'**
  String get inventoryReport;

  /// No description provided for @customerReport.
  ///
  /// In en, this message translates to:
  /// **'Customer Report'**
  String get customerReport;

  /// No description provided for @dailySummary.
  ///
  /// In en, this message translates to:
  /// **'Daily Summary'**
  String get dailySummary;

  /// No description provided for @monthlySummary.
  ///
  /// In en, this message translates to:
  /// **'Monthly Summary'**
  String get monthlySummary;

  /// No description provided for @dateRange.
  ///
  /// In en, this message translates to:
  /// **'Date Range'**
  String get dateRange;

  /// No description provided for @totalRevenue.
  ///
  /// In en, this message translates to:
  /// **'Total Revenue'**
  String get totalRevenue;

  /// No description provided for @totalProfit.
  ///
  /// In en, this message translates to:
  /// **'Total Profit'**
  String get totalProfit;

  /// No description provided for @totalExpenses.
  ///
  /// In en, this message translates to:
  /// **'Total Expenses'**
  String get totalExpenses;

  /// No description provided for @netIncome.
  ///
  /// In en, this message translates to:
  /// **'Net Income'**
  String get netIncome;

  /// No description provided for @topSelling.
  ///
  /// In en, this message translates to:
  /// **'Top Selling'**
  String get topSelling;

  /// No description provided for @addStaff.
  ///
  /// In en, this message translates to:
  /// **'Add Staff'**
  String get addStaff;

  /// No description provided for @role.
  ///
  /// In en, this message translates to:
  /// **'Role'**
  String get role;

  /// No description provided for @permissions.
  ///
  /// In en, this message translates to:
  /// **'Permissions'**
  String get permissions;

  /// No description provided for @active.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get active;

  /// No description provided for @inactive.
  ///
  /// In en, this message translates to:
  /// **'Inactive'**
  String get inactive;

  /// No description provided for @salary.
  ///
  /// In en, this message translates to:
  /// **'Salary'**
  String get salary;

  /// No description provided for @joiningDate.
  ///
  /// In en, this message translates to:
  /// **'Joining Date'**
  String get joiningDate;

  /// No description provided for @shopName.
  ///
  /// In en, this message translates to:
  /// **'Shop Name'**
  String get shopName;

  /// No description provided for @shopAddress.
  ///
  /// In en, this message translates to:
  /// **'Shop Address'**
  String get shopAddress;

  /// No description provided for @shopPhone.
  ///
  /// In en, this message translates to:
  /// **'Shop Phone'**
  String get shopPhone;

  /// No description provided for @currency.
  ///
  /// In en, this message translates to:
  /// **'Currency'**
  String get currency;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @invoiceFooter.
  ///
  /// In en, this message translates to:
  /// **'Invoice Footer'**
  String get invoiceFooter;

  /// No description provided for @logo.
  ///
  /// In en, this message translates to:
  /// **'Logo'**
  String get logo;

  /// No description provided for @shopProfile.
  ///
  /// In en, this message translates to:
  /// **'Shop Profile'**
  String get shopProfile;

  /// No description provided for @invoiceSettings.
  ///
  /// In en, this message translates to:
  /// **'Invoice Settings'**
  String get invoiceSettings;

  /// No description provided for @userProfile.
  ///
  /// In en, this message translates to:
  /// **'User Profile'**
  String get userProfile;

  /// No description provided for @security.
  ///
  /// In en, this message translates to:
  /// **'Security'**
  String get security;

  /// No description provided for @website.
  ///
  /// In en, this message translates to:
  /// **'Website'**
  String get website;

  /// No description provided for @invoiceTitle.
  ///
  /// In en, this message translates to:
  /// **'Invoice Title'**
  String get invoiceTitle;

  /// No description provided for @footerNote.
  ///
  /// In en, this message translates to:
  /// **'Footer Note'**
  String get footerNote;

  /// No description provided for @termsConditions.
  ///
  /// In en, this message translates to:
  /// **'Terms & Conditions'**
  String get termsConditions;

  /// No description provided for @success.
  ///
  /// In en, this message translates to:
  /// **'Success'**
  String get success;

  /// No description provided for @error.
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get error;

  /// No description provided for @savedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Saved successfully'**
  String get savedSuccessfully;

  /// No description provided for @saveChanges.
  ///
  /// In en, this message translates to:
  /// **'Save Changes'**
  String get saveChanges;

  /// No description provided for @changePassword.
  ///
  /// In en, this message translates to:
  /// **'Change Password'**
  String get changePassword;

  /// No description provided for @oldPassword.
  ///
  /// In en, this message translates to:
  /// **'Old Password'**
  String get oldPassword;

  /// No description provided for @newPassword.
  ///
  /// In en, this message translates to:
  /// **'New Password'**
  String get newPassword;

  /// No description provided for @confirmPassword.
  ///
  /// In en, this message translates to:
  /// **'Confirm Password'**
  String get confirmPassword;

  /// No description provided for @accountRecovery.
  ///
  /// In en, this message translates to:
  /// **'Account Recovery'**
  String get accountRecovery;

  /// No description provided for @deletedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Deleted successfully'**
  String get deletedSuccessfully;

  /// No description provided for @confirmDelete.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete?'**
  String get confirmDelete;

  /// No description provided for @fillRequired.
  ///
  /// In en, this message translates to:
  /// **'Please fill all required fields'**
  String get fillRequired;

  /// No description provided for @loginSuccess.
  ///
  /// In en, this message translates to:
  /// **'Login successful'**
  String get loginSuccess;

  /// No description provided for @loginFailed.
  ///
  /// In en, this message translates to:
  /// **'Login failed'**
  String get loginFailed;

  /// No description provided for @noProductsFound.
  ///
  /// In en, this message translates to:
  /// **'No products found'**
  String get noProductsFound;

  /// No description provided for @businessReports.
  ///
  /// In en, this message translates to:
  /// **'Business Reports'**
  String get businessReports;

  /// No description provided for @performanceAnalytics.
  ///
  /// In en, this message translates to:
  /// **'Performance Analytics'**
  String get performanceAnalytics;

  /// No description provided for @avgOrderValue.
  ///
  /// In en, this message translates to:
  /// **'Avg. Order Value'**
  String get avgOrderValue;

  /// No description provided for @pendingPayments.
  ///
  /// In en, this message translates to:
  /// **'Pending Payments'**
  String get pendingPayments;

  /// No description provided for @lowStockAlerts.
  ///
  /// In en, this message translates to:
  /// **'Low Stock Alerts'**
  String get lowStockAlerts;

  /// No description provided for @goodMorning.
  ///
  /// In en, this message translates to:
  /// **'Good morning'**
  String get goodMorning;

  /// No description provided for @todaysSales.
  ///
  /// In en, this message translates to:
  /// **'Today\'s Sales'**
  String get todaysSales;

  /// No description provided for @inventoryValue.
  ///
  /// In en, this message translates to:
  /// **'Inventory Value'**
  String get inventoryValue;

  /// No description provided for @totalCustomers.
  ///
  /// In en, this message translates to:
  /// **'Total Customers'**
  String get totalCustomers;

  /// No description provided for @salesOverview.
  ///
  /// In en, this message translates to:
  /// **'Sales Overview'**
  String get salesOverview;

  /// No description provided for @recentTransactions.
  ///
  /// In en, this message translates to:
  /// **'Recent Transactions'**
  String get recentTransactions;

  /// No description provided for @whatsHappening.
  ///
  /// In en, this message translates to:
  /// **'What\'s happening today'**
  String get whatsHappening;

  /// No description provided for @viewFullReport.
  ///
  /// In en, this message translates to:
  /// **'View Full Report'**
  String get viewFullReport;

  /// No description provided for @orderActivity.
  ///
  /// In en, this message translates to:
  /// **'Order Activity'**
  String get orderActivity;

  /// No description provided for @dailyOrderVolume.
  ///
  /// In en, this message translates to:
  /// **'Daily Order Volume'**
  String get dailyOrderVolume;

  /// No description provided for @hot.
  ///
  /// In en, this message translates to:
  /// **'Hot'**
  String get hot;

  /// No description provided for @vsYesterday.
  ///
  /// In en, this message translates to:
  /// **'vs Yesterday'**
  String get vsYesterday;

  /// No description provided for @cartIsEmpty.
  ///
  /// In en, this message translates to:
  /// **'Cart is empty'**
  String get cartIsEmpty;

  /// No description provided for @addProductsToGetStarted.
  ///
  /// In en, this message translates to:
  /// **'Add products to get started'**
  String get addProductsToGetStarted;

  /// No description provided for @completeSale.
  ///
  /// In en, this message translates to:
  /// **'Complete Sale'**
  String get completeSale;

  /// No description provided for @transactionRecorded.
  ///
  /// In en, this message translates to:
  /// **'Transaction has been recorded successfully.'**
  String get transactionRecorded;

  /// No description provided for @printReceipt.
  ///
  /// In en, this message translates to:
  /// **'Print Receipt'**
  String get printReceipt;

  /// No description provided for @newCustomer.
  ///
  /// In en, this message translates to:
  /// **'New Customer'**
  String get newCustomer;

  /// No description provided for @noTransactionsFound.
  ///
  /// In en, this message translates to:
  /// **'No transactions found'**
  String get noTransactionsFound;

  /// No description provided for @allTransactions.
  ///
  /// In en, this message translates to:
  /// **'All Transactions'**
  String get allTransactions;

  /// No description provided for @paymentOverdue.
  ///
  /// In en, this message translates to:
  /// **'Payment Overdue'**
  String get paymentOverdue;

  /// No description provided for @overdueMessage.
  ///
  /// In en, this message translates to:
  /// **'This transaction is more than 30 days old and still has a pending balance.'**
  String get overdueMessage;

  /// No description provided for @status.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get status;

  /// No description provided for @orderId.
  ///
  /// In en, this message translates to:
  /// **'Order ID'**
  String get orderId;

  /// No description provided for @markPaid.
  ///
  /// In en, this message translates to:
  /// **'Mark as Paid'**
  String get markPaid;

  /// No description provided for @dataBackup.
  ///
  /// In en, this message translates to:
  /// **'Data Backup'**
  String get dataBackup;

  /// No description provided for @exportData.
  ///
  /// In en, this message translates to:
  /// **'Export All Data'**
  String get exportData;

  /// No description provided for @importData.
  ///
  /// In en, this message translates to:
  /// **'Import Data'**
  String get importData;

  /// No description provided for @backupDescription.
  ///
  /// In en, this message translates to:
  /// **'Download a backup of all your shop data (Products, Transactions, Customers, etc.) in JSON format.'**
  String get backupDescription;

  /// No description provided for @importDescription.
  ///
  /// In en, this message translates to:
  /// **'Restore your shop data from a previously exported JSON backup file.'**
  String get importDescription;

  /// No description provided for @restoreWarning.
  ///
  /// In en, this message translates to:
  /// **'Restoring data will merge records. Ensure your backup file is from this shop.'**
  String get restoreWarning;

  /// No description provided for @inventorySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Manage your shop\'s stock levels, track pricing, and organize inventory efficiently.'**
  String get inventorySubtitle;

  /// No description provided for @inventoryManagement.
  ///
  /// In en, this message translates to:
  /// **'Inventory Management'**
  String get inventoryManagement;

  /// No description provided for @uploadPhoto.
  ///
  /// In en, this message translates to:
  /// **'Upload Photo'**
  String get uploadPhoto;

  /// No description provided for @stockLevel.
  ///
  /// In en, this message translates to:
  /// **'Stock Level'**
  String get stockLevel;

  /// No description provided for @retailPrice.
  ///
  /// In en, this message translates to:
  /// **'Retail Price'**
  String get retailPrice;

  /// No description provided for @industrySpecificData.
  ///
  /// In en, this message translates to:
  /// **'Industry Specific Data'**
  String get industrySpecificData;

  /// No description provided for @engineNumber.
  ///
  /// In en, this message translates to:
  /// **'Engine Number'**
  String get engineNumber;

  /// No description provided for @chassisNumber.
  ///
  /// In en, this message translates to:
  /// **'Chassis Number'**
  String get chassisNumber;

  /// No description provided for @modelYear.
  ///
  /// In en, this message translates to:
  /// **'Model Year'**
  String get modelYear;

  /// No description provided for @materialProductionCost.
  ///
  /// In en, this message translates to:
  /// **'Material Production Cost'**
  String get materialProductionCost;

  /// No description provided for @selectYear.
  ///
  /// In en, this message translates to:
  /// **'Select Year'**
  String get selectYear;

  /// No description provided for @registerProduct.
  ///
  /// In en, this message translates to:
  /// **'Register New Product'**
  String get registerProduct;

  /// No description provided for @loadingDashboard.
  ///
  /// In en, this message translates to:
  /// **'Loading dashboard...'**
  String get loadingDashboard;

  /// No description provided for @last7Days.
  ///
  /// In en, this message translates to:
  /// **'Last 7 Days'**
  String get last7Days;

  /// No description provided for @noTransactionsYet.
  ///
  /// In en, this message translates to:
  /// **'No transactions yet'**
  String get noTransactionsYet;

  /// No description provided for @allStockLevelsGood.
  ///
  /// In en, this message translates to:
  /// **'All stock levels are good'**
  String get allStockLevelsGood;

  /// No description provided for @financialHealthOverview.
  ///
  /// In en, this message translates to:
  /// **'Overview of your shop\'s financial health'**
  String get financialHealthOverview;

  /// No description provided for @totalOrdersProcessed.
  ///
  /// In en, this message translates to:
  /// **'Total orders processed'**
  String get totalOrdersProcessed;

  /// No description provided for @perTransaction.
  ///
  /// In en, this message translates to:
  /// **'Per transaction'**
  String get perTransaction;

  /// No description provided for @needsAttention.
  ///
  /// In en, this message translates to:
  /// **'Needs attention'**
  String get needsAttention;

  /// No description provided for @salesTrend7Days.
  ///
  /// In en, this message translates to:
  /// **'Sales Trend (Last 7 Days)'**
  String get salesTrend7Days;

  /// No description provided for @noSalesData.
  ///
  /// In en, this message translates to:
  /// **'No sales data available'**
  String get noSalesData;

  /// No description provided for @inventoryDistribution.
  ///
  /// In en, this message translates to:
  /// **'Inventory Distribution'**
  String get inventoryDistribution;

  /// No description provided for @noInventoryData.
  ///
  /// In en, this message translates to:
  /// **'No inventory data available'**
  String get noInventoryData;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['bn', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'bn':
      return AppLocalizationsBn();
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
