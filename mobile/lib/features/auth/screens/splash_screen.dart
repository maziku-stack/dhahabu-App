import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dhahabu/features/auth/providers/auth_provider.dart';
import 'package:dhahabu/core/theme/app_colors.dart';
import 'package:dhahabu/core/widgets/dhahabu_logo.dart';
import 'package:dhahabu/features/onboarding/screens/onboarding_screen.dart';
import 'package:dhahabu/features/shell/screens/role_router.dart';
import 'package:dhahabu/features/auth/screens/login_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
      ),
    );

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutBack),
    );

    _controller.forward();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    final stopwatch = Stopwatch()..start();

    final auth = Provider.of<AuthProvider>(context, listen: false);
    final prefsFuture = SharedPreferences.getInstance();
    final authFuture = auth.initialized;

    final results = await Future.wait([prefsFuture, authFuture]);
    final prefs = results[0] as SharedPreferences;

    final onboardingSeen = prefs.getBool('onboarding_seen') ?? false;

    final elapsed = stopwatch.elapsedMilliseconds;
    const minDuration = 2500;
    if (elapsed < minDuration) {
      await Future.delayed(Duration(milliseconds: minDuration - elapsed));
    }

    if (!mounted) return;

    if (!onboardingSeen) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const OnboardingScreen()),
      );
    } else if (auth.isAuthenticated) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const RoleRouter()),
      );
    } else {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.navy,
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: ScaleTransition(
          scale: _scaleAnimation,
          child: SafeArea(
            child: SizedBox.expand(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const SizedBox.shrink(),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const DhahabuLogo(size: 88),
                        const SizedBox(height: 20),
                        Text(
                          'Dhahabu',
                          style: GoogleFonts.urbanist(
                            fontSize: 32,
                            fontWeight: FontWeight.w700,
                            color: AppColors.gold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Biashara ya Dhahabu kwa Uwazi',
                          style: GoogleFonts.publicSans(
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                            color: AppColors.white.withValues(alpha: 0.7),
                          ),
                        ),
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 24),
                      child: Column(
                        children: [
                          const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              color: AppColors.gold,
                              strokeWidth: 2,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'v1.0.0',
                            style: GoogleFonts.publicSans(
                              fontSize: 12,
                              fontWeight: FontWeight.w400,
                              color: AppColors.white.withValues(alpha: 0.5),
                            ),
                          ),
                        ],
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
