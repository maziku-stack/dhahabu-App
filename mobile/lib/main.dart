import 'package:dhahabu/screens/landing_screens.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/auth_provider.dart';
import 'screens/splash_screen.dart';
import 'screens/login_screen.dart';
import 'screens/home_shell.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const DhahabuApp());
}

class DhahabuApp extends StatelessWidget {
  const DhahabuApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AuthProvider(),
      child: MaterialApp(
        title: 'Dhahabu',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFFD4A017), // gold
            primary: const Color(0xFFB8860B),
            secondary: const Color(0xFF1A1A2E),
            brightness: Brightness.light,
          ),
          textTheme: ThemeData.light().textTheme,
          useMaterial3: true,
          appBarTheme: const AppBarTheme(centerTitle: true, elevation: 0),
          inputDecorationTheme: InputDecorationTheme(
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            filled: true,
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ),
        home: const SplashScreen(),
        routes: {
          '/Landing': (_) => const LandingScreens(),
          '/login': (_) => const LoginScreen(),
          '/home': (_) => const HomeShell(),
        },
      ),
    );
  }
}
