import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../services/api_service.dart';
import '../../providers/auth_provider.dart';
import '../../theme/app_colors.dart';
import '../../widgets/app_card.dart';
import '../../widgets/status_badge.dart';
import 'confirm_sale_screen.dart';
import 'receipt_screen.dart';

class TransactionsScreen extends StatefulWidget {
  const TransactionsScreen({super.key});
  @override
  State<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends State<TransactionsScreen> {
  List<dynamic> _items = [];
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
      final data = await ApiService().getTransactions();
      setState(() { _items = data; _loading = false; });
    } catch (_) {
      setState(() => _loading = false);
    }
  }

  Future<void> _confirm(String id) async {
    try {
      final txn = await ApiService().confirmTransaction(id);
      if (!mounted) return;
      Navigator.push(context, MaterialPageRoute(builder: (_) => ReceiptScreen(txn: txn)));
      _load();
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sales'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () async {
              await Navigator.push(context, MaterialPageRoute(builder: (_) => const ConfirmSaleScreen(counterpartyPhone: '')));
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
                ? ListView(children: const [SizedBox(height: 80), Center(child: Text('No transactions'))])
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _items.length,
                    itemBuilder: (ctx, i) {
                      final t = _items[i];
                      final pending = t['status'] == 'pending_confirm';
                      final confirmed = t['status'] == 'confirmed';
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: AppCard(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text('${t['weight_grams']} g · ${t['karat']}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                  confirmed
                                      ? StatusBadge.verified()
                                      : StatusBadge.pending(),
                                ],
                              ),
                              Text('TSh ${_fmt.format(double.tryParse('${t['agreed_price']}') ?? 0)}'),
                              if (t['tax_record'] != null)
                                Text('Royalty: TSh ${_fmt.format(double.tryParse('${t['tax_record']['royalty_amount']}') ?? 0)}',
                                    style: const TextStyle(color: AppColors.gold)),
                              if (pending && user?.isMiner == true) ...[
                                const SizedBox(height: 12),
                                ElevatedButton(
                                  onPressed: () => _confirm(t['id'].toString()),
                                  child: const Text('Confirm & Sign'),
                                ),
                              ],
                              TextButton(
                                onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ReceiptScreen(txn: Map<String, dynamic>.from(t)))),
                                child: const Text('View receipt'),
                              ),
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
