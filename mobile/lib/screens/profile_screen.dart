import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;
    if (user == null) return const SizedBox();

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        const CircleAvatar(radius: 40, child: Icon(Icons.person, size: 40)),
        const SizedBox(height: 12),
        Text(
          user.fullName.isNotEmpty ? user.fullName : 'User',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        Text(user.phone, textAlign: TextAlign.center, style: TextStyle(color: Colors.grey[600])),
        const SizedBox(height: 8),
        Center(
          child: Chip(
            label: Text(user.role.toUpperCase()),
            backgroundColor: const Color(0xFFD4A017).withOpacity(0.2),
          ),
        ),
        if (user.region.isNotEmpty) ...[
          const SizedBox(height: 8),
          Text('Region: ${user.region}', textAlign: TextAlign.center),
        ],
        if (user.isDealer && user.dealerVerified == true)
          const Padding(
            padding: EdgeInsets.only(top: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.verified, color: Colors.green, size: 18),
                SizedBox(width: 4),
                Text('Verified Dealer'),
              ],
            ),
          ),
        const SizedBox(height: 32),
        OutlinedButton.icon(
          onPressed: () async {
            await context.read<AuthProvider>().logout();
            if (context.mounted) {
              Navigator.pushReplacementNamed(context, '/login');
            }
          },
          icon: const Icon(Icons.logout),
          label: const Text('Logout'),
        ),
      ],
    );
  }
}
