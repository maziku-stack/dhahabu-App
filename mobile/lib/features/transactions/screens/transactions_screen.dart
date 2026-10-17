import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:dhahabu/core/network/api_service.dart';
import 'package:dhahabu/core/theme/app_colors.dart';
import 'package:dhahabu/features/auth/providers/auth_provider.dart';
import 'add_new_sale_screen.dart';
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

  Future<void> _newSale() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const AddNewSaleScreen(counterpartyPhone: ''),
      ),
    );
    _load();
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
        context,
        MaterialPageRoute(builder: (_) => ReceiptScreen(txn: txn)),
      );
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
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        title: Text(
          'Sales',
          style: textTheme.titleLarge?.copyWith(color: AppColors.navy),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        tooltip: 'Record a sale',
        backgroundColor: AppColors.gold,
        foregroundColor: AppColors.navy,
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
        ),
        onPressed: _newSale,
        child: const Icon(Icons.add_rounded, size: 30),
      ),
      body: RefreshIndicator(
        color: AppColors.navy,
        onRefresh: _load,
        child: _loading
            ? const Center(
          child: CircularProgressIndicator(color: AppColors.gold),
        )
            : _items.isEmpty
            ? const _EmptyState()
            : ListView.separated(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 96),
          itemCount: _items.length,
          separatorBuilder: (_, __) => const SizedBox(height: 14),
          itemBuilder: (ctx, i) {
            final t = _items[i];
            final confirmed = t['status'] == 'confirmed';
            final pending = t['status'] == 'pending_confirm';
            final isMiner = user?.id == t['miner']?.toString();
            final isDealer = user?.id == t['dealer']?.toString();
            final currentPartyAccepted = isMiner
                ? t['miner_confirmed_at'] != null
                : isDealer && t['dealer_confirmed_at'] != null;
            final canConfirm = pending &&
                (isMiner || isDealer) &&
                !currentPartyAccepted;
            final price =
                double.tryParse('${t['agreed_price']}') ?? 0;
            final tax = t['tax_record'];

            return Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          '${t['weight_grams']} g  ·  ${t['karat']}',
                          style: textTheme.titleMedium?.copyWith(
                            color: AppColors.navy,
                            fontFeatures: const [
                              FontFeature.tabularFigures()
                            ],
                          ),
                        ),
                      ),
                      _StatusPill(confirmed: confirmed),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'TSh ${_fmt.format(price)}',
                    style: textTheme.displayLarge?.copyWith(
                      color: AppColors.navy,
                      fontSize: 24,
                      fontFeatures: const [
                        FontFeature.tabularFigures()
                      ],
                    ),
                  ),
                  if (tax != null) ...[
                    const SizedBox(height: 10),
                    Text(
                      'Government charge: ${tax['assessment_status'] ?? 'not assessed'}'
                          '  ·  Payment: ${tax['payment_status'] ?? 'not started'}',
                      style: textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                        height: 1.4,
                      ),
                    ),
                  ],
                  if (canConfirm) ...[
                    const SizedBox(height: 14),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.gold,
                          foregroundColor: AppColors.navy,
                          minimumSize: const Size.fromHeight(48),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: () => _confirm(t['id'].toString()),
                        child: Text(
                          'Agree to sale & sign',
                          style: textTheme.labelLarge
                              ?.copyWith(color: AppColors.navy),
                        ),
                      ),
                    ),
                  ],
                  const SizedBox(height: 4),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: TextButton.icon(
                      style: TextButton.styleFrom(
                        foregroundColor: AppColors.navy,
                        padding: EdgeInsets.zero,
                        minimumSize: const Size(48, 44),
                      ),
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ReceiptScreen(
                            txn: Map<String, dynamic>.from(t),
                          ),
                        ),
                      ),
                      icon: const Icon(Icons.receipt_long_outlined,
                          size: 18, color: AppColors.gold),
                      label: Text(
                        'View receipt',
                        style: textTheme.labelLarge?.copyWith(
                          color: AppColors.navy,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  const _StatusPill({required this.confirmed});

  final bool confirmed;

  @override
  Widget build(BuildContext context) {
    final color = confirmed ? AppColors.success : AppColors.warning;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            confirmed ? Icons.check_circle_rounded : Icons.schedule_rounded,
            size: 14,
            color: color,
          ),
          const SizedBox(width: 5),
          Text(
            confirmed ? 'Confirmed' : 'Awaiting',
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: color,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 32),
      children: [
        const SizedBox(height: 120),
        Center(
          child: Container(
            width: 84,
            height: 84,
            decoration: BoxDecoration(
              color: AppColors.gold.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.receipt_long_outlined,
                size: 40, color: AppColors.navy),
          ),
        ),
        const SizedBox(height: 24),
        Text(
          'No sales yet',
          textAlign: TextAlign.center,
          style: textTheme.titleLarge
              ?.copyWith(color: AppColors.navy, fontSize: 22),
        ),
        const SizedBox(height: 12),
        Text(
          'Sales you record or confirm will appear here with their receipts. Use the + button below to record a new sale.',
          textAlign: TextAlign.center,
          style: textTheme.bodyMedium?.copyWith(
            color: AppColors.textSecondary,
            height: 1.5,
          ),
        ),
      ],
    );
  }
}
