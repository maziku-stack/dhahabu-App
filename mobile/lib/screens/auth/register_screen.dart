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
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _passwordConfirmation = TextEditingController();
  String? _role;
  bool _loading = false;
  bool _passwordVisible = false;
  bool _passwordConfirmationVisible = false;
  String? _error;

  Future<void> _register() async {
    if (_role == null) {
      setState(() => _error = 'Choose whether you are a miner or dealer.');
      return;
    }
    if (_name.text.trim().isEmpty) {
      setState(() => _error = 'Enter your full name.');
      return;
    }
    if (_phone.text.trim().length < 9) {
      setState(() => _error = 'Enter a valid phone number.');
      return;
    }
    if (!_email.text.trim().contains('@')) {
      setState(() => _error = 'Enter a valid email address.');
      return;
    }
    if (_password.text.length < 8) {
      setState(() => _error = 'Use a password with at least 8 characters.');
      return;
    }
    if (_password.text != _passwordConfirmation.text) {
      setState(() => _error = 'The passwords do not match.');
      return;
    }
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      await context.read<AuthProvider>().registerWithEmailPassword(
            fullName: _name.text.trim(),
            email: _email.text.trim(),
            phone: _phone.text.trim(),
            role: _role!,
            password: _password.text,
            passwordConfirmation: _passwordConfirmation.text,
          );
      if (!mounted) return;
      Navigator.pushNamedAndRemoveUntil(context, '/set-pin', (_) => false);
    } catch (e) {
      if (mounted) {
        setState(() => _error = e.toString().replaceFirst('Exception: ', ''));
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  void dispose() {
    _name.dispose();
    _phone.dispose();
    _email.dispose();
    _password.dispose();
    _passwordConfirmation.dispose();
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
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            if (_error != null)
              Text(_error!, style: const TextStyle(color: AppColors.error)),
            const Text(
              'I am registering as',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 16),
            ),
            const SizedBox(height: 12),
            Row(children: [
              Expanded(child: _card('Miner', 'Small-scale gold seller', Icons.hiking_outlined, _role == 'miner', () => setState(() => _role = 'miner'))),
              const SizedBox(width: 12),
              Expanded(child: _card('Dealer', 'Licensed gold buyer', Icons.storefront_outlined, _role == 'dealer', () => setState(() => _role = 'dealer'))),
            ]),
            const SizedBox(height: 20),
            TextField(
              controller: _name,
              style: const TextStyle(color: Colors.white),
              textCapitalization: TextCapitalization.words,
              decoration: const InputDecoration(labelText: 'Full name', prefixIcon: Icon(Icons.person_outline)),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: _email,
              style: const TextStyle(color: Colors.white),
              keyboardType: TextInputType.emailAddress,
              autocorrect: false,
              decoration: const InputDecoration(labelText: 'Email address', prefixIcon: Icon(Icons.email_outlined)),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: _phone,
              style: const TextStyle(color: Colors.white),
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(
                filled: true,
                fillColor: Colors.black,
                labelText: 'Phone number',
                labelStyle: TextStyle(color: Colors.white),
                contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                prefixIcon: Icon(Icons.phone, color: Colors.white70),
              ),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: _password,
              style: const TextStyle(color: Colors.white),
              obscureText: !_passwordVisible,
              cursorColor: AppColors.gold,
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.black,
                labelText: 'Password (at least 8 characters)',
                labelStyle: const TextStyle(color: Colors.white),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 12,
                ),
                prefixIcon: const Icon(Icons.lock_outline, color: Colors.white70),
                suffixIcon: IconButton(
                  tooltip: _passwordVisible ? 'Hide password' : 'Show password',
                  onPressed: () => setState(
                    () => _passwordVisible = !_passwordVisible,
                  ),
                  icon: Icon(
                    _passwordVisible
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                    color: Colors.white70,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: _passwordConfirmation,
              style: const TextStyle(color: Colors.white),
              obscureText: !_passwordConfirmationVisible,
              cursorColor: AppColors.gold,
              textInputAction: TextInputAction.done,
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.black,
                labelText: 'Confirm password',
                labelStyle: const TextStyle(color: Colors.white),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 12,
                ),
                prefixIcon: const Icon(Icons.lock_reset_outlined, color: Colors.white70),
                suffixIcon: IconButton(
                  tooltip: _passwordConfirmationVisible
                      ? 'Hide password'
                      : 'Show password',
                  onPressed: () => setState(
                    () => _passwordConfirmationVisible =
                        !_passwordConfirmationVisible,
                  ),
                  icon: Icon(
                    _passwordConfirmationVisible
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                    color: Colors.white70,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 22),
            ElevatedButton(
              onPressed: _loading ? null : _register,
              child: _loading
                  ? const SizedBox(height: 22, width: 22, child: CircularProgressIndicator(strokeWidth: 2))
                  : const Text('Create account'),
            ),
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
