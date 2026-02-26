class AppConstants {
  static const String apiBaseUrl = 'https://api.yourdomain.com'; // User should change this
  static const String tokenKey = 'lenden_token';
  static const String userKey = 'lenden_user';
  static const String currentShopKey = 'lenden_current_shop';
  static const String languageKey = 'lenden_language';
  
  static const int maxRetries = 3;
  static const Duration retryBaseDelay = Duration(seconds: 1);
}
