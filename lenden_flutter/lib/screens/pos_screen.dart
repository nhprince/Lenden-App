import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../providers/providers.dart';
import '../core/api/api_client.dart';
import '../core/models/models.dart';
import 'dart:convert';
import 'package:cached_network_image/cached_network_image.dart';
import '../core/utils/invoice_generator.dart';
import '../core/utils/notification_service.dart';
import '../app/theme.dart';

class POSScreen extends ConsumerStatefulWidget {
  const POSScreen({super.key});

  @override
  ConsumerState<POSScreen> createState() => _POSScreenState();
}

class _POSScreenState extends ConsumerState<POSScreen> {
  final _searchController = TextEditingController();
  List<Product> _allProducts = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  Future<void> _loadProducts() async {
    setState(() => _isLoading = true);
    try {
      final res = await ApiClient().dio.get('/api/products');
      setState(() {
        _allProducts = (res.data as List).map((e) => Product.fromJson(e)).toList();
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  List<Product> get _filteredProducts {
    final query = _searchController.text.toLowerCase();
    if (query.isEmpty) return _allProducts;
    return _allProducts.where((p) =>
      p.name.toLowerCase().contains(query) ||
      (p.sku?.toLowerCase().contains(query) ?? false)
    ).toList();
  }

  @override
  Widget build(BuildContext context) {
    final posState = ref.watch(posProvider);
    final isEn = ref.watch(languageProvider) == 'en';

    return Scaffold(
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(
                hintText: isEn ? 'Search products by name or SKU...' : 'পণ্য খুঁজুন...',
                prefixIcon: const Icon(LucideIcons.search, size: 20),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(LucideIcons.x, size: 18),
                        onPressed: () { _searchController.clear(); setState(() {}); },
                      )
                    : null,
              ),
            ),
          ),

          // Product List
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredProducts.isEmpty
                    ? Center(child: Text(isEn ? 'No products found' : 'এখনো কোনো পণ্য নেই'))
                    : GridView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: MediaQuery.of(context).size.width > 700 ? 4 : 2,
                          childAspectRatio: 0.85,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                        ),
                        itemCount: _filteredProducts.length,
                        itemBuilder: (context, index) {
                          final product = _filteredProducts[index];
                          final isInCart = posState.items.any((i) => i.product.id == product.id);
                          return _ProductCard(
                            product: product,
                            isInCart: isInCart,
                            onAdd: () => ref.read(posProvider.notifier).addToCart(product),
                          );
                        },
                      ),
          ),
        ],
      ),
      floatingActionButton: posState.items.isNotEmpty
          ? FloatingActionButton.extended(
              onPressed: () => _showCartDrawer(context),
              icon: const Icon(LucideIcons.shoppingCart),
              label: Text('${posState.items.length} ${isEn ? 'Items' : 'আইটেম'} | ৳${posState.total.toStringAsFixed(0)}'),
              backgroundColor: AppTheme.primary600,
            )
          : null,
    );
  }

  void _showCartDrawer(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const _CartBottomSheet(),
    );
  }
}

class _ProductCard extends StatelessWidget {
  final Product product;
  final bool isInCart;
  final VoidCallback onAdd;

  const _ProductCard({required this.product, required this.isInCart, required this.onAdd});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isInCart ? AppTheme.primary600 : Colors.grey.shade200, width: isInCart ? 2 : 1),
        boxShadow: AppTheme.shadowSoft,
      ),
      child: InkWell(
        onTap: onAdd,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Product Image Placeholder
              Container(
                height: 80,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: AppTheme.primary50,
                  borderRadius: BorderRadius.circular(12),
                  image: product.image != null
                      ? (product.image!.startsWith('data:')
                          ? DecorationImage(
                              image: MemoryImage(base64Decode(product.image!.split(',').last)),
                              fit: BoxFit.cover,
                            )
                          : DecorationImage(
                              image: CachedNetworkImageProvider(product.image!),
                              fit: BoxFit.cover,
                            ))
                      : null,
                ),
                child: product.image == null 
                  ? const Icon(LucideIcons.package_, color: AppTheme.primary600, size: 32)
                  : null,
              ),
              const SizedBox(height: 8),
              Text(
                product.name,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
              ),
              const Spacer(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '৳${product.sellingPrice.toStringAsFixed(0)}',
                    style: const TextStyle(fontWeight: FontWeight.w800, color: AppTheme.primary600, fontSize: 14),
                  ),
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: isInCart ? AppTheme.primary600 : AppTheme.primary50,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      isInCart ? LucideIcons.check : LucideIcons.plus,
                      color: isInCart ? Colors.white : AppTheme.primary600,
                      size: 16,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CartBottomSheet extends ConsumerWidget {
  const _CartBottomSheet();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(posProvider);
    final isEn = ref.watch(languageProvider) == 'en';

    return DraggableScrollableSheet(
      initialChildSize: 0.85,
      minChildSize: 0.6,
      maxChildSize: 0.95,
      builder: (_, controller) => Container(
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          children: [
            const SizedBox(height: 12),
            Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2))),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  const Icon(LucideIcons.shoppingCart, size: 24),
                  const SizedBox(width: 12),
                  Text(isEn ? 'Cart View' : 'কার্ট ভিউ', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
                  const Spacer(),
                  TextButton(onPressed: () => ref.read(posProvider.notifier).clear(), child: Text(isEn ? 'Clear' : 'মুছুন', style: const TextStyle(color: Colors.red))),
                ],
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: ListView.separated(
                controller: controller,
                padding: const EdgeInsets.all(16),
                itemCount: state.items.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final item = state.items[index];
                  return Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(item.product.name, style: const TextStyle(fontWeight: FontWeight.w600)),
                            Text('৳${item.price.toStringAsFixed(0)} × ${item.quantity}', style: TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
                          ],
                        ),
                      ),
                      Row(
                        children: [
                          _QtyBtn(icon: LucideIcons.minus, onTap: () => ref.read(posProvider.notifier).updateQuantity(item.product.id, item.quantity - 1)),
                          const SizedBox(width: 12),
                          Text('${item.quantity}', style: const TextStyle(fontWeight: FontWeight.w700)),
                          const SizedBox(width: 12),
                          _QtyBtn(icon: LucideIcons.plus, onTap: () => ref.read(posProvider.notifier).updateQuantity(item.product.id, item.quantity + 1)),
                        ],
                      ),
                    ],
                  );
                },
              ),
            ),
            _CheckoutSummary(state: state, isEn: isEn),
          ],
        ),
      ),
    );
  }
}

class _QtyBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _QtyBtn({required this.icon, required this.onTap});
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade300), borderRadius: BorderRadius.circular(8)),
        child: Icon(icon, size: 16),
      ),
    );
  }
}

class _CheckoutSummary extends ConsumerWidget {
  final POSState state;
  final bool isEn;
  const _CheckoutSummary({required this.state, required this.isEn});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, -5))],
      ),
      child: SafeArea(
        child: Column(
          children: [
            _SumRow(label: isEn ? 'Subtotal' : 'সাবটোটাল', value: '৳${state.subtotal.toStringAsFixed(0)}'),
            _SumRow(label: isEn ? 'Total' : 'সর্বমোট', value: '৳${state.total.toStringAsFixed(0)}', isBold: true),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: state.isSubmitting ? null : () async {
                  final notifier = ref.read(posProvider.notifier);
                  final currentItems = List<CartItem>.from(state.items);
                  final shop = ref.read(shopProvider).currentShop;

                  final txnId = await notifier.submitSale();
                  if (txnId != null && context.mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(isEn ? 'Sale completed!' : 'বিক্রয় সম্পন্ন হয়েছে!')));
                    
                    // Trigger PDF Print
                    if (shop != null) {
                      final txn = Transaction(
                        id: txnId,
                        type: 'SALE',
                        amount: state.total,
                        paidAmount: state.paidAmount,
                        dueAmount: state.total - state.paidAmount,
                        date: DateTime.now(),
                        status: 'COMPLETED',
                        customerName: state.selectedCustomer?.name,
                        customerPhone: state.selectedCustomer?.phone,
                        paymentMethod: state.paymentMethod,
                        discount: state.discount,
                      );
                      InvoiceGenerator.generateAndPrintSalesInvoice(txn, currentItems, shop);
                      
                      // Show Local Notification
                      NotificationService().showNotification(
                        id: txnId,
                        title: isEn ? 'Sale Successful' : 'বিক্রয় সফল হয়েছে',
                        body: isEn 
                          ? 'Total: BTDT ${state.total.toStringAsFixed(2)} for ${currentItems.length} items.'
                          : 'মোট: BTDT ${state.total.toStringAsFixed(2)}, ${currentItems.length}টি আইটেম।',
                      );
                    }
                  }
                },
                child: state.isSubmitting
                  ? const CircularProgressIndicator(color: Colors.white)
                  : Text(isEn ? 'Complete Sale' : 'বিক্রয় সম্পন্ন করুন'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SumRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isBold;
  const _SumRow({required this.label, required this.value, this.isBold = false});
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: isBold ? null : AppTheme.textSecondary, fontWeight: isBold ? FontWeight.w700 : null)),
          Text(value, style: TextStyle(fontWeight: isBold ? FontWeight.w800 : FontWeight.w600, fontSize: isBold ? 18 : 14)),
        ],
      ),
    );
  }
}
