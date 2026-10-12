import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../services/api_service.dart';
import '../../theme/app_colors.dart';
import '../../widgets/app_card.dart';

class TaxSummaryScreen extends StatefulWidget {
  const TaxSummaryScreen({super.key});
  @override
  State<TaxSummaryScreen> createState() => _TaxSummaryScreenState();
}

class _TaxSummaryScreenState extends State<TaxSummaryScreen> {
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
      final d = await ApiService().getTaxSummary();
      setState(() {
        _data = d;
        _loading = false;
      });
    } catch (_) {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tax Summary')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                AppCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Assessed government charges',
                          style: TextStyle(color: AppColors.gold)),
                      Text(
                        'TSh ${_fmt.format(double.tryParse('${_data?['total_assessed_charges_tzs']}') ?? 0)}',
                        style: const TextStyle(
                            fontSize: 28, fontWeight: FontWeight.bold),
                      ),
                      Text(
                          '${_data?['transaction_count'] ?? 0} confirmed transactions'),
                      if (_data?['assessment_status'] ==
                          'unavailable_until_authority_api_connected')
                        const Padding(
                          padding: EdgeInsets.only(top: 10),
                          child: Text(
                              'Authority assessment is not connected. This total includes assessed records only; it does not show payments collected.'),
                        ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}
