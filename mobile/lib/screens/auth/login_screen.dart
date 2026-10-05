import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../theme/app_colors.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _phone = TextEditingController();
  final _otp = TextEditingController();
  final _name = TextEditingController();
  bool _otpSent = false;
  bool _loading = false;
  String? _error;
  String? _mockOtp;

  Future<void> _request() async {
    if (_phone.text.trim().length < 9) {
      setState(() => _error = 'Enter a valid phone number');
      return;
    }
    setState(() { _loading = true; _error = null; });
    try {
      final res = await context.read<AuthProvider>().requestOtp(_phone.text.trim(), 'miner');
      setState(() { _otpSent = true; _mockOtp = res['mock_otp']?.toString(); });
    } catch (e) {
      setState(() => _error = e.toString().replaceFirst('Exception: ', ''));
    } finally {
      setState(() => _loading = false);
    }
  }

  Future<void> _verify() async {
    setState(() { _loading = true; _error = null; });
    try {
      await context.read<AuthProvider>().verifyOtp(
            phone: _phone.text.trim(),
            code: _otp.text.trim(),
            role: 'miner',
            fullName: _name.text.trim(),
          );
      if (!mounted) return;
      final u = context.read<AuthProvider>().user;
      if (u?.pinSet != true) {
        Navigator.pushNamedAndRemoveUntil(context, '/set-pin', (_) => false);
      } else {
        Navigator.pushNamedAndRemoveUntil(context, '/home', (_) => false);
      }
    } catch (e) {
      setState(() => _error = e.toString().replaceFirst('Exception: ', ''));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  void dispose() {
    _phone.dispose();
    _otp.dispose();
    _name.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sign in'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.canPop(context)
              ? Navigator.pop(context)
              : Navigator.pushReplacementNamed(context, '/landing'),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text('Welcome back', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text('Use the phone number you registered with. Admin: 0700000001', style: TextStyle(color: Colors.grey[400])),
            const SizedBox(height: 24),
            if (_error != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Text(_error!, style: const TextStyle(color: AppColors.error)),
              ),
            if (!_otpSent) ...[
              TextField(controller: _phone, keyboardType: TextInputType.phone, decoration: const InputDecoration(labelText: 'Phone number', prefixIcon: Icon(Icons.phone))),
              const SizedBox(height: 20),
              ElevatedButton(onPressed: _loading ? null : _request, child: Text(_loading ? '…' : 'Send OTP')),
            ] else ...[
              if (_mockOtp != null) Text('Dev OTP: $_mockOtp', style: const TextStyle(color: AppColors.gold, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              TextField(controller: _otp, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'OTP', prefixIcon: Icon(Icons.lock))),
              const SizedBox(height: 12),
              TextField(controller: _name, decoration: const InputDecoration(labelText: 'Full name (optional)', prefixIcon: Icon(Icons.person))),
              const SizedBox(height: 20),
              ElevatedButton(onPressed: _loading ? null : _verify, child: Text(_loading ? '…' : 'Sign in')),
            ],
            TextButton(onPressed: () => Navigator.pushReplacementNamed(context, '/register'), child: const Text('New user? Create account')),
          ],
        ),
      ),
    );
  }
}
