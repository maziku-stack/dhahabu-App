import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../theme/app_colors.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});
  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _phone = TextEditingController();
  final _otp = TextEditingController();
  final _name = TextEditingController();
  final _region = TextEditingController();
  final _business = TextEditingController();
  String? _role;
  bool _otpSent = false;
  bool _loading = false;
  String? _error;
  String? _mockOtp;

  Future<void> _request() async {
    if (_role == null) {
      setState(() => _error = 'Choose Miner or Dealer');
      return;
    }
    if (_phone.text.trim().length < 9) {
      setState(() => _error = 'Valid phone required');
      return;
    }
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final res = await context
          .read<AuthProvider>()
          .requestOtp(_phone.text.trim(), _role!);
      setState(() {
        _otpSent = true;
        _mockOtp = res['mock_otp']?.toString();
      });
    } catch (e) {
      setState(() => _error = e.toString().replaceFirst('Exception: ', ''));
    } finally {
      setState(() => _loading = false);
    }
  }

  Future<void> _verify() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      await context.read<AuthProvider>().verifyOtp(
            phone: _phone.text.trim(),
            code: _otp.text.trim(),
            role: _role!,
            fullName: _name.text.trim(),
            region: _region.text.trim(),
            businessName: _business.text.trim(),
          );
      if (!mounted) return;
      Navigator.pushNamedAndRemoveUntil(context, '/set-pin', (_) => false);
    } catch (e) {
      setState(() => _error = e.toString().replaceFirst('Exception: ', ''));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  void dispose() {
    _name.dispose();
    _phone.dispose();
    _otp.dispose();
    _region.dispose();
    _business.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create account'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pushNamed(context, '/login'),
              child: const Text('Sign in',
                  style: TextStyle(color: AppColors.gold))),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Register as Miner or Dealer ',
                style: TextStyle(color: Colors.grey[400])),
            const SizedBox(height: 16),
            if (_error != null)
              Text(_error!, style: const TextStyle(color: AppColors.error)),
            if (!_otpSent) ...[
              const Text('Account for a ',
                  style: TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 12),
              Row(children: [
                Expanded(
                    child: _card('Miner', Icons.construction, _role == 'miner',
                        () => setState(() => _role = 'miner'))),
                const SizedBox(width: 12),
                Expanded(
                    child: _card('Dealer', Icons.store, _role == 'dealer',
                        () => setState(() => _role = 'dealer'))),
              ]),
              const SizedBox(height: 20),
              TextField(
                  controller: _phone,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(
                      labelText: 'Phone', prefixIcon: Icon(Icons.phone))),
              const SizedBox(height: 20),
              ElevatedButton(
                  onPressed: _loading ? null : _request,
                  child: Text(_loading ? '…' : 'Send OTP')),
            ] else ...[
              if (_mockOtp != null)
                Text('Dev OTP: $_mockOtp',
                    style: const TextStyle(
                        color: AppColors.gold, fontWeight: FontWeight.bold)),
              TextField(
                  controller: _otp,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'OTP')),
              const SizedBox(height: 12),
              TextField(
                  controller: _name,
                  decoration: const InputDecoration(labelText: 'Full name')),
              const SizedBox(height: 12),
              TextField(
                  controller: _region,
                  decoration: const InputDecoration(labelText: 'Region')),
              if (_role == 'dealer') ...[
                const SizedBox(height: 12),
                TextField(
                    controller: _business,
                    decoration:
                        const InputDecoration(labelText: 'Business name')),
              ],
              const SizedBox(height: 20),
              ElevatedButton(
                  onPressed: _loading ? null : _verify,
                  child: Text(_loading ? '…' : 'Verify & continue')),
            ],
          ],
        ),
      ),
    );
  }

  Widget _card(String label, IconData icon, bool sel, VoidCallback onTap) {
    return Material(
      color: sel ? AppColors.gold.withOpacity(0.15) : AppColors.surfaceDark,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
                color: sel ? AppColors.gold : AppColors.border, width: 2),
          ),
          child: Column(children: [
            Icon(icon, color: sel ? AppColors.gold : Colors.grey),
            const SizedBox(height: 8),
            Text(label,
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: sel ? AppColors.gold : null)),
          ]),
        ),
      ),
    );
  }
}
