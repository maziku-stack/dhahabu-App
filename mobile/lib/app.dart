import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:dhahabu/core/theme/app_theme.dart';
import 'package:dhahabu/features/auth/providers/auth_provider.dart';
import 'package:dhahabu/core/providers/app_settings_provider.dart';
import 'package:dhahabu/features/auth/screens/splash_screen.dart';

import 'package:dhahabu/features/auth/screens/login_screen.dart';
import 'package:dhahabu/features/auth/screens/register_screen.dart';
import 'package:dhahabu/features/auth/screens/role_selection_screen.dart';
import 'package:dhahabu/features/shell/screens/role_router.dart';
import 'package:dhahabu/features/privacy/screens/privacy_screen.dart';

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
          final lightTheme = dhahabuTheme();
          final darkTheme = dhahabuDarkTheme();

          return MaterialApp(
            title: 'Dhahabu',
            debugShowCheckedModeBanner: false,
            builder: (context, child) {
              final mediaQuery = MediaQuery.of(context);
              return MediaQuery(
                data: mediaQuery.copyWith(
                  textScaler: _AppTextScaler(mediaQuery.textScaler, 1.1),
                ),
                child: child ?? const SizedBox.shrink(),
              );
            },
            theme: lightTheme,
            darkTheme: darkTheme,
            themeMode: settings.themeMode,
            locale: settings.locale,
            home: const SplashScreen(),
            routes: {
              '/role-selection': (_) => const RoleSelectionScreen(),
              '/login': (_) => const LoginScreen(),
              '/register': (_) => const RegisterScreen(),
              '/home': (_) => const RoleRouter(),
              '/privacy': (_) => const PrivacyScreen(),
            },
          );
        },
      ),
    );
  }
}

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
