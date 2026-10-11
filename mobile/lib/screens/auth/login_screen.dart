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
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _usePassword = true;
  bool _otpSent = false;
  bool _loading = false;
  String? _error;
  String? _mockOtp;

  Future<void> _loginWithPassword() async {
    if (_email.text.trim().isEmpty || _password.text.isEmpty) {
      setState(() => _error = 'Enter your email and password.');
      return;
    }
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      await context.read<AuthProvider>().loginWithEmailPassword(
            email: _email.text.trim(),
            password: _password.text,
          );
      if (!mounted) return;
      final user = context.read<AuthProvider>().user;
      Navigator.pushNamedAndRemoveUntil(
        context,
        user?.pinSet == true ? '/home' : '/set-pin',
        (_) => false,
      );
    } catch (e) {
      setState(() => _error = e.toString().replaceFirst('Exception: ', ''));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _request() async {
    if (_phone.text.trim().length < 9) {
      setState(() => _error = 'Enter a valid phone number');
      return;
    }
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final res = await context
          .read<AuthProvider>()
          .requestOtp(_phone.text.trim(), 'miner');
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
    _email.dispose();
    _password.dispose();
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
            const Text('Welcome back',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text('Sign in with your email and password, or use a phone code.',
                style: TextStyle(color: Colors.grey[400])),
            const SizedBox(height: 24),
            SegmentedButton<bool>(
              segments: const [
                ButtonSegment(value: true, label: Text('Email & password')),
                ButtonSegment(value: false, label: Text('Phone code')),
              ],
              selected: {_usePassword},
              onSelectionChanged: (selection) => setState(() {
                _usePassword = selection.first;
                _error = null;
              }),
            ),
            const SizedBox(height: 20),
            if (_error != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Text(_error!,
                    style: const TextStyle(color: AppColors.error)),
              ),
            if (_usePassword) ...[
              TextField(
                controller: _email,
                keyboardType: TextInputType.emailAddress,
                autocorrect: false,
                decoration: const InputDecoration(
                  labelText: 'Email address',
                  prefixIcon: Icon(Icons.email_outlined),
                ),
              ),
              const SizedBox(height: 14),
              TextField(
                controller: _password,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Password',
                  prefixIcon: Icon(Icons.lock_outline),
                ),
                onSubmitted: (_) => _loginWithPassword(),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _loading ? null : _loginWithPassword,
                child: Text(_loading ? 'Please wait…' : 'Sign in'),
              ),
            ] else if (!_otpSent) ...[
              TextField(
                  controller: _phone,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(
                      labelText: 'Phone number',
                      prefixIcon: Icon(Icons.phone))),
              const SizedBox(height: 20),
              ElevatedButton(
                  onPressed: _loading ? null : _request,
                  child: Text(_loading ? '…' : 'Send OTP')),
            ] else ...[
              if (_mockOtp != null)
                Text('Dev OTP: $_mockOtp',
                    style: const TextStyle(
                        color: AppColors.gold, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              TextField(
                  controller: _otp,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                      labelText: 'OTP', prefixIcon: Icon(Icons.lock))),
              const SizedBox(height: 12),
              TextField(
                  controller: _name,
                  decoration: const InputDecoration(
                      labelText: 'Full name (optional)',
                      prefixIcon: Icon(Icons.person))),
              const SizedBox(height: 20),
              ElevatedButton(
                  onPressed: _loading ? null : _verify,
                  child: Text(_loading ? '…' : 'Sign in')),
            ],
            TextButton(
                onPressed: () =>
                    Navigator.pushReplacementNamed(context, '/register'),
                child: const Text('New user? Create account')),
          ],
        ),
      ),
    );
  }
}
