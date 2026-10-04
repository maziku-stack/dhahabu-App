import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _phoneCtrl = TextEditingController();
  final _otpCtrl = TextEditingController();
  final _nameCtrl = TextEditingController();
  final _regionCtrl = TextEditingController();
  final _businessCtrl = TextEditingController();

  String _role = 'miner';
  bool _otpSent = false;
  bool _loading = false;
  String? _error;
  String? _mockOtp;

  /// Quick-fill for demo admin (created via: python manage.py create_admin)
  void _fillAdminDemo() {
    setState(() {
      _role = 'admin';
      _phoneCtrl.text = '0700000001';
      _nameCtrl.text = 'Government Admin';
      _regionCtrl.text = 'National';
      _otpSent = false;
      _mockOtp = null;
      _error = null;
    });
  }

  Future<void> _requestOtp() async {
    if (_phoneCtrl.text.trim().length < 9) {
      setState(() => _error = 'Enter a valid phone number (at least 9 digits)');
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
            region: _regionCtrl.text.trim(),
            businessName: _businessCtrl.text.trim(),
          );
      if (!mounted) return;
      Navigator.pushReplacementNamed(context, '/home');
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
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 16),
              const Icon(Icons.diamond, size: 56, color: Color(0xFFB8860B)),
              const SizedBox(height: 8),
              Text(
                'Dhahabu',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFFB8860B),
                    ),
              ),
              const SizedBox(height: 4),
              Text(
                'Miners • Dealers • Government',
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
                  child: Text(_error!,
                      style: TextStyle(color: Colors.red.shade800)),
                ),
              if (!_otpSent) ...[
                Text('Login as', style: Theme.of(context).textTheme.titleSmall),
                const SizedBox(height: 10),
                // Role cards
                Row(
                  children: [
                    _RoleCard(
                      label: 'Miner',
                      icon: Icons.construction,
                      selected: _role == 'miner',
                      onTap: () => setState(() => _role = 'miner'),
                    ),
                    const SizedBox(width: 8),
                    _RoleCard(
                      label: 'Dealer',
                      icon: Icons.store,
                      selected: _role == 'dealer',
                      onTap: () => setState(() => _role = 'dealer'),
                    ),
                    const SizedBox(width: 8),
                    _RoleCard(
                      label: 'Admin',
                      icon: Icons.account_balance,
                      selected: _role == 'admin',
                      onTap: () => setState(() => _role = 'admin'),
                      highlight: true,
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                if (_role == 'admin')
                  TextButton.icon(
                    onPressed: _fillAdminDemo,
                    icon: const Icon(Icons.bolt, size: 18),
                    label: const Text('Use demo admin (0700000001)'),
                  ),
                const SizedBox(height: 8),
                TextField(
                  controller: _phoneCtrl,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(
                    labelText: 'Phone number',
                    prefixIcon: Icon(Icons.phone),
                    hintText: '07XXXXXXXX',
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _loading ? null : _requestOtp,
                  child: _loading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white),
                        )
                      : Text(_role == 'admin'
                          ? 'Admin Login — Send OTP'
                          : 'Send OTP'),
                ),
              ] else ...[
                if (_mockOtp != null)
                  Container(
                    padding: const EdgeInsets.all(12),
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      color: Colors.amber.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.amber.shade200),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.info_outline, color: Colors.amber),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Dev OTP: $_mockOtp',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                  ),
                TextField(
                  controller: _otpCtrl,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Enter 6-digit OTP',
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
                if (_role == 'admin')
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      'You will access the Government Dashboard after login.',
                      style: TextStyle(color: Colors.blue[800], fontSize: 13),
                    ),
                  ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _loading ? null : _verify,
                  child: _loading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white),
                        )
                      : const Text('Verify & Continue'),
                ),
                TextButton(
                  onPressed: () => setState(() {
                    _otpSent = false;
                    _mockOtp = null;
                    _error = null;
                  }),
                  child: const Text('Change phone / role'),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _RoleCard extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;
  final bool highlight;

  const _RoleCard({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
    this.highlight = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = highlight ? const Color(0xFF1A1A2E) : const Color(0xFFB8860B);
    return Expanded(
      child: Material(
        color: selected ? color.withValues(alpha: 0.12) : Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 14),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: selected ? color : Colors.transparent,
                width: 2,
              ),
            ),
            child: Column(
              children: [
                Icon(icon, color: selected ? color : Colors.grey[600]),
                const SizedBox(height: 4),
                Text(
                  label,
                  style: TextStyle(
                    fontWeight: selected ? FontWeight.bold : FontWeight.normal,
                    color: selected ? color : Colors.grey[700],
                    fontSize: 13,
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
