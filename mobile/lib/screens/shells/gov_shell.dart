import 'package:flutter/material.dart';
import '../government/compliance_screen.dart';
import '../government/dealer_queue_screen.dart';
import '../feedback/feedback_screen.dart';
import '../government/audit_screen.dart';
import '../market/market_screen.dart';

class GovShell extends StatefulWidget {
  const GovShell({super.key});
  @override
  State<GovShell> createState() => _GovShellState();
}

class _GovShellState extends State<GovShell> {
  int _i = 0;
  @override
  Widget build(BuildContext context) {
    final pages = [
      const ComplianceScreen(),
      const DealerQueueScreen(),
      const FeedbackScreen(isAdmin: true),
      const AuditScreen(),
      const MarketScreen(showNewListing: false, isAdmin: true),
    ];
    return Scaffold(
      body: IndexedStack(index: _i, children: pages),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _i,
        onDestinationSelected: (v) => setState(() => _i = v),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.dashboard_outlined), selectedIcon: Icon(Icons.dashboard), label: 'Overview'),
          NavigationDestination(icon: Icon(Icons.verified_user_outlined), selectedIcon: Icon(Icons.verified_user), label: 'Dealers'),
          NavigationDestination(icon: Icon(Icons.inbox_outlined), selectedIcon: Icon(Icons.inbox), label: 'Inbox'),
          NavigationDestination(icon: Icon(Icons.history), selectedIcon: Icon(Icons.history), label: 'Audit'),
          NavigationDestination(icon: Icon(Icons.price_change_outlined), selectedIcon: Icon(Icons.price_change), label: 'Prices'),
        ],
      ),
    );
  }
}
