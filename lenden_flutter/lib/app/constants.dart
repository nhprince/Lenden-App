/// App-wide constants for the Lenden Flutter application.
class AppConstants {
  AppConstants._();

  // API Configuration
  static const String apiBaseUrl = 'https://api.lenden.nhprince.dpdns.org';
  static const String apiPrefix = '/api';

  // Storage Keys
  static const String tokenKey = 'auth_token';
  static const String userKey = 'user_data';
  static const String currentShopKey = 'current_shop';
  static const String languageKey = 'app_language';

  // App Info
  static const String appName = 'Lenden';
  static const String appVersion = '1.0.0';
  static const String currencySymbol = '৳';

  // Pagination
  static const int defaultPageSize = 20;

  // Rate Limits
  static const int maxRetries = 3;
  static const Duration retryBaseDelay = Duration(seconds: 1);
}
