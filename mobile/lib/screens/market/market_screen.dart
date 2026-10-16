import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
import '../../services/api_service.dart';
import 'package:dhahabu/core/theme/app_colors.dart';
import '../../widgets/app_card.dart';
import '../../widgets/dhahabu_logo.dart';
import '../listings/listing_new_screen.dart';

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
  List<dynamic> _prices = [];
  bool _loading = true;
  bool _loadFailed = false;
  final _fmt = NumberFormat('#,##0.00');

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final prices = await ApiService().getCurrentPrices();
      if (!mounted) return;
      setState(() {
        _prices = prices;
        _loading = false;
        _loadFailed = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _loadFailed = true;
      });
    }
  }

  Future<void> _openNewListing() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const ListingNewScreen()),
    );
    if (mounted) _load();
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;
    final isMinerHome = widget.showNewListing;

    return Scaffold(
      appBar: AppBar(
        leading: isMinerHome
            ? const Padding(
                padding: EdgeInsets.only(left: 12),
                child: Center(child: DhahabuLogo(size: 38)),
              )
            : null,
        title: isMinerHome
            ? const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Dhahabu',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                  Text(
                    'MINER DASHBOARD',
                    style: TextStyle(
                      fontSize: 10,
                      letterSpacing: 1.4,
                      color: AppColors.gold,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              )
            : const Text('Gold market'),
        actions: [
          if (user != null)
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 7,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.gold.withValues(alpha: .12),
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(
                      color: AppColors.gold.withValues(alpha: .35),
                    ),
                  ),
                  child: Text(
                    user.role.toUpperCase(),
                    style: const TextStyle(
                      fontSize: 10,
                      letterSpacing: .8,
                      color: AppColors.gold,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _load,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
          children: isMinerHome
              ? _buildMinerDashboard(user?.fullName ?? '')
              : user?.isDealer == true
                  ? _buildDealerDashboard(user?.fullName ?? '')
                  : _buildMarketContent(),
        ),
      ),
    );
  }

  List<Widget> _buildMinerDashboard(String fullName) {
    final firstName = fullName.trim().isEmpty
        ? 'Miner'
        : fullName.trim().split(RegExp(r'\s+')).first;

    return [
      Container(
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(22),
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF17375D), AppColors.navy, Color(0xFF091629)],
          ),
          border: Border.all(color: AppColors.gold.withValues(alpha: .28)),
          boxShadow: [
            BoxShadow(
              color: AppColors.navy.withValues(alpha: .32),
              blurRadius: 22,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'WELCOME BACK',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: .72),
                      fontSize: 11,
                      letterSpacing: 1.5,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Habari, $firstName',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      height: 1.1,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Follow gold prices and manage your listings.',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: .82),
                      fontSize: 13,
                      height: 1.35,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Container(
              width: 54,
              height: 54,
              decoration: BoxDecoration(
                color: AppColors.gold.withValues(alpha: .14),
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.gold.withValues(alpha: .5)),
              ),
              child: const Icon(
                Icons.auto_awesome,
                color: AppColors.gold,
                size: 26,
              ),
            ),
          ],
        ),
      ),
      const SizedBox(height: 26),
      Row(
        children: [
          const Expanded(
            child: Text(
              'Today’s gold prices',
              style: TextStyle(fontSize: 19, fontWeight: FontWeight.w700),
            ),
          ),
          if (!_loading && _prices.isNotEmpty)
            _MarketStatus(
              stale: _prices.any(
                (p) =>
                    p['is_stale'] == true ||
                    (p['value'] ?? p['price_per_gram']) == null,
              ),
            ),
        ],
      ),
      const SizedBox(height: 5),
      Text(
        'Reference price per gram',
        style: TextStyle(
          color: Theme.of(context).colorScheme.onSurfaceVariant,
          fontSize: 14,
        ),
      ),
      const SizedBox(height: 13),
      _buildPriceCard(),
      const SizedBox(height: 25),
      const Text(
        'Grow your gold business',
        style: TextStyle(fontSize: 19, fontWeight: FontWeight.w700),
      ),
      const SizedBox(height: 12),
      Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: AppColors.surfaceDark,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: AppColors.gold.withValues(alpha: .14),
                    borderRadius: BorderRadius.circular(13),
                  ),
                  child: const Icon(
                    Icons.inventory_2_outlined,
                    color: AppColors.gold,
                  ),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    'List gold for sale',
                    style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              'Add the weight, karat and price to let licensed dealers find your gold.',
              style: TextStyle(
                color: Colors.white.withValues(alpha: .68),
                fontSize: 13,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _openNewListing,
                icon: const Icon(Icons.add),
                label: const Text('Create a listing'),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size.fromHeight(52),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(13),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    ];
  }

  List<Widget> _buildMarketContent() => [
        const Text(
          'Today’s gold prices',
          style: TextStyle(fontSize: 21, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 5),
        Text(
          'Reference price per gram',
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 16),
        _buildPriceCard(),
      ];

  List<Widget> _buildDealerDashboard(String fullName) {
    final firstName = fullName.trim().isEmpty
        ? 'Dealer'
        : fullName.trim().split(RegExp(r'\s+')).first;
    return [
      Container(
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(22),
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF17375D), AppColors.navy, Color(0xFF091629)],
          ),
          border: Border.all(color: AppColors.gold.withValues(alpha: .28)),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'DEALER DASHBOARD',
                    style: TextStyle(
                      color: AppColors.gold,
                      fontSize: 11,
                      letterSpacing: 1.4,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Karibu, $firstName',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 7),
                  Text(
                    'Check reference prices before browsing available gold.',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: .84),
                      fontSize: 14,
                      height: 1.35,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            const Icon(Icons.storefront_outlined,
                color: AppColors.gold, size: 36),
          ],
        ),
      ),
      const SizedBox(height: 24),
      Row(
        children: [
          const Expanded(
            child: Text(
              'Today’s gold prices',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
            ),
          ),
          if (!_loading && _prices.isNotEmpty)
            _MarketStatus(
              stale: _prices.any(
                (p) =>
                    p['is_stale'] == true ||
                    (p['value'] ?? p['price_per_gram']) == null,
              ),
            ),
        ],
      ),
      const SizedBox(height: 5),
      Text(
        'Reference price per gram',
        style: TextStyle(
          color: Theme.of(context).colorScheme.onSurfaceVariant,
          fontSize: 14,
        ),
      ),
      const SizedBox(height: 13),
      _buildPriceCard(),
    ];
  }

  Widget _buildPriceCard() {
    if (_loading) {
      return const AppCard(
        padding: EdgeInsets.symmetric(vertical: 30),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (_loadFailed || _prices.isEmpty) {
      return AppCard(
        child: Column(
          children: [
            Icon(
              _loadFailed
                  ? Icons.cloud_off_outlined
                  : Icons.price_change_outlined,
              color: AppColors.gold,
              size: 28,
            ),
            const SizedBox(height: 8),
            Text(_loadFailed
                ? 'Prices could not be loaded'
                : 'Official Mining Commission price feed is not connected yet'),
            TextButton.icon(
              onPressed: _load,
              icon: const Icon(Icons.refresh),
              label: const Text('Try again'),
            ),
          ],
        ),
      );
    }

    return AppCard(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Column(
        children: _prices.map((p) {
          final label = p['price_type']?.toString() ??
              p['karat']?.toString() ??
              'Gold price';
          final price = p['value'] ?? p['price_per_gram'];
          final unit = p['unit']?.toString() ?? 'TZS/g';
          final stale = p['is_stale'] == true || price == null;
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 42,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: AppColors.gold.withValues(alpha: .13),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.price_change_outlined,
                      color: AppColors.gold),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(label,
                          style: const TextStyle(
                              fontSize: 12, fontWeight: FontWeight.w700)),
                      Text(
                        price != null
                            ? '${p['currency'] ?? 'TZS'} ${_fmt.format(double.tryParse(price.toString()) ?? 0)}'
                            : 'Price unavailable',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                          color: stale
                              ? AppColors.warning
                              : Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                      Text(
                        unit,
                        style: TextStyle(
                          fontSize: 12,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                      if (p['source'] != null)
                        Text(
                          '${p['source']}${p['reference'] == null ? '' : ' · Ref ${p['reference']}'}',
                          style: TextStyle(
                              fontSize: 11,
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurfaceVariant),
                        ),
                    ],
                  ),
                ),
                Icon(
                  stale ? Icons.schedule : Icons.check_circle_outline,
                  color: stale ? AppColors.warning : AppColors.success,
                  size: 19,
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _MarketStatus extends StatelessWidget {
  const _MarketStatus({required this.stale});

  final bool stale;

  @override
  Widget build(BuildContext context) {
    final color = stale ? AppColors.warning : AppColors.success;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: .13),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(stale ? Icons.schedule : Icons.circle, color: color, size: 9),
          const SizedBox(width: 6),
          Text(
            stale ? 'Last known' : 'Current',
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w600,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}
