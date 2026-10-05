import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../services/api_service.dart';
import '../../theme/app_colors.dart';
import '../../widgets/app_card.dart';
import 'listing_new_screen.dart';
import '../transactions/confirm_sale_screen.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';

class ListingsScreen extends StatefulWidget {
  final bool mineOnly;
  const ListingsScreen({super.key, this.mineOnly = false});
  @override
  State<ListingsScreen> createState() => _ListingsScreenState();
}

class _ListingsScreenState extends State<ListingsScreen> {
  List<dynamic> _items = [];
  bool _loading = true;
  final _fmt = NumberFormat('#,##0');

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final data = await ApiService().getListings(mine: widget.mineOnly, status: 'open');
      setState(() { _items = data; _loading = false; });
    } catch (_) {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;
    final canTrade = user?.isMiner == true || user?.isVerifiedDealer == true;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.mineOnly ? 'My Listings' : 'Browse Listings'),
        actions: [
          if (widget.mineOnly)
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: () async {
                await Navigator.push(context, MaterialPageRoute(builder: (_) => const ListingNewScreen()));
                _load();
              },
            ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _load,
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : _items.isEmpty
                ? ListView(children: const [SizedBox(height: 80), Center(child: Text('No open listings'))])
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _items.length,
                    itemBuilder: (ctx, i) {
                      final l = _items[i];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: AppCard(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('${l['weight_grams']} g · ${l['karat']}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                              const SizedBox(height: 4),
                              Text('Asking: TSh ${_fmt.format(double.tryParse('${l['asking_price']}') ?? 0)}'),
                              Text('${l['miner_name'] ?? ''} · ${l['region'] ?? ''}', style: TextStyle(color: Colors.grey[400], fontSize: 13)),
                              if (!widget.mineOnly && user?.isDealer == true) ...[
                                const SizedBox(height: 12),
                                if (!canTrade)
                                  const Text('Verification required to transact', style: TextStyle(color: AppColors.warning))
                                else
                                  ElevatedButton(
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) => ConfirmSaleScreen(
                                            counterpartyPhone: l['miner_phone'] ?? '',
                                            weight: double.tryParse('${l['weight_grams']}') ?? 0,
                                            karat: l['karat'] ?? '24K',
                                            pricePerGram: double.tryParse('${l['price_per_gram'] ?? l['asking_price']}') ?? 0,
                                            listingId: l['id']?.toString(),
                                          ),
                                        ),
                                      );
                                    },
                                    child: const Text('Start Confirm Sale'),
                                  ),
                              ],
                            ],
                          ),
                        ),
                      );
                    },
                  ),
      ),
    );
  }
}
