import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:dhahabu/features/auth/providers/auth_provider.dart';
import 'package:dhahabu/core/theme/app_colors.dart';
import 'package:dhahabu/features/privacy/screens/privacy_screen.dart';
import 'package:dhahabu/core/validation/app_validator.dart';

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
  bool _noticeAcknowledged = false;
  bool _initializedRole = false;
  String? _error;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initializedRole) {
      _initializedRole = true;
      final args = ModalRoute.of(context)?.settings.arguments;
      if (args is String) {
        setState(() {
          _role = args;
        });
      }
    }
  }

  Future<void> _register() async {
    if (!_noticeAcknowledged) {
      setState(() =>
          _error = 'Read and acknowledge the privacy notice to continue.');
      return;
    }
    if (_role == null) {
      setState(() => _error = 'Role not specified. Please go back and select a role.');
      return;
    }

    final nameErr = AppValidator.validateName(_name.text);
    if (nameErr != null) {
      setState(() => _error = nameErr);
      return;
    }

    final phoneErr = AppValidator.validatePhone(_phone.text);
    if (phoneErr != null) {
      setState(() => _error = phoneErr);
      return;
    }

    final emailErr = AppValidator.validateEmail(_email.text);
    if (emailErr != null) {
      setState(() => _error = emailErr);
      return;
    }

    final passErr = AppValidator.validatePassword(_password.text);
    if (passErr != null) {
      setState(() => _error = passErr);
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
            privacyNoticeAcknowledged: _noticeAcknowledged,
          );
      if (!mounted) return;
      Navigator.pushNamedAndRemoveUntil(context, '/home', (_) => false);
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
    final roleTitle = _role != null 
        ? 'Registering as ${_role![0].toUpperCase()}${_role!.substring(1)}' 
        : 'Create account';

    final logoAsset = _role == 'dealer'
        ? 'assets/icon/dealer.jpg'
        : _role == 'miner'
            ? 'assets/icon/mirer.png'
            : 'assets/branding/logo.png';

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: Text(
          roleTitle,
          style: const TextStyle(
            color: AppColors.navy,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.navy),
          onPressed: () => Navigator.canPop(context)
              ? Navigator.pop(context)
              : Navigator.pushReplacementNamed(context, '/role-selection'),
        ),
      ),
      body: Theme(
        data: Theme.of(context).copyWith(
          inputDecorationTheme: const InputDecorationTheme(
            filled: true,
            fillColor: Color(0xFFF9FAFB),
            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            labelStyle: TextStyle(color: AppColors.textSecondary, fontSize: 13),
            hintStyle: TextStyle(color: Colors.grey, fontSize: 13),
            prefixIconColor: AppColors.navy,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(12)),
              borderSide: BorderSide(color: AppColors.border, width: 1),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(12)),
              borderSide: BorderSide(color: AppColors.border, width: 1),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(12)),
              borderSide: BorderSide(color: AppColors.gold, width: 2),
            ),
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 480),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Center(
                      child: Container(
                        width: 72,
                        height: 72,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: AppColors.gold, width: 2.5),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.08),
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: ClipOval(
                          child: Image.asset(
                            logoAsset,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Complete your details',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: AppColors.navy,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    if (_error != null)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: Text(_error!,
                            textAlign: TextAlign.center,
                            style: const TextStyle(color: AppColors.error)),
                      ),
                    TextField(
                      controller: _name,
                      style: const TextStyle(color: AppColors.navy, fontSize: 14),
                      textCapitalization: TextCapitalization.words,
                      decoration: const InputDecoration(
                        labelText: 'Full name',
                        prefixIcon: Icon(Icons.person_outline, size: 20),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _email,
                      style: const TextStyle(color: AppColors.navy, fontSize: 14),
                      keyboardType: TextInputType.emailAddress,
                      autocorrect: false,
                      decoration: const InputDecoration(
                        labelText: 'Email address',
                        prefixIcon: Icon(Icons.email_outlined, size: 20),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _phone,
                      style: const TextStyle(color: AppColors.navy, fontSize: 14),
                      keyboardType: TextInputType.phone,
                      decoration: const InputDecoration(
                        labelText: 'Phone number',
                        prefixIcon: Icon(Icons.phone_outlined, size: 20),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _password,
                      style: const TextStyle(color: AppColors.navy, fontSize: 14),
                      obscureText: !_passwordVisible,
                      decoration: InputDecoration(
                        labelText: 'Password (at least 8 chars)',
                        prefixIcon: const Icon(Icons.lock_outline, size: 20),
                        suffixIcon: IconButton(
                          onPressed: () => setState(
                            () => _passwordVisible = !_passwordVisible,
                          ),
                          icon: Icon(
                            _passwordVisible
                                ? Icons.visibility_off_outlined
                                : Icons.visibility_outlined,
                            color: AppColors.textSecondary,
                            size: 20,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _passwordConfirmation,
                      style: const TextStyle(color: AppColors.navy, fontSize: 14),
                      obscureText: !_passwordConfirmationVisible,
                      textInputAction: TextInputAction.done,
                      decoration: InputDecoration(
                        labelText: 'Confirm password',
                        prefixIcon: const Icon(Icons.lock_reset_outlined, size: 20),
                        suffixIcon: IconButton(
                          onPressed: () => setState(
                            () => _passwordConfirmationVisible =
                                !_passwordConfirmationVisible,
                          ),
                          icon: Icon(
                            _passwordConfirmationVisible
                                ? Icons.visibility_off_outlined
                                : Icons.visibility_outlined,
                            color: AppColors.textSecondary,
                            size: 20,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Checkbox(
                          value: _noticeAcknowledged,
                          onChanged: (value) =>
                              setState(() => _noticeAcknowledged = value ?? false),
                          activeColor: AppColors.navy,
                        ),
                        Expanded(
                          child: GestureDetector(
                            onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (_) => const PrivacyScreen())),
                            child: const Text(
                              'I have read and agree to the privacy notice',
                              style: TextStyle(
                                color: AppColors.navy,
                                fontSize: 13,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _loading ? null : _register,
                      child: _loading
                          ? const SizedBox(
                              height: 22,
                              width: 22,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: AppColors.navy,
                              ))
                          : const Text('Create account'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
