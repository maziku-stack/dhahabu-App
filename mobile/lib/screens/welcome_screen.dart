import 'package:flutter/material.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  final _pageController = PageController();
  int _page = 0;

  final _slides = const [
    _Slide(
      icon: Icons.diamond,
      title: 'Welcome to Dhahabu',
      body:
          'A secure platform that connects small-scale miners, licensed gold dealers, '
          'and government under one auditable system for fair gold trade in Tanzania.',
    ),
    _Slide(
      icon: Icons.price_change,
      title: 'Know the fair price',
      body:
          'See today\'s gold price by karat (24K, 22K, 18K) before you sell. '
          'No more guessing or relying only on word of mouth.',
    ),
    _Slide(
      icon: Icons.receipt_long,
      title: 'Record every sale',
      body:
          'Both miner and dealer share one digital receipt. '
          'Royalties and taxes are calculated automatically for compliance.',
    ),
    _Slide(
      icon: Icons.verified_user,
      title: 'Privacy & trust',
      body:
          'Your phone is verified with OTP. Transactions are locked after confirmation. '
          'Government sees volumes and royalties — not private chats. '
          'By continuing you agree to our Privacy Policy and Terms of Use.',
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _next() {
    if (_page < _slides.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      Navigator.pushReplacementNamed(context, '/register');
    }
  }

  @override
  Widget build(BuildContext context) {
    final gold = const Color(0xFFB8860B);
    final dark = const Color(0xFF1A1A2E);

    return Scaffold(
      backgroundColor: const Color(0xFFFFFBF5),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          TextButton(
            onPressed: () => Navigator.pushNamed(context, '/login'),
            child: Text(
              'Login',
              style: TextStyle(
                color: gold,
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: _slides.length,
                onPageChanged: (i) => setState(() => _page = i),
                itemBuilder: (context, i) {
                  final s = _slides[i];
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 28),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            color: gold.withOpacity(0.12),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(s.icon, size: 52, color: gold),
                        ),
                        const SizedBox(height: 32),
                        Text(
                          s.title,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: dark,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          s.body,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 15,
                            height: 1.5,
                            color: Colors.grey[700],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            // Dots
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(_slides.length, (i) {
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: _page == i ? 24 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: _page == i ? gold : Colors.grey[300],
                    borderRadius: BorderRadius.circular(4),
                  ),
                );
              }),
            ),
            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _next,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: gold,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    _page < _slides.length - 1 ? 'Next' : 'Create account',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: () => Navigator.pushNamed(context, '/login'),
              child: Text(
                'Already have an account? Login',
                style: TextStyle(color: Colors.grey[700]),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

class _Slide {
  final IconData icon;
  final String title;
  final String body;
  const _Slide({required this.icon, required this.title, required this.body});
}
