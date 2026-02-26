import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:intl/intl.dart';
import '../core/api/api_client.dart';
import '../core/models/models.dart';
import '../providers/providers.dart';
import '../app/theme.dart';

class TripsScreen extends ConsumerStatefulWidget {
  const TripsScreen({super.key});

  @override
  ConsumerState<TripsScreen> createState() => _TripsScreenState();
}

class _TripsScreenState extends ConsumerState<TripsScreen> {
  List<Trip> _trips = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _isLoading = true);
    try {
      final res = await ApiClient().dio.get('/api/trips');
      if (mounted) {
        setState(() {
          _trips = (res.data as List).map((e) => Trip.fromJson(e)).toList();
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
            else if (_trips.isEmpty)
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(LucideIcons.truck, size: 48, color: AppTheme.textLight),
                      const SizedBox(height: 12),
                      Text(isEn ? 'No trips found' : 'কোনো ট্রিপ পাওয়া যায়নি'),
                    ],
                  ),
                ),
              )
            else
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _trips.length,
                  itemBuilder: (context, i) {
                    final t = _trips[i];
                    return _TripTile(trip: t, isEn: isEn, onUpdate: _load);
                  },
                ),
              ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showTripForm(null),
        backgroundColor: AppTheme.primary600,
        child: const Icon(LucideIcons.plus, color: Colors.white),
      ),
    );
  }

  void _showTripForm(Trip? trip) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _TripFormSheet(trip: trip, onSaved: _load),
    );
  }
}

class _TripTile extends StatelessWidget {
  final Trip trip;
  final bool isEn;
  final VoidCallback onUpdate;
  const _TripTile({required this.trip, required this.isEn, required this.onUpdate});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(color: AppTheme.primary50, shape: BoxShape.circle),
          child: const Icon(LucideIcons.truck, color: AppTheme.primary600, size: 20),
        ),
        title: Text('${trip.vehicleNo} - ${trip.driverNameSnapshot ?? (isEn ? "Driver" : "চালক")}'),
        subtitle: Text('${trip.destination ?? (isEn ? "Local" : "স্থান")} • ${trip.date != null ? _formatDate(DateTime.tryParse(trip.date!) ?? DateTime.now()) : (isEn ? "No Date" : "তারিখ নেই")}'),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text('BTDT ${trip.fare.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold)),
            Text(trip.status.toUpperCase(), style: TextStyle(fontSize: 10, color: trip.status.toLowerCase() == 'completed' ? Colors.green : Colors.orange)),
          ],
        ),
        onTap: () => _showTripDetails(context),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return DateFormat('dd MMM yyyy').format(date);
  }

  void _showTripDetails(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _TripDetailsSheet(trip: trip, onUpdate: onUpdate),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'COMPLETED': return Colors.green;
      case 'ONGOING': return Colors.blue;
      case 'SCHEDULED': return Colors.orange;
      case 'CANCELLED': return Colors.red;
      default: return Colors.grey;
    }
  }
}

class _TripFormSheet extends ConsumerStatefulWidget {
  final Trip? trip;
  final VoidCallback onSaved;
  const _TripFormSheet({this.trip, required this.onSaved});

  @override
  ConsumerState<_TripFormSheet> createState() => _TripFormSheetState();
}

class _TripFormSheetState extends ConsumerState<_TripFormSheet> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _vehicleController;
  late TextEditingController _driverController;
  late TextEditingController _destController;
  late TextEditingController _fareController;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _vehicleController = TextEditingController(text: widget.trip?.vehicleNo);
    _driverController = TextEditingController(text: widget.trip?.driverName);
    _destController = TextEditingController(text: widget.trip?.destination);
    _fareController = TextEditingController(text: widget.trip?.fare.toString());
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
              Text(widget.trip == null ? 'Schedule Trip' : 'Edit Trip', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
              const SizedBox(height: 24),
              TextFormField(controller: _vehicleController, decoration: InputDecoration(labelText: isEn ? 'Vehicle No*' : 'গাড়ি নম্বর*', prefixIcon: const Icon(LucideIcons.truck)), validator: (v) => v!.isEmpty ? 'Required' : null),
              const SizedBox(height: 16),
              TextFormField(controller: _driverController, decoration: InputDecoration(labelText: isEn ? 'Driver Name*' : 'চালকের নাম*', prefixIcon: const Icon(LucideIcons.user)), validator: (v) => v!.isEmpty ? 'Required' : null),
              const SizedBox(height: 16),
              TextFormField(controller: _destController, decoration: InputDecoration(labelText: isEn ? 'Destination*' : 'গন্তব্য*', prefixIcon: const Icon(LucideIcons.mapPin)), validator: (v) => v!.isEmpty ? 'Required' : null),
              const SizedBox(height: 16),
              TextFormField(controller: _fareController, keyboardType: TextInputType.number, decoration: InputDecoration(labelText: isEn ? 'Fare*' : 'ভাড়া*', prefixIcon: const Icon(LucideIcons.dollarSign)), validator: (v) => v!.isEmpty ? 'Required' : null),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _isSaving ? null : _save,
                child: _isSaving ? const CircularProgressIndicator() : const Text('Save Trip'),
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
      'vehicle_no': _vehicleController.text,
      'driver_name': _driverController.text,
      'destination': _destController.text,
      'fare': double.parse(_fareController.text),
      'status': 'SCHEDULED',
    };
    try {
      if (widget.trip == null) {
        await ApiClient().dio.post('/api/trips', data: data);
      } else {
        await ApiClient().dio.put('/api/trips/${widget.trip!.id}', data: data);
      }
      widget.onSaved();
      if (mounted) Navigator.pop(context);
    } catch (_) {
      if (mounted) setState(() => _isSaving = false);
    }
  }
}

class _TripDetailsSheet extends ConsumerStatefulWidget {
  final Trip trip;
  final VoidCallback onUpdate;
  const _TripDetailsSheet({required this.trip, required this.onUpdate});

  @override
  ConsumerState<_TripDetailsSheet> createState() => _TripDetailsSheetState();
}

class _TripDetailsSheetState extends ConsumerState<_TripDetailsSheet> {
  bool _isUpdating = false;

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
              Text(isEn ? 'Trip Details' : 'ট্রিপের তথ্য', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
              IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(LucideIcons.x)),
            ],
          ),
          const Divider(),
          const SizedBox(height: 16),
          _InfoRow(label: isEn ? 'Destination' : 'গন্তব্য', value: widget.trip.destination ?? '-'),
          _InfoRow(label: isEn ? 'Vehicle' : 'গাড়ি', value: widget.trip.vehicleNo),
          _InfoRow(label: isEn ? 'Driver' : 'চালক', value: widget.trip.driverName ?? '-'),
          _InfoRow(label: isEn ? 'Fare' : 'ভাড়া', value: 'BTDT ${widget.trip.fare.toStringAsFixed(2)}', isBold: true),
          _InfoRow(label: isEn ? 'Status' : 'অবস্থা', value: widget.trip.status),
          const SizedBox(height: 32),
          if (widget.trip.status != 'COMPLETED' && widget.trip.status != 'CANCELLED')
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _isUpdating ? null : () => _updateStatus('CANCELLED'),
                    style: OutlinedButton.styleFrom(foregroundColor: Colors.red),
                    child: Text(isEn ? 'Cancel' : 'বাতিল'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isUpdating ? null : () => _updateStatus('COMPLETED'),
                    child: Text(isEn ? 'Complete Trip' : 'ট্রিপ সম্পন্ন করুন'),
                  ),
                ),
              ],
            ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Future<void> _updateStatus(String status) async {
    setState(() => _isUpdating = true);
    try {
      await ApiClient().dio.put('/api/trips/${widget.trip.id}/status', data: {'status': status});
      widget.onUpdate();
      if (mounted) Navigator.pop(context);
    } catch (_) {
      if (mounted) setState(() => _isUpdating = false);
    }
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isBold;
  const _InfoRow({required this.label, required this.value, this.isBold = false});
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: AppTheme.textSecondary)),
          Text(value, style: TextStyle(fontWeight: isBold ? FontWeight.w800 : FontWeight.w600)),
        ],
      ),
    );
  }
}
