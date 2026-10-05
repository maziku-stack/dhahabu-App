import 'package:dhahabu/utils/app_colors.dart';
import 'package:flutter/material.dart';

class LandingScreens extends StatelessWidget {
  const LandingScreens({super.key});
  @override
  Widget build(BuildContext context) {
    const gold = Color(0xFFB8860B);
    return Scaffold(
      backgroundColor: const Color(0xFFFFFBF5),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(
              children: [
                Icon(Icons.diamond, color: AppColors.gold),
                SizedBox(width: 8),
                Text(
                  'Dhahabu',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppColors.gold,
                    fontSize: 18,
                  ),
                ),
                const Spacer(),
                OutlinedButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/login');
                  },
                  child: Text('Sign in'),
                ),
              ],
            ),
            const SizedBox(height: 32),
            const Text(
              'Gold trade under control',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(
              height: 12,
            ),
            Text(
              'Fair prices,shared receipts, automatic royalty for miners, dealers and governments.',
              style: TextStyle(color: Colors.grey[700], height: 1.4),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/register');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: gold,
                foregroundColor: Colors.white,
              ),
              child: const Text('create account'),
            ),
          ]),
        ),
      ),
    );
  }
}
