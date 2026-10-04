import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/price.dart';
import '../services/api_service.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';

class PricesScreen extends StatefulWidget {
  const PricesScreen({super.key});
  @override
  State<PricesScreen> createState() => _PricesScreenState();
}

class _PricesScreenState extends State<PricesScreen> {
  List<GoldPrice> _prices = [];
  bool _loading = true;
  String? _error;
  final _fmt = NumberFormat('#,##0.00');

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final data = await ApiService().getCurrentPrices();
      setState(() {
        _prices = data
            .map((e) => GoldPrice.fromJson(e as Map<String, dynamic>))
            .toList();
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString().replaceFirst('Exception: ', '');
        _loading = false;
      });
    }
  }

  Future<void> _setPrice(String karat) async {
    final ctrl = TextEditingController();
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Set $karat price (TZS/g)'),
        content: TextField(
          controller: ctrl,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: const InputDecoration(labelText: 'Price per gram'),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancel')),
          ElevatedButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Save')),
        ],
      ),
    );
    if (ok == true && ctrl.text.isNotEmpty) {
      try {
        await ApiService().setPrice(
          karat: karat,
          pricePerGram: double.parse(ctrl.text),
        );
        _load();
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(e.toString())),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isAdmin = context.watch<AuthProvider>().user?.isAdmin == true;

    return RefreshIndicator(
      onRefresh: _load,
      child: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? ListView(children: [
                  Padding(
                      padding: const EdgeInsets.all(24), child: Text(_error!))
                ])
              : ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    Text(
                      "Today's Gold Prices",
                      style: Theme.of(context)
                          .textTheme
                          .titleLarge
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text('Per gram • Tanzania Shillings',
                        style: TextStyle(color: Colors.grey[600])),
                    const SizedBox(height: 16),
                    ..._prices.map((p) {
                      final stale = p.isStale || p.pricePerGram == null;
                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 12),
                          leading: CircleAvatar(
                            backgroundColor:
                                const Color(0xFFD4A017).withValues(alpha: 0.2),
                            child: Text(p.karat,
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                    color: Color(0xFFB8860B))),
                          ),
                          title: Text(
                            p.pricePerGram != null
                                ? 'TZS ${_fmt.format(p.pricePerGram)} / g'
                                : 'No price set',
                            style: const TextStyle(
                                fontWeight: FontWeight.w600, fontSize: 18),
                          ),
                          subtitle: Text(
                            stale
                                ? '⚠ Last known / stale'
                                : 'Live • updated recently',
                            style: TextStyle(
                                color: stale
                                    ? Colors.orange[800]
                                    : Colors.green[700]),
                          ),
                          trailing: isAdmin
                              ? IconButton(
                                  icon: const Icon(Icons.edit),
                                  onPressed: () => _setPrice(p.karat),
                                )
                              : null,
                        ),
                      );
                    }),
                    if (isAdmin)
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: OutlinedButton.icon(
                          onPressed: () => _setPrice('24K'),
                          icon: const Icon(Icons.add),
                          label: const Text('Publish new price'),
                        ),
                      ),
                  ],
                ),
    );
  }
}
