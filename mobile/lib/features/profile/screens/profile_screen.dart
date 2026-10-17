import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:dhahabu/core/theme/app_colors.dart';
import 'package:dhahabu/core/widgets/status_badge.dart';
import 'package:dhahabu/features/auth/models/user.dart';
import 'package:dhahabu/features/auth/providers/auth_provider.dart';
import 'package:dhahabu/features/feedback/screens/feedback_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  String _roleLabel(String role) {
    switch (role.toLowerCase()) {
      case 'miner':
        return 'MINER';
      case 'dealer':
        return 'DEALER';
      case 'government':
      case 'admin':
        return 'GOVERNMENT';
      default:
        return role.toUpperCase();
    }
  }

  Future<void> _confirmSignOut(BuildContext context) async {
    final auth = context.read<AuthProvider>();
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Sign out?'),
        content: const Text('You will need to sign in again to continue.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(
              'Sign out',
              style: Theme.of(ctx)
                  .textTheme
                  .labelLarge
                  ?.copyWith(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
    if (ok == true) auth.logout();
  }

  void _showEditProfileSheet(BuildContext context, User user) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _EditProfileSheet(user: user),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;
    if (user == null) return const SizedBox();

    final textTheme = Theme.of(context).textTheme;
    const notSpecified = 'Not specified';

    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        title: Text(
          'Profile',
          style: textTheme.titleLarge?.copyWith(color: AppColors.navy),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined, color: AppColors.navy),
            tooltip: 'Edit Profile',
            onPressed: () => _showEditProfileSheet(context, user),
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 40),
        children: [
          // ---------- Header ----------
          Center(
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.gold, width: 2),
              ),
              child: CircleAvatar(
                radius: 46,
                backgroundColor: AppColors.navy,
                child: Text(
                  user.fullName.isNotEmpty
                      ? user.fullName[0].toUpperCase()
                      : 'U',
                  style: textTheme.displayLarge?.copyWith(
                    color: AppColors.gold,
                    fontSize: 36,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 18),
          Text(
            user.fullName,
            textAlign: TextAlign.center,
            style: textTheme.displayLarge?.copyWith(
              color: AppColors.navy,
              fontSize: 24,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            user.email,
            textAlign: TextAlign.center,
            style: textTheme.bodyMedium?.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 14),
          Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.gold.withValues(alpha: 0.18),
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(
                _roleLabel(user.role),
                style: textTheme.labelSmall?.copyWith(
                  color: AppColors.navy,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.2,
                ),
              ),
            ),
          ),
          const SizedBox(height: 36),

          // ---------- Account ----------
          const _SectionTitle('ACCOUNT'),
          _InfoRow(
            icon: Icons.phone_outlined,
            label: 'Phone',
            value: user.phone,
          ),
          _InfoRow(
            icon: Icons.location_on_outlined,
            label: 'Region',
            value: user.region.isNotEmpty ? user.region : notSpecified,
            muted: user.region.isEmpty,
          ),
          if (user.isMiner)
            _InfoRow(
              icon: Icons.landscape_outlined,
              label: 'Mining site',
              value:
              user.miningSite.isNotEmpty ? user.miningSite : notSpecified,
              muted: user.miningSite.isEmpty,
            ),
          if (user.isDealer)
            _InfoRow(
              icon: Icons.verified_outlined,
              label: 'Dealer verification',
              value: user.isVerifiedDealer ? 'Verified' : 'Pending',
              trailing: user.isVerifiedDealer
                  ? StatusBadge.verified()
                  : StatusBadge.pending(),
            ),
          const SizedBox(height: 32),

          // ---------- Support ----------
          const _SectionTitle('SUPPORT'),
          _ActionRow(
            icon: Icons.feedback_outlined,
            label: 'Feedback & support',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const FeedbackScreen()),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Official TRA integration is not connected yet.',
            style: textTheme.bodySmall?.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 40),

          // ---------- Sign out ----------
          Center(
            child: TextButton.icon(
              style: TextButton.styleFrom(
                foregroundColor: AppColors.error,
                minimumSize: const Size(160, 48),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () => _confirmSignOut(context),
              icon: const Icon(Icons.logout_rounded, size: 20),
              label: Text(
                'Sign out',
                style: textTheme.labelLarge?.copyWith(color: AppColors.error),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// =====================================================================
// EDIT PROFILE: compact bottom sheet (about half the screen)
// =====================================================================

class _EditProfileSheet extends StatefulWidget {
  const _EditProfileSheet({required this.user});

  final User user;

  @override
  State<_EditProfileSheet> createState() => _EditProfileSheetState();
}

class _EditProfileSheetState extends State<_EditProfileSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _name;
  late final TextEditingController _email;
  late final TextEditingController _region;
  late final TextEditingController _site;
  bool _loading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _name = TextEditingController(text: widget.user.fullName);
    _email = TextEditingController(text: widget.user.email);
    _region = TextEditingController(text: widget.user.region);
    _site = TextEditingController(text: widget.user.miningSite);
  }

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _region.dispose();
    _site.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final auth = context.read<AuthProvider>();
    final navigator = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);

    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      await auth.updateProfile(
        fullName: _name.text.trim(),
        email: _email.text.trim(),
        region: _region.text.trim(),
        miningSite: _site.text.trim(),
      );
      navigator.pop();
      messenger.showSnackBar(
        const SnackBar(content: Text('Profile updated successfully!')),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString().replaceFirst('Exception: ', '');
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final keyboard = MediaQuery.of(context).viewInsets.bottom;
    final bottomSafe = MediaQuery.of(context).padding.bottom;
    final maxHeight = MediaQuery.of(context).size.height * 0.62;

    return Padding(
      // Lifts the whole sheet above the keyboard
      padding: EdgeInsets.only(bottom: keyboard),
      child: Align(
        alignment: Alignment.bottomCenter,
        child: Container(
          width: double.infinity,
          constraints: BoxConstraints(maxHeight: maxHeight),
          decoration: const BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(24),
              topRight: Radius.circular(24),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Drag handle
              const SizedBox(height: 10),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              // Header
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 12, 8, 4),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Edit profile',
                        style: textTheme.titleLarge?.copyWith(
                          color: AppColors.navy,
                        ),
                      ),
                    ),
                    IconButton(
                      tooltip: 'Close',
                      onPressed:
                      _loading ? null : () => Navigator.pop(context),
                      icon: const Icon(Icons.close_rounded,
                          color: AppColors.navy, size: 22),
                    ),
                  ],
                ),
              ),

              // Form (scrolls only if taller than the sheet)
              Flexible(
                child: Form(
                  key: _formKey,
                  child: ListView(
                    shrinkWrap: true,
                    keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
                    children: [
                      if (_error != null) ...[
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppColors.error.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: AppColors.error.withValues(alpha: 0.3),
                            ),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Icon(Icons.error_outline_rounded,
                                  color: AppColors.error, size: 18),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  _error!,
                                  style: textTheme.bodySmall
                                      ?.copyWith(color: AppColors.error),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 14),
                      ],
                      _Field(
                        controller: _name,
                        label: 'Full name',
                        icon: Icons.person_outline_rounded,
                        textCapitalization: TextCapitalization.words,
                        validator: (v) => (v == null || v.trim().isEmpty)
                            ? 'Please enter your name'
                            : null,
                      ),
                      const SizedBox(height: 14),
                      _Field(
                        controller: _email,
                        label: 'Email address',
                        icon: Icons.mail_outline_rounded,
                        keyboardType: TextInputType.emailAddress,
                      ),
                      const SizedBox(height: 14),
                      _Field(
                        controller: _region,
                        label: 'Region',
                        icon: Icons.location_on_outlined,
                        textCapitalization: TextCapitalization.words,
                      ),
                      if (widget.user.isMiner) ...[
                        const SizedBox(height: 14),
                        _Field(
                          controller: _site,
                          label: 'Mining site',
                          icon: Icons.landscape_outlined,
                          textCapitalization: TextCapitalization.words,
                        ),
                      ],
                    ],
                  ),
                ),
              ),

              // Actions
              Padding(
                padding: EdgeInsets.fromLTRB(20, 4, 20, 16 + bottomSafe),
                child: Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.navy,
                          minimumSize: const Size.fromHeight(48),
                          side: const BorderSide(color: AppColors.border),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed:
                        _loading ? null : () => Navigator.pop(context),
                        child: const Text('Cancel'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 3,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.gold,
                          foregroundColor: AppColors.navy,
                          minimumSize: const Size.fromHeight(48),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: _loading ? null : _save,
                        child: _loading
                            ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            color: AppColors.navy,
                          ),
                        )
                            : Text(
                          'Save changes',
                          style: textTheme.labelLarge
                              ?.copyWith(color: AppColors.navy),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Field extends StatelessWidget {
  const _Field({
    required this.controller,
    required this.label,
    required this.icon,
    this.keyboardType,
    this.textCapitalization = TextCapitalization.none,
    this.validator,
  });

  final TextEditingController controller;
  final String label;
  final IconData icon;
  final TextInputType? keyboardType;
  final TextCapitalization textCapitalization;
  final String? Function(String?)? validator;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    OutlineInputBorder border(Color color, [double width = 1]) =>
        OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: color, width: width),
        );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: textTheme.bodySmall?.copyWith(
            color: AppColors.navy,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          textCapitalization: textCapitalization,
          validator: validator,
          style: textTheme.bodyLarge?.copyWith(color: AppColors.navy),
          cursorColor: AppColors.gold,
          decoration: InputDecoration(
            filled: true,
            fillColor: AppColors.white,
            isDense: true,
            prefixIcon: Icon(icon, color: AppColors.textSecondary, size: 20),
            contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
            enabledBorder: border(AppColors.border),
            focusedBorder: border(AppColors.gold, 2),
            errorBorder: border(AppColors.error),
            focusedErrorBorder: border(AppColors.error, 2),
          ),
        ),
      ],
    );
  }
}

// =====================================================================
// Profile page rows (no cards: clean list with thin dividers)
// =====================================================================

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Text(
        text,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: AppColors.textSecondary,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.4,
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
    this.muted = false,
    this.trailing,
  });

  final IconData icon;
  final String label;
  final String value;
  final bool muted;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.border)),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.textSecondary, size: 22),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: textTheme.bodySmall
                      ?.copyWith(color: AppColors.textSecondary),
                ),
                const SizedBox(height: 3),
                Text(
                  value,
                  style: textTheme.bodyLarge?.copyWith(
                    color: muted ? AppColors.textSecondary : AppColors.navy,
                    fontWeight: muted ? FontWeight.w400 : FontWeight.w600,
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                ),
              ],
            ),
          ),
          if (trailing != null) trailing!,
        ],
      ),
    );
  }
}

class _ActionRow extends StatelessWidget {
  const _ActionRow({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: const BoxDecoration(
          border: Border(bottom: BorderSide(color: AppColors.border)),
        ),
        child: Row(
          children: [
            Icon(icon, color: AppColors.textSecondary, size: 22),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                label,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: AppColors.navy,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const Icon(Icons.chevron_right_rounded,
                color: AppColors.textSecondary),
          ],
        ),
      ),
    );
  }
}