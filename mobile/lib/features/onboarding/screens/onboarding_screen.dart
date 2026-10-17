import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dhahabu/core/theme/app_colors.dart';
import 'package:dhahabu/features/auth/screens/login_screen.dart';

class OnboardingPage {
  const OnboardingPage({
    required this.image,
    required this.title,
    required this.description,
    required this.color,
  });

  final String image;
  final String title;
  final String description;
  final Color color;
}

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  double _pageOffset = 0.0;
  int _currentIndex = 0;

  // Each page color is matched to its image:
  // gold bars -> deep warm gold-brown, rock -> deep earth brown-green,
  // third image -> deep navy blue. Change these freely.
  static const List<OnboardingPage> _pages = [
    OnboardingPage(
      image:
      'assets/images/depositphotos_9221392-stock-photo-stacked-gold-bars.jpg',
      title: 'Trade Gold Securely',
      description:
      'Post your gold listings and easily connect with licensed dealers across Tanzania.',
      color: Color(0xFF7A5C0A),
    ),
    OnboardingPage(
      image: 'assets/images/gold2.jpg',
      title: 'Verified Dealers',
      description:
      'Every dealer is vetted and approved before purchasing, ensuring you trade with trusted partners.',
      color: Color(0xFF3E4A3D),
    ),
    OnboardingPage(
      image: 'assets/images/gold3.jpg',
      title: 'Transparent Taxes & Receipts',
      description:
      '7% royalty is automatically calculated and secure digital receipts are stored for every transaction.',
      color: Color(0xFF12306B),
    ),
  ];

  static const SystemUiOverlayStyle _overlayStyle = SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
    systemNavigationBarColor: Colors.transparent,
    systemNavigationBarIconBrightness: Brightness.light,
    systemNavigationBarContrastEnforced: false,
  );

  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    SystemChrome.setSystemUIOverlayStyle(_overlayStyle);
    _pageController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_pageController.hasClients && _pageController.position.haveDimensions) {
      setState(() {
        _pageOffset = _pageController.page ?? 0.0;
      });
    }
  }

  Future<void> _finishOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarding_seen', true);
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
    );
  }

  void _next() {
    if (_currentIndex < _pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    } else {
      _finishOnboarding();
    }
  }

  @override
  void dispose() {
    _pageController.removeListener(_onScroll);
    _pageController.dispose();
    super.dispose();
  }

  Color _currentBackgroundColor() {
    final int lower = _pageOffset.floor().clamp(0, _pages.length - 1);
    final int upper = _pageOffset.ceil().clamp(0, _pages.length - 1);
    final double t = _pageOffset - lower;
    return Color.lerp(_pages[lower].color, _pages[upper].color, t) ??
        _pages[0].color;
  }

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    final topInset = media.padding.top;
    final bottomInset = media.padding.bottom;
    final bg = _currentBackgroundColor();
    final textTheme = Theme.of(context).textTheme;
    final isLast = _currentIndex == _pages.length - 1;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: _overlayStyle,
      child: Scaffold(
        extendBody: true,
        extendBodyBehindAppBar: true,
        backgroundColor: bg,
        body: SizedBox.expand(
          child: Stack(
            children: [
              // Pages: image circle + text slide together
              Positioned.fill(
                child: PageView.builder(
                  controller: _pageController,
                  itemCount: _pages.length,
                  onPageChanged: (index) =>
                      setState(() => _currentIndex = index),
                  itemBuilder: (context, index) {
                    final page = _pages[index];
                    final double delta =
                    (_pageOffset - index).abs().clamp(0.0, 1.0);
                    final double scale = 1.0 - (delta * 0.18);
                    final double opacity = 1.0 - (delta * 0.6);

                    return LayoutBuilder(
                      builder: (context, constraints) {
                        final double topPad = topInset + 72;
                        final double bottomPad = bottomInset + 120;
                        final double available =
                            constraints.maxHeight - topPad - bottomPad;
                        final double diameter = (constraints.maxWidth * 0.62)
                            .clamp(140.0, 260.0)
                            .clamp(0.0, available * 0.55)
                            .toDouble();

                        return SingleChildScrollView(
                          physics: const ClampingScrollPhysics(),
                          padding:
                          EdgeInsets.fromLTRB(28, topPad, 28, bottomPad),
                          child: ConstrainedBox(
                            constraints: BoxConstraints(
                              minHeight: available > 0 ? available : 0,
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Opacity(
                                  opacity: opacity.clamp(0.0, 1.0),
                                  child: Transform.scale(
                                    scale: scale,
                                    child: _HeroCircle(
                                      image: page.image,
                                      diameter: diameter,
                                    ),
                                  ),
                                ),
                                SizedBox(height: available < 380 ? 24 : 44),
                                Text(
                                  page.title,
                                  textAlign: TextAlign.center,
                                  style: textTheme.displayLarge?.copyWith(
                                    color: AppColors.white,
                                    fontSize: available < 380 ? 24 : 28,
                                    height: 1.2,
                                  ),
                                ),
                                const SizedBox(height: 14),
                                Text(
                                  page.description,
                                  textAlign: TextAlign.center,
                                  style: textTheme.bodyLarge?.copyWith(
                                    color:
                                    AppColors.white.withValues(alpha: 0.85),
                                    fontSize: available < 380 ? 14 : 15,
                                    height: 1.5,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),

              // Top bar
              Positioned(
                top: topInset + 12,
                left: 24,
                right: 24,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: AppColors.gold,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'DHAHABU',
                          style: textTheme.titleMedium?.copyWith(
                            color: AppColors.white,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1.5,
                          ),
                        ),
                      ],
                    ),
                    AnimatedOpacity(
                      opacity: isLast ? 0.0 : 1.0,
                      duration: const Duration(milliseconds: 300),
                      child: IgnorePointer(
                        ignoring: isLast,
                        child: TextButton(
                          onPressed: _finishOnboarding,
                          child: Text(
                            'Skip',
                            style: textTheme.labelLarge?.copyWith(
                              fontSize: 15,
                              color: AppColors.white.withValues(alpha: 0.9),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Bottom controls: dots + button
              Positioned(
                left: 28,
                right: 28,
                bottom: bottomInset + 24,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _PageIndicator(
                      totalPages: _pages.length,
                      currentIndex: _currentIndex,
                    ),
                    ElevatedButton(
                      onPressed: _next,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.gold,
                        foregroundColor: AppColors.navy,
                        minimumSize: const Size(155, 52),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            isLast ? 'Get Started' : 'Continue',
                            style: textTheme.labelLarge?.copyWith(
                              color: AppColors.navy,
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Icon(Icons.arrow_forward_rounded, size: 18),
                        ],
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

class _HeroCircle extends StatelessWidget {
  const _HeroCircle({required this.image, required this.diameter});

  final String image;
  final double diameter;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: diameter,
      height: diameter,
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.white,
        border: Border.all(color: AppColors.gold, width: 2.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.30),
            blurRadius: 30,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      child: ClipOval(
        child: Image.asset(
          image,
          width: double.infinity,
          height: double.infinity,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => Container(
            color: AppColors.navyLight,
            child: const Center(
              child: Icon(
                Icons.image_not_supported_outlined,
                size: 48,
                color: AppColors.gold,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _PageIndicator extends StatelessWidget {
  const _PageIndicator({
    required this.totalPages,
    required this.currentIndex,
  });

  final int totalPages;
  final int currentIndex;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(
        totalPages,
            (index) => AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin: const EdgeInsets.only(right: 6),
          height: 8,
          width: currentIndex == index ? 28 : 8,
          decoration: BoxDecoration(
            color: currentIndex == index
                ? AppColors.gold
                : AppColors.white.withValues(alpha: 0.4),
            borderRadius: BorderRadius.circular(4),
          ),
        ),
      ),
    );
  }
}