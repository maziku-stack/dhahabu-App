import 'package:flutter/material.dart';
import 'package:dhahabu/core/theme/app_colors.dart';
import 'package:dhahabu/features/market/screens/market_screen.dart';
import 'package:dhahabu/features/listings/screens/listings_screen.dart';
import 'package:dhahabu/features/transactions/screens/transactions_screen.dart';
import 'package:dhahabu/features/profile/screens/profile_screen.dart';

class MinerShell extends StatefulWidget {
  const MinerShell({super.key});
  @override
  State<MinerShell> createState() => _MinerShellState();
}

class _MinerShellState extends State<MinerShell> {
  int _i = 0;
  static const _screens = [
    MarketScreen(showNewListing: true),
    ListingsScreen(mineOnly: true),
    TransactionsScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
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
          destinations: const [
            NavigationDestination(icon: Icon(Icons.home), label: 'Home'),
            NavigationDestination(icon: Icon(Icons.list), label: 'Listings'),
            NavigationDestination(icon: Icon(Icons.receipt), label: 'Sales'),
            NavigationDestination(icon: Icon(Icons.person), label: 'Profile'),
          ],
        ),
      ),
    );
  }
}
