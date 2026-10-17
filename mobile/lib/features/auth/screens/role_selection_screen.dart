import 'package:flutter/material.dart';
import 'package:dhahabu/core/theme/app_colors.dart';

class RoleSelectionScreen extends StatefulWidget {
  const RoleSelectionScreen({super.key});

  @override
  State<RoleSelectionScreen> createState() => _RoleSelectionScreenState();
}

class _RoleSelectionScreenState extends State<RoleSelectionScreen> {
  String? _selectedRole;
  String? _error;

  void _continue() {
    if (_selectedRole == null) {
      setState(() => _error = 'Please select whether you are a Miner or Dealer.');
      return;
    }
    Navigator.pushNamed(
      context,
      '/register',
      arguments: _selectedRole,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(
                    child: Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.gold, width: 3),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.1),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: ClipOval(
                        child: Image.asset(
                          'assets/branding/logo.png',
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Choose your role',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: AppColors.navy,
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Select how you will participate in the Dhahabu platform.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 36),
                  if (_error != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: Text(
                        _error!,
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: AppColors.error),
                      ),
                    ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Expanded(
                        child: _roleOption(
                          'Miner',
                          'assets/icon/mirer.png',
                          _selectedRole == 'miner',
                          () => setState(() {
                            _selectedRole = 'miner';
                            _error = null;
                          }),
                        ),
                      ),
                      const SizedBox(width: 32),
                      Expanded(
                        child: _roleOption(
                          'Dealer',
                          'assets/icon/dealer.jpg',
                          _selectedRole == 'dealer',
                          () => setState(() {
                            _selectedRole = 'dealer';
                            _error = null;
                          }),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 40),
                  ElevatedButton(
                    onPressed: _continue,
                    child: const Text('Continue'),
                  ),
                  const SizedBox(height: 16),
                  TextButton(
                    onPressed: () => Navigator.pushReplacementNamed(context, '/login'),
                    child: RichText(
                      text: const TextSpan(
                        text: 'Already have an account? ',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                        children: [
                          TextSpan(
                            text: 'Sign in',
                            style: TextStyle(
                              color: AppColors.gold,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _roleOption(
    String label,
    String assetPath,
    bool selected,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 96,
            height: 96,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: selected ? AppColors.gold : Colors.transparent,
                width: 3.5,
              ),
              boxShadow: selected
                  ? [
                      BoxShadow(
                        color: AppColors.gold.withValues(alpha: 0.3),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ]
                  : [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.08),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
            ),
            child: Stack(
              children: [
                ClipOval(
                  child: Image.asset(
                    assetPath,
                    width: 96,
                    height: 96,
                    fit: BoxFit.cover,
                  ),
                ),
                if (selected)
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: AppColors.gold,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.check,
                        size: 14,
                        color: AppColors.navy,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: selected ? AppColors.navy : AppColors.textSecondary,
              fontSize: 16,
              fontWeight: selected ? FontWeight.bold : FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
