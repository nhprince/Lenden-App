import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../providers/providers.dart';
import '../app/theme.dart';
import 'notification_bell.dart';

/// App Shell — provides bottom navigation and drawer for the main app screens.
/// Mirrors the web app's Layout.tsx sidebar navigation.
class AppShell extends ConsumerStatefulWidget {
  final Widget child;
  const AppShell({super.key, required this.child});

  @override
  ConsumerState<AppShell> createState() => _AppShellState();
}

class _AppShellState extends ConsumerState<AppShell> {
  int _currentIndex = 0;

  static const _navItems = [
    _NavItem('/dashboard', LucideIcons.layoutDashboard, 'Dashboard', 'ড্যাশবোর্ড'),
    _NavItem('/pos', LucideIcons.shoppingCart, 'POS', 'বিক্রয়'),
    _NavItem('/products', LucideIcons.package, 'Inventory', 'মজুদ'),
    _NavItem('/transactions', LucideIcons.receipt, 'Transactions', 'লেনদেন'),
    _NavItem('/settings', LucideIcons.settings, 'More', 'আরো'),
  ];

  static const _drawerItems = [
    _NavItem('/dashboard', LucideIcons.layoutDashboard, 'Dashboard', 'ড্যাশবোর্ড'),
    _NavItem('/pos', LucideIcons.shoppingCart, 'POS', 'বিক্রয় কেন্দ্র'),
    _NavItem('/products', LucideIcons.package, 'Inventory', 'মজুদ পণ্য'),
    _NavItem('/customers', LucideIcons.users, 'Customers', 'গ্রাহক তালিকা'),
    _NavItem('/transactions', LucideIcons.receipt, 'Transactions', 'লেনদেন'),
    _NavItem('/expenses', LucideIcons.wallet, 'Expenses', 'খরচপাতি'),
    _NavItem('/vendors', LucideIcons.truck, 'Vendors', 'সরবরাহকারী'),
    _NavItem('/purchases', LucideIcons.shoppingBag, 'Purchases', 'ক্রয়'),
    _NavItem('/services', LucideIcons.wrench, 'Services', 'সেবাসমূহ'),
    _NavItem('/trips', LucideIcons.mapPin, 'Trips', 'রেন্টাল ট্রিপ'),
    _NavItem('/staff', LucideIcons.userCheck, 'Staff', 'কর্মচারী'),
    _NavItem('/reports', LucideIcons.barChart3, 'Reports', 'রিপোর্ট'),
    _NavItem('/settings', LucideIcons.settings, 'Settings', 'সেটিংস'),
  ];

  @override
  void didUpdateWidget(AppShell oldWidget) {
    super.didUpdateWidget(oldWidget);
    _updateIndex();
  }

  void _updateIndex() {
    final location = GoRouterState.of(context).matchedLocation;
    for (int i = 0; i < _navItems.length; i++) {
      if (location.startsWith(_navItems[i].path)) {
        if (_currentIndex != i) setState(() => _currentIndex = i);
        return;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final lang = ref.watch(languageProvider);
    final shop = ref.watch(shopProvider).currentShop;
    final auth = ref.watch(authProvider);
    final isEn = lang == 'en';
    final connectivity = ref.watch(connectivityProvider).value;
    final isOffline = connectivity != null && connectivity.contains(ConnectivityResult.none);
    final size = MediaQuery.of(context).size;
    final isWide = size.width > 700;

    return Scaffold(
      appBar: AppBar(
        leading: isWide ? const SizedBox.shrink() : null,
        bottom: isOffline ? PreferredSize(
          preferredSize: const Size.fromHeight(30),
          child: Container(
            color: Colors.red,
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Text(
              isEn ? 'OFFLINE MODE' : 'অফলাইন মোড',
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
            ),
          ),
        ) : null,
        title: Text(shop?.name ?? 'Lenden'),
        actions: [
          // Shop switcher
          if (auth.user?.isOwner == true)
            IconButton(
              icon: const Icon(LucideIcons.store),
              tooltip: 'Switch Shop',
              onPressed: () => context.go('/select-shop'),
            ),
          // Notifications
          const NotificationBell(),
        ],
      ),
      drawer: Drawer(
        child: SafeArea(
          child: Column(
            children: [
              // User header
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Theme.of(context).colorScheme.primary,
                      Theme.of(context).colorScheme.primary.withValues(alpha: 0.8),
                    ],
                  ),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 24,
                      backgroundColor: Colors.white24,
                      child: Text(
                        (auth.user?.name ?? 'U')[0].toUpperCase(),
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.w700),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            auth.user?.name ?? '',
                            style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                                fontSize: 16),
                          ),
                          Text(
                            shop?.name ?? '',
                            style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.8),
                                fontSize: 13),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              // Navigation items
              Expanded(
                child: ListView(
                  padding: EdgeInsets.zero,
                  children: _drawerItems.map((item) {
                    final isActive =
                        GoRouterState.of(context).matchedLocation == item.path;
                    return ListTile(
                      leading: Icon(
                        item.icon,
                        color: isActive
                            ? Theme.of(context).colorScheme.primary
                            : null,
                        size: 22,
                      ),
                      title: Text(
                        isEn ? item.labelEn : item.labelBn,
                        style: TextStyle(
                          fontWeight:
                              isActive ? FontWeight.w600 : FontWeight.w500,
                          color: isActive
                              ? Theme.of(context).colorScheme.primary
                              : null,
                        ),
                      ),
                      selected: isActive,
                      selectedTileColor: Theme.of(context)
                          .colorScheme
                          .primary
                          .withValues(alpha: 0.08),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      onTap: () {
                        Navigator.pop(context);
                        context.go(item.path);
                      },
                    );
                  }).toList(),
                ),
              ),
              // Logout
              const Divider(),
              ListTile(
                leading: const Icon(LucideIcons.logOut, color: Colors.red),
                title: Text(
                  isEn ? 'Log out' : 'লগ আউট',
                  style: const TextStyle(color: Colors.red),
                ),
                onTap: () {
                  ref.read(authProvider.notifier).logout();
                  context.go('/');
                },
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
      body: Row(
        children: [
          if (isWide)
            _WideSidebar(
              items: _drawerItems,
              isEn: isEn,
              currentPath: GoRouterState.of(context).matchedLocation,
              onSelect: (path) => context.go(path),
            ),
          Expanded(child: widget.child),
        ],
      ),
      bottomNavigationBar: isWide ? null : BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() => _currentIndex = index);
          context.go(_navItems[index].path);
        },
        items: _navItems
            .map((item) => BottomNavigationBarItem(
                  icon: Icon(item.icon),
                  label: isEn ? item.labelEn : item.labelBn,
                ))
            .toList(),
      ),
    );
  }
}

class _WideSidebar extends StatelessWidget {
  final List<_NavItem> items;
  final bool isEn;
  final String currentPath;
  final Function(String) onSelect;

  const _WideSidebar({
    required this.items,
    required this.isEn,
    required this.currentPath,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 260,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(right: BorderSide(color: Colors.grey.shade200)),
      ),
      child: ListView(
        children: [
          const SizedBox(height: 20),
          ...items.map((item) {
            final isActive = currentPath.startsWith(item.path);
            return ListTile(
              leading: Icon(item.icon, color: isActive ? AppTheme.primary600 : AppTheme.textSecondary),
              title: Text(
                isEn ? item.labelEn : item.labelBn,
                style: TextStyle(
                  color: isActive ? AppTheme.primary600 : AppTheme.textSecondary,
                  fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                ),
              ),
              selected: isActive,
              selectedTileColor: AppTheme.primary600.withValues(alpha: 0.05),
              onTap: () => onSelect(item.path),
            );
          }),
        ],
      ),
    );
  }
}

class _NavItem {
  final String path;
  final IconData icon;
  final String labelEn;
  final String labelBn;

  const _NavItem(this.path, this.icon, this.labelEn, this.labelBn);
}
