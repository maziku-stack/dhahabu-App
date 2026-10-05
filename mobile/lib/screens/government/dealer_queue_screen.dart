import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import '../../theme/app_colors.dart';
import '../../widgets/app_card.dart';
import '../../widgets/status_badge.dart';

class DealerQueueScreen extends StatefulWidget {
  const DealerQueueScreen({super.key});
  @override
  State<DealerQueueScreen> createState() => _DealerQueueScreenState();
}

class _DealerQueueScreenState extends State<DealerQueueScreen> {
  List<dynamic> _items = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final d = await ApiService().getPendingDealers();
      setState(() { _items = d; _loading = false; });
    } catch (_) {
      setState(() => _loading = false);
    }
  }

  Future<void> _act(String id, bool approve) async {
    await ApiService().verifyDealer(id, approve: approve);
    _load();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Dealer Verification')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _items.isEmpty
              ? const Center(child: Text('No pending dealers'))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _items.length,
                  itemBuilder: (ctx, i) {
                    final d = _items[i];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: AppCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(d['business_name'] ?? '', style: const TextStyle(fontWeight: FontWeight.bold)),
                            StatusBadge.pending(),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Expanded(child: ElevatedButton(onPressed: () => _act(d['id'].toString(), true), child: const Text('Approve'))),
                                const SizedBox(width: 8),
                                Expanded(child: OutlinedButton(onPressed: () => _act(d['id'].toString(), false), child: const Text('Reject', style: TextStyle(color: AppColors.error)))),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
