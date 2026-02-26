import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../core/api/api_client.dart';
import '../core/models/models.dart';
import '../providers/providers.dart';
import '../app/theme.dart';

class VendorsScreen extends ConsumerStatefulWidget {
  const VendorsScreen({super.key});

  @override
  ConsumerState<VendorsScreen> createState() => _VendorsScreenState();
}

class _VendorsScreenState extends ConsumerState<VendorsScreen> {
  List<Vendor> _vendors = [];
  bool _isLoading = true;
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _isLoading = true);
    try {
      final res = await ApiClient().dio.get('/api/vendors');
      if (mounted) {
        setState(() {
          _vendors = (res.data as List).map((e) => Vendor.fromJson(e)).toList();
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  List<Vendor> get _filtered {
    final q = _searchController.text.toLowerCase();
    if (q.isEmpty) return _vendors;
    return _vendors.where((v) =>
      v.name.toLowerCase().contains(q) ||
      (v.companyName?.toLowerCase().contains(q) ?? false)
    ).toList();
  }

  @override
  Widget build(BuildContext context) {
    final isEn = ref.watch(languageProvider) == 'en';

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: _load,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: TextField(
                controller: _searchController,
                onChanged: (_) => setState(() {}),
                decoration: InputDecoration(
                  hintText: isEn ? 'Search vendors...' : 'সরবরাহকারী খুঁজুন...',
                  prefixIcon: const Icon(LucideIcons.search, size: 20),
                ),
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
                      Icon(LucideIcons.truck, size: 48, color: AppTheme.textLight),
                      const SizedBox(height: 12),
                      Text(isEn ? 'No vendors found' : 'কোনো সরবরাহকারী পাওয়া যায়নি'),
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
                    final v = _filtered[i];
                    return _VendorTile(vendor: v, isEn: isEn, onUpdate: _load);
                  },
                ),
              ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showVendorForm(null),
        backgroundColor: AppTheme.primary600,
        child: const Icon(LucideIcons.userPlus, color: Colors.white),
      ),
    );
  }

  void _showVendorForm(Vendor? vendor) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _VendorFormSheet(vendor: vendor, onSaved: _load),
    );
  }
}

class _VendorTile extends StatelessWidget {
  final Vendor vendor;
  final bool isEn;
  final VoidCallback onUpdate;
  const _VendorTile({required this.vendor, required this.isEn, required this.onUpdate});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: CircleAvatar(
          backgroundColor: AppTheme.primary50,
          child: const Icon(LucideIcons.truck, color: AppTheme.primary600, size: 20),
        ),
        title: Text(vendor.name, style: const TextStyle(fontWeight: FontWeight.w700)),
        subtitle: Text(vendor.companyName ?? (isEn ? 'Individual Vendor' : 'ব্যক্তিগত সরবরাহকারী')),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              '৳${vendor.totalPayable.toStringAsFixed(0)}',
              style: TextStyle(
                fontWeight: FontWeight.w800,
                color: vendor.totalPayable > 0 ? Colors.red : Colors.green,
                fontSize: 16,
              ),
            ),
            Text(isEn ? 'Payable' : 'পাওনা', style: TextStyle(color: AppTheme.textLight, fontSize: 11)),
          ],
        ),
        onTap: () => _showVendorDetails(context),
      ),
    );
  }

  void _showVendorDetails(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _VendorDetailsSheet(vendor: vendor, onUpdate: onUpdate),
    );
  }
}

class _VendorFormSheet extends ConsumerStatefulWidget {
  final Vendor? vendor;
  final VoidCallback onSaved;
  const _VendorFormSheet({this.vendor, required this.onSaved});

  @override
  ConsumerState<_VendorFormSheet> createState() => _VendorFormSheetState();
}

class _VendorFormSheetState extends ConsumerState<_VendorFormSheet> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _companyController;
  late TextEditingController _phoneController;
  late TextEditingController _emailController;
  late TextEditingController _addressController;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.vendor?.name);
    _companyController = TextEditingController(text: widget.vendor?.companyName);
    _phoneController = TextEditingController(text: widget.vendor?.phone);
    _emailController = TextEditingController(text: widget.vendor?.email);
    _addressController = TextEditingController(text: widget.vendor?.address);
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
        child: Form(
          key: _formKey,
          child: ListView(
            controller: controller,
            children: [
              Text(widget.vendor == null ? 'Add Vendor' : 'Edit Vendor', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
              const SizedBox(height: 24),
              _buildField(isEn ? 'Name*' : 'নাম*', _nameController, LucideIcons.user, required: true),
              _buildField(isEn ? 'Company' : 'কোম্পানি', _companyController, LucideIcons.building2),
              _buildField(isEn ? 'Phone' : 'ফোন', _phoneController, LucideIcons.phone, type: TextInputType.phone),
              _buildField(isEn ? 'Email' : 'ইমেইল', _emailController, LucideIcons.mail, type: TextInputType.emailAddress),
              _buildField(isEn ? 'Address' : 'ঠিকানা', _addressController, LucideIcons.mapPin),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _isSaving ? null : _save,
                child: _isSaving ? const CircularProgressIndicator(color: Colors.white) : const Text('Save Vendor'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);
    final data = {
      'name': _nameController.text,
      'company_name': _companyController.text,
      'phone': _phoneController.text,
      'email': _emailController.text,
      'address': _addressController.text,
    };
    try {
      if (widget.vendor == null) {
        await ApiClient().dio.post('/api/vendors', data: data);
      } else {
        await ApiClient().dio.put('/api/vendors/${widget.vendor!.id}', data: data);
      }
      widget.onSaved();
      if (mounted) Navigator.pop(context);
    } catch (_) {
      setState(() => _isSaving = false);
    }
  }

  Widget _buildField(String label, TextEditingController controller, IconData icon, {bool required = false, TextInputType type = TextInputType.text}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        keyboardType: type,
        validator: required ? (v) => v!.isEmpty ? 'Required' : null : null,
        decoration: InputDecoration(labelText: label, prefixIcon: Icon(icon, size: 20)),
      ),
    );
  }
}

class _VendorDetailsSheet extends ConsumerStatefulWidget {
  final Vendor vendor;
  final VoidCallback onUpdate;
  const _VendorDetailsSheet({required this.vendor, required this.onUpdate});

  @override
  ConsumerState<_VendorDetailsSheet> createState() => _VendorDetailsSheetState();
}

class _VendorDetailsSheetState extends ConsumerState<_VendorDetailsSheet> {
  final _amountController = TextEditingController();
  bool _isProcessing = false;

  @override
  Widget build(BuildContext context) {
    final isEn = ref.watch(languageProvider) == 'en';

    return DraggableScrollableSheet(
      initialChildSize: 0.9,
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
              children: [
                CircleAvatar(radius: 28, backgroundColor: AppTheme.primary50, child: const Icon(LucideIcons.truck, color: AppTheme.primary600, size: 24)),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(widget.vendor.name, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
                      Text(widget.vendor.companyName ?? '', style: TextStyle(color: AppTheme.textSecondary)),
                    ],
                  ),
                ),
                IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(LucideIcons.x)),
              ],
            ),
            const SizedBox(height: 32),
            Row(
              children: [
                _StatCard(label: isEn ? 'Total Purchases' : 'মোট ক্রয়', value: '৳${widget.vendor.totalPurchases.toStringAsFixed(0)}', color: AppTheme.primary600),
                const SizedBox(width: 12),
                _StatCard(label: isEn ? 'Total Payable' : 'মোট পাওনা', value: '৳${widget.vendor.totalPayable.toStringAsFixed(0)}', color: Colors.red),
              ],
            ),
            const SizedBox(height: 32),
            if (widget.vendor.totalPayable > 0) ...[
              Text(isEn ? 'Record Payment' : 'পেমেন্ট প্রদান', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
              const SizedBox(height: 16),
              TextField(
                controller: _amountController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  hintText: isEn ? 'Enter amount to pay...' : 'টাকার পরিমাণ লিখুন...',
                  prefixText: '৳ ',
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _isProcessing ? null : _payVendor,
                child: _isProcessing ? const CircularProgressIndicator() : Text(isEn ? 'Record Payment' : 'পেমেন্ট সংরক্ষণ করুন'),
              ),
            ],
            const SizedBox(height: 32),
            _DetailItem(icon: LucideIcons.phone, text: widget.vendor.phone ?? ''),
            _DetailItem(icon: LucideIcons.mail, text: widget.vendor.email ?? ''),
            _DetailItem(icon: LucideIcons.mapPin, text: widget.vendor.address ?? ''),
          ],
        ),
      ),
    );
  }

  Future<void> _payVendor() async {
    final amount = double.tryParse(_amountController.text);
    if (amount == null || amount <= 0) return;
    setState(() => _isProcessing = true);
    try {
      await ApiClient().dio.post('/api/transactions/payment-made', data: {
        'vendor_id': widget.vendor.id,
        'amount': amount,
        'method': 'cash',
        'notes': 'Manual payment to vendor via mobile app',
      });
      widget.onUpdate();
      if (mounted) Navigator.pop(context);
    } catch (_) {
      setState(() => _isProcessing = false);
    }
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  const _StatCard({required this.label, required this.value, required this.color});
  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: color.withValues(alpha: 0.05), borderRadius: BorderRadius.circular(16), border: Border.all(color: color.withValues(alpha: 0.1))),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: TextStyle(color: AppTheme.textSecondary, fontSize: 11)),
            const SizedBox(height: 4),
            Text(value, style: TextStyle(color: color, fontSize: 18, fontWeight: FontWeight.w800)),
          ],
        ),
      ),
    );
  }
}

class _DetailItem extends StatelessWidget {
  final IconData icon;
  final String text;
  const _DetailItem({required this.icon, required this.text});
  @override
  Widget build(BuildContext context) {
    if (text.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, size: 16, color: AppTheme.textLight),
          const SizedBox(width: 12),
          Text(text, style: TextStyle(color: AppTheme.textSecondary)),
        ],
      ),
    );
  }
}
