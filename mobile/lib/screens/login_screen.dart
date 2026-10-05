import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';

/// Login for existing users (Miner, Dealer, or Admin).
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _phoneCtrl = TextEditingController();
  final _otpCtrl = TextEditingController();
  final _nameCtrl = TextEditingController();

  bool _otpSent = false;
  bool _loading = false;
  String? _error;
  String? _mockOtp;
  String _role = 'miner';

  Future<void> _requestOtp() async {
    if (_phoneCtrl.text.trim().length < 9) {
      setState(() => _error = 'Enter a valid phone number');
      return;
    }
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final res = await context.read<AuthProvider>().requestOtp(
            _phoneCtrl.text.trim(),
            _role,
          );
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
    if (_otpCtrl.text.trim().length < 4) {
      setState(() => _error = 'Enter the OTP code');
      return;
    }
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      await context.read<AuthProvider>().verifyOtp(
            phone: _phoneCtrl.text.trim(),
            code: _otpCtrl.text.trim(),
            role: _role,
            fullName: _nameCtrl.text.trim(),
          );
      if (!mounted) return;
      Navigator.pushNamedAndRemoveUntil(context, '/home', (_) => false);
    } catch (e) {
      setState(() => _error = e.toString().replaceFirst('Exception: ', ''));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  void dispose() {
    _phoneCtrl.dispose();
    _otpCtrl.dispose();
    _nameCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const gold = Color(0xFFB8860B);

    return Scaffold(
      backgroundColor: const Color(0xFFFFFBF5),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('Login'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (Navigator.canPop(context)) {
              Navigator.pop(context);
            } else {
              Navigator.pushReplacementNamed(context, '/welcome');
            }
          },
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Icon(Icons.diamond, size: 48, color: gold),
              const SizedBox(height: 8),
              Text(
                'Welcome back',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Text(
                'Enter the phone number you registered with.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey[600]),
              ),
              const SizedBox(height: 28),
              if (_error != null)
                Container(
                  padding: const EdgeInsets.all(12),
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(_error!, style: TextStyle(color: Colors.red.shade800)),
                ),
              if (!_otpSent) ...[
                TextField(
                  controller: _phoneCtrl,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(
                    labelText: 'Phone number',
                    hintText: '07XXXXXXXX',
                    prefixIcon: Icon(Icons.phone),
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _loading ? null : _requestOtp,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: gold,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: _loading
                      ? const SizedBox(
                          height: 22,
                          width: 22,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : const Text('Send OTP'),
                ),
              ] else ...[
                if (_mockOtp != null)
                  Container(
                    padding: const EdgeInsets.all(12),
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      color: Colors.amber.shade50,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text('Dev OTP: $_mockOtp', style: const TextStyle(fontWeight: FontWeight.bold)),
                  ),
                TextField(
                  controller: _otpCtrl,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: '6-digit OTP',
                    prefixIcon: Icon(Icons.lock),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _nameCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Full name (optional)',
                    prefixIcon: Icon(Icons.person),
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _loading ? null : _verify,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: gold,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: _loading
                      ? const SizedBox(
                          height: 22,
                          width: 22,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : const Text('Login'),
                ),
                TextButton(
                  onPressed: () => setState(() {
                    _otpSent = false;
                    _mockOtp = null;
                  }),
                  child: const Text('Change phone number'),
                ),
              ],
              const SizedBox(height: 16),
              TextButton(
                onPressed: () => Navigator.pushReplacementNamed(context, '/register'),
                child: const Text('New user? Create account'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
