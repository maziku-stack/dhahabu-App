import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/transaction.dart';
import '../services/api_service.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';

class TransactionsScreen extends StatefulWidget {
  const TransactionsScreen({super.key});
  @override
  State<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends State<TransactionsScreen> {
  List<GoldTransaction> _txns = [];
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
      setState(() {
        _txns = data
            .map((e) => GoldTransaction.fromJson(e as Map<String, dynamic>))
            .toList();
        _loading = false;
      });
    } catch (_) {
      setState(() => _loading = false);
    }
  }

  Future<void> _confirm(GoldTransaction t) async {
    try {
      await ApiService().confirmTransaction(t.id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Sale confirmed. Tax/royalty recorded.')),
        );
      }
      _load();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('$e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;
    final isMiner = user?.isMiner == true;

    return RefreshIndicator(
      onRefresh: _load,
      child: _loading
          ? const Center(child: CircularProgressIndicator())
          : _txns.isEmpty
              ? ListView(
                  children: const [
                    SizedBox(height: 100),
                    Center(child: Text('No transactions yet')),
                  ],
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: _txns.length,
                  itemBuilder: (ctx, i) {
                    final t = _txns[i];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 10),
                      child: Padding(
                        padding: const EdgeInsets.all(14),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  '${t.weightGrams} g • ${t.karat}',
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16),
                                ),
                                Chip(
                                  label: Text(t.status,
                                      style: const TextStyle(fontSize: 11)),
                                  backgroundColor: t.isConfirmed
                                      ? Colors.green.shade50
                                      : Colors.orange.shade50,
                                  visualDensity: VisualDensity.compact,
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Text('Total: TZS ${_fmt.format(t.agreedPrice)}'),
                            Text(
                              isMiner
                                  ? 'Dealer: ${t.dealerName.isNotEmpty ? t.dealerName : t.dealerPhone}'
                                  : 'Miner: ${t.minerName.isNotEmpty ? t.minerName : t.minerPhone}',
                              style: TextStyle(
                                  color: Colors.grey[600], fontSize: 13),
                            ),
                            if (t.taxRecord != null) ...[
                              const SizedBox(height: 6),
                              Text(
                                'Royalty (${(t.taxRecord!.royaltyRate * 100).toStringAsFixed(1)}%): '
                                'TZS ${_fmt.format(t.taxRecord!.royaltyAmount)}',
                                style: TextStyle(
                                    color: Colors.blue[800],
                                    fontWeight: FontWeight.w500),
                              ),
                            ],
                            if (t.isPending && isMiner) ...[
                              const SizedBox(height: 10),
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  onPressed: () => _confirm(t),
                                  child: const Text('Confirm Sale'),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
