import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';

/// Public registration: Miner or Dealer only (Admin is not self-register).
class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _phoneCtrl = TextEditingController();
  final _otpCtrl = TextEditingController();
  final _nameCtrl = TextEditingController();
  final _regionCtrl = TextEditingController();
  final _businessCtrl = TextEditingController();

  String? _role; // null until user picks Miner or Dealer
  bool _otpSent = false;
  bool _loading = false;
  String? _error;
  String? _mockOtp;

  Future<void> _requestOtp() async {
    if (_role == null) {
      setState(() => _error = 'Please choose Miner or Dealer');
      return;
    }
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
            _role!,
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
            role: _role!,
            fullName: _nameCtrl.text.trim(),
            region: _regionCtrl.text.trim(),
            businessName: _businessCtrl.text.trim(),
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
    _regionCtrl.dispose();
    _businessCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final gold = const Color(0xFFB8860B);

    return Scaffold(
      backgroundColor: const Color(0xFFFFFBF5),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (_otpSent) {
              setState(() {
                _otpSent = false;
                _mockOtp = null;
                _error = null;
              });
            } else if (Navigator.canPop(context)) {
              Navigator.pop(context);
            } else {
              Navigator.pushReplacementNamed(context, '/welcome');
            }
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pushNamed(context, '/login'),
            child: Text('Login',
                style: TextStyle(color: gold, fontWeight: FontWeight.w600)),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Create account',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF1A1A2E),
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                'Register as a miner or a licensed dealer. Government accounts are created by administrators.',
                style: TextStyle(color: Colors.grey[600], height: 1.4),
              ),
              const SizedBox(height: 24),
              if (_error != null)
                Container(
                  padding: const EdgeInsets.all(12),
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(_error!,
                      style: TextStyle(color: Colors.red.shade800)),
                ),
              if (!_otpSent) ...[
                Text('I am a…', style: Theme.of(context).textTheme.titleSmall),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _ChoiceCard(
                        label: 'Miner',
                        subtitle: 'Small-scale seller',
                        icon: Icons.construction,
                        selected: _role == 'miner',
                        onTap: () => setState(() => _role = 'miner'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _ChoiceCard(
                        label: 'Dealer',
                        subtitle: 'Licensed buyer',
                        icon: Icons.store,
                        selected: _role == 'dealer',
                        onTap: () => setState(() => _role = 'dealer'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
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
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white),
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
                    child: Text('Dev OTP: $_mockOtp',
                        style: const TextStyle(fontWeight: FontWeight.bold)),
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
                    labelText: 'Full name',
                    prefixIcon: Icon(Icons.person),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _regionCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Region',
                    prefixIcon: Icon(Icons.location_on),
                  ),
                ),
                if (_role == 'dealer') ...[
                  const SizedBox(height: 12),
                  TextField(
                    controller: _businessCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Business name',
                      prefixIcon: Icon(Icons.business),
                    ),
                  ),
                ],
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
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white),
                        )
                      : const Text('Verify & register'),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _ChoiceCard extends StatelessWidget {
  final String label;
  final String subtitle;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  const _ChoiceCard({
    required this.label,
    required this.subtitle,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final gold = const Color(0xFFB8860B);
    return Material(
      color: selected ? gold.withValues(alpha: 0.12) : Colors.grey.shade100,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
                color: selected ? gold : Colors.transparent, width: 2),
          ),
          child: Column(
            children: [
              Icon(icon, size: 36, color: selected ? gold : Colors.grey[600]),
              const SizedBox(height: 8),
              Text(label,
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: selected ? gold : Colors.black87)),
              Text(subtitle,
                  style: TextStyle(fontSize: 12, color: Colors.grey[600])),
            ],
          ),
        ),
      ),
    );
  }
}
