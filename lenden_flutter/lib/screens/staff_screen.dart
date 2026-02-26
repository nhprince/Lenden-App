import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../core/api/api_client.dart';
import '../core/models/models.dart';
import '../providers/providers.dart';
import '../app/theme.dart';

class StaffScreen extends ConsumerStatefulWidget {
  const StaffScreen({super.key});

  @override
  ConsumerState<StaffScreen> createState() => _StaffScreenState();
}

class _StaffScreenState extends ConsumerState<StaffScreen> {
  List<Staff> _staffMembers = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _isLoading = true);
    try {
      final res = await ApiClient().dio.get('/api/staff');
      if (mounted) {
        setState(() {
          _staffMembers = (res.data as List).map((e) => Staff.fromJson(e)).toList();
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
    final user = ref.watch(authProvider).user;
    final isOwner = user?.role == 'OWNER' || user?.role == 'owner';

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: _load,
        child: Column(
          children: [
            if (_isLoading)
              const Expanded(child: Center(child: CircularProgressIndicator()))
            else if (_staffMembers.isEmpty)
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(LucideIcons.users, size: 48, color: AppTheme.textLight),
                      const SizedBox(height: 12),
                      Text(isEn ? 'No staff members found' : 'কোনো স্টাফ পাওয়া যায়নি'),
                    ],
                  ),
                ),
              )
            else
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _staffMembers.length,
                  itemBuilder: (context, i) {
                    final staff = _staffMembers[i];
                    return _StaffTile(staff: staff, isEn: isEn, onUpdate: _load);
                  },
                ),
              ),
          ],
        ),
      ),
      floatingActionButton: isOwner ? FloatingActionButton.extended(
        onPressed: () => _showStaffForm(null),
        backgroundColor: AppTheme.primary600,
        icon: const Icon(LucideIcons.userPlus, color: Colors.white),
        label: Text(isEn ? 'Add Staff' : 'স্টাফ যোগ করুন', style: const TextStyle(color: Colors.white)),
      ) : null,
    );
  }

  void _showStaffForm(Staff? staff) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _StaffFormSheet(staff: staff, onSaved: _load),
    );
  }
}

class _StaffTile extends StatelessWidget {
  final Staff staff;
  final bool isEn;
  final VoidCallback onUpdate;
  const _StaffTile({required this.staff, required this.isEn, required this.onUpdate});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: CircleAvatar(
          backgroundColor: AppTheme.primary50,
          child: const Icon(LucideIcons.user, color: AppTheme.primary600, size: 20),
        ),
        title: Text(staff.username, style: const TextStyle(fontWeight: FontWeight.w700)),
        subtitle: Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(color: AppTheme.primary50, borderRadius: BorderRadius.circular(4)),
              child: Text(staff.role.toUpperCase(), style: const TextStyle(color: AppTheme.primary600, fontSize: 10, fontWeight: FontWeight.bold)),
            ),
            const SizedBox(width: 8),
            Text(staff.status.toUpperCase(), style: TextStyle(color: staff.status == 'ACTIVE' ? Colors.green : Colors.red, fontSize: 10, fontWeight: FontWeight.bold)),
          ],
        ),
        trailing: IconButton(
          icon: const Icon(LucideIcons.settings, size: 20),
          onPressed: () => _showDetails(context),
        ),
      ),
    );
  }

  void _showDetails(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _StaffDetailSheet(staff: staff, onUpdate: onUpdate),
    );
  }
}

class _StaffFormSheet extends ConsumerStatefulWidget {
  final Staff? staff;
  final VoidCallback onSaved;
  const _StaffFormSheet({this.staff, required this.onSaved});

  @override
  ConsumerState<_StaffFormSheet> createState() => _StaffFormSheetState();
}

class _StaffFormSheetState extends ConsumerState<_StaffFormSheet> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _usernameController;
  late TextEditingController _passwordController;
  late TextEditingController _salaryController;
  String _selectedRole = 'manager';
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _usernameController = TextEditingController(text: widget.staff?.username);
    _passwordController = TextEditingController();
    _salaryController = TextEditingController(text: widget.staff?.salary.toString());
    if (widget.staff != null) _selectedRole = widget.staff!.role;
  }

  @override
  Widget build(BuildContext context) {
    final isEn = ref.watch(languageProvider) == 'en';

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
              Text(widget.staff == null ? 'Add New Staff' : 'Edit Staff', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
              const SizedBox(height: 24),
              TextFormField(controller: _usernameController, decoration: InputDecoration(labelText: isEn ? 'Username*' : 'ইউজারনেম*', prefixIcon: const Icon(LucideIcons.user)), validator: (v) => v!.isEmpty ? 'Required' : null),
              const SizedBox(height: 16),
              if (widget.staff == null)
                TextFormField(controller: _passwordController, obscureText: true, decoration: InputDecoration(labelText: isEn ? 'Password*' : 'পাসওয়ার্ড*', prefixIcon: const Icon(LucideIcons.lock)), validator: (v) => v!.isEmpty ? 'Required' : null),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _selectedRole,
                decoration: InputDecoration(labelText: isEn ? 'Role' : 'পদবী', prefixIcon: const Icon(LucideIcons.shield)),
                items: const [
                  DropdownMenuItem(value: 'manager', child: Text('Manager')),
                  DropdownMenuItem(value: 'staff', child: Text('Staff')),
                ],
                onChanged: (v) => setState(() => _selectedRole = v!),
              ),
              const SizedBox(height: 16),
              TextFormField(controller: _salaryController, keyboardType: TextInputType.number, decoration: InputDecoration(labelText: isEn ? 'Salary' : 'বেতন', prefixIcon: const Icon(LucideIcons.dollarSign))),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _isSaving ? null : _save,
                child: _isSaving ? const CircularProgressIndicator() : const Text('Save Staff Member'),
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
      'username': _usernameController.text,
      if (widget.staff == null) 'password': _passwordController.text,
      'role': _selectedRole,
      'salary': double.tryParse(_salaryController.text) ?? 0.0,
      'status': 'ACTIVE',
    };
    try {
      if (widget.staff == null) {
        await ApiClient().dio.post('/api/staff', data: data);
      } else {
        await ApiClient().dio.put('/api/staff/${widget.staff!.id}', data: data);
      }
      widget.onSaved();
      if (mounted) Navigator.pop(context);
    } catch (_) {
      if (mounted) setState(() => _isSaving = false);
    }
  }
}

class _StaffDetailSheet extends ConsumerStatefulWidget {
  final Staff staff;
  final VoidCallback onUpdate;
  const _StaffDetailSheet({required this.staff, required this.onUpdate});

  @override
  ConsumerState<_StaffDetailSheet> createState() => _StaffDetailSheetState();
}

class _StaffDetailSheetState extends ConsumerState<_StaffDetailSheet> {
  bool _isProcessing = false;

  @override
  Widget build(BuildContext context) {
    final isEn = ref.watch(languageProvider) == 'en';

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(isEn ? 'Staff Details' : 'স্টাফের তথ্য', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
              IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(LucideIcons.x)),
            ],
          ),
          const Divider(),
          const SizedBox(height: 16),
          _InfoRow(label: isEn ? 'Username' : 'ইউজারনেম', value: widget.staff.username),
          _InfoRow(label: isEn ? 'Role' : 'পদবী', value: widget.staff.role.toUpperCase()),
          _InfoRow(label: isEn ? 'Salary' : 'বেতন', value: '৳${widget.staff.salary.toStringAsFixed(0)}'),
          _InfoRow(label: isEn ? 'Status' : 'অবস্থা', value: widget.staff.status.toUpperCase()),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: _isProcessing ? null : () => _toggleStatus(),
              style: OutlinedButton.styleFrom(
                foregroundColor: widget.staff.status == 'ACTIVE' ? Colors.red : Colors.green,
                side: BorderSide(color: widget.staff.status == 'ACTIVE' ? Colors.red : Colors.green),
              ),
              child: Text(widget.staff.status == 'ACTIVE' 
                ? (isEn ? 'Deactivate Account' : 'ডিঅ্যাক্টিভেট করুন')
                : (isEn ? 'Activate Account' : 'অ্যাক্টিভেট করুন')),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Future<void> _toggleStatus() async {
    setState(() => _isProcessing = true);
    final newStatus = widget.staff.status == 'ACTIVE' ? 'INACTIVE' : 'ACTIVE';
    try {
      await ApiClient().dio.put('/api/staff/${widget.staff.id}', data: {'status': newStatus, 'username': widget.staff.username, 'role': widget.staff.role});
      widget.onUpdate();
      if (mounted) Navigator.pop(context);
    } catch (_) {
      if (mounted) setState(() => _isProcessing = false);
    }
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  const _InfoRow({required this.label, required this.value});
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: AppTheme.textSecondary)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}
