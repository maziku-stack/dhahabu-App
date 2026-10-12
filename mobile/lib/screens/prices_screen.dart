import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/price.dart';
import '../services/api_service.dart';

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

  @override
  Widget build(BuildContext context) {
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
                            child: const Icon(Icons.price_change_outlined,
                                color: Color(0xFFB8860B)),
                          ),
                          title: Text(
                            p.pricePerGram != null
                                ? '${p.currency} ${_fmt.format(p.pricePerGram)}'
                                : 'No official price',
                            style: const TextStyle(
                                fontWeight: FontWeight.w600, fontSize: 18),
                          ),
                          subtitle: Text(
                            stale
                                ? 'Commission feed not connected or price is stale'
                                : '${p.priceType} · ${p.unit} · ${p.source ?? 'Mining Commission'} · Ref ${p.reference ?? '—'}',
                            style: TextStyle(
                                color: stale
                                    ? Colors.orange[800]
                                    : Colors.green[700]),
                          ),
                          trailing: null,
                        ),
                      );
                    }),
                    if (_prices.isEmpty)
                      const Card(
                        child: Padding(
                          padding: EdgeInsets.all(16),
                          child: Text(
                              'No official prices are available until the Mining Commission integration is approved and connected.'),
                        ),
                      ),
                  ],
                ),
    );
  }
}
