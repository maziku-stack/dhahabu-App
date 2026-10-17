import 'package:flutter/material.dart';
import 'package:dhahabu/core/theme/app_colors.dart';
import 'package:dhahabu/features/government/screens/compliance_screen.dart';
import 'package:dhahabu/features/government/screens/dealer_queue_screen.dart';
import 'package:dhahabu/features/government/screens/audit_screen.dart';
import 'package:dhahabu/features/profile/screens/profile_screen.dart';
import 'package:dhahabu/l10n/l10n.dart';

class GovShell extends StatefulWidget {
  const GovShell({super.key});
  @override
  State<GovShell> createState() => _GovShellState();
}

class _GovShellState extends State<GovShell> {
  int _i = 0;
  static const _screens = [
    ComplianceScreen(),
    DealerQueueScreen(),
    AuditScreen(),
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
            NavigationDestination(icon: const Icon(Icons.verified), label: l10n.navOverview),
            NavigationDestination(icon: const Icon(Icons.people), label: l10n.navDealers),
            NavigationDestination(icon: const Icon(Icons.history), label: l10n.navAudit),
            NavigationDestination(icon: const Icon(Icons.person), label: l10n.navProfile),
          ],
        ),
      ),
    );
  }
}
