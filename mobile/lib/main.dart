import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'theme/app_theme.dart';
import 'providers/auth_provider.dart';
import 'providers/app_settings_provider.dart';
import 'screens/auth/splash_screen.dart';
import 'screens/auth/landing_screen.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/register_screen.dart';
import 'screens/auth/set_pin_screen.dart';
import 'screens/shells/role_router.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const DhahabuApp());
}

class DhahabuApp extends StatelessWidget {
  const DhahabuApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => AppSettingsProvider()),
      ],
      child: Consumer<AppSettingsProvider>(
        builder: (context, settings, _) {
          final hasDashboardTheme = context.watch<AuthProvider>().user != null;
          final lightTheme = buildDhahabuLightTheme();
          final darkTheme = buildDhahabuTheme();

          return MaterialApp(
            title: 'Dhahabu',
            debugShowCheckedModeBanner: false,
            builder: (context, child) {
              final mediaQuery = MediaQuery.of(context);
              final app = MediaQuery(
                data: mediaQuery.copyWith(
                  textScaler: _AppTextScaler(mediaQuery.textScaler, 1.1),
                ),
                child: child ?? const SizedBox.shrink(),
              );
              if (!hasDashboardTheme) return app;
              return Stack(
                fit: StackFit.expand,
                children: [
                  _DashboardAtmosphere(isDark: settings.isDark),
                  app,
                ],
              );
            },
            // Keep each ThemeData paired with its actual brightness. The
            // previous pairing sent dark mode to the light palette.
            theme: hasDashboardTheme
                ? buildGlassDashboardTheme(lightTheme)
                : lightTheme,
            darkTheme: hasDashboardTheme
                ? buildGlassDashboardTheme(darkTheme)
                : darkTheme,
            themeMode: settings.themeMode,
            locale: settings.locale,
            home: const SplashScreen(),
            routes: {
              '/landing': (_) => const LandingScreen(),
              '/login': (_) => const LoginScreen(),
              '/register': (_) => const RegisterScreen(),
              '/set-pin': (_) => const SetPinScreen(),
              '/home': (_) => const RoleRouter(),
            },
          );
        },
      ),
    );
  }
}

class _DashboardAtmosphere extends StatelessWidget {
  const _DashboardAtmosphere({required this.isDark});

  final bool isDark;

  @override
  Widget build(BuildContext context) => DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDark
                ? const [
                    Color(0xFF071321),
                    Color(0xFF10243A),
                    Color(0xFF091626),
                  ]
                : const [
                    Color(0xFFF7F6F2),
                    Color(0xFFE9EFF4),
                    Color(0xFFF8F9FA),
                  ],
          ),
        ),
        child: Stack(
          fit: StackFit.expand,
          children: [
            Positioned(
              top: -170,
              right: -100,
              child: _AmbientGlow(
                color:
                    isDark ? const Color(0x35C9A227) : const Color(0x3AC9A227),
                size: 380,
              ),
            ),
            Positioned(
              left: -180,
              bottom: 50,
              child: _AmbientGlow(
                color:
                    isDark ? const Color(0x283F79A8) : const Color(0x183F79A8),
                size: 430,
              ),
            ),
          ],
        ),
      );
}

class _AmbientGlow extends StatelessWidget {
  const _AmbientGlow({required this.color, required this.size});

  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) => SizedBox.square(
        dimension: size,
        child: DecoratedBox(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(
              colors: [color, color.withValues(alpha: 0)],
            ),
          ),
        ),
      );
}

/// Gives app text a modest 10% size increase while retaining the user's
/// platform text scaling preference, including nonlinear accessibility scaling.
class _AppTextScaler extends TextScaler {
  const _AppTextScaler(this.platformScaler, this.factor);

  final TextScaler platformScaler;
  final double factor;

  @override
  double scale(double fontSize) => platformScaler.scale(fontSize) * factor;

  @override
  double get textScaleFactor => platformScaler.scale(1) * factor;

  @override
  bool operator ==(Object other) =>
      other is _AppTextScaler &&
      other.platformScaler == platformScaler &&
      other.factor == factor;

  @override
  int get hashCode => Object.hash(platformScaler, factor);
}
