import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../routes/app_router.dart';
import '../../theme/app_colors.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _index = 0;

  final List<_OnboardingData> _pages = const [
    _OnboardingData(
      title: 'Satisfy Your Cravings',
      subtitle: 'Discover bold Dhakaiya flavors with juicy burgers and more.',
      icon: Icons.lunch_dining_rounded,
      logoAsset: 'assets/logo.png',
      bgColor: AppColors.primary,
    ),
    _OnboardingData(
      title: 'Order from Anywhere',
      subtitle:
          'Get your favorite meals delivered across your city in minutes.',
      icon: Icons.delivery_dining_rounded,
      bgColor: Color(0xFFFFD54F),
    ),
    _OnboardingData(
      title: 'Fast Pickup with Token',
      subtitle:
          'Skip queues with instant token pickup for a seamless experience.',
      icon: Icons.qr_code_2_rounded,
      bgColor: Color(0xFFFFCA28),
    ),
  ];

  Future<void> _completeOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('seen_onboarding', true);
    if (!mounted) return;
    Navigator.pushReplacementNamed(context, AppRouter.login);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final current = _pages[_index];
    return Scaffold(
      body: AnimatedContainer(
        duration: const Duration(milliseconds: 350),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              current.bgColor,
              current.bgColor.withValues(alpha: 0.88),
              const Color(0xFFFFF7DA),
            ],
            stops: const [0, 0.56, 1],
          ),
        ),
        child: Stack(
          children: [
            Positioned(
              top: -70,
              right: -30,
              child: _BackOrb(
                size: 220,
                color: Colors.white.withValues(alpha: 0.26),
              ),
            ),
            Positioned(
              bottom: 120,
              left: -48,
              child: _BackOrb(
                size: 170,
                color: AppColors.secondary.withValues(alpha: 0.08),
              ),
            ),
            SafeArea(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 18,
                      vertical: 8,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.7),
                            borderRadius: BorderRadius.circular(28),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.8),
                            ),
                          ),
                          child: Text(
                            '${_index + 1}/${_pages.length}',
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(
                                  color: AppColors.secondary,
                                  fontWeight: FontWeight.w700,
                                ),
                          ),
                        ),
                        TextButton(
                          onPressed: _completeOnboarding,
                          style: TextButton.styleFrom(
                            backgroundColor: Colors.white.withValues(
                              alpha: 0.7,
                            ),
                            foregroundColor: AppColors.secondary,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 9,
                            ),
                          ),
                          child: const Text('Skip'),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: PageView.builder(
                      controller: _pageController,
                      onPageChanged: (value) => setState(() => _index = value),
                      itemCount: _pages.length,
                      itemBuilder: (context, i) {
                        final page = _pages[i];
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 26),
                          child: _OnboardingPage(page: page, index: i),
                        );
                      },
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      _pages.length,
                      (i) => AnimatedContainer(
                        duration: const Duration(milliseconds: 250),
                        curve: Curves.easeOut,
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width: _index == i ? 34 : 12,
                        height: 12,
                        decoration: BoxDecoration(
                          color: _index == i
                              ? AppColors.secondary
                              : AppColors.secondary.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 24, 24, 26),
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          if (_index == _pages.length - 1) {
                            _completeOnboarding();
                          } else {
                            _pageController.nextPage(
                              duration: const Duration(milliseconds: 320),
                              curve: Curves.easeOutCubic,
                            );
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.secondary,
                          foregroundColor: Colors.white,
                          elevation: 2,
                          shadowColor: AppColors.secondary.withValues(
                            alpha: 0.4,
                          ),
                        ),
                        child: Text(
                          _index == _pages.length - 1 ? 'Get Started' : 'Next',
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OnboardingPage extends StatelessWidget {
  const _OnboardingPage({required this.page, required this.index});

  final _OnboardingData page;
  final int index;

  @override
  Widget build(BuildContext context) {
    final card = Container(
      width: 270,
      height: 270,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withValues(alpha: 0.94),
            const Color(0xFFFFFDF6),
          ],
        ),
        borderRadius: BorderRadius.circular(40),
        border: Border.all(color: Colors.white, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12),
            blurRadius: 34,
            offset: const Offset(0, 18),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            left: 20,
            top: 20,
            child: Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.35),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            right: 20,
            top: 20,
            child: Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.86),
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppColors.secondary.withValues(alpha: 0.08),
                ),
              ),
              child: Icon(page.icon, color: AppColors.secondary, size: 26),
            ),
          ),
          Positioned(
            right: 24,
            bottom: 24,
            child: Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: AppColors.secondary.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Center(
            child: page.logoAsset != null
                ? Padding(
                    padding: const EdgeInsets.all(18),
                    child: Image.asset(page.logoAsset!, fit: BoxFit.contain),
                  )
                : Icon(page.icon, size: 126, color: AppColors.secondary),
          ),
        ],
      ),
    );

    return Column(
      children: [
        const Spacer(flex: 2),
        if (index == 0) Hero(tag: 'food-hero', child: card) else card,
        const SizedBox(height: 34),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 280),
          transitionBuilder: (child, animation) {
            return FadeTransition(
              opacity: animation,
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0.08, 0),
                  end: Offset.zero,
                ).animate(animation),
                child: child,
              ),
            );
          },
          child: Text(
            page.title,
            key: ValueKey(page.title),
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              color: AppColors.secondary,
              fontWeight: FontWeight.w800,
              height: 1.28,
            ),
          ),
        ),
        const SizedBox(height: 14),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 2),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.56),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Text(
            page.subtitle,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: AppColors.textPrimary,
              height: 1.5,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        const Spacer(flex: 3),
      ],
    );
  }
}

class _BackOrb extends StatelessWidget {
  const _BackOrb({required this.size, required this.color});

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      ),
    );
  }
}

class _OnboardingData {
  const _OnboardingData({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.bgColor,
    this.logoAsset,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final Color bgColor;
  final String? logoAsset;
}
