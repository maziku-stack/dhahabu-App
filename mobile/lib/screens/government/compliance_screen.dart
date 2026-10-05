import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../services/api_service.dart';
import '../../theme/app_colors.dart';
import '../../widgets/app_card.dart';

class ComplianceScreen extends StatefulWidget {
  const ComplianceScreen({super.key});
  @override
  State<ComplianceScreen> createState() => _ComplianceScreenState();
}

class _ComplianceScreenState extends State<ComplianceScreen> {
  Map<String, dynamic>? _data;
  bool _loading = true;
  final _fmt = NumberFormat('#,##0.00');

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final d = await ApiService().getAdminDashboard();
      setState(() { _data = d; _loading = false; });
    } catch (_) {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = _data?['summary'] as Map<String, dynamic>? ?? {};
    return Scaffold(
      appBar: AppBar(title: const Text('Compliance Overview')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _load,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  _metric('Transactions', '${s['transaction_count'] ?? 0}'),
                  _metric('Volume', '${s['total_volume_grams'] ?? 0} g'),
                  _metric('Value', 'TSh ${_fmt.format(double.tryParse('${s['total_value_tzs']}') ?? 0)}'),
                  _metric('Royalty', 'TSh ${_fmt.format(double.tryParse('${s['total_royalty_tzs']}') ?? 0)}'),
                ],
              ),
            ),
    );
  }

  Widget _metric(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: AppCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: TextStyle(color: Colors.grey[400], fontSize: 13)),
            Text(value, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.gold)),
          ],
        ),
      ),
    );
  }
}
