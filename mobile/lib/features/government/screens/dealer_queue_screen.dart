import 'package:flutter/material.dart';
import 'package:dhahabu/core/network/api_service.dart';
import 'package:dhahabu/core/theme/app_colors.dart';
import 'package:dhahabu/core/widgets/app_card.dart';
import 'package:dhahabu/core/widgets/status_badge.dart';
import 'package:dhahabu/l10n/l10n.dart';

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
      setState(() {
        _items = d;
        _loading = false;
      });
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
    final l10n = context.l10n;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.dealerVerification)),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _items.isEmpty
              ? Center(child: Text(l10n.noPendingDealers))
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
                            Text(d['business_name'] ?? '',
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold)),
                            Text(l10n.owner(d['owner_name'] ?? '—')),
                            Text(l10n.phone(d['owner_phone'] ?? '—')),
                            Text(
                                l10n.license(d['license_number'] ?? 'Not provided')),
                            StatusBadge.pending(),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Expanded(
                                    child: ElevatedButton(
                                        onPressed: () =>
                                            _act(d['id'].toString(), true),
                                        child: Text(l10n.approve))),
                                const SizedBox(width: 8),
                                Expanded(
                                    child: OutlinedButton(
                                        onPressed: () =>
                                            _act(d['id'].toString(), false),
                                        child: Text(l10n.reject,
                                            style: const TextStyle(
                                                color: AppColors.error)))),
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
