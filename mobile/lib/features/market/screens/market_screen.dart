import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import 'package:dhahabu/features/auth/providers/auth_provider.dart';
import 'package:dhahabu/core/network/api_service.dart';
import 'package:dhahabu/core/theme/app_colors.dart';
import 'package:dhahabu/core/widgets/app_card.dart';
import 'package:dhahabu/core/widgets/dhahabu_logo.dart';
import 'package:dhahabu/features/listings/screens/listing_new_screen.dart';

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
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: AppColors.navy,
        foregroundColor: AppColors.white,
        toolbarHeight: 64,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: const Padding(
          padding: EdgeInsets.only(left: 12),
          child: Center(child: DhahabuLogo(size: 36)),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Dhahabu',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.white,
              ),
            ),
            Text(
              isMinerHome
                  ? '${user?.role.toUpperCase() ?? 'MINER'} DASHBOARD'
                  : widget.isAdmin
                      ? 'GOVERNMENT DASHBOARD'
                      : user?.isDealer == true
                          ? 'DEALER DASHBOARD'
                          : 'GOLD MARKET',
              style: const TextStyle(
                fontSize: 10,
                letterSpacing: 1.4,
                color: AppColors.gold,
                fontWeight: FontWeight.w600,
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
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 7,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.gold.withValues(alpha: .2),
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(
                      color: AppColors.gold.withValues(alpha: .4),
                    ),
                  ),
                  child: Text(
                    widget.isAdmin ? 'GOVERNMENT' : (user?.role.toUpperCase() ?? 'USER'),
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
          borderRadius: BorderRadius.circular(20),
          color: Colors.white,
          border: Border.all(color: AppColors.border),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: .04),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'WELCOME BACK',
                    style: TextStyle(
                      color: AppColors.gold,
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
                      color: AppColors.navy,
                      fontSize: 24,
                      height: 1.1,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Follow gold prices and manage your listings.',
                    style: TextStyle(
                      color: AppColors.textSecondary,
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
                color: AppColors.gold.withValues(alpha: .15),
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.gold),
              ),
              child: const Icon(
                Icons.auto_awesome,
                color: AppColors.navy,
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
              style: TextStyle(
                fontSize: 19,
                fontWeight: FontWeight.w700,
                color: AppColors.navy,
              ),
            ),
          ),
          if (!_loading && _prices.isNotEmpty)
            _MarketStatus(
              isStale: _prices.any(
                (p) =>
                    p['is_stale'] == true ||
                    (p['value'] ?? p['price_per_gram']) == null,
              ),
            ),
        ],
      ),
      const SizedBox(height: 5),
      const Text(
        'Reference price per gram',
        style: TextStyle(
          color: AppColors.textSecondary,
          fontSize: 14,
        ),
      ),
      const SizedBox(height: 13),
      _buildPriceCard(),
      const SizedBox(height: 25),
      const Text(
        'Grow your gold business',
        style: TextStyle(
          fontSize: 19,
          fontWeight: FontWeight.w700,
          color: AppColors.navy,
        ),
      ),
      const SizedBox(height: 12),
      Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: const Color(0xFFF9FAFB),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.border),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: .03),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
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
                    color: AppColors.gold.withValues(alpha: .15),
                    borderRadius: BorderRadius.circular(13),
                  ),
                  child: const Icon(
                    Icons.inventory_2_outlined,
                    color: AppColors.navy,
                  ),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    'List gold for sale',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                      color: AppColors.navy,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            const Text(
              'Add the weight, karat and price to let licensed dealers find your gold.',
              style: TextStyle(
                color: AppColors.textSecondary,
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
                  backgroundColor: AppColors.gold,
                  foregroundColor: AppColors.navy,
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
          style: TextStyle(
            fontSize: 21,
            fontWeight: FontWeight.w700,
            color: AppColors.navy,
          ),
        ),
        const SizedBox(height: 5),
        const Text(
          'Reference price per gram',
          style: TextStyle(
            color: AppColors.textSecondary,
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
          borderRadius: BorderRadius.circular(20),
          color: const Color(0xFFF9FAFB),
          border: Border.all(color: AppColors.border),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: .04),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
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
                      color: AppColors.navy,
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 7),
                  const Text(
                    'Check reference prices before browsing available gold.',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 14,
                      height: 1.35,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            const Icon(Icons.storefront_outlined,
                color: AppColors.navy, size: 36),
          ],
        ),
      ),
      const SizedBox(height: 24),
      Row(
        children: [
          const Expanded(
            child: Text(
              'Today’s gold prices',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: AppColors.navy,
              ),
            ),
          ),
          if (!_loading && _prices.isNotEmpty)
            _MarketStatus(
              isStale: _prices.any(
                (p) =>
                    p['is_stale'] == true ||
                    (p['value'] ?? p['price_per_gram']) == null,
              ),
            ),
        ],
      ),
      const SizedBox(height: 5),
      const Text(
        'Reference price per gram',
        style: TextStyle(
          color: AppColors.textSecondary,
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
        child: Center(child: CircularProgressIndicator(color: AppColors.gold)),
      );
    }
    if (_loadFailed || _prices.isEmpty) {
      return AppCard(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Column(
            children: [
              const Icon(Icons.cloud_off_rounded,
                  size: 38, color: AppColors.textSecondary),
              const SizedBox(height: 10),
              const Text(
                'Official Mining Commission price feed\nis not connected yet',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColors.navy,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 14),
              OutlinedButton.icon(
                onPressed: _load,
                icon: const Icon(Icons.refresh, size: 16),
                label: const Text('Try again'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.navy,
                  side: const BorderSide(color: AppColors.border),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      children: _prices.map((p) {
        final karat = p['karat']?.toString() ?? '24K';
        final val = p['value'] ?? p['price_per_gram'];
        final displayVal = val != null ? 'TZS ${_fmt.format(val)}' : 'N/A';
        final isStale = p['is_stale'] == true || val == null;

        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFFF9FAFB),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: AppColors.gold.withValues(alpha: .15),
                      shape: BoxShape.circle,
                    ),
                    child: const Center(
                      child: Text(
                        'Au',
                        style: TextStyle(
                          color: AppColors.navy,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Gold $karat',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: AppColors.navy,
                        ),
                      ),
                      if (isStale)
                        const Text(
                          'Estimated reference',
                          style: TextStyle(
                            fontSize: 11,
                            color: AppColors.warning,
                          ),
                        ),
                    ],
                  ),
                ],
              ),
              Text(
                displayVal,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: AppColors.navy,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}

class _MarketStatus extends StatelessWidget {
  const _MarketStatus({this.isStale = false});
  final bool isStale;

  @override
  Widget build(BuildContext context) => const SizedBox.shrink();
}
