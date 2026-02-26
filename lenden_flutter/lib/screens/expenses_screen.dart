import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:intl/intl.dart';
import '../core/api/api_client.dart';
import '../core/models/models.dart';
import '../providers/providers.dart';
import '../app/theme.dart';

class ExpensesScreen extends ConsumerStatefulWidget {
  const ExpensesScreen({super.key});

  @override
  ConsumerState<ExpensesScreen> createState() => _ExpensesScreenState();
}

class _ExpensesScreenState extends ConsumerState<ExpensesScreen> {
  List<Transaction> _expenses = [];
  bool _isLoading = true;
  String _currentCategory = 'All';

  final List<String> _categories = [
    'All', 'Rent', 'Utilities', 'Salary', 'Supplies', 'Marketing', 'Maintenance', 'Tax', 'Other'
  ];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _isLoading = true);
    try {
      final res = await ApiClient().dio.get('/api/transactions?type=EXPENSE');
      if (mounted) {
        setState(() {
          _expenses = (res.data as List).map((e) => Transaction.fromJson(e)).toList();
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  List<Transaction> get _filtered {
    if (_currentCategory == 'All') return _expenses;
    return _expenses.where((e) => e.note?.contains(_currentCategory) ?? false).toList();
  }

  @override
  Widget build(BuildContext context) {
    final isEn = ref.watch(languageProvider) == 'en';

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: _load,
        child: Column(
          children: [
            // Category Filter
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.all(16),
              child: Row(
                children: _categories.map((cat) => Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(cat),
                    selected: _currentCategory == cat,
                    onSelected: (selected) {
                      setState(() => _currentCategory = cat);
                    },
                    selectedColor: AppTheme.primary600.withValues(alpha: 0.1),
                    checkmarkColor: AppTheme.primary600,
                  ),
                )).toList(),
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
                      Icon(LucideIcons.wallet, size: 48, color: AppTheme.textLight),
                      const SizedBox(height: 12),
                      Text(isEn ? 'No expenses found' : 'কোনো খরচ পাওয়া যায়নি'),
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
                    final e = _filtered[i];
                    return _ExpenseTile(expense: e, isEn: isEn);
                  },
                ),
              ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showExpenseForm(context),
        backgroundColor: AppTheme.primary600,
        icon: const Icon(LucideIcons.plus, color: Colors.white),
        label: Text(isEn ? 'Record Expense' : 'খরচ লিখুন', style: const TextStyle(color: Colors.white)),
      ),
    );
  }

  void _showExpenseForm(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _ExpenseFormSheet(onSaved: _load),
    );
  }
}

class _ExpenseTile extends StatelessWidget {
  final Transaction expense;
  final bool isEn;
  const _ExpenseTile({required this.expense, required this.isEn});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(color: Colors.red.withValues(alpha: 0.05), shape: BoxShape.circle),
          child: const Icon(LucideIcons.wallet, color: Colors.red, size: 20),
        ),
        title: Text(
          expense.note ?? (isEn ? 'Uncategorized Expense' : 'অনির্ধারিত খরচ'),
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
        subtitle: Text(
          _formatDate(DateTime.tryParse(expense.date ?? '') ?? DateTime.now()),
          style: TextStyle(color: AppTheme.textLight, fontSize: 12),
        ),
        trailing: Text(
          '-BTDT ${expense.amount.toStringAsFixed(2)}',
          style: const TextStyle(fontWeight: FontWeight.w800, color: Colors.red, fontSize: 16),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return DateFormat('dd MMM yyyy').format(date);
  }
}

class _ExpenseFormSheet extends ConsumerStatefulWidget {
  final VoidCallback onSaved;
  const _ExpenseFormSheet({required this.onSaved});

  @override
  ConsumerState<_ExpenseFormSheet> createState() => _ExpenseFormSheetState();
}

class _ExpenseFormSheetState extends ConsumerState<_ExpenseFormSheet> {
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();
  String _selectedCategory = 'Rent';
  bool _isSaving = false;

  final List<String> _categories = [
    'Rent', 'Utilities', 'Salary', 'Supplies', 'Marketing', 'Maintenance', 'Tax', 'Other'
  ];

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
                Text(isEn ? 'Record New Expense' : 'নতুন খরচ যোগ করুন', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
                IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(LucideIcons.x)),
              ],
            ),
            const Divider(),
            const SizedBox(height: 16),
            Text(isEn ? 'Category' : 'ধরণ', style: const TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: _categories.map((cat) => ChoiceChip(
                label: Text(cat),
                selected: _selectedCategory == cat,
                onSelected: (selected) {
                  if (selected) setState(() => _selectedCategory = cat);
                },
              )).toList(),
            ),
            const SizedBox(height: 24),
            TextField(
              controller: _amountController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: isEn ? 'Amount*' : 'পরিমাণ*',
                prefixText: 'BTDT  ',
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _noteController,
              maxLines: 3,
              decoration: InputDecoration(
                labelText: isEn ? 'Additional Note (Optional)' : 'অতিরিক্ত নোট (ঐচ্ছিক)',
                alignLabelWithHint: true,
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: _isSaving ? null : _save,
              child: _isSaving
                ? const CircularProgressIndicator(color: Colors.white)
                : Text(isEn ? 'Save Expense' : 'খরচ সংরক্ষণ করুন'),
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
      await ApiClient().dio.post('/api/transactions/expense', data: {
        'amount': amount,
        'category': _selectedCategory,
        'payment_method': 'cash',
        'description': '$_selectedCategory: ${_noteController.text}',
      });
      widget.onSaved();
      if (mounted) Navigator.pop(context);
    } catch (e) {
      setState(() => _isSaving = false);
    }
  }
}
