import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../app/constants.dart';

/// Dio HTTP client configured to match the web app's Axios setup.
/// Features: JWT auth header, Shop-Id header, retry with exponential backoff.
class ApiClient {
  static final ApiClient _instance = ApiClient._internal();
  factory ApiClient() => _instance;

  late final Dio dio;
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  ApiClient._internal() {
    dio = Dio(BaseOptions(
      baseUrl: AppConstants.apiBaseUrl,
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 15),
      headers: {
        'Content-Type': 'application/json',
        'User-Agent': 'Mozilla/5.0 (Linux; Android 10; Mobile) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Mobile Safari/537.36',
      },
    ));

    // Request interceptor — attach JWT token and Shop-Id
    dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        // Ensure /api prefix
        if (!options.path.startsWith('http') && !options.path.startsWith('/api')) {
          options.path = '/api${options.path.startsWith('/') ? '' : '/'}${options.path}';
        }

        // Attach token
        final token = await _storage.read(key: AppConstants.tokenKey);
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }

        // Attach shop ID
        final shopId = await _storage.read(key: 'current_shop_id');
        if (shopId != null) {
          options.headers['Shop-Id'] = shopId;
        }

        handler.next(options);
      },
      onError: (error, handler) async {
        // Handle 401 — clear auth and redirect to login
        if (error.response?.statusCode == 401) {
          await _clearAuth();
          handler.next(error);
          return;
        }

        // Retry logic with exponential backoff (mirrors web api.ts)
        final config = error.requestOptions;
        final retryCount = config.extra['_retryCount'] ?? 0;

        if (retryCount < AppConstants.maxRetries &&
            error.response != null &&
            (error.response!.statusCode! >= 500 ||
             error.type == DioExceptionType.connectionError)) {
          config.extra['_retryCount'] = retryCount + 1;
          final delay = Duration(
            milliseconds: AppConstants.retryBaseDelay.inMilliseconds *
                (1 << retryCount), // 1s, 2s, 4s
          );
          await Future.delayed(delay);
          try {
            final response = await dio.fetch(config);
            handler.resolve(response);
          } catch (e) {
            handler.next(error);
          }
          return;
        }

        // Show toast for non-retryable errors or final retry failure
        if (retryCount >= AppConstants.maxRetries || (error.response?.statusCode != null && error.response!.statusCode! < 500)) {
          String message = 'An error occurred';
          if (error.response?.data is Map) {
            message = error.response?.data['message'] ?? error.response?.data['error'] ?? message;
          } else if (error.type == DioExceptionType.connectionTimeout) {
            message = 'Connection timed out';
          }
          
          Fluttertoast.showToast(msg: message);
        }

        handler.next(error);
      },
    ));
  }

  Future<void> _clearAuth() async {
    await _storage.delete(key: AppConstants.tokenKey);
    await _storage.delete(key: AppConstants.userKey);
    await _storage.delete(key: AppConstants.currentShopKey);
    await _storage.delete(key: 'current_shop_id');
  }

  /// Store authentication data after login
  Future<void> saveAuth(String token, Map<String, dynamic> user) async {
    await _storage.write(key: AppConstants.tokenKey, value: token);
    await _storage.write(key: AppConstants.userKey, value: _encode(user));
  }

  /// Store current shop ID for API headers
  Future<void> saveShopId(String shopId) async {
    await _storage.write(key: 'current_shop_id', value: shopId);
  }

  /// Store current shop data
  Future<void> saveShop(Map<String, dynamic> shop) async {
    await _storage.write(key: AppConstants.currentShopKey, value: _encode(shop));
    if (shop['id'] != null) {
      await saveShopId(shop['id'].toString());
    }
  }

  /// Get stored token
  Future<String?> getToken() => _storage.read(key: AppConstants.tokenKey);

  /// Get stored user data
  Future<Map<String, dynamic>?> getUser() async {
    final data = await _storage.read(key: AppConstants.userKey);
    return data != null ? _decode(data) : null;
  }

  /// Get stored shop data
  Future<Map<String, dynamic>?> getShop() async {
    final data = await _storage.read(key: AppConstants.currentShopKey);
    return data != null ? _decode(data) : null;
  }

  /// Clear all auth data (logout)
  Future<void> logout() => _clearAuth();

  // JSON encode/decode helpers
  String _encode(Map<String, dynamic> data) => jsonEncode(data);

  Map<String, dynamic> _decode(String encoded) => jsonDecode(encoded);
}
