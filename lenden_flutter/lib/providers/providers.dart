import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'dart:convert';
import '../core/api/api_client.dart';
import '../core/models/models.dart';
import '../app/constants.dart';

// ─── Auth State ────────────────────────────────────────────
class AuthState {
  final User? user;
  final bool isLoading;
  final bool isAuthenticated;

  const AuthState({
    this.user,
    this.isLoading = true,
    this.isAuthenticated = false,
  });

  AuthState copyWith({
    User? user,
    bool? isLoading,
    bool? isAuthenticated,
  }) =>
      AuthState(
        user: user ?? this.user,
        isLoading: isLoading ?? this.isLoading,
        isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      );
}

// ─── Auth Notifier ─────────────────────────────────────────
class AuthNotifier extends StateNotifier<AuthState> {
  final ApiClient _api = ApiClient();
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  AuthNotifier() : super(const AuthState()) {
    _loadInitialAuth();
  }

  Future<void> _loadInitialAuth() async {
    final token = await _api.getToken();
    final userData = await _storage.read(key: AppConstants.userKey);

    if (token != null && userData != null) {
      try {
        final userMap = jsonDecode(userData);
        state = AuthState(
          user: User.fromJson(userMap),
          isLoading: false,
          isAuthenticated: true,
        );
      } catch (_) {
        state = const AuthState(isLoading: false);
      }
    } else {
      state = const AuthState(isLoading: false);
    }
  }

  Future<String?> login(String email, String password) async {
    try {
      final response = await _api.dio.post('/api/auth/login', data: {
        'email': email,
        'password': password,
      });

      final data = response.data;
      final token = data['token'];
      final userMap = data['user'];

      // Store token and user
      await _storage.write(key: AppConstants.tokenKey, value: token);
      await _storage.write(
          key: AppConstants.userKey, value: jsonEncode(userMap));

      final user = User.fromJson(userMap);
      state = AuthState(
        user: user,
        isLoading: false,
        isAuthenticated: true,
      );

      return null; // Success
    } on DioException catch (e) {
      if (e.response?.data is Map) {
        return e.response?.data['message'] ?? 'Login failed';
      }
      return 'Connection error';
    } catch (e) {
      return 'An unexpected error occurred';
    }
  }

  Future<bool> register(
      String name, String email, String password, String? shopName) async {
    try {
      await _api.dio.post('/api/auth/register', data: {
        'name': name,
        'email': email,
        'password': password,
        if (shopName != null) 'shopName': shopName,
      });
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> forgotPassword(String email) async {
    try {
      await _api.dio.post('/api/auth/forgot-password', data: {'email': email});
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> resetPassword(
      String email, String password, String? token, String? code) async {
    try {
      await _api.dio.post('/api/auth/forgot-password', data: {
        'email': email,
        'newPassword': password,
        if (token != null) 'token': token,
        if (code != null) 'recoveryCode': code,
      });
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> changePassword(String oldPassword, String newPassword) async {
    try {
      await _api.dio.post('/api/auth/change-password', data: {
        'oldPassword': oldPassword,
        'newPassword': newPassword,
      });
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<void> logout() async {
    await _api.logout();
    await _storage.deleteAll();
    state = const AuthState(isLoading: false);
  }

  void updateUser(User updatedUser) {
    state = state.copyWith(user: updatedUser);
    _storage.write(
        key: AppConstants.userKey, value: jsonEncode(updatedUser.toJson()));
  }

  /// RBAC check — mirrors web app's `can()` function
  bool can(String action) {
    final role = state.user?.role.toLowerCase();
    if (role == 'owner') return true;

    const staffRestrictions = {
      'delete_customer': true,
      'view_reports': false, // Staff CAN view reports
      'view_profits': true,
      'manage_vendors': true,
      'manage_staff': true,
      'manage_shop_settings': true,
      'delete_product': true,
      'delete_transaction': true,
      'delete_expense': true,
      'edit_product_price': false,
    };

    if (role == 'manager') {
      const managerRestricted = ['manage_staff', 'manage_shop_settings'];
      return !managerRestricted.contains(action);
    }

    return !(staffRestrictions[action] ?? false);
  }
}

// ─── Shop State ────────────────────────────────────────────
class ShopState {
  final Shop? currentShop;
  final List<Shop> shops;
  final bool isLoading;

  const ShopState({
    this.currentShop,
    this.shops = const [],
    this.isLoading = false,
  });

  ShopState copyWith({
    Shop? currentShop,
    List<Shop>? shops,
    bool? isLoading,
  }) =>
      ShopState(
        currentShop: currentShop ?? this.currentShop,
        shops: shops ?? this.shops,
        isLoading: isLoading ?? this.isLoading,
      );
}

class ShopNotifier extends StateNotifier<ShopState> {
  final ApiClient _api = ApiClient();
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  ShopNotifier() : super(const ShopState());

  Future<void> loadShops() async {
    state = state.copyWith(isLoading: true);
    try {
      final response = await _api.dio.get('/api/shops');
      final shops =
          (response.data as List).map((s) => Shop.fromJson(s)).toList();

      // Restore saved shop or default to first
      Shop? current;
      final savedShopData =
          await _storage.read(key: AppConstants.currentShopKey);
      if (savedShopData != null) {
        try {
          final savedShop = Shop.fromJson(jsonDecode(savedShopData));
          current = shops.firstWhere((s) => s.id == savedShop.id,
              orElse: () => shops.first);
        } catch (_) {
          current = shops.isNotEmpty ? shops.first : null;
        }
      } else {
        current = shops.isNotEmpty ? shops.first : null;
      }

      if (current != null) {
        await _selectShop(current);
      }

      state = ShopState(
        currentShop: current,
        shops: shops,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false);
    }
  }

  Future<void> selectShop(Shop shop) async {
    await _selectShop(shop);
    state = state.copyWith(currentShop: shop);
  }

  Future<void> _selectShop(Shop shop) async {
    await _storage.write(
        key: AppConstants.currentShopKey, value: jsonEncode(shop.toJson()));
    await _api.saveShopId(shop.id.toString());
  }

  Future<bool> createShop(String name, String businessType,
      {String? address, String? phone}) async {
    try {
      await _api.dio.post('/api/shops', data: {
        'name': name,
        'business_type': businessType,
        'address': address,
        'phone': phone,
      });
      await loadShops();
      return true;
    } catch (e) {
      return false;
    }
  }
}

// ─── Language State ────────────────────────────────────────
class LanguageNotifier extends StateNotifier<String> {
  LanguageNotifier() : super('en') {
    _load();
  }

  Future<void> _load() async {
    const storage = FlutterSecureStorage();
    final saved = await storage.read(key: AppConstants.languageKey);
    if (saved != null) state = saved;
  }

  Future<void> setLanguage(String lang) async {
    state = lang;
    const storage = FlutterSecureStorage();
    await storage.write(key: AppConstants.languageKey, value: lang);
  }

  void toggleLanguage() {
    setLanguage(state == 'en' ? 'bn' : 'en');
  }
}

// ─── Notification State ────────────────────────────────────
class NotificationState {
  final List<AppNotification> notifications;
  final bool isLoading;
  final int unreadCount;

  const NotificationState({
    this.notifications = const [],
    this.isLoading = false,
    this.unreadCount = 0,
  });

  NotificationState copyWith({
    List<AppNotification>? notifications,
    bool? isLoading,
    int? unreadCount,
  }) =>
      NotificationState(
        notifications: notifications ?? this.notifications,
        isLoading: isLoading ?? this.isLoading,
        unreadCount: unreadCount ?? this.unreadCount,
      );
}

class NotificationNotifier extends StateNotifier<NotificationState> {
  final ApiClient _api = ApiClient();

  NotificationNotifier() : super(const NotificationState());

  Future<void> loadNotifications() async {
    state = state.copyWith(isLoading: true);
    try {
      final response = await _api.dio.get('/api/notifications');
      final list = (response.data as List)
          .map((n) => AppNotification.fromJson(n))
          .toList();
      final unread = list.where((n) => !n.isRead).length;

      state = NotificationState(
        notifications: list,
        unreadCount: unread,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false);
    }
  }

  Future<void> markAsRead(int id) async {
    try {
      await _api.dio.patch('/api/notifications/$id/read');
      final newList = state.notifications.map((n) {
        if (n.id == id) return n.copyWith(isRead: true);
        return n;
      }).toList();
      state = state.copyWith(
        notifications: newList,
        unreadCount: newList.where((n) => !n.isRead).length,
      );
    } catch (_) {}
  }

  Future<void> markAllAsRead() async {
    try {
      await _api.dio.patch('/api/notifications/mark-all-read');
      final newList =
          state.notifications.map((n) => n.copyWith(isRead: true)).toList();
      state = state.copyWith(
        notifications: newList,
        unreadCount: 0,
      );
    } catch (_) {}
  }

  Future<void> deleteNotification(int id) async {
    try {
      await _api.dio.delete('/api/notifications/$id');
      final newList = state.notifications.where((n) => n.id != id).toList();
      state = state.copyWith(
        notifications: newList,
        unreadCount: newList.where((n) => !n.isRead).length,
      );
    } catch (_) {}
  }
}

// ─── POS State ─────────────────────────────────────────────
class CartItem {
  final Product product;
  final int quantity;
  final double price;

  CartItem({required this.product, this.quantity = 1, required this.price});

  CartItem copyWith({Product? product, int? quantity, double? price}) =>
      CartItem(
        product: product ?? this.product,
        quantity: quantity ?? this.quantity,
        price: price ?? this.price,
      );

  double get subtotal => price * quantity;
}

class POSState {
  final List<CartItem> items;
  final Customer? selectedCustomer;
  final double discount;
  final double paidAmount;
  final String paymentMethod;
  final bool isSubmitting;

  const POSState({
    this.items = const [],
    this.selectedCustomer,
    this.discount = 0.0,
    this.paidAmount = 0.0,
    this.paymentMethod = 'cash',
    this.isSubmitting = false,
  });

  double get subtotal => items.fold(0, (sum, item) => sum + item.subtotal);
  double get total => subtotal - discount;
  double get dueAmount => total - paidAmount;

  POSState copyWith({
    List<CartItem>? items,
    Customer? selectedCustomer,
    double? discount,
    double? paidAmount,
    String? paymentMethod,
    bool? isSubmitting,
  }) =>
      POSState(
        items: items ?? this.items,
        selectedCustomer: selectedCustomer ?? this.selectedCustomer,
        discount: discount ?? this.discount,
        paidAmount: paidAmount ?? this.paidAmount,
        paymentMethod: paymentMethod ?? this.paymentMethod,
        isSubmitting: isSubmitting ?? this.isSubmitting,
      );
}

class POSNotifier extends StateNotifier<POSState> {
  final ApiClient _api = ApiClient();

  POSNotifier() : super(const POSState());

  void addToCart(Product product) {
    final existingIndex = state.items.indexWhere((i) => i.product.id == product.id);
    if (existingIndex != -1) {
      final item = state.items[existingIndex];
      final newList = List<CartItem>.from(state.items);
      newList[existingIndex] = item.copyWith(quantity: item.quantity + 1);
      state = state.copyWith(items: newList);
    } else {
      state = state.copyWith(
        items: [...state.items, CartItem(product: product, price: product.sellingPrice)],
      );
    }
  }

  void updateQuantity(int productId, int quantity) {
    if (quantity <= 0) {
      removeFromCart(productId);
      return;
    }
    final newList = state.items.map((i) {
      if (i.product.id == productId) return i.copyWith(quantity: quantity);
      return i;
    }).toList();
    state = state.copyWith(items: newList);
  }

  void removeFromCart(int productId) {
    state = state.copyWith(
      items: state.items.where((i) => i.product.id != productId).toList(),
    );
  }

  void selectCustomer(Customer? customer) {
    state = state.copyWith(selectedCustomer: customer);
  }

  void setDiscount(double discount) {
    state = state.copyWith(discount: discount);
  }

  void setPaidAmount(double amount) {
    state = state.copyWith(paidAmount: amount);
  }

  void setPaymentMethod(String method) {
    state = state.copyWith(paymentMethod: method);
  }

  void clear() {
    state = const POSState();
  }

  Future<int?> submitSale() async {
    if (state.items.isEmpty) return null;
    state = state.copyWith(isSubmitting: true);

    try {
      final response = await _api.dio.post('/api/transactions/sale', data: {
        if (state.selectedCustomer != null) 'customer_id': state.selectedCustomer!.id,
        'items': state.items.map((i) => {
          'product_id': i.product.id,
          'quantity': i.quantity,
          'unit_price': i.price,
        }).toList(),
        'discount': state.discount,
        'paid_amount': state.paidAmount,
        'payment_method': state.paymentMethod,
      });

      state = state.copyWith(isSubmitting: false);
      final txnId = response.data['id'];
      clear();
      return txnId;
    } catch (e) {
      state = state.copyWith(isSubmitting: false);
      return null;
    }
  }
}

// ─── Providers ─────────────────────────────────────────────
final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier();
});

final shopProvider = StateNotifierProvider<ShopNotifier, ShopState>((ref) {
  return ShopNotifier();
});

final languageProvider =
    StateNotifierProvider<LanguageNotifier, String>((ref) {
  return LanguageNotifier();
});

final notificationProvider =
    StateNotifierProvider<NotificationNotifier, NotificationState>((ref) {
  return NotificationNotifier();
});

final posProvider = StateNotifierProvider<POSNotifier, POSState>((ref) {
  return POSNotifier();
});

final connectivityProvider = StreamProvider<List<ConnectivityResult>>((ref) {
  return Connectivity().onConnectivityChanged;
});
