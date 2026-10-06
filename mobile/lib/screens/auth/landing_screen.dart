import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/app_settings_provider.dart';
import '../../theme/app_colors.dart';
import '../../widgets/app_card.dart';

class LandingScreen extends StatelessWidget {
  const LandingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<AppSettingsProvider>();
    final sw = settings.isSwahili;
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(children: [
                const Icon(Icons.diamond, color: AppColors.gold),
                const SizedBox(width: 8),
                const Text('Dhahabu',
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppColors.gold,
                        fontSize: 18)),
                const Spacer(),
                PopupMenuButton<String>(
                  tooltip: sw ? 'Lugha' : 'Language',
                  onSelected: settings.setLanguage,
                  itemBuilder: (_) => const [
                    PopupMenuItem(value: 'en', child: Text('English')),
                    PopupMenuItem(value: 'sw', child: Text('Kiswahili')),
                  ],
                  child: Padding(
                      padding: const EdgeInsets.all(8),
                      child: Text(sw ? 'SW' : 'EN')),
                ),
                IconButton(
                  tooltip: settings.isDark
                      ? (sw ? 'Hali ya mwanga' : 'Light mode')
                      : (sw ? 'Hali ya giza' : 'Dark mode'),
                  onPressed: settings.toggleTheme,
                  icon: Icon(settings.isDark
                      ? Icons.light_mode_outlined
                      : Icons.dark_mode_outlined),
                ),
                OutlinedButton(
                  onPressed: () => Navigator.pushNamed(context, '/login'),
                  child: Text(sw ? 'Ingia' : 'Sign in'),
                ),
              ]),
              const SizedBox(height: 32),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                    color: AppColors.success.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(999)),
                child: Text(
                    sw
                        ? 'IMEJENGWA KWA BIASHARA YA DHAHABU TANZANIA'
                        : 'BUILT FOR TANZANIA GOLD TRADE',
                    style: const TextStyle(
                        fontSize: 12, color: AppColors.success)),
              ),
              const SizedBox(height: 16),
              Text(
                  sw
                      ? 'Biashara ya dhahabu,\nchini ya udhibiti.'
                      : 'Gold trade,\nunder control.',
                  style: const TextStyle(
                      fontSize: 32, fontWeight: FontWeight.bold, height: 1.2)),
              const SizedBox(height: 12),
              Text(
                  sw
                      ? 'Bei za haki kulingana na karati, risiti za pamoja za kidijitali na mrabaha wa moja kwa moja kwa wachimbaji, wafanyabiashara wenye leseni na serikali.'
                      : 'Fair prices by karat, shared digital receipts, automatic royalty — for miners, licensed dealers and government.',
                  style: TextStyle(
                      color: Theme.of(context).hintColor,
                      height: 1.45,
                      fontSize: 16)),
              const SizedBox(height: 24),
              ElevatedButton(
                  onPressed: () => Navigator.pushNamed(context, '/register'),
                  child: Text(sw ? 'Fungua akaunti →' : 'Create account →')),
              const SizedBox(height: 12),
              OutlinedButton(
                  onPressed: () => Navigator.pushNamed(context, '/login'),
                  child: Text(sw
                      ? 'Ingia kama mtumiaji aliyesajiliwa'
                      : 'Explore as returning user')),
              const SizedBox(height: 12),
              Text(
                  sw
                      ? '✓ Uthibitishaji wa simu kwa OTP\n✓ Rekodi za mauzo zisizobadilika\n✓ Mrahaba wa 7% huhesabiwa moja kwa moja'
                      : '✓ OTP phone verification\n✓ Immutable sale records\n✓ 7% royalty auto-calculated',
                  style: const TextStyle(height: 1.6)),
              const SizedBox(height: 32),
              Text(sw ? 'KWA NINI DHAHABU' : 'WHY DHAHABU',
                  style: const TextStyle(
                      fontSize: 12, letterSpacing: 1.2, color: AppColors.gold)),
              const SizedBox(height: 12),
              AppCard(
                  child: Column(children: [
                _stat(
                    '24K',
                    sw
                        ? 'Bei za karati za moja kwa moja'
                        : 'Live karat prices'),
                const Divider(),
                _stat('1',
                    sw ? 'Rekodi ya mauzo ya pamoja' : 'Shared sale record'),
                const Divider(),
                _stat('7%', sw ? 'Mrahaba wa moja kwa moja' : 'Auto royalty'),
                const Divider(),
                _stat(
                    'TZS',
                    sw
                        ? 'Imeundwa kwa mazingira ya ndani'
                        : 'Local-first design'),
              ])),
              const SizedBox(height: 24),
              Text(
                  sw
                      ? 'Kwa kuendelea unakubali Sera ya Faragha. Miamala inaweza kukaguliwa na rekodi za kodi haziwezi kubadilishwa baada ya kuthibitishwa.'
                      : 'By continuing you agree to the Privacy Policy. Transactions are auditable and tax records are immutable once confirmed.',
                  style: TextStyle(
                      fontSize: 12, color: Theme.of(context).hintColor)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _stat(String value, String label) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(children: [
          SizedBox(
              width: 56,
              child: Text(value,
                  style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: AppColors.gold))),
          Expanded(child: Text(label)),
        ]),
      );
}
