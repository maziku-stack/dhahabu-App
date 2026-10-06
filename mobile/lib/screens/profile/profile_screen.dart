import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../theme/app_colors.dart';
import '../../widgets/status_badge.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;
    if (user == null) return const SizedBox();

    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          const CircleAvatar(radius: 40, child: Icon(Icons.person, size: 40)),
          const SizedBox(height: 12),
          Text(user.fullName.isNotEmpty ? user.fullName : 'User',
              textAlign: TextAlign.center,
              style:
                  const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          Text(user.phone,
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey[400])),
          const SizedBox(height: 8),
          Center(
              child: Chip(
                  label: Text(user.role.toUpperCase()),
                  backgroundColor: AppColors.gold.withValues(alpha: 0.2))),
          if (user.isDealer) ...[
            const SizedBox(height: 8),
            Center(
                child: user.isVerifiedDealer
                    ? StatusBadge.verified()
                    : StatusBadge.pending()),
          ],
          if (user.region.isNotEmpty)
            Text('Region: ${user.region}', textAlign: TextAlign.center),
          const SizedBox(height: 32),
          OutlinedButton.icon(
            onPressed: () async {
              await context.read<AuthProvider>().logout();
              if (context.mounted) {
                Navigator.pushNamedAndRemoveUntil(
                    context, '/landing', (_) => false);
              }
            },
            icon: const Icon(Icons.logout),
            label: const Text('Logout'),
          ),
        ],
      ),
    );
  }
}
