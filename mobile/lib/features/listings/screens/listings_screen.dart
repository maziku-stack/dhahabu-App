import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:dhahabu/core/network/api_service.dart';
import 'package:dhahabu/core/theme/app_colors.dart';
import 'package:dhahabu/features/listings/screens/listing_new_screen.dart';
import 'package:provider/provider.dart';
import 'package:dhahabu/features/auth/providers/auth_provider.dart';
import 'package:dhahabu/l10n/l10n.dart';

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
      final data =
          await ApiService().getListings(mine: widget.mineOnly, status: 'open');
      setState(() {
        _items = data;
        _loading = false;
      });
    } catch (_) {
      setState(() => _loading = false);
    }
  }

  Future<void> _newListing() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const ListingNewScreen()),
    );
    _load();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
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
          widget.mineOnly ? l10n.myListings : l10n.browseListings,
          style: textTheme.titleLarge?.copyWith(color: AppColors.navy),
        ),
      ),
      floatingActionButton: widget.mineOnly
          ? FloatingActionButton(
              tooltip: l10n.createListing,
              backgroundColor: AppColors.gold,
              foregroundColor: AppColors.navy,
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
              onPressed: _newListing,
              child: const Icon(Icons.add_rounded, size: 30),
            )
          : null,
      body: RefreshIndicator(
        color: AppColors.navy,
        onRefresh: _load,
        child: _loading
            ? const Center(
                child: CircularProgressIndicator(color: AppColors.gold),
              )
            : _items.isEmpty
                ? ListView(
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
                          child: const Icon(Icons.list_alt_rounded,
                              size: 40, color: AppColors.navy),
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        l10n.noOpenListings,
                        textAlign: TextAlign.center,
                        style: textTheme.titleLarge
                            ?.copyWith(color: AppColors.navy, fontSize: 22),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        widget.mineOnly
                            ? l10n.myListingsEmptyDesc
                            : l10n.browseListingsEmptyDesc,
                        textAlign: TextAlign.center,
                        style: textTheme.bodyMedium?.copyWith(
                          color: AppColors.textSecondary,
                          height: 1.5,
                        ),
                      ),
                    ],
                  )
                : ListView.separated(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 96),
                    itemCount: _items.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 14),
                    itemBuilder: (ctx, i) {
                      final l = _items[i];
                      final price = double.tryParse('${l['asking_price']}') ?? 0;

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
                            if (widget.mineOnly) ...[
                              SwitchListTile(
                                value: l['share_phone'] == true,
                                contentPadding: EdgeInsets.zero,
                                activeThumbColor: AppColors.navy,
                                title: Text(
                                  l10n.sharePhoneOnListing,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.navy,
                                  ),
                                ),
                                onChanged: (value) async {
                                  final scaffoldContext = context;
                                  try {
                                    await ApiService().setListingPhoneSharing(
                                        l['id'].toString(), value);
                                    if (!scaffoldContext.mounted) return;
                                    _load();
                                  } catch (e) {
                                    if (!scaffoldContext.mounted) return;
                                    ScaffoldMessenger.of(scaffoldContext)
                                        .showSnackBar(SnackBar(
                                            content: Text(e.toString())));
                                  }
                                },
                              ),
                              const Divider(color: AppColors.border, height: 1),
                              const SizedBox(height: 10),
                            ],
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  '${l['weight_grams']} g  ·  ${l['karat']}',
                                  style: textTheme.titleMedium?.copyWith(
                                    color: AppColors.navy,
                                    fontFeatures: const [
                                      FontFeature.tabularFigures()
                                    ],
                                  ),
                                ),
                                Text(
                                  l['region'] ?? '',
                                  style: textTheme.bodySmall?.copyWith(
                                    color: AppColors.textSecondary,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Text(
                              'TSh ${_fmt.format(price)}',
                              style: textTheme.displayLarge?.copyWith(
                                color: AppColors.gold,
                                fontSize: 24,
                                fontFeatures: const [
                                  FontFeature.tabularFigures()
                                ],
                              ),
                            ),
                            if (!widget.mineOnly && user?.isDealer == true) ...[
                              const SizedBox(height: 10),
                              if (l['miner_phone'] == null)
                                Text(
                                  l10n.sellerPhonePrivate,
                                  style: textTheme.bodySmall?.copyWith(
                                    color: AppColors.textSecondary,
                                  ),
                                )
                              else
                                Text(
                                  l10n.contactSeller('${l['miner_phone']}'),
                                  style: textTheme.bodySmall?.copyWith(
                                    color: AppColors.navy,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                            ],
                          ],
                        ),
                      );
                    },
                  ),
      ),
    );
  }
}
