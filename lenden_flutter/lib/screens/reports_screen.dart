import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:fl_chart/fl_chart.dart';
import '../core/api/api_client.dart';
import '../providers/providers.dart';
import '../app/theme.dart';

class ReportsScreen extends ConsumerStatefulWidget {
  const ReportsScreen({super.key});

  @override
  ConsumerState<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends ConsumerState<ReportsScreen> {
  Map<String, dynamic> _reportData = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadReports();
  }

  Future<void> _loadReports() async {
    setState(() => _isLoading = true);
    try {
      final res = await ApiClient().dio.get('/api/reports/summary');
      if (mounted) {
        setState(() {
          _reportData = res.data;
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
        onRefresh: _loadReports,
        child: _isLoading 
          ? const Center(child: CircularProgressIndicator())
          : ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Text(isEn ? 'Performance Summary' : 'পারফরম্যান্স সারাংশ', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
            const SizedBox(height: 16),
            _SummaryGrid(data: _reportData, isEn: isEn),
            const SizedBox(height: 32),
            Text(isEn ? 'Sales Trend' : 'বিক্রয় প্রবণতা', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
            const SizedBox(height: 16),
            _LineChartWidget(isEn: isEn),
            const SizedBox(height: 32),
            Text(isEn ? 'Category Distribution' : 'ক্যাটাগরি অনুযায়ী বিক্রয়', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
            const SizedBox(height: 16),
            _PieChartWidget(isEn: isEn),
            const SizedBox(height: 40),
            ElevatedButton.icon(
              onPressed: () {}, // Future PDF Export
              icon: const Icon(LucideIcons.download),
              label: Text(isEn ? 'Export Full Report (PDF)' : 'সম্পূর্ণ রিপোর্ট এক্সপোর্ট করুন'),
              style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primary600, foregroundColor: Colors.white, padding: const EdgeInsets.all(16)),
            ),
            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }
}

class _SummaryGrid extends StatelessWidget {
  final Map<String, dynamic> data;
  final bool isEn;
  const _SummaryGrid({required this.data, required this.isEn});

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      childAspectRatio: 1.5,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      children: [
        _ReportCard(label: isEn ? 'Total Sales' : 'মোট বিক্রয়', value: 'BTDT ${data['totalSales']?.toStringAsFixed(0) ?? '0'}', color: Colors.green),
        _ReportCard(label: isEn ? 'Total Expenses' : 'মোট খরচ', value: 'BTDT ${data['totalExpenses']?.toStringAsFixed(0) ?? '0'}', color: Colors.red),
        _ReportCard(label: isEn ? 'Net Profit' : 'নিট লাভ', value: 'BTDT ${data['netProfit']?.toStringAsFixed(0) ?? '0'}', color: AppTheme.primary600),
        _ReportCard(label: isEn ? 'Growth' : 'প্রবৃদ্ধি', value: '+12.5%', color: Colors.blue),
      ],
    );
  }
}

class _ReportCard extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  const _ReportCard({required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade100),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(label, style: TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
          const SizedBox(height: 4),
          Text(value, style: TextStyle(color: color, fontSize: 18, fontWeight: FontWeight.w800)),
        ],
      ),
    );
  }
}

class _LineChartWidget extends StatelessWidget {
  final bool isEn;
  const _LineChartWidget({required this.isEn});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 200,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: AppTheme.primary600.withValues(alpha: 0.05), borderRadius: BorderRadius.circular(20)),
      child: LineChart(
        LineChartData(
          gridData: const FlGridData(show: false),
          titlesData: const FlTitlesData(show: false),
          borderData: FlBorderData(show: false),
          lineBarsData: [
            LineChartBarData(
              spots: const [FlSpot(0, 3), FlSpot(1, 1), FlSpot(2, 4), FlSpot(3, 2), FlSpot(4, 5)],
              isCurved: true,
              color: AppTheme.primary600,
              barWidth: 4,
              dotData: const FlDotData(show: false),
              belowBarData: BarAreaData(show: true, color: AppTheme.primary600.withValues(alpha: 0.1)),
            ),
          ],
        ),
      ),
    );
  }
}

class _PieChartWidget extends StatelessWidget {
  final bool isEn;
  const _PieChartWidget({required this.isEn});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 200,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.orange.withValues(alpha: 0.05), borderRadius: BorderRadius.circular(20)),
      child: PieChart(
        PieChartData(
          sectionsSpace: 4,
          centerSpaceRadius: 40,
          sections: [
            PieChartSectionData(color: Colors.green, value: 40, title: 'Sales', radius: 50, titleStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
            PieChartSectionData(color: Colors.red, value: 30, title: 'Exp', radius: 50, titleStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
            PieChartSectionData(color: Colors.blue, value: 30, title: 'Inv', radius: 50, titleStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
          ],
        ),
      ),
    );
  }
}
