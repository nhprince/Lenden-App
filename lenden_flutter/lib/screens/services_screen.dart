import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../core/api/api_client.dart';
import '../core/models/models.dart';
import '../providers/providers.dart';
import '../app/theme.dart';

class ServicesScreen extends ConsumerStatefulWidget {
  const ServicesScreen({super.key});

  @override
  ConsumerState<ServicesScreen> createState() => _ServicesScreenState();
}

class _ServicesScreenState extends ConsumerState<ServicesScreen> {
  List<Service> _services = [];
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
      final res = await ApiClient().dio.get('/api/services');
      if (mounted) {
        setState(() {
          _services = (res.data as List).map((e) => Service.fromJson(e)).toList();
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  List<Service> get _filtered {
    final q = _searchController.text.toLowerCase();
    if (q.isEmpty) return _services;
    return _services.where((s) => s.name.toLowerCase().contains(q)).toList();
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
                  hintText: isEn ? 'Search services...' : 'সার্ভিস খুঁজুন...',
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
                      Icon(LucideIcons.settings, size: 48, color: AppTheme.textLight),
                      const SizedBox(height: 12),
                      Text(isEn ? 'No services found' : 'কোনো সার্ভিস পাওয়া যায়নি'),
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
                    final s = _filtered[i];
                    return _ServiceTile(service: s, isEn: isEn, onUpdate: _load);
                  },
                ),
              ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showServiceForm(null),
        backgroundColor: AppTheme.primary600,
        child: const Icon(LucideIcons.plus, color: Colors.white),
      ),
    );
  }

  void _showServiceForm(Service? service) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _ServiceFormSheet(service: service, onSaved: _load),
    );
  }
}

class _ServiceTile extends StatelessWidget {
  final Service service;
  final bool isEn;
  final VoidCallback onUpdate;
  const _ServiceTile({required this.service, required this.isEn, required this.onUpdate});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(color: AppTheme.primary50, shape: BoxShape.circle),
          child: const Icon(LucideIcons.settings, color: AppTheme.primary600, size: 20),
        ),
        title: Text(service.name, style: const TextStyle(fontWeight: FontWeight.w700)),
        subtitle: Text('${isEn ? 'Charge' : 'সার্ভিস চার্জ'}: ৳${service.serviceCharge.toStringAsFixed(0)}'),
        trailing: IconButton(
          icon: const Icon(LucideIcons.edit3, size: 20),
          onPressed: () => _showServiceForm(context),
        ),
      ),
    );
  }

  void _showServiceForm(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _ServiceFormSheet(service: service, onSaved: onUpdate),
    );
  }
}

class _ServiceFormSheet extends ConsumerStatefulWidget {
  final Service? service;
  final VoidCallback onSaved;
  const _ServiceFormSheet({this.service, required this.onSaved});

  @override
  ConsumerState<_ServiceFormSheet> createState() => _ServiceFormSheetState();
}

class _ServiceFormSheetState extends ConsumerState<_ServiceFormSheet> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _chargeController;
  late TextEditingController _descController;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.service?.name);
    _chargeController = TextEditingController(text: widget.service?.serviceCharge.toString());
    _descController = TextEditingController(text: widget.service?.description);
  }

  @override
  Widget build(BuildContext context) {
    final isEn = ref.watch(languageProvider) == 'en';

    return DraggableScrollableSheet(
      initialChildSize: 0.6,
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
              Text(widget.service == null ? 'Add Service' : 'Edit Service', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
              const SizedBox(height: 24),
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(labelText: isEn ? 'Service Name*' : 'সার্ভিসের নাম*', prefixIcon: const Icon(LucideIcons.settings)),
                validator: (v) => v!.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _chargeController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(labelText: isEn ? 'Service Charge*' : 'সার্ভিস চার্জ*', prefixIcon: const Icon(LucideIcons.dollarSign)),
                validator: (v) => v!.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descController,
                maxLines: 2,
                decoration: InputDecoration(labelText: isEn ? 'Description' : 'বিবরণ', prefixIcon: const Icon(LucideIcons.fileText)),
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _isSaving ? null : _save,
                child: _isSaving ? const CircularProgressIndicator() : const Text('Save Service'),
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
      'service_charge': double.parse(_chargeController.text),
      'description': _descController.text,
    };
    try {
      if (widget.service == null) {
        await ApiClient().dio.post('/api/services', data: data);
      } else {
        await ApiClient().dio.put('/api/services/${widget.service!.id}', data: data);
      }
      widget.onSaved();
      if (mounted) Navigator.pop(context);
    } catch (_) {
      setState(() => _isSaving = false);
    }
  }
}
