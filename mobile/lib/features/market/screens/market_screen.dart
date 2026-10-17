import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import 'package:dhahabu/core/network/api_service.dart';
import 'package:dhahabu/core/theme/app_colors.dart';
import 'package:dhahabu/core/widgets/dhahabu_logo.dart';
import 'package:dhahabu/features/auth/providers/auth_provider.dart';
import 'package:dhahabu/features/transactions/screens/add_new_sale_screen.dart';
import 'package:dhahabu/features/transactions/screens/receipt_screen.dart';
import 'package:dhahabu/l10n/l10n.dart';

class MarketScreen extends StatefulWidget {
  final bool showNewListing;
  final bool isAdmin;

  const MarketScreen({
    super.key,
    this.showNewListing = false,
    this.isAdmin = false,
  });

  @override
  State<MarketScreen> createState() => _MarketScreenState();
}

class _MarketScreenState extends State<MarketScreen> {
  List<dynamic> _transactions = [];
  bool _loading = true;
  final _fmt = NumberFormat('#,##0.00');
  final _fmtInt = NumberFormat('#,##0');

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final txns = await ApiService().getTransactions();
      if (!mounted) return;
      setState(() {
        _transactions = txns;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
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

  String _firstName(String fullName, String fallback) {
    final t = fullName.trim();
    return t.isEmpty ? fallback : t.split(RegExp(r'\s+')).first;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final user = context.watch<AuthProvider>().user;
    final textTheme = Theme.of(context).textTheme;

    final String subtitle = widget.showNewListing
        ? l10n.minerDashboard
        : widget.isAdmin
            ? l10n.govDashboard
            : user?.isDealer == true
                ? l10n.dealerDashboard
                : l10n.goldMarket;

    final String chip = widget.isAdmin
        ? l10n.government
        : (user?.role.toUpperCase() ?? 'USER');

    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: AppColors.navy,
        foregroundColor: AppColors.white,
        surfaceTintColor: Colors.transparent,
        toolbarHeight: 64,
        elevation: 0,
        scrolledUnderElevation: 0,
        leadingWidth: 56,
        leading: const Padding(
          padding: EdgeInsets.only(left: 16),
          child: Center(child: DhahabuLogo(size: 32)),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              l10n.dhahabu,
              style: textTheme.titleLarge?.copyWith(
                color: AppColors.white,
                fontWeight: FontWeight.w700,
              ),
            ),
            Text(
              subtitle,
              style: textTheme.bodySmall?.copyWith(
                color: AppColors.white.withValues(alpha: 0.7),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        actions: [
          if (user != null || widget.isAdmin)
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Center(
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: AppColors.gold.withValues(alpha: 0.18),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    chip,
                    style: textTheme.labelSmall?.copyWith(
                      color: AppColors.goldLight,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.8,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        tooltip: l10n.recordSaleTooltip,
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
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 96),
          children: [
            if (widget.showNewListing)
              ..._minerHeader(user?.fullName ?? '', textTheme, l10n)
            else if (widget.isAdmin)
              ..._plainHeader(
                l10n.welcomeUser(_firstName(user?.fullName ?? '', 'Admin')),
                l10n.govOversightSubtitle,
                textTheme,
              )
            else if (user?.isDealer == true)
              ..._dealerHeader(user?.fullName ?? '', textTheme, l10n)
            else
              ..._plainHeader(
                l10n.goldMarket,
                l10n.goldMarketOverviewSubtitle,
                textTheme,
              ),
            const SizedBox(height: 28),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  l10n.recentSales,
                  style: textTheme.titleLarge?.copyWith(
                    color: AppColors.navy,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  l10n.totalCount(_transactions.length),
                  style: textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (_loading)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 30),
                child: Center(
                    child: CircularProgressIndicator(color: AppColors.gold)),
              )
            else if (_transactions.isEmpty)
              const SizedBox.shrink()
            else
              ..._transactions.map((t) {
                final confirmed = t['status'] == 'confirmed';
                final price = double.tryParse('${t['agreed_price']}') ?? 0;
                final tax = t['tax_record'];

                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
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
                          _StatusPill(confirmed: confirmed, l10n: l10n),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'TSh ${_fmt.format(price)}',
                        style: textTheme.displayLarge?.copyWith(
                          color: AppColors.navy,
                          fontSize: 22,
                          fontFeatures: const [
                            FontFeature.tabularFigures()
                          ],
                        ),
                      ),
                      if (tax != null) ...[
                        const SizedBox(height: 8),
                        Text(
                          '${l10n.governmentCharge(tax['assessment_status'] ?? l10n.notAssessed)}  ·  ${l10n.paymentStatus(tax['payment_status'] ?? l10n.notStarted)}',
                          style: textTheme.bodySmall?.copyWith(
                            color: AppColors.textSecondary,
                            height: 1.4,
                          ),
                        ),
                      ],
                      const SizedBox(height: 8),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: TextButton.icon(
                          style: TextButton.styleFrom(
                            foregroundColor: AppColors.navy,
                            padding: EdgeInsets.zero,
                            minimumSize: const Size(48, 40),
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
                            l10n.viewReceipt,
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
              }),
          ],
        ),
      ),
    );
  }

  List<Widget> _plainHeader(String title, String subtitle, TextTheme t) => [
        Text(
          title,
          style: t.displayLarge?.copyWith(color: AppColors.navy, fontSize: 26),
        ),
        const SizedBox(height: 4),
        Text(
          subtitle,
          style: t.bodyMedium?.copyWith(color: AppColors.textSecondary),
        ),
      ];

  List<Widget> _minerHeader(String fullName, TextTheme t, AppLocalizations l10n) {
    double totalWeight = 0;
    double totalRevenue = 0;
    for (var tx in _transactions) {
      final w = double.tryParse('${tx['weight_grams']}') ?? 0;
      final p = double.tryParse('${tx['agreed_price']}') ?? 0;
      totalWeight += w;
      totalRevenue += p;
    }

    return [
      ..._plainHeader(
        l10n.welcomeUser(_firstName(fullName, l10n.miner)),
        l10n.minerOverviewSubtitle,
        t,
      ),
      const SizedBox(height: 24),
      Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF17375D), AppColors.navy, Color(0xFF091629)],
          ),
          border: Border.all(color: AppColors.gold.withValues(alpha: .3)),
          boxShadow: [
            BoxShadow(
              color: AppColors.navy.withValues(alpha: .2),
              blurRadius: 14,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  l10n.portfolioSummary,
                  style: const TextStyle(
                    color: AppColors.gold,
                    fontSize: 11,
                    letterSpacing: 1.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.gold.withValues(alpha: .2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    l10n.active,
                    style: const TextStyle(
                      color: AppColors.gold,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.totalSalesValue,
                        style: const TextStyle(color: Colors.white70, fontSize: 12),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'TZS ${_fmtInt.format(totalRevenue)}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          fontFeatures: [FontFeature.tabularFigures()],
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                    width: 1,
                    height: 35,
                    color: Colors.white24,
                    margin: const EdgeInsets.symmetric(horizontal: 16)),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.goldSold,
                        style: const TextStyle(color: Colors.white70, fontSize: 12),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${totalWeight.toStringAsFixed(1)} g',
                        style: const TextStyle(
                          color: AppColors.gold,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          fontFeatures: [FontFeature.tabularFigures()],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    ];
  }

  List<Widget> _dealerHeader(String fullName, TextTheme t, AppLocalizations l10n) {
    double totalWeight = 0;
    double totalRevenue = 0;
    for (var tx in _transactions) {
      final w = double.tryParse('${tx['weight_grams']}') ?? 0;
      final p = double.tryParse('${tx['agreed_price']}') ?? 0;
      totalWeight += w;
      totalRevenue += p;
    }

    return [
      ..._plainHeader(
        l10n.welcomeUser(_firstName(fullName, l10n.dealer)),
        l10n.dealerLicensedSubtitle,
        t,
      ),
      const SizedBox(height: 20),
      Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF17375D), AppColors.navy, Color(0xFF091629)],
          ),
          border: Border.all(color: AppColors.gold.withValues(alpha: .3)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.dealerPortfolioSummary,
              style: const TextStyle(
                color: AppColors.gold,
                fontSize: 11,
                letterSpacing: 1.5,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.totalPurchases,
                        style: const TextStyle(color: Colors.white70, fontSize: 12),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'TZS ${_fmtInt.format(totalRevenue)}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                    width: 1,
                    height: 35,
                    color: Colors.white24,
                    margin: const EdgeInsets.symmetric(horizontal: 16)),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.goldAcquired,
                        style: const TextStyle(color: Colors.white70, fontSize: 12),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${totalWeight.toStringAsFixed(1)} g',
                        style: const TextStyle(
                          color: AppColors.gold,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    ];
  }
}

class _StatusPill extends StatelessWidget {
  const _StatusPill({required this.confirmed, required this.l10n});

  final bool confirmed;
  final AppLocalizations l10n;

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
            confirmed ? l10n.confirmed : l10n.awaiting,
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
