import 'package:flutter/material.dart';
import 'package:dhahabu/core/theme/app_colors.dart';
import 'package:dhahabu/features/market/screens/market_screen.dart';
import 'package:dhahabu/features/listings/screens/listings_screen.dart';
import 'package:dhahabu/features/transactions/screens/transactions_screen.dart';
import 'package:dhahabu/features/profile/screens/profile_screen.dart';
import 'package:dhahabu/l10n/l10n.dart';

class DealerShell extends StatefulWidget {
  const DealerShell({super.key});
  @override
  State<DealerShell> createState() => _DealerShellState();
}

class _DealerShellState extends State<DealerShell> {
  int _i = 0;
  static const _screens = [
    MarketScreen(),
    ListingsScreen(),
    TransactionsScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Scaffold(
      backgroundColor: AppColors.white,
      body: _screens[_i],
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          border: Border(top: BorderSide(color: AppColors.border, width: 1)),
        ),
        child: NavigationBar(
          selectedIndex: _i,
          onDestinationSelected: (idx) => setState(() => _i = idx),
          destinations: [
            NavigationDestination(icon: const Icon(Icons.home), label: l10n.navHome),
            NavigationDestination(icon: const Icon(Icons.list), label: l10n.navListings),
            NavigationDestination(icon: const Icon(Icons.receipt), label: l10n.navSales),
            NavigationDestination(icon: const Icon(Icons.person), label: l10n.navProfile),
          ],
        ),
      ),
    );
  }
}
