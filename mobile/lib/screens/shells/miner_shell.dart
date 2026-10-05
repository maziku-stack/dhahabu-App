import 'package:flutter/material.dart';
import '../market/market_screen.dart';
import '../listings/listings_screen.dart';
import '../transactions/transactions_screen.dart';
import '../feedback/feedback_screen.dart';
import '../profile/profile_screen.dart';

class MinerShell extends StatefulWidget {
  const MinerShell({super.key});
  @override
  State<MinerShell> createState() => _MinerShellState();
}

class _MinerShellState extends State<MinerShell> {
  int _i = 0;
  @override
  Widget build(BuildContext context) {
    final pages = [
      const MarketScreen(showNewListing: true),
      const ListingsScreen(mineOnly: true),
      const TransactionsScreen(),
      const FeedbackScreen(),
      const ProfileScreen(),
    ];
    return Scaffold(
      body: IndexedStack(index: _i, children: pages),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _i,
        onDestinationSelected: (v) => setState(() => _i = v),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home), label: 'Home'),
          NavigationDestination(icon: Icon(Icons.list_alt_outlined), selectedIcon: Icon(Icons.list_alt), label: 'Listings'),
          NavigationDestination(icon: Icon(Icons.receipt_long_outlined), selectedIcon: Icon(Icons.receipt_long), label: 'Sales'),
          NavigationDestination(icon: Icon(Icons.feedback_outlined), selectedIcon: Icon(Icons.feedback), label: 'Feedback'),
          NavigationDestination(icon: Icon(Icons.person_outline), selectedIcon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}
