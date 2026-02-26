import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:fl_chart/fl_chart.dart';
import '../providers/providers.dart';
import '../core/api/api_client.dart';
import '../core/models/models.dart';
import '../app/theme.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  Map<String, dynamic> _stats = {};
  List<Transaction> _recentTxns = [];
  List<Product> _lowStockProducts = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  Future<void> _loadDashboardData() async {
    setState(() => _isLoading = true);
    try {
      final statsRes = await ApiClient().dio.get('/api/reports/summary');
      final txnsRes = await ApiClient().dio.get('/api/transactions?limit=5');
      final productsRes = await ApiClient().dio.get('/api/products');

      if (mounted) {
        setState(() {
          _stats = statsRes.data;
          _recentTxns = (txnsRes.data as List).map((e) => Transaction.fromJson(e)).toList();
          final allProducts = (productsRes.data as List).map((e) => Product.fromJson(e)).toList();
          _lowStockProducts = allProducts.where((p) => p.isLowStock).take(5).toList();
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authProvider).user;
    final isEn = ref.watch(languageProvider) == 'en';

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: _loadDashboardData,
        child: _isLoading 
          ? const Center(child: CircularProgressIndicator())
          : CustomScrollView(
          slivers: [
            // Header & Greeting
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${isEn ? 'Good Morning' : 'শুভ সকাল'}, ${user?.name ?? ''} 👋',
                      style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800),
                    ),
                    Text(
                      isEn ? "Here's what's happening today." : "আজকের কার্যক্রমের সারাংশ।",
                      style: TextStyle(color: AppTheme.textSecondary, fontSize: 14),
                    ),
                  ],
                ),
              ),
            ),

            // Stat Cards
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                child: GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: MediaQuery.of(context).size.width > 700 ? 4 : 2,
                  childAspectRatio: MediaQuery.of(context).size.width > 700 ? 1.6 : 1.4,
                  children: [
                    _StatCard(
                      label: isEn ? "Today's Sales" : "আজকের বিক্রয়",
                      value: 'BTDT ${_stats['todaySales']?.toStringAsFixed(0) ?? '0'}',
                      icon: LucideIcons.trendingUp,
                      color: Colors.green,
                    ),
                    _StatCard(
                      label: isEn ? "Total Expenses" : "মোট খরচ",
                      value: 'BTDT ${_stats['totalExpenses']?.toStringAsFixed(0) ?? '0'}',
                      icon: LucideIcons.wallet,
                      color: Colors.red,
                    ),
                    _StatCard(
                      label: isEn ? "Stock Value" : "মজুদ মূল্য",
                      value: 'BTDT ${_stats['inventoryValue']?.toStringAsFixed(0) ?? '0'}',
                      icon: LucideIcons.package2,
                      color: Colors.blue,
                    ),
                    _StatCard(
                      label: isEn ? "Total Customers" : "মোট গ্রাহক",
                      value: '${_stats['totalCustomers'] ?? '0'}',
                      icon: LucideIcons.users,
                      color: Colors.orange,
                    ),
                  ],
                ),
              ),
            ),

            // Sales Trend Chart
            SliverToBoxAdapter(
              child: _SalesChart(isEn: isEn),
            ),

            // Low Stock Alerts
            if (_lowStockProducts.isNotEmpty)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(LucideIcons.alertTriangle, color: AppTheme.danger500, size: 18),
                          const SizedBox(width: 8),
                          Text(isEn ? 'Low Stock Alerts' : 'স্বল্প মজুদ সতর্কতা', style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
                        ],
                      ),
                      const SizedBox(height: 12),
                      ..._lowStockProducts.map((p) => _AlertTile(product: p, isEn: isEn)),
                    ],
                  ),
                ),
              ),

            // Recent Transactions
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(isEn ? 'Recent Transactions' : 'সাম্প্রতিক লেনদেন', style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
                    const SizedBox(height: 12),
                    ..._recentTxns.map((t) => _TxnListItem(transaction: t, isEn: isEn)),
                    const SizedBox(height: 80), // Padding for FAB
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;
  const _StatCard({required this.label, required this.value, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20), side: BorderSide(color: Colors.grey.shade100)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
              child: Icon(icon, color: color, size: 20),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(value, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 18)),
                Text(label, style: TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _SalesChart extends StatelessWidget {
  final bool isEn;
  const _SalesChart({required this.isEn});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 240,
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.fromLTRB(16, 24, 24, 16),
      decoration: BoxDecoration(
        color: AppTheme.primary600.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppTheme.primary600.withValues(alpha: 0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(isEn ? 'Sales Trend' : 'বিক্রয় প্রবণতা', style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
          const SizedBox(height: 20),
          Expanded(
            child: LineChart(
              LineChartData(
                gridData: const FlGridData(show: false),
                titlesData: const FlTitlesData(show: false),
                borderData: FlBorderData(show: false),
                lineBarsData: [
                  LineChartBarData(
                    spots: const [
                      FlSpot(0, 1000), FlSpot(1, 2300), FlSpot(2, 1800),
                      FlSpot(3, 3500), FlSpot(4, 2800), FlSpot(5, 4200),
                      FlSpot(6, 3800),
                    ],
                    isCurved: true,
                    color: AppTheme.primary600,
                    barWidth: 4,
                    isStrokeCapRound: true,
                    dotData: const FlDotData(show: false),
                    belowBarData: BarAreaData(
                      show: true,
                      color: AppTheme.primary600.withValues(alpha: 0.1),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AlertTile extends StatelessWidget {
  final Product product;
  final bool isEn;
  const _AlertTile({required this.product, required this.isEn});
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(color: Colors.red.shade50, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.red.shade100)),
      child: Row(
        children: [
          Expanded(child: Text(product.name, style: const TextStyle(fontWeight: FontWeight.w600))),
          Text('${isEn ? 'Stock' : 'মজুদ'}: ${product.stockQuantity}', style: const TextStyle(color: Colors.red, fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}

class _TxnListItem extends StatelessWidget {
  final Transaction transaction;
  final bool isEn;
  const _TxnListItem({required this.transaction, required this.isEn});
  @override
  Widget build(BuildContext context) {
    final color = transaction.type == 'SALE' ? Colors.green : Colors.red;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(width: 40, height: 40, decoration: BoxDecoration(color: color.withValues(alpha: 0.1), shape: BoxShape.circle), child: Icon(transaction.type == 'SALE' ? LucideIcons.arrowDownLeft : LucideIcons.arrowUpRight, color: color, size: 18)),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(transaction.customerName ?? transaction.vendorName ?? (isEn ? 'General' : 'সাধারণ'), style: const TextStyle(fontWeight: FontWeight.w600)), Text(transaction.date.toString().split(' ')[0], style: TextStyle(color: AppTheme.textLight, fontSize: 11))])),
          Text('${transaction.type == 'SALE' ? '+' : '-'}BTDT ${transaction.amount.toStringAsFixed(0)}', style: TextStyle(fontWeight: FontWeight.w800, color: color)),
        ],
      ),
    );
  }
}
