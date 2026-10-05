import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../theme/app_colors.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _go();
  }

  Future<void> _go() async {
    await Future.delayed(const Duration(milliseconds: 900));
    if (!mounted) return;
    final auth = context.read<AuthProvider>();
    var n = 0;
    while (auth.isLoading && n < 40) {
      await Future.delayed(const Duration(milliseconds: 100));
      n++;
      if (!mounted) return;
    }
    if (!mounted) return;
    if (auth.isAuthenticated) {
      if (auth.user?.pinSet != true) {
        Navigator.pushReplacementNamed(context, '/set-pin');
      } else {
        Navigator.pushReplacementNamed(context, '/home');
      }
    } else {
      Navigator.pushReplacementNamed(context, '/landing');
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: AppColors.navy,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.diamond, size: 72, color: AppColors.gold),
            SizedBox(height: 16),
            Text('Dhahabu', style: TextStyle(color: AppColors.gold, fontSize: 28, fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            Text('Gold Trade · Transparent · Auditable', style: TextStyle(color: AppColors.textOnDark)),
            SizedBox(height: 32),
            CircularProgressIndicator(color: AppColors.gold),
          ],
        ),
      ),
    );
  }
}
