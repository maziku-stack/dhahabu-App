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
          theme: buildDhahabuTheme(),
          lightTheme: buildDhahabuLightTheme(),
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
