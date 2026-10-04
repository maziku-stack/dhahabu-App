import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/api_service.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});
  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  Map<String, dynamic>? _data;
  bool _loading = true;
  final _fmt = NumberFormat('#,##0.00');

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final data = await ApiService().getAdminDashboard();
      setState(() {
        _data = data;
        _loading = false;
      });
    } catch (_) {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Center(child: CircularProgressIndicator());
    final s = _data?['summary'] as Map<String, dynamic>? ?? {};

    return RefreshIndicator(
      onRefresh: _load,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text('Government Dashboard',
              style: Theme.of(context)
                  .textTheme
                  .titleLarge
                  ?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text('Real-time sector visibility',
              style: TextStyle(color: Colors.grey[600])),
          const SizedBox(height: 16),
          _metricCard('Confirmed Transactions',
              '${s['transaction_count'] ?? 0}', Icons.receipt),
          _metricCard(
              'Total Volume', '${s['total_volume_grams'] ?? 0} g', Icons.scale),
          _metricCard(
              'Total Value',
              'TZS ${_fmt.format(double.tryParse('${s['total_value_tzs']}') ?? 0)}',
              Icons.payments),
          _metricCard(
              'Royalty Collected',
              'TZS ${_fmt.format(double.tryParse('${s['total_royalty_tzs']}') ?? 0)}',
              Icons.account_balance),
        ],
      ),
    );
  }

  Widget _metricCard(String label, String value, IconData icon) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: const Color(0xFFD4A017).withValues(alpha: 0.2),
          child: Icon(icon, color: const Color(0xFFB8860B)),
        ),
        title: Text(label,
            style: TextStyle(color: Colors.grey[600], fontSize: 13)),
        subtitle: Text(value,
            style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20,
                color: Colors.black87)),
      ),
    );
  }
}
