import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:dhahabu/core/theme/app_colors.dart';
import 'package:dhahabu/core/widgets/status_badge.dart';
import 'package:dhahabu/core/providers/app_settings_provider.dart';
import 'package:dhahabu/features/auth/models/user.dart';
import 'package:dhahabu/features/auth/providers/auth_provider.dart';
import 'package:dhahabu/features/feedback/screens/feedback_screen.dart';
import 'package:dhahabu/features/privacy/screens/privacy_screen.dart';
import 'package:dhahabu/l10n/l10n.dart';

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
    final l10n = context.l10n;
    final auth = context.read<AuthProvider>();
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.signOutPrompt),
        content: Text(l10n.signOutConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(
              l10n.signOut,
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
    final l10n = context.l10n;
    final settings = context.watch<AppSettingsProvider>();
    final user = context.watch<AuthProvider>().user;
    if (user == null) return const SizedBox();

    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        title: Text(
          l10n.profile,
          style: textTheme.titleLarge?.copyWith(
            color: AppColors.navy,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined, color: AppColors.navy),
            tooltip: l10n.editProfile,
            onPressed: () => _showEditProfileSheet(context, user),
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
        children: [
          Center(
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.gold, width: 2),
              ),
              child: CircleAvatar(
                radius: 44,
                backgroundColor: AppColors.navy,
                child: Text(
                  user.fullName.isNotEmpty
                      ? user.fullName[0].toUpperCase()
                      : 'U',
                  style: textTheme.displayLarge?.copyWith(
                    color: AppColors.gold,
                    fontSize: 34,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            user.fullName,
            textAlign: TextAlign.center,
            style: textTheme.titleLarge?.copyWith(
              color: AppColors.navy,
              fontSize: 22,
              fontWeight: FontWeight.w700,
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
          const SizedBox(height: 12),
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
                  letterSpacing: 1.1,
                ),
              ),
            ),
          ),
          const SizedBox(height: 32),

          _SectionTitle(l10n.accountInfo),
          _InfoCard(
            children: [
              _InfoRow(
                icon: Icons.phone_outlined,
                label: l10n.phoneNumber,
                value: user.phone,
              ),
              _InfoRow(
                icon: Icons.location_on_outlined,
                label: l10n.region,
                value: user.region.isNotEmpty ? user.region : l10n.notSpecified,
                muted: user.region.isEmpty,
              ),
              if (user.isMiner)
                _InfoRow(
                  icon: Icons.landscape_outlined,
                  label: l10n.miningSite,
                  value: user.miningSite.isNotEmpty
                      ? user.miningSite
                      : l10n.notSpecified,
                  muted: user.miningSite.isEmpty,
                ),
              if (user.isDealer)
                _InfoRow(
                  icon: Icons.verified_outlined,
                  label: l10n.dealerVerification,
                  value: user.isVerifiedDealer ? l10n.verified : l10n.pending,
                  trailing: user.isVerifiedDealer
                      ? StatusBadge.verified()
                      : StatusBadge.pending(),
                ),
            ],
          ),
          const SizedBox(height: 24),

          _SectionTitle(l10n.settingsAndPrivacy),
          _InfoCard(
            children: [
              _ActionRow(
                icon: Icons.brightness_6_rounded,
                label: l10n.theme,
                trailingText: settings.themeMode == ThemeMode.dark
                    ? l10n.darkTheme
                    : settings.themeMode == ThemeMode.system
                        ? l10n.systemTheme
                        : l10n.lightTheme,
                onTap: () {
                  showModalBottomSheet(
                    context: context,
                    builder: (ctx) => SafeArea(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          ListTile(
                            leading: const Icon(Icons.wb_sunny_outlined),
                            title: Text(l10n.lightTheme),
                            trailing: settings.themeMode == ThemeMode.light
                                ? const Icon(Icons.check, color: AppColors.gold)
                                : null,
                            onTap: () {
                              settings.setThemeMode(ThemeMode.light);
                              Navigator.pop(ctx);
                            },
                          ),
                          ListTile(
                            leading: const Icon(Icons.nightlight_outlined),
                            title: Text(l10n.darkTheme),
                            trailing: settings.themeMode == ThemeMode.dark
                                ? const Icon(Icons.check, color: AppColors.gold)
                                : null,
                            onTap: () {
                              settings.setThemeMode(ThemeMode.dark);
                              Navigator.pop(ctx);
                            },
                          ),
                          ListTile(
                            leading: const Icon(Icons.brightness_auto_outlined),
                            title: Text(l10n.systemTheme),
                            trailing: settings.themeMode == ThemeMode.system
                                ? const Icon(Icons.check, color: AppColors.gold)
                                : null,
                            onTap: () {
                              settings.setThemeMode(ThemeMode.system);
                              Navigator.pop(ctx);
                            },
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
              _ActionRow(
                icon: Icons.language_rounded,
                label: l10n.language,
                trailingText: settings.isSwahili ? l10n.swahili : l10n.english,
                onTap: () {
                  final newLang = settings.isSwahili ? 'en' : 'sw';
                  settings.setLanguage(newLang);
                },
              ),
              _ActionRow(
                icon: Icons.privacy_tip_outlined,
                label: l10n.privacyAndDataPolicy,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const PrivacyScreen()),
                ),
              ),
              _InfoRow(
                icon: Icons.info_outline_rounded,
                label: l10n.appVersion,
                value: 'v1.0.0 (Dhahabu Mobile)',
              ),
            ],
          ),
          const SizedBox(height: 24),

          _SectionTitle(l10n.support),
          _InfoCard(
            children: [
              _ActionRow(
                icon: Icons.feedback_outlined,
                label: l10n.feedbackAndSupport,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const FeedbackScreen()),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Text(
              l10n.officialTraNotConnected,
              style: textTheme.bodySmall?.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ),
          const SizedBox(height: 32),

          SizedBox(
            height: 52,
            child: OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.error,
                side: const BorderSide(color: AppColors.error),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () => _confirmSignOut(context),
              icon: const Icon(Icons.logout_rounded, size: 20),
              label: Text(
                l10n.signOut,
                style: textTheme.labelLarge?.copyWith(
                  color: AppColors.error,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

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
    final l10n = context.l10n;
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
        SnackBar(content: Text(l10n.profileUpdated)),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString().replaceFirst('Exception: ', '');
        _loading = false;
      });
    }
  }

  InputDecoration _decoration({required IconData icon, String? label}) {
    OutlineInputBorder border(Color c, [double w = 1]) => OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: c, width: w),
        );
    return InputDecoration(
      labelText: label,
      filled: true,
      fillColor: const Color(0xFFF9FAFB),
      isDense: true,
      prefixIcon: Icon(icon, color: AppColors.navy, size: 20),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      enabledBorder: border(AppColors.border),
      focusedBorder: border(AppColors.gold, 2),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final textTheme = Theme.of(context).textTheme;
    final keyboard = MediaQuery.of(context).viewInsets.bottom;
    final maxHeight = MediaQuery.of(context).size.height * 0.7;

    return Padding(
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
          child: SafeArea(
            top: false,
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: AppColors.border,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      l10n.editProfile,
                      style: textTheme.titleLarge?.copyWith(
                        color: AppColors.navy,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
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
                        child: Text(
                          _error!,
                          style: textTheme.bodySmall
                              ?.copyWith(color: AppColors.error),
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                    TextFormField(
                      controller: _name,
                      style: textTheme.bodyLarge?.copyWith(color: AppColors.navy),
                      cursorColor: AppColors.gold,
                      decoration: _decoration(icon: Icons.person_outline, label: l10n.fullName),
                      validator: (v) => v?.trim().isEmpty == true ? l10n.required : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _email,
                      keyboardType: TextInputType.emailAddress,
                      style: textTheme.bodyLarge?.copyWith(color: AppColors.navy),
                      cursorColor: AppColors.gold,
                      decoration: _decoration(icon: Icons.email_outlined, label: l10n.emailAddress),
                      validator: (v) => v?.trim().isEmpty == true ? l10n.required : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _region,
                      style: textTheme.bodyLarge?.copyWith(color: AppColors.navy),
                      cursorColor: AppColors.gold,
                      decoration: _decoration(icon: Icons.location_on_outlined, label: l10n.region),
                    ),
                    if (widget.user.isMiner) ...[
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _site,
                        style: textTheme.bodyLarge?.copyWith(color: AppColors.navy),
                        cursorColor: AppColors.gold,
                        decoration: _decoration(icon: Icons.landscape_outlined, label: l10n.miningSite),
                      ),
                    ],
                    const SizedBox(height: 24),
                    SizedBox(
                      height: 52,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.gold,
                          foregroundColor: AppColors.navy,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: _loading ? null : _save,
                        child: _loading
                            ? const SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.5,
                                  color: AppColors.navy,
                                ),
                              )
                            : Text(
                                l10n.save,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                ),
                              ),
                      ),
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

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 10),
      child: Text(
        text,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.3,
            ),
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final items = <Widget>[];
    for (var i = 0; i < children.length; i++) {
      items.add(children[i]);
      if (i < children.length - 1) {
        items.add(const Divider(height: 1, color: AppColors.border));
      }
    }
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(children: items),
    );
  }
}

class _IconBox extends StatelessWidget {
  const _IconBox(this.icon);

  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: AppColors.gold.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(icon, color: AppColors.navy, size: 20),
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
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          _IconBox(icon),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 2),
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
    this.trailingText,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final String? trailingText;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            _IconBox(icon),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                label,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: AppColors.navy,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            if (trailingText != null) ...[
              Text(
                trailingText!,
                style: const TextStyle(
                  color: AppColors.gold,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              const SizedBox(width: 8),
            ],
            const Icon(Icons.chevron_right_rounded,
                color: AppColors.textSecondary),
          ],
        ),
      ),
    );
  }
}
