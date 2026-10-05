import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';

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
    await Future.delayed(const Duration(milliseconds: 800));
    if (!mounted) return;
    final auth = context.read<AuthProvider>();
    var tries = 0;
    while (auth.isLoading && tries < 30) {
      await Future.delayed(const Duration(milliseconds: 100));
      tries++;
      if (!mounted) return;
    }
    if (!mounted) return;
    if (auth.isAuthenticated) {
      Navigator.pushReplacementNamed(context, '/home');
    } else {
      Navigator.pushReplacementNamed(context, '/welcome');
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Color(0xFF1A1A2E),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.diamond, size: 72, color: Color(0xFFD4A017)),
            SizedBox(height: 16),
            Text(
              'Dhahabu',
              style: TextStyle(
                color: Color(0xFFD4A017),
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Gold Trade • Transparent • Auditable',
              style: TextStyle(color: Colors.white70),
            ),
            SizedBox(height: 32),
            CircularProgressIndicator(color: Color(0xFFD4A017)),
          ],
        ),
      ),
    );
  }
}
