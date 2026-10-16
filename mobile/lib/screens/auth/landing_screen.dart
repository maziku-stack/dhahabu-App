import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/app_settings_provider.dart';
import 'package:dhahabu/core/theme/app_colors.dart';
import '../../widgets/app_card.dart';
import '../../widgets/dhahabu_logo.dart';

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
                const DhahabuLogo(size: 32),
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
              const SizedBox(height: 20),
              _goldPhotoCollage(),
              const SizedBox(height: 28),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                    color: AppColors.success.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(999)),
                child: Text(
                    sw
                        ? 'KWA AJIRI YA BIASHARA YA DHAHABU TANZANIA'   
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
                      : 'Gold listings by karat and shared digital trade records for miners and licensed dealers.',
                  style: TextStyle(
                      color: Theme.of(context).hintColor,
                      height: 1.45,
                      fontSize: 16)),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size.fromHeight(52),
                  ),
                  onPressed: () => Navigator.pushNamed(context, '/register'),
                  child: Text(sw ? 'Fungua akaunti →' : 'Create account →'),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size.fromHeight(52),
                  ),
                  onPressed: () => Navigator.pushNamed(context, '/login'),
                  child: Text(sw
                      ? 'Ingia kama mtumiaji aliyesajiliwa'
                      : 'Explore as returning user'),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                  sw
                      ? '✓ Uthibitishaji wa simu kwa OTP\n✓ Rekodi za mauzo za pamoja\n✓ Taarifa ya faragha inapatikana'
                      : '✓ OTP phone verification\n✓ Shared sale records\n✓ Privacy notice available',
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
                _stat(
                    'TRA',
                    sw
                        ? 'Muunganisho rasmi bado haujaunganishwa'
                        : 'Official integration not connected yet'),
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
                      ? 'Soma taarifa ya faragha kabla ya kufungua akaunti. Kukubali taarifa hii hakumaanishi ridhaa kwa matumizi ya hiari ya data.'
                      : 'Read the privacy notice before creating an account. Acknowledging it is not consent to optional data uses.',
                  style: TextStyle(
                      fontSize: 12, color: Theme.of(context).hintColor)),
              TextButton.icon(
                onPressed: () => Navigator.pushNamed(context, '/privacy'),
                icon: const Icon(Icons.privacy_tip_outlined),
                label: Text(sw
                    ? 'Soma taarifa ya faragha (RASIMU)'
                    : 'Read privacy notice (DRAFT)'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _goldPhotoCollage() => SizedBox(
        height: 190,
        child: GridView.count(
          crossAxisCount: 3,
          mainAxisSpacing: 8,
          crossAxisSpacing: 8,
          childAspectRatio: 1.15,
          physics: const NeverScrollableScrollPhysics(),
          children: [
            'gold1.jpg',
            'gold2.jpg',
            'gold3.jpg',
            'depositphotos_9221392-stock-photo-stacked-gold-bars.jpg',
            'OIP.webp',
            'Purified_gold.webp',
          ].map(_goldPhoto).toList(),
        ),
      );

  Widget _goldPhoto(String filename) => ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Image.asset(
          'assets/images/$filename',
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => Container(
            color: AppColors.gold.withValues(alpha: 0.12),
            child: const Icon(Icons.image_not_supported_outlined,
                color: AppColors.gold),
          ),
        ),
      );

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
