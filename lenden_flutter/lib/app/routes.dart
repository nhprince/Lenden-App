import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/providers.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/signup_screen.dart';
import '../screens/auth/forgot_password_screen.dart';
import '../screens/shop_selector_screen.dart';
import '../screens/dashboard_screen.dart';
import '../screens/products_screen.dart';
import '../screens/pos_screen.dart';
import '../screens/customers_screen.dart';
import '../screens/transactions_screen.dart';
import '../screens/expenses_screen.dart';
import '../screens/vendors_screen.dart';
import '../screens/services_screen.dart';
import '../screens/trips_screen.dart';
import '../screens/reports_screen.dart';
import '../screens/settings_screen.dart';
import '../screens/staff_screen.dart';
import '../screens/purchases_screen.dart';
import '../widgets/app_shell.dart';

/// GoRouter configuration — mirrors the web app's HashRouter routes.
final routerProvider = Provider<GoRouter>((ref) {
  final auth = ref.watch(authProvider);

  return GoRouter(
    initialLocation: '/',
    redirect: (context, state) {
      final isAuth = auth.isAuthenticated;
      final isLoading = auth.isLoading;
      final isLoginRoute = state.matchedLocation == '/';
      final isSignupRoute = state.matchedLocation == '/signup';
      final isForgotRoute = state.matchedLocation == '/forgot-password';
      final isPublicRoute = isLoginRoute || isSignupRoute || isForgotRoute;

      if (isLoading) return null;

      // Not authenticated → redirect to login
      if (!isAuth && !isPublicRoute) return '/';

      // Authenticated and on login page → go to dashboard or shop selector
      if (isAuth && isPublicRoute) return '/select-shop';

      return null;
    },
    routes: [
      // ─── Public Routes ──────────────────────────────
      GoRoute(
        path: '/',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/signup',
        builder: (context, state) => const SignupScreen(),
      ),
      GoRoute(
        path: '/forgot-password',
        builder: (context, state) => const ForgotPasswordScreen(),
      ),

      // ─── Shop Selection ─────────────────────────────
      GoRoute(
        path: '/select-shop',
        builder: (context, state) => const ShopSelectorScreen(),
      ),

      // ─── App Shell (with bottom nav) ────────────────
      ShellRoute(
        builder: (context, state, child) => AppShell(child: child),
        routes: [
          GoRoute(
            path: '/dashboard',
            builder: (context, state) => const DashboardScreen(),
          ),
          GoRoute(
            path: '/products',
            builder: (context, state) => const ProductsScreen(),
          ),
          GoRoute(
            path: '/pos',
            builder: (context, state) => const POSScreen(),
          ),
          GoRoute(
            path: '/customers',
            builder: (context, state) => const CustomersScreen(),
          ),
          GoRoute(
            path: '/transactions',
            builder: (context, state) => const TransactionsScreen(),
          ),
          GoRoute(
            path: '/expenses',
            builder: (context, state) => const ExpensesScreen(),
          ),
          GoRoute(
            path: '/vendors',
            builder: (context, state) => const VendorsScreen(),
          ),
          GoRoute(
            path: '/purchases',
            builder: (context, state) => const PurchasesScreen(),
          ),
          GoRoute(
            path: '/services',
            builder: (context, state) => const ServicesScreen(),
          ),
          GoRoute(
            path: '/trips',
            builder: (context, state) => const TripsScreen(),
          ),
          GoRoute(
            path: '/staff',
            builder: (context, state) => const StaffScreen(),
          ),
          GoRoute(
            path: '/reports',
            builder: (context, state) => const ReportsScreen(),
          ),
          GoRoute(
            path: '/settings',
            builder: (context, state) => const SettingsScreen(),
          ),
        ],
      ),
    ],
    errorBuilder: (context, state) => const LoginScreen(),
  );
});
