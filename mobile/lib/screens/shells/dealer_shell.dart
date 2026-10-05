import 'package:flutter/material.dart';
import '../market/market_screen.dart';
import '../listings/listings_screen.dart';
import '../transactions/transactions_screen.dart';
import '../tax/tax_summary_screen.dart';
import '../profile/profile_screen.dart';

class DealerShell extends StatefulWidget {
  const DealerShell({super.key});
  @override
  State<DealerShell> createState() => _DealerShellState();
}

class _DealerShellState extends State<DealerShell> {
  int _i = 0;
  @override
  Widget build(BuildContext context) {
    final pages = [
      const MarketScreen(showNewListing: false),
      const ListingsScreen(mineOnly: false),
      const TransactionsScreen(),
      const TaxSummaryScreen(),
      const ProfileScreen(),
    ];
    return Scaffold(
      body: IndexedStack(index: _i, children: pages),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _i,
        onDestinationSelected: (v) => setState(() => _i = v),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.price_change_outlined), selectedIcon: Icon(Icons.price_change), label: 'Market'),
          NavigationDestination(icon: Icon(Icons.storefront_outlined), selectedIcon: Icon(Icons.storefront), label: 'Listings'),
          NavigationDestination(icon: Icon(Icons.receipt_long_outlined), selectedIcon: Icon(Icons.receipt_long), label: 'Sales'),
          NavigationDestination(icon: Icon(Icons.account_balance_outlined), selectedIcon: Icon(Icons.account_balance), label: 'Tax'),
          NavigationDestination(icon: Icon(Icons.person_outline), selectedIcon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}
