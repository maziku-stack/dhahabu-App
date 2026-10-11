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
        builder: (context, settings, _) => MaterialApp(
          title: 'Dhahabu',
          debugShowCheckedModeBanner: false,
          builder: (context, child) {
            final mediaQuery = MediaQuery.of(context);
            return MediaQuery(
              data: mediaQuery.copyWith(
                textScaler: _AppTextScaler(mediaQuery.textScaler, 1.1),
              ),
              child: child!,
            );
          },
          theme: buildDhahabuTheme(),
          darkTheme: buildDhahabuLightTheme(),
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
        ),
      ),
    );
  }
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
  double get textScaleFactor => platformScaler.textScaleFactor * factor;

  @override
  bool operator ==(Object other) =>
      other is _AppTextScaler &&
      other.platformScaler == platformScaler &&
      other.factor == factor;

  @override
  int get hashCode => Object.hash(platformScaler, factor);
}
