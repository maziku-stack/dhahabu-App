import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:dhahabu/features/auth/providers/auth_provider.dart';
import 'package:dhahabu/l10n/l10n.dart';
import 'miner_shell.dart';
import 'dealer_shell.dart';
import 'gov_shell.dart';

class RoleRouter extends StatelessWidget {
  const RoleRouter({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final user = context.watch<AuthProvider>().user;
    if (user == null) {
      return Scaffold(body: Center(child: Text(l10n.notLoggedIn)));
    }
    if (user.isAdmin) {
      return const GovShell();
    }
    if (user.isDealer) {
      return const DealerShell();
    }
    return const MinerShell();
  }
}
