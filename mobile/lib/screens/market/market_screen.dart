import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../services/api_service.dart';
import '../../theme/app_colors.dart';
import '../../widgets/app_card.dart';
import '../../providers/auth_provider.dart';
import '../listings/listing_new_screen.dart';

class MarketScreen extends StatefulWidget {
  final bool showNewListing;
  final bool isAdmin;
  const MarketScreen({super.key, this.showNewListing = false, this.isAdmin = false});
  @override
  State<MarketScreen> createState() => _MarketScreenState();
}

class _MarketScreenState extends State<MarketScreen> {
  List<dynamic> _prices = [];
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
      final p = await ApiService().getCurrentPrices();
      setState(() { _prices = p; _loading = false; });
    } catch (_) {
      setState(() => _loading = false);
    }
  }

  Future<void> _setPrice(String karat) async {
    final c = TextEditingController();
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Set $karat TZS/g'),
        content: TextField(controller: c, keyboardType: const TextInputType.numberWithOptions(decimal: true)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          ElevatedButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Save')),
        ],
      ),
    );
    if (ok == true && c.text.isNotEmpty) {
      await ApiService().setPrice(karat, double.parse(c.text));
      _load();
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dhahabu'),
        actions: [
          if (user != null)
            Padding(
              padding: const EdgeInsets.only(right: 12),
              child: Center(child: Text(user.role.toUpperCase(), style: const TextStyle(fontSize: 11, color: AppColors.gold))),
            ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _load,
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  const Text("TODAY'S GOLD PRICE", style: TextStyle(fontSize: 12, letterSpacing: 1, color: AppColors.gold)),
                  const SizedBox(height: 12),
                  AppCard(
                    child: Column(
                      children: _prices.map((p) {
                        final karat = p['karat']?.toString() ?? '';
                        final price = p['price_per_gram'];
                        final stale = p['is_stale'] == true || price == null;
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          child: Row(
                            children: [
                              SizedBox(width: 48, child: Text(karat, style: const TextStyle(fontWeight: FontWeight.bold))),
                              Expanded(
                                child: Text(
                                  price != null ? 'TSh ${_fmt.format(double.tryParse(price.toString()) ?? 0)} /g' : 'No price',
                                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: stale ? AppColors.warning : AppColors.gold),
                                ),
                              ),
                              if (widget.isAdmin)
                                IconButton(icon: const Icon(Icons.edit, size: 18), onPressed: () => _setPrice(karat)),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _prices.any((p) => p['is_stale'] == true) ? '⚠ Some prices are last known / stale' : 'Live market feed',
                    style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                  ),
                  if (widget.showNewListing) ...[
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: () async {
                        await Navigator.push(context, MaterialPageRoute(builder: (_) => const ListingNewScreen()));
                        _load();
                      },
                      icon: const Icon(Icons.add),
                      label: const Text('+ New Listing'),
                    ),
                  ],
                ],
              ),
      ),
    );
  }
}
