import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../providers/providers.dart';
import '../core/models/models.dart';
import '../app/theme.dart';

class ShopSelectorScreen extends ConsumerStatefulWidget {
  const ShopSelectorScreen({super.key});
  @override
  ConsumerState<ShopSelectorScreen> createState() => _ShopSelectorScreenState();
}

class _ShopSelectorScreenState extends ConsumerState<ShopSelectorScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(shopProvider.notifier).loadShops());
  }

  IconData _getBusinessIcon(String? type) {
    switch (type) {
      case 'bike_sales': return LucideIcons.bike;
      case 'garage': return LucideIcons.wrench;
      case 'furniture': return LucideIcons.armchair;
      case 'showroom': return LucideIcons.monitor;
      case 'pickup_rental': return LucideIcons.truck;
      default: return LucideIcons.store;
    }
  }

  Color _getBusinessColor(String? type) {
    switch (type) {
      case 'bike_sales': return AppTheme.primary600;
      case 'garage': return AppTheme.warning500;
      case 'furniture': return AppTheme.secondary500;
      case 'showroom': return Colors.purple;
      case 'pickup_rental': return AppTheme.danger500;
      default: return AppTheme.primary600;
    }
  }

  @override
  Widget build(BuildContext context) {
    final shopState = ref.watch(shopProvider);
    final auth = ref.watch(authProvider);

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Welcome back,', style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: AppTheme.textSecondary)),
                        Text(auth.user?.name ?? '', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800)),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(LucideIcons.logOut),
                    onPressed: () { ref.read(authProvider.notifier).logout(); context.go('/'); },
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text('Select a shop to get started', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppTheme.textSecondary)),
              const SizedBox(height: 24),

              if (shopState.isLoading)
                const Expanded(child: Center(child: CircularProgressIndicator()))
              else if (shopState.shops.isEmpty)
                Expanded(child: Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
                  Icon(LucideIcons.storefront, size: 64, color: AppTheme.textLight),
                  const SizedBox(height: 16),
                  Text('No shops yet', style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 8),
                  Text('Create your first shop to begin', style: TextStyle(color: AppTheme.textSecondary)),
                ])))
              else
                Expanded(
                  child: GridView.builder(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2, mainAxisSpacing: 16, crossAxisSpacing: 16, childAspectRatio: 0.95,
                    ),
                    itemCount: shopState.shops.length,
                    itemBuilder: (context, index) {
                      final shop = shopState.shops[index];
                      final color = _getBusinessColor(shop.businessType);
                      return GestureDetector(
                        onTap: () {
                          ref.read(shopProvider.notifier).selectShop(shop);
                          context.go('/dashboard');
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: Theme.of(context).cardTheme.color,
                            borderRadius: BorderRadius.circular(AppTheme.radiusLg),
                            border: Border.all(color: Colors.grey.shade200),
                            boxShadow: AppTheme.shadowSoft,
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                width: 56, height: 56,
                                decoration: BoxDecoration(
                                  color: color.withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Icon(_getBusinessIcon(shop.businessType), color: color, size: 28),
                              ),
                              const SizedBox(height: 12),
                              Text(shop.name, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15), textAlign: TextAlign.center, maxLines: 2, overflow: TextOverflow.ellipsis),
                              const SizedBox(height: 4),
                              Text(
                                (shop.businessType ?? 'general').replaceAll('_', ' ').split(' ').map((w) => w[0].toUpperCase() + w.substring(1)).join(' '),
                                style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w600),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
