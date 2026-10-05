import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import 'miner_shell.dart';
import 'dealer_shell.dart';
import 'gov_shell.dart';

class RoleRouter extends StatelessWidget {
  const RoleRouter({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;
    if (user == null) {
      return const Scaffold(body: Center(child: Text('Not logged in')));
    }
    if (user.isAdmin) return const GovShell();
    if (user.isDealer) return const DealerShell();
    return const MinerShell();
  }
}
