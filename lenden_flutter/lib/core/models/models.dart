/// Data models for the Lenden Flutter app.
/// Mirrors TypeScript interfaces from client/src/types.ts.

// ─── User ──────────────────────────────────────────────────
class User {
  final int? id;
  final String name;
  final String email;
  final String role;
  final String? shopId;
  final String? avatarUrl;
  final String? createdAt;

  User({
    this.id,
    required this.name,
    required this.email,
    required this.role,
    this.shopId,
    this.avatarUrl,
    this.createdAt,
  });

  factory User.fromJson(Map<String, dynamic> json) => User(
        id: json['id'] is int ? json['id'] : int.tryParse('${json['id']}'),
        name: json['name'] ?? '',
        email: json['email'] ?? '',
        role: json['role'] ?? 'owner',
        shopId: json['shopId']?.toString(),
        avatarUrl: json['avatar_url'] ?? json['avatarUrl'],
        createdAt: json['created_at'],
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'email': email,
        'role': role,
        'shopId': shopId,
        'avatarUrl': avatarUrl,
      };

  bool get isOwner => role.toLowerCase() == 'owner';
  bool get isStaff => role.toLowerCase() == 'staff';
}

// ─── Shop ──────────────────────────────────────────────────
class Shop {
  final int id;
  final String name;
  final String? businessType;
  final String? address;
  final String? phone;
  final String? email;
  final String? website;
  final String? logoUrl;
  final String? headerTitle;
  final String? footerNote;
  final String? terms;
  final bool showLogo;

  Shop({
    required this.id,
    required this.name,
    this.businessType,
    this.address,
    this.phone,
    this.email,
    this.website,
    this.logoUrl,
    this.headerTitle,
    this.footerNote,
    this.terms,
    this.showLogo = true,
  });

  factory Shop.fromJson(Map<String, dynamic> json) => Shop(
        id: json['id'] is int ? json['id'] : int.parse('${json['id']}'),
        name: json['name'] ?? '',
        businessType: json['business_type'] ?? json['businessType'],
        address: json['address'],
        phone: json['phone'],
        email: json['email'],
        website: json['website'],
        logoUrl: json['logo_url'] ?? json['logoUrl'],
        headerTitle: json['header_title'] ?? json['headerTitle'],
        footerNote: json['footer_note'] ?? json['footerNote'],
        terms: json['terms'],
        showLogo: json['show_logo'] == true || json['show_logo'] == 1,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'business_type': businessType,
        'address': address,
        'phone': phone,
        'email': email,
        'website': website,
        'logo_url': logoUrl,
        'header_title': headerTitle,
        'footer_note': footerNote,
        'terms': terms,
        'show_logo': showLogo,
      };
}

// ─── Product ───────────────────────────────────────────────
class Product {
  final int id;
  final String name;
  final String? sku;
  final String? category;
  final double costPrice;
  final double sellingPrice;
  final int stockQuantity;
  final String? unit;
  final int? minStockLevel;
  final String? engineNo;
  final String? chassisNo;
  final String? modelYear;
  final double? materialCost;
  final String? imageUrl;

  Product({
    required this.id,
    required this.name,
    this.sku,
    this.category,
    required this.costPrice,
    required this.sellingPrice,
    required this.stockQuantity,
    this.unit,
    this.minStockLevel,
    this.engineNo,
    this.chassisNo,
    this.modelYear,
    this.materialCost,
    this.imageUrl,
  });

  bool get isLowStock =>
      minStockLevel != null && stockQuantity <= minStockLevel!;
  bool get isOutOfStock => stockQuantity <= 0;
  double get profitPerUnit => sellingPrice - costPrice;
  double get margin =>
      sellingPrice > 0 ? (profitPerUnit / sellingPrice) * 100 : 0;

  factory Product.fromJson(Map<String, dynamic> json) => Product(
        id: json['id'] is int ? json['id'] : int.parse('${json['id']}'),
        name: json['name'] ?? '',
        sku: json['sku'],
        category: json['category'],
        costPrice: _toDouble(json['cost_price'] ?? json['costPrice']),
        sellingPrice: _toDouble(json['selling_price'] ?? json['sellingPrice']),
        stockQuantity:
            _toInt(json['stock_quantity'] ?? json['qty'] ?? json['stockQuantity']),
        unit: json['unit'] ?? 'pcs',
        minStockLevel:
            json['min_stock_level'] != null ? _toInt(json['min_stock_level']) : 5,
        engineNo: json['engine_no'] ?? json['engineNo'],
        chassisNo: json['chassis_no'] ?? json['chassisNo'],
        modelYear: json['model_year'] ?? json['modelYear'],
        materialCost: json['material_cost'] != null
            ? _toDouble(json['material_cost'])
            : null,
        imageUrl: json['image_url'] ?? json['imageUrl'],
      );

  Map<String, dynamic> toJson() => {
        'name': name,
        'sku': sku,
        'category': category,
        'cost_price': costPrice,
        'selling_price': sellingPrice,
        'stock_quantity': stockQuantity,
        'unit': unit,
        'min_stock_level': minStockLevel,
        'engine_no': engineNo,
        'chassis_no': chassisNo,
        'model_year': modelYear,
        'material_cost': materialCost,
        'image_url': imageUrl,
      };

  // UI Compat Aliases
  String? get image => imageUrl;
  String? get engineNumber => engineNo;
  String? get chassisNumber => chassisNo;
}

// ─── Customer ──────────────────────────────────────────────
class Customer {
  final int id;
  final String name;
  final String? phone;
  final String? address;
  final String? email;
  final double totalDue;
  final double totalSpent;

  Customer({
    required this.id,
    required this.name,
    this.phone,
    this.address,
    this.email,
    this.totalDue = 0,
    this.totalSpent = 0,
  });

  factory Customer.fromJson(Map<String, dynamic> json) => Customer(
        id: json['id'] is int ? json['id'] : int.parse('${json['id']}'),
        name: json['name'] ?? '',
        phone: json['phone'],
        address: json['address'],
        email: json['email'],
        totalDue: _toDouble(json['total_due']),
        totalSpent: _toDouble(json['total_spent']),
      );

  // UI Compat Aliases
  String? get lastVisit => null; // To be implemented if backend supports it

  Map<String, dynamic> toJson() => {
        'name': name,
        'phone': phone,
        'address': address,
        'email': email,
      };
}

// ─── Vendor ────────────────────────────────────────────────
class Vendor {
  final int id;
  final String name;
  final String? companyName;
  final String? phone;
  final String? email;
  final String? address;
  final double totalPayable;
  final double totalPurchases;

  Vendor({
    required this.id,
    required this.name,
    this.companyName,
    this.phone,
    this.email,
    this.address,
    this.totalPayable = 0,
    this.totalPurchases = 0,
  });

  factory Vendor.fromJson(Map<String, dynamic> json) => Vendor(
        id: json['id'] is int ? json['id'] : int.parse('${json['id']}'),
        name: json['name'] ?? '',
        companyName: json['company_name'] ?? json['companyName'],
        phone: json['phone'],
        email: json['email'],
        address: json['address'],
        totalPayable: _toDouble(json['total_payable'] ?? json['payable']),
        totalPurchases: _toDouble(json['total_purchases']),
      );

  Map<String, dynamic> toJson() => {
        'name': name,
        'company_name': companyName,
        'phone': phone,
      };
}

// ─── Transaction ───────────────────────────────────────────
class Transaction {
  final int id;
  final String type;
  final double amount;
  final double paidAmount;
  final double? dueAmount;
  final double? discount;
  final String? paymentMethod;
  final String? referenceNo;
  final String? description;
  final String? date;
  final String? dueDate;
  final String status;
  final int? customerId;
  final String? customerName;
  final int? vendorId;
  final String? vendorName;
  final String? customerPhone;

  Transaction({
    required this.id,
    required this.type,
    required this.amount,
    this.paidAmount = 0,
    this.dueAmount,
    this.paymentMethod,
    this.referenceNo,
    this.description,
    this.date,
    this.dueDate,
    this.status = 'Pending',
    this.customerId,
    this.customerName,
    this.vendorId,
    this.vendorName,
    this.customerPhone,
    this.discount = 0.0,
  });

  factory Transaction.fromJson(Map<String, dynamic> json) => Transaction(
        id: json['id'] is int ? json['id'] : int.parse('${json['id']}'),
        type: json['type'] ?? 'sale',
        amount: _toDouble(json['amount']),
        paidAmount: _toDouble(json['paid_amount']),
        dueAmount: json['due_amount'] != null ? _toDouble(json['due_amount']) : null,
        paymentMethod: json['payment_method'],
        referenceNo: json['reference_no'],
        description: json['description'],
        date: json['date'],
        dueDate: json['due_date'],
        status: json['status'] ?? 'Pending',
        customerId: json['customer_id'] is int ? json['customer_id'] : null,
        customerName: json['customer_name'] ?? json['customer_name_snapshot'],
        vendorId: json['vendor_id'] is int ? json['vendor_id'] : null,
        vendorName: json['vendor_name'],
        customerPhone: json['customer_phone'] ?? json['customer_phone_snapshot'],
        discount: _toDouble(json['discount']),
      );

  // UI Compat Aliases
  String? get note => description;
}

// ─── Service ───────────────────────────────────────────────
class Service {
  final int id;
  final String name;
  final String? description;
  final double serviceCharge;
  final String? imageUrl;

  Service({
    required this.id,
    required this.name,
    this.description,
    required this.serviceCharge,
    this.imageUrl,
  });

  factory Service.fromJson(Map<String, dynamic> json) => Service(
        id: json['id'] is int ? json['id'] : int.parse('${json['id']}'),
        name: json['name'] ?? '',
        description: json['description'],
        serviceCharge: _toDouble(json['service_charge']),
        imageUrl: json['image_url'],
      );

  Map<String, dynamic> toJson() => {
        'name': name,
        'description': description,
        'service_charge': serviceCharge,
        'image_url': imageUrl,
      };
}

// ─── Trip ──────────────────────────────────────────────────
class Trip {
  final int id;
  final String vehicleNo;
  final String? driverName;
  final String? destination;
  final String? startDate;
  final String? endDate;
  final double tripFare;
  final double expenses;
  final int? customerId;
  final String? customerName;
  final String status;

  Trip({required this.id, required this.vehicleNo, this.driverName, this.destination, this.startDate, this.endDate, required this.tripFare, this.expenses = 0, this.customerId, this.customerName, this.status = 'ongoing'});

  // UI Compat Aliases
  double get fare => tripFare;
  String? get date => startDate;
  String? get driverNameSnapshot => driverName;

  factory Trip.fromJson(Map<String, dynamic> json) => Trip(
        id: json['id'] is int ? json['id'] : int.parse('${json['id']}'),
        vehicleNo: json['vehicle_no'] ?? '',
        driverName: json['driver_name'],
        destination: json['destination'],
        startDate: json['start_date'],
        endDate: json['end_date'],
        tripFare: _toDouble(json['trip_fare']),
        expenses: _toDouble(json['expenses']),
        customerId: json['customer_id'] is int ? json['customer_id'] : null,
        customerName: json['customer_name'],
        status: json['status'] ?? 'ongoing',
      );

  Map<String, dynamic> toJson() => {
        'vehicle_no': vehicleNo,
        'driver_name': driverName,
        'destination': destination,
        'start_date': startDate,
        'trip_fare': tripFare,
        'expenses': expenses,
        'customer_id': customerId,
      };
}

// ─── Staff ─────────────────────────────────────────────────
class Staff {
  final int id;
  final String name;
  final String? username;
  final String? email;
  final String? phone;
  final String role;
  final double? salary;
  final String? joiningDate;
  final String status;

  Staff({
    required this.id,
    required this.name,
    this.username,
    this.email,
    this.phone,
    this.role = 'Staff',
    this.salary,
    this.joiningDate,
    this.status = 'active',
  });

  factory Staff.fromJson(Map<String, dynamic> json) => Staff(
        id: json['id'] is int ? json['id'] : int.parse('${json['id']}'),
        name: json['name'] ?? '',
        username: json['username'],
        email: json['email'],
        phone: json['phone'],
        role: json['role'] ?? 'Staff',
        salary: json['salary'] != null ? _toDouble(json['salary']) : null,
        joiningDate: json['joining_date'],
        status: json['status'] ?? 'active',
      );
}

// ─── Notification ──────────────────────────────────────────
class AppNotification {
  final int id;
  final String type;
  final String title;
  final String message;
  final bool isRead;
  final String? createdAt;

  AppNotification({
    required this.id,
    required this.type,
    required this.title,
    required this.message,
    this.isRead = false,
    this.createdAt,
  });

  factory AppNotification.fromJson(Map<String, dynamic> json) =>
      AppNotification(
        id: json['id'] is int ? json['id'] : int.parse('${json['id']}'),
        type: json['type'] ?? 'general',
        title: json['title'] ?? '',
        message: json['message'] ?? '',
        isRead: json['is_read'] == true || json['is_read'] == 1,
        createdAt: json['created_at'],
      );

  AppNotification copyWith({
    int? id,
    String? type,
    String? title,
    String? message,
    bool? isRead,
    String? createdAt,
  }) =>
      AppNotification(
        id: id ?? this.id,
        type: type ?? this.type,
        title: title ?? this.title,
        message: message ?? this.message,
        isRead: isRead ?? this.isRead,
        createdAt: createdAt ?? this.createdAt,
      );
}

// ─── Dashboard Summary ────────────────────────────────────
class DashboardSummary {
  final double totalSales;
  final int salesCount;
  final double totalExpenses;
  final double totalPurchases;
  final double dueCollected;
  final double grossProfit;
  final double netProfit;
  final int productCount;
  final double inventoryValue;
  final int customerCount;
  final double totalDue;
  final double pendingAmount;
  final int activeTrips;
  final int vendorCount;

  DashboardSummary({
    this.totalSales = 0,
    this.salesCount = 0,
    this.totalExpenses = 0,
    this.totalPurchases = 0,
    this.dueCollected = 0,
    this.grossProfit = 0,
    this.netProfit = 0,
    this.productCount = 0,
    this.inventoryValue = 0,
    this.customerCount = 0,
    this.totalDue = 0,
    this.pendingAmount = 0,
    this.activeTrips = 0,
    this.vendorCount = 0,
  });

  factory DashboardSummary.fromJson(Map<String, dynamic> json) =>
      DashboardSummary(
        totalSales: _toDouble(json['total_sales']),
        salesCount: _toInt(json['sales_count']),
        totalExpenses: _toDouble(json['total_expenses']),
        totalPurchases: _toDouble(json['total_purchases']),
        dueCollected: _toDouble(json['due_collected']),
        grossProfit: _toDouble(json['gross_profit']),
        netProfit: _toDouble(json['net_profit']),
        productCount: _toInt(json['product_count']),
        inventoryValue: _toDouble(json['inventory_value']),
        customerCount: _toInt(json['customer_count']),
        totalDue: _toDouble(json['total_due']),
        pendingAmount: _toDouble(json['pending_amount']),
        activeTrips: _toInt(json['active_trips']),
        vendorCount: _toInt(json['vendor_count']),
      );
}

// ─── Invoice Settings ──────────────────────────────────────
class InvoiceSettings {
  final String headerTitle;
  final String footerNote;
  final String terms;
  final bool showLogo;
  final String currencySymbol;

  InvoiceSettings({
    this.headerTitle = 'INVOICE',
    this.footerNote = 'Thank you for shopping with us!',
    this.terms = 'Goods once sold are not returnable.',
    this.showLogo = true,
    this.currencySymbol = '৳',
  });
}

// ─── Helpers ───────────────────────────────────────────────
double _toDouble(dynamic value) {
  if (value == null) return 0;
  if (value is double) return value;
  if (value is int) return value.toDouble();
  if (value is String) return double.tryParse(value) ?? 0;
  return 0;
}

int _toInt(dynamic value) {
  if (value == null) return 0;
  if (value is int) return value;
  if (value is double) return value.toInt();
  if (value is String) return int.tryParse(value) ?? 0;
  return 0;
}
