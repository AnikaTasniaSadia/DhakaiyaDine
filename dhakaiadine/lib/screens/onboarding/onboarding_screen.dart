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
    return Scaffold(
      body: AnimatedContainer(
        duration: const Duration(milliseconds: 350),
        color: _pages[_index].bgColor,
        child: SafeArea(
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
                    const SizedBox(width: 56),
                    Text(
                      '${_index + 1}/3',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: AppColors.secondary,
                      ),
                    ),
                    TextButton(
                      onPressed: _completeOnboarding,
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
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: _index == i ? 30 : 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: _index == i ? AppColors.secondary : Colors.black26,
                      borderRadius: BorderRadius.circular(20),
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
                    child: Text(
                      _index == _pages.length - 1 ? 'Get Started' : 'Next',
                    ),
                  ),
                ),
              ),
            ],
          ),
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
      width: 250,
      height: 250,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFFFFDF6), Color(0xFFFFFFFF)],
        ),
        borderRadius: BorderRadius.circular(36),
        border: Border.all(color: Colors.white, width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.14),
            blurRadius: 30,
            offset: const Offset(0, 16),
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
            right: 28,
            bottom: 24,
            child: Container(
              width: 22,
              height: 22,
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
        const Spacer(),
        if (index == 0) Hero(tag: 'food-hero', child: card) else card,
        const SizedBox(height: 42),
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
            style: Theme.of(
              context,
            ).textTheme.headlineMedium?.copyWith(color: AppColors.secondary),
          ),
        ),
        const SizedBox(height: 10),
        Text(
          page.subtitle,
          textAlign: TextAlign.center,
          style: Theme.of(
            context,
          ).textTheme.bodyLarge?.copyWith(color: AppColors.textPrimary),
        ),
        const Spacer(),
      ],
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
