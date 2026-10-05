import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../widgets/app_card.dart';

class LandingScreen extends StatelessWidget {
  const LandingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.diamond, color: AppColors.gold),
                  const SizedBox(width: 8),
                  const Text('Dhahabu', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.gold, fontSize: 18)),
                  const Spacer(),
                  OutlinedButton(
                    onPressed: () => Navigator.pushNamed(context, '/login'),
                    child: const Text('Sign in'),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.success.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: const Text('BUILT FOR TANZANIA GOLD TRADE', style: TextStyle(fontSize: 12, color: AppColors.success)),
              ),
              const SizedBox(height: 16),
              const Text('Gold trade,\nunder control.', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, height: 1.2)),
              const SizedBox(height: 12),
              Text(
                'Fair prices by karat, shared digital receipts, automatic royalty — for miners, licensed dealers and government.',
                style: TextStyle(color: Colors.grey[400], height: 1.45, fontSize: 16),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => Navigator.pushNamed(context, '/register'),
                child: const Text('Create account →'),
              ),
              const SizedBox(height: 12),
              OutlinedButton(
                onPressed: () => Navigator.pushNamed(context, '/login'),
                child: const Text('Explore as returning user'),
              ),
              const SizedBox(height: 12),
              const Text('✓ OTP phone verification\n✓ Immutable sale records\n✓ 7% royalty auto-calculated', style: TextStyle(height: 1.6)),
              const SizedBox(height: 32),
              const Text('WHY DHAHABU', style: TextStyle(fontSize: 12, letterSpacing: 1.2, color: AppColors.gold)),
              const SizedBox(height: 12),
              AppCard(
                child: Column(
                  children: [
                    _stat('24K', 'Live karat prices'),
                    const Divider(color: AppColors.border),
                    _stat('1', 'Shared sale record'),
                    const Divider(color: AppColors.border),
                    _stat('7%', 'Auto royalty'),
                    const Divider(color: AppColors.border),
                    _stat('TZS', 'Local-first design'),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'By continuing you agree to the Privacy Policy. Transactions are auditable and tax records are immutable once confirmed.',
                style: TextStyle(fontSize: 12, color: Colors.grey[500]),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _stat(String v, String l) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          SizedBox(width: 56, child: Text(v, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.gold))),
          Expanded(child: Text(l, style: TextStyle(color: Colors.grey[400]))),
        ],
      ),
    );
  }
}
