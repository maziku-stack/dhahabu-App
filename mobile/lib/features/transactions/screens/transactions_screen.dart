import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:dhahabu/core/network/api_service.dart';
import 'package:dhahabu/features/auth/providers/auth_provider.dart';
import 'package:dhahabu/core/theme/app_colors.dart';
import 'package:dhahabu/core/widgets/app_card.dart';
import 'package:dhahabu/core/widgets/status_badge.dart';
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
      setState(() {
        _items = data;
        _loading = false;
      });
    } catch (_) {
      setState(() => _loading = false);
    }
  }

  Future<void> _confirm(String id) async {
    final pinController = TextEditingController();
    final pin = await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Confirm with your PIN'),
        content: TextField(
          controller: pinController,
          autofocus: true,
          obscureText: true,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(labelText: 'Account PIN'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(dialogContext, pinController.text),
            child: const Text('Confirm sale'),
          ),
        ],
      ),
    );
    pinController.dispose();
    if (pin == null || pin.isEmpty || !mounted) return;

    try {
      final txn = await ApiService().confirmTransaction(id, pin: pin);
      if (!mounted) return;
      Navigator.push(
          context, MaterialPageRoute(builder: (_) => ReceiptScreen(txn: txn)));
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sales'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () async {
              await Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) =>
                          const ConfirmSaleScreen(counterpartyPhone: '')));
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
                ? ListView(children: const [
                    SizedBox(height: 80),
                    Center(child: Text('No transactions'))
                  ])
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _items.length,
                    itemBuilder: (ctx, i) {
                      final t = _items[i];
                      final pending = t['status'] == 'pending_confirm';
                      final confirmed = t['status'] == 'confirmed';
                      final isMiner = user?.id == t['miner']?.toString();
                      final isDealer = user?.id == t['dealer']?.toString();
                      final currentPartyAccepted = isMiner
                          ? t['miner_confirmed_at'] != null
                          : isDealer && t['dealer_confirmed_at'] != null;
                      final canConfirm = pending &&
                          (isMiner || isDealer) &&
                          !currentPartyAccepted;
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: AppCard(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text('${t['weight_grams']} g · ${t['karat']}',
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16)),
                                  confirmed
                                      ? StatusBadge.verified()
                                      : StatusBadge.pending(),
                                ],
                              ),
                              Text(
                                  'TSh ${_fmt.format(double.tryParse('${t['agreed_price']}') ?? 0)}'),
                              if (t['tax_record'] != null)
                                Text(
                                    'Government charge: ${t['tax_record']['assessment_status'] ?? 'not assessed'} · Payment: ${t['tax_record']['payment_status'] ?? 'not started'}',
                                    style:
                                        const TextStyle(color: AppColors.gold)),
                              if (canConfirm) ...[
                                const SizedBox(height: 12),
                                ElevatedButton(
                                  onPressed: () => _confirm(t['id'].toString()),
                                  child: const Text('Agree to sale & Sign'),
                                ),
                              ],
                              TextButton(
                                onPressed: () => Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (_) => ReceiptScreen(
                                            txn:
                                                Map<String, dynamic>.from(t)))),
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
