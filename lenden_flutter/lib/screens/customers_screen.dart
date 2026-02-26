import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../core/api/api_client.dart';
import '../core/models/models.dart';
import '../providers/providers.dart';
import '../app/theme.dart';

class CustomersScreen extends ConsumerStatefulWidget {
  const CustomersScreen({super.key});

  @override
  ConsumerState<CustomersScreen> createState() => _CustomersScreenState();
}

class _CustomersScreenState extends ConsumerState<CustomersScreen> {
  List<Customer> _customers = [];
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
      final res = await ApiClient().dio.get('/api/customers');
      setState(() {
        _customers = (res.data as List).map((e) => Customer.fromJson(e)).toList();
        _isLoading = false;
      });
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  List<Customer> get _filtered {
    final q = _searchController.text.toLowerCase();
    if (q.isEmpty) return _customers;
    return _customers.where((c) =>
      c.name.toLowerCase().contains(q) ||
      (c.phone?.contains(q) ?? false)
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
                  hintText: isEn ? 'Search by name or phone...' : 'নাম বা ফোন দিয়ে খুঁজুন...',
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
                      Icon(LucideIcons.users, size: 48, color: AppTheme.textLight),
                      const SizedBox(height: 12),
                      Text(isEn ? 'No customers found' : 'কোনো গ্রাহক পাওয়া যায়নি'),
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
                    final c = _filtered[i];
                    return _CustomerTile(
                      customer: c,
                      isEn: isEn,
                      onUpdate: _load,
                    );
                  },
                ),
              ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showCustomerForm(null),
        backgroundColor: AppTheme.primary600,
        child: const Icon(LucideIcons.userPlus, color: Colors.white),
      ),
    );
  }

  void _showCustomerForm(Customer? customer) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _CustomerForm(customer: customer, onSaved: _load),
    );
  }
}

class _CustomerTile extends ConsumerWidget {
  final Customer customer;
  final bool isEn;
  final VoidCallback onUpdate;

  const _CustomerTile({required this.customer, required this.isEn, required this.onUpdate});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: CircleAvatar(
          backgroundColor: AppTheme.primary50,
          child: Text(
            customer.name[0].toUpperCase(),
            style: const TextStyle(color: AppTheme.primary600, fontWeight: FontWeight.w700),
          ),
        ),
        title: Text(customer.name, style: const TextStyle(fontWeight: FontWeight.w700)),
        subtitle: Text(customer.phone ?? (isEn ? 'No phone' : 'ফোন নম্বর নেই'), style: TextStyle(color: AppTheme.textSecondary, fontSize: 13)),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              'BTDT ${customer.totalDue.toStringAsFixed(0)}',
              style: TextStyle(
                fontWeight: FontWeight.w800,
                color: customer.totalDue > 0 ? AppTheme.danger500 : Colors.green,
                fontSize: 16,
              ),
            ),
            Text(isEn ? 'Due' : 'বাকি', style: TextStyle(color: AppTheme.textLight, fontSize: 11)),
          ],
        ),
        onTap: () => _showCustomerDetails(context),
      ),
    );
  }

  void _showCustomerDetails(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _CustomerDetailsSheet(customer: customer, onUpdate: onUpdate),
    );
  }
}

class _CustomerForm extends StatefulWidget {
  final Customer? customer;
  final VoidCallback onSaved;
  const _CustomerForm({this.customer, required this.onSaved});

  @override
  State<_CustomerForm> createState() => _CustomerFormState();
}

class _CustomerFormState extends State<_CustomerForm> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  late TextEditingController _emailController;
  late TextEditingController _addressController;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.customer?.name);
    _phoneController = TextEditingController(text: widget.customer?.phone);
    _emailController = TextEditingController(text: widget.customer?.email);
    _addressController = TextEditingController(text: widget.customer?.address);
  }

  @override
  Widget build(BuildContext context) {
    final isEn = true; // Use a proper lang check if needed

    return DraggableScrollableSheet(
      initialChildSize: 0.7,
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
              Text(widget.customer == null ? 'Add Customer' : 'Edit Customer', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
              const SizedBox(height: 24),
              _buildField('Name*', _nameController, LucideIcons.user, required: true),
              _buildField('Phone', _phoneController, LucideIcons.phone, type: TextInputType.phone),
              _buildField('Email', _emailController, LucideIcons.mail, type: TextInputType.emailAddress),
              _buildField('Address', _addressController, LucideIcons.mapPin),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _isSaving ? null : _save,
                child: _isSaving ? const CircularProgressIndicator() : const Text('Save Customer'),
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
      'phone': _phoneController.text,
      'email': _emailController.text,
      'address': _addressController.text,
    };
    try {
      if (widget.customer == null) {
        await ApiClient().dio.post('/api/customers', data: data);
      } else {
        await ApiClient().dio.put('/api/customers/${widget.customer!.id}', data: data);
      }
      widget.onSaved();
      Navigator.pop(context);
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

class _CustomerDetailsSheet extends ConsumerStatefulWidget {
  final Customer customer;
  final VoidCallback onUpdate;
  const _CustomerDetailsSheet({required this.customer, required this.onUpdate});

  @override
  ConsumerState<_CustomerDetailsSheet> createState() => _CustomerDetailsSheetState();
}

class _CustomerDetailsSheetState extends ConsumerState<_CustomerDetailsSheet> {
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
                CircleAvatar(radius: 28, backgroundColor: AppTheme.primary50, child: Text(widget.customer.name[0].toUpperCase(), style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: AppTheme.primary600))),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(widget.customer.name, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
                      Text(widget.customer.phone ?? '', style: TextStyle(color: AppTheme.textSecondary)),
                    ],
                  ),
                ),
                IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(LucideIcons.x)),
              ],
            ),
            const SizedBox(height: 32),
            Row(
              children: [
                _StatItem(label: isEn ? 'Total Spent' : 'মোট কেনাকাটা', value: 'BTDT ${widget.customer.totalSpent.toStringAsFixed(0)}', color: AppTheme.primary600),
                const SizedBox(width: 12),
                _StatItem(label: isEn ? 'Total Due' : 'মোট বাকি', value: 'BTDT ${widget.customer.totalDue.toStringAsFixed(0)}', color: AppTheme.danger500),
              ],
            ),
            const SizedBox(height: 32),
            if (widget.customer.totalDue > 0) ...[
              Text(isEn ? 'Collect Payment' : 'বাকি আদায়', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
              const SizedBox(height: 16),
              TextField(
                controller: _amountController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  hintText: isEn ? 'Enter amount...' : 'টাকার পরিমাণ লিখুন...',
                  prefixText: 'BTDT  ',
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _isProcessing ? null : _collectDue,
                child: _isProcessing ? const CircularProgressIndicator() : Text(isEn ? 'Record Payment' : 'লেনদেন সংরক্ষণ করুন'),
              ),
            ],
            const SizedBox(height: 32),
            Text(isEn ? 'Customer Details' : 'গ্রাহকের তথ্য', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
            const SizedBox(height: 16),
            _DetailRow(icon: LucideIcons.mapPin, text: widget.customer.address ?? (isEn ? 'No address' : 'ঠিকানা নেই')),
            _DetailRow(icon: LucideIcons.mail, text: widget.customer.email ?? (isEn ? 'No email' : 'ইমেইল নেই')),
            _DetailRow(icon: LucideIcons.calendar, text: '${isEn ? 'Last visit' : 'সর্বশেষ আগমন'}: ${widget.customer.lastVisit ?? '-'}'),
          ],
        ),
      ),
    );
  }

  Future<void> _collectDue() async {
    final amount = double.tryParse(_amountController.text);
    if (amount == null || amount <= 0) return;
    setState(() => _isProcessing = true);
    try {
      await ApiClient().dio.post('/api/transactions/payment-received', data: {
        'customer_id': widget.customer.id,
        'amount': amount,
        'payment_method': 'cash',
        'note': 'Manual due collection from mobile app',
      });
      widget.onUpdate();
      Navigator.pop(context);
    } catch (_) {
      setState(() => _isProcessing = false);
    }
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  const _StatItem({required this.label, required this.value, required this.color});
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

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String text;
  const _DetailRow({required this.icon, required this.text});
  @override
  Widget build(BuildContext context) {
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
