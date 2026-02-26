import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../core/api/api_client.dart';
import '../core/models/models.dart';
import '../core/utils/invoice_generator.dart';
import '../providers/providers.dart';
import '../app/theme.dart';

class TransactionsScreen extends ConsumerStatefulWidget {
  const TransactionsScreen({super.key});

  @override
  ConsumerState<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends ConsumerState<TransactionsScreen> {
  List<Transaction> _transactions = [];
  bool _isLoading = true;
  String? _typeFilter;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _isLoading = true);
    try {
      final res = await ApiClient().dio.get('/api/transactions');
      setState(() {
        _transactions = (res.data as List).map((e) => Transaction.fromJson(e)).toList();
        _isLoading = false;
      });
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  List<Transaction> get _filtered {
    if (_typeFilter == null || _typeFilter == 'ALL') return _transactions;
    return _transactions.where((t) => t.type == _typeFilter).toList();
  }

  @override
  Widget build(BuildContext context) {
    final isEn = ref.watch(languageProvider) == 'en';

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: _load,
        child: Column(
          children: [
            // Filter Tabs
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  _FilterChip(label: isEn ? 'All' : 'সব', isSelected: _typeFilter == null || _typeFilter == 'ALL', onSelected: () => setState(() => _typeFilter = 'ALL')),
                  _FilterChip(label: isEn ? 'Sales' : 'বিক্রয়', isSelected: _typeFilter == 'SALE', onSelected: () => setState(() => _typeFilter = 'SALE')),
                  _FilterChip(label: isEn ? 'Purchases' : 'ক্রয়', isSelected: _typeFilter == 'PURCHASE', onSelected: () => setState(() => _typeFilter = 'PURCHASE')),
                  _FilterChip(label: isEn ? 'Expenses' : 'খরচ', isSelected: _typeFilter == 'EXPENSE', onSelected: () => setState(() => _typeFilter = 'EXPENSE')),
                  _FilterChip(label: isEn ? 'Payments' : 'পেমেন্ট', isSelected: _typeFilter == 'PAYMENT_RECEIVED' || _typeFilter == 'PAYMENT_MADE', onSelected: () => setState(() => _typeFilter = 'PAYMENT_RECEIVED')),
                ],
              ),
            ),

            if (_isLoading)
              const Expanded(child: Center(child: CircularProgressIndicator()))
            else if (_filtered.isEmpty)
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(LucideIcons.fileText, size: 48, color: AppTheme.textLight),
                      const SizedBox(height: 12),
                      Text(isEn ? 'No transactions found' : 'কোনো লেনদেন পাওয়া যায়নি'),
                    ],
                  ),
                ),
              )
            else
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: _filtered.length,
                  itemBuilder: (context, i) {
                    final t = _filtered[i];
                    return _TransactionTile(transaction: t, isEn: isEn);
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onSelected;
  const _FilterChip({required this.label, required this.isSelected, required this.onSelected});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (_) => onSelected(),
        selectedColor: AppTheme.primary600.withValues(alpha: 0.1),
        checkmarkColor: AppTheme.primary600,
        labelStyle: TextStyle(
          color: isSelected ? AppTheme.primary600 : AppTheme.textSecondary,
          fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
          fontSize: 13,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: isSelected ? AppTheme.primary600 : Colors.grey.shade300),
        ),
      ),
    );
  }
}

class _TransactionTile extends StatelessWidget {
  final Transaction transaction;
  final bool isEn;
  const _TransactionTile({required this.transaction, required this.isEn});

  @override
  Widget build(BuildContext context) {
    final color = _getTypeColor(transaction.type);
    final icon = _getTypeIcon(transaction.type);

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: BorderSide(color: Colors.grey.shade200)),
      child: InkWell(
        onTap: () => _showDetails(context),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(color: color.withValues(alpha: 0.05), shape: BoxShape.circle),
                child: Icon(icon, color: color, size: 20),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      transaction.customerName ?? transaction.vendorName ?? (isEn ? 'General Transaction' : 'সাধারণ লেনদেন'),
                      style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${_formatDate(transaction.date)} • ${transaction.paymentMethod?.toUpperCase()}',
                      style: TextStyle(color: AppTheme.textLight, fontSize: 11),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${_getTypePrefix(transaction.type)}৳${transaction.amount.toStringAsFixed(0)}',
                    style: TextStyle(fontWeight: FontWeight.w800, color: color, fontSize: 16),
                  ),
                  _StatusBadge(status: transaction.status, isEn: isEn),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showDetails(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _TransactionDetailSheet(transaction: transaction, isEn: isEn),
    );
  }

  Color _getTypeColor(String type) {
    switch (type) {
      case 'SALE':
      case 'PAYMENT_RECEIVED':
        return Colors.green;
      case 'PURCHASE':
      case 'PAYMENT_MADE':
      case 'EXPENSE':
        return Colors.red;
      default:
        return AppTheme.primary600;
    }
  }

  IconData _getTypeIcon(String type) {
    switch (type) {
      case 'SALE': return LucideIcons.shoppingCart;
      case 'PURCHASE': return LucideIcons.shoppingBag;
      case 'EXPENSE': return LucideIcons.wallet;
      case 'PAYMENT_RECEIVED': return LucideIcons.arrowDownLeft;
      case 'PAYMENT_MADE': return LucideIcons.arrowUpRight;
      default: return LucideIcons.fileText;
    }
  }

  String _getTypePrefix(String type) {
    if (type == 'SALE' || type == 'PAYMENT_RECEIVED') return '+';
    if (type == 'PURCHASE' || type == 'PAYMENT_MADE' || type == 'EXPENSE') return '-';
    return '';
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}

class _StatusBadge extends StatelessWidget {
  final String status;
  final bool isEn;
  const _StatusBadge({required this.status, required this.isEn});

  @override
  Widget build(BuildContext context) {
    final color = status == 'COMPLETED' ? Colors.green : status == 'PENDING' ? Colors.orange : Colors.red;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(4)),
      child: Text(
        isEn ? status : (status == 'COMPLETED' ? 'সম্পন্ন' : status == 'PENDING' ? 'চলমান' : 'বাতিল'),
        style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.w700),
      ),
    );
  }
}

class _TransactionDetailSheet extends ConsumerStatefulWidget {
  final Transaction transaction;
  final bool isEn;
  const _TransactionDetailSheet({required this.transaction, required this.isEn});

  @override
  ConsumerState<_TransactionDetailSheet> createState() => _TransactionDetailSheetState();
}

class _TransactionDetailSheetState extends ConsumerState<_TransactionDetailSheet> {
  bool _isPrinting = false;

  @override
  Widget build(BuildContext context) {
    final shop = ref.watch(shopProvider).currentShop;

    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      builder: (_, controller) => Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: ListView(
          controller: controller,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(isEn ? 'Transaction Details' : 'লেনদেনের তথ্য', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
                IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(LucideIcons.x)),
              ],
            ),
            const Divider(),
            const SizedBox(height: 16),
            _KeyValue(label: widget.isEn ? 'Order ID' : 'অর্ডার আইডি', value: '#${widget.transaction.id}'),
            _KeyValue(label: widget.isEn ? 'Date' : 'তারিখ', value: widget.transaction.date.toString().split(' ')[0]),
            _KeyValue(label: widget.isEn ? 'Type' : 'ধরণ', value: widget.transaction.type),
            _KeyValue(label: widget.isEn ? 'Status' : 'অবস্থা', value: widget.transaction.status),
            const Divider(height: 32),
            _KeyValue(label: widget.isEn ? 'Total Amount' : 'সর্বমোট', value: '৳${widget.transaction.amount.toStringAsFixed(0)}', isBold: true),
            _KeyValue(label: widget.isEn ? 'Paid Amount' : 'পরিশোধিত', value: '৳${widget.transaction.paidAmount.toStringAsFixed(0)}', color: Colors.green),
            _KeyValue(label: widget.isEn ? 'Balance Due' : 'বাকি', value: '৳${widget.transaction.dueAmount.toStringAsFixed(0)}', color: Colors.red, isBold: true),
            const SizedBox(height: 24),
            _KeyValue(label: widget.isEn ? 'Customer/Vendor' : 'গ্রাহক/সরবরাহকারী', value: widget.transaction.customerName ?? widget.transaction.vendorName ?? '-'),
            _KeyValue(label: widget.isEn ? 'Payment Method' : 'পেমেন্ট মাধ্যম', value: widget.transaction.paymentMethod?.toUpperCase() ?? '-'),
            if (widget.transaction.note != null && widget.transaction.note!.isNotEmpty)
              _KeyValue(label: widget.isEn ? 'Note' : 'নোট', value: widget.transaction.note!),
            const SizedBox(height: 40),
            if (widget.transaction.type == 'SALE')
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _isPrinting ? null : () async {
                    if (shop == null) return;
                    setState(() => _isPrinting = true);
                    try {
                      final id = widget.transaction.id;
                      final res = await ApiClient().dio.get('/api/transactions/$id');
                      final items = (res.data['items'] as List).map((i) => CartItem(
                        product: Product.fromJson(i['Product']),
                        quantity: i['quantity'],
                        price: (i['unit_price'] as num).toDouble(),
                      )).toList();
                      
                      await InvoiceGenerator.generateAndPrintSalesInvoice(widget.transaction, items, shop);
                    } catch (_) {}
                    if (mounted) setState(() => _isPrinting = false);
                  },
                  icon: _isPrinting 
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : const Icon(LucideIcons.printer),
                  label: Text(widget.isEn ? 'Print Invoice' : 'ইনভয়েস প্রিন্ট করুন'),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _KeyValue extends StatelessWidget {
  final String label;
  final String value;
  final Color? color;
  final bool isBold;
  const _KeyValue({required this.label, required this.value, this.color, this.isBold = false});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: AppTheme.textSecondary, fontWeight: isBold ? FontWeight.bold : null)),
          Text(value, style: TextStyle(fontWeight: isBold ? FontWeight.w800 : FontWeight.w600, color: color, fontSize: isBold ? 16 : 14)),
        ],
      ),
    );
  }
}
