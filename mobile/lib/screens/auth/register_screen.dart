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
  final _license = TextEditingController();
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
            licenseNumber: _license.text.trim(),
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
    _license.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        scrolledUnderElevation: 0,
        title: const Text(
          'Create account',
          style: TextStyle(color: Colors.white),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pushNamed(context, '/login'),
              child: const Text('Sign in',
                  style: TextStyle(color: AppColors.gold))),
        ],
      ),
      body: Theme(
        data: Theme.of(context).copyWith(
          inputDecorationTheme: Theme.of(context).inputDecorationTheme.copyWith(
            labelStyle: const TextStyle(color: Colors.white),
            hintStyle: const TextStyle(color: Colors.white70),
            prefixIconColor: Colors.white70,
          ),
        ),
        child: Stack(
          fit: StackFit.expand,
          children: [
          Image.asset(
            'lib/assets/images/Purified_gold.webp',
            fit: BoxFit.cover,
          ),
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xB80B1F3A),
                  Color(0xD9101115),
                  Color(0xE6101115),
                ],
              ),
            ),
          ),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 76, 24, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
            const Text(
              'Choose the account type that fits you',
              style: TextStyle(color: Colors.white),
            ),
            const SizedBox(height: 16),
            if (_error != null)
              Text(_error!, style: const TextStyle(color: AppColors.error)),
            if (!_otpSent) ...[
              const Text(
                'I am registering as',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 12),
              Row(children: [
                Expanded(
                    child: _card(
                  'Miner',
                  'Small-scale gold seller',
                  Icons.hiking_outlined,
                  _role == 'miner',
                  () => setState(() => _role = 'miner'),
                )),
                const SizedBox(width: 12),
                Expanded(
                    child: _card(
                  'Dealer',
                  'Licensed gold buyer',
                  Icons.storefront_outlined,
                  _role == 'dealer',
                  () => setState(() => _role = 'dealer'),
                )),
              ]),
              const SizedBox(height: 20),
              TextField(
                controller: _phone,
                style: const TextStyle(color: Colors.white),
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  labelText: 'Phone number',
                  labelStyle: TextStyle(color: Colors.white),
                  prefixIcon: Icon(Icons.phone, color: Colors.white70),
                ),
              ),
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
                const SizedBox(height: 12),
                TextField(
                    controller: _license,
                    decoration:
                        const InputDecoration(labelText: 'Dealer license number')),
              ],
              const SizedBox(height: 20),
              ElevatedButton(
                  onPressed: _loading ? null : _verify,
                  child: Text(_loading ? '…' : 'Verify & continue')),
            ],
                ],
              ),
            ),
          ),
          ],
        ),
      ),
    );
  }

  Widget _card(
    String label,
    String subtitle,
    IconData icon,
    bool selected,
    VoidCallback onTap,
  ) {
    final theme = Theme.of(context);
    final foreground = selected ? AppColors.navy : theme.colorScheme.onSurface;
    return Semantics(
      button: true,
      selected: selected,
      label: '$label, $subtitle',
      child: Material(
        color: selected ? AppColors.gold : theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(18),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(18),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            constraints: const BoxConstraints(minHeight: 148),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: selected ? AppColors.gold : AppColors.border,
                width: selected ? 2 : 1,
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Stack(
                  alignment: Alignment.topRight,
                  children: [
                    Icon(icon, size: 34, color: foreground),
                    if (selected)
                      const Padding(
                        padding: EdgeInsets.only(left: 28, bottom: 24),
                        child: Icon(Icons.check_circle,
                            size: 17, color: AppColors.navy),
                      ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  label,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: foreground,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: selected
                        ? AppColors.navy.withValues(alpha: 0.82)
                        : Colors.white70,
                    fontSize: 12,
                    height: 1.2,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
