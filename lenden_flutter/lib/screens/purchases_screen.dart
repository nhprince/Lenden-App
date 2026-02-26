import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:intl/intl.dart';
import '../core/api/api_client.dart';
import '../core/models/models.dart';
import '../providers/providers.dart';
import '../app/theme.dart';

class PurchasesScreen extends ConsumerStatefulWidget {
  const PurchasesScreen({super.key});

  @override
  ConsumerState<PurchasesScreen> createState() => _PurchasesScreenState();
}

class _PurchasesScreenState extends ConsumerState<PurchasesScreen> {
  List<Transaction> _purchases = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _isLoading = true);
    try {
      final res = await ApiClient().dio.get('/api/transactions?type=PURCHASE');
      if (mounted) {
        setState(() {
          _purchases = (res.data as List).map((e) => Transaction.fromJson(e)).toList();
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEn = ref.watch(languageProvider) == 'en';

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: _load,
        child: Column(
          children: [
            if (_isLoading)
              const Expanded(child: Center(child: CircularProgressIndicator()))
            else if (_purchases.isEmpty)
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(LucideIcons.shoppingBag, size: 48, color: AppTheme.textLight),
                      const SizedBox(height: 12),
                      Text(isEn ? 'No purchases found' : 'কোনো ক্রয় পাওয়া যায়নি'),
                    ],
                  ),
                ),
              )
            else
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _purchases.length,
                  itemBuilder: (context, i) {
                    final p = _purchases[i];
                    return _PurchaseTile(purchase: p, isEn: isEn);
                  },
                ),
              ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showPurchaseForm(context),
        backgroundColor: AppTheme.primary600,
        icon: const Icon(LucideIcons.plus, color: Colors.white),
        label: Text(isEn ? 'New Purchase' : 'নতুন ক্রয়', style: const TextStyle(color: Colors.white)),
      ),
    );
  }

  void _showPurchaseForm(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _PurchaseFormSheet(onSaved: _load),
    );
  }
}

class _PurchaseTile extends StatelessWidget {
  final Transaction purchase;
  final bool isEn;
  const _PurchaseTile({required this.purchase, required this.isEn});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(color: Colors.blue.withValues(alpha: 0.05), shape: BoxShape.circle),
          child: const Icon(LucideIcons.shoppingBag, color: Colors.blue, size: 20),
        ),
        title: Text(
          purchase.vendorName ?? (isEn ? 'Direct Purchase' : 'সরাসরি ক্রয়'),
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(_formatDate(DateTime.tryParse(purchase.date ?? '') ?? DateTime.now()), style: TextStyle(color: AppTheme.textLight, fontSize: 11)),
            if (purchase.note != null && purchase.note!.isNotEmpty)
              Text(purchase.note!, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
          ],
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              'BTDT ${purchase.amount.toStringAsFixed(2)}',
              style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(color: Colors.green.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(4)),
              child: Text(isEn ? 'Paid' : 'পরিশোধিত', style: const TextStyle(color: Colors.green, fontSize: 10, fontWeight: FontWeight.w700)),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return DateFormat('dd MMM yyyy').format(date);
  }
}

class _PurchaseFormSheet extends ConsumerStatefulWidget {
  final VoidCallback onSaved;
  const _PurchaseFormSheet({required this.onSaved});

  @override
  ConsumerState<_PurchaseFormSheet> createState() => _PurchaseFormSheetState();
}

class _PurchaseFormSheetState extends ConsumerState<_PurchaseFormSheet> {
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();
  List<Vendor> _vendors = [];
  Vendor? _selectedVendor;
  bool _isLoadingVendors = true;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _loadVendors();
  }

  Future<void> _loadVendors() async {
    try {
      final res = await ApiClient().dio.get('/api/vendors');
      if (mounted) {
        setState(() {
          _vendors = (res.data as List).map((e) => Vendor.fromJson(e)).toList();
          _isLoadingVendors = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isLoadingVendors = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEn = ref.watch(languageProvider) == 'en';

    return DraggableScrollableSheet(
      initialChildSize: 0.8,
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
                Text(isEn ? 'Record Purchase' : 'ক্রয় যোগ করুন', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
                IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(LucideIcons.x)),
              ],
            ),
            const Divider(),
            const SizedBox(height: 16),
            if (_isLoadingVendors)
              const LinearProgressIndicator()
            else
              DropdownButtonFormField<Vendor>(
                value: _selectedVendor,
                decoration: InputDecoration(labelText: isEn ? 'Select Vendor' : 'সরবরাহকারী নির্বাচন করুন'),
                items: _vendors.map((v) => DropdownMenuItem(value: v, child: Text(v.name))).toList(),
                onChanged: (v) => setState(() => _selectedVendor = v),
              ),
            const SizedBox(height: 16),
            TextField(
              controller: _amountController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(label: Text(isEn ? 'Total Amount*' : 'সর্বমোট পরিমাণ*'), prefixText: 'BTDT  '),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _noteController,
              maxLines: 2,
              decoration: InputDecoration(label: Text(isEn ? 'Items/Notes' : 'বিবরণ/নোট')),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: _isSaving ? null : _save,
              child: _isSaving ? const CircularProgressIndicator() : Text(isEn ? 'Save Purchase' : 'ক্রয় সংরক্ষণ করুন'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _save() async {
    final amount = double.tryParse(_amountController.text);
    if (amount == null || amount <= 0) return;
    setState(() => _isSaving = true);
    try {
      await ApiClient().dio.post('/api/transactions/purchase', data: {
        'vendor_id': _selectedVendor?.id,
        'amount': amount,
        'paid_amount': amount, // Simplified for now
        'payment_method': 'cash',
        'description': _noteController.text, // Corrected from 'note'
      });
      widget.onSaved();
      if (mounted) Navigator.pop(context);
    } catch (_) {
      setState(() => _isSaving = false);
    }
  }
}
