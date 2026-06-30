import 'dart:async';

import 'package:flutter/material.dart';

class PromoBanner extends StatefulWidget {
  const PromoBanner({
    super.key,
    required this.onOrderNow,
    required this.imageUrl,
  });

  final VoidCallback onOrderNow;
  final String imageUrl;

  @override
  State<PromoBanner> createState() => _PromoBannerState();
}

class _PromoBannerState extends State<PromoBanner> {
  late final List<String> _images;
  int _currentIndex = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _images = [
      'https://i.ibb.co/hJMSRdtY/food-web-banner-31.jpg',
      'https://i.ibb.co.com/3ycq2PVY/9950673.jpg',
      'https://i.ibb.co.com/KcCRkyYR/18774187-6025059.jpg',
    ];

    _timer = Timer.periodic(const Duration(seconds: 3), (_) {
      if (!mounted) {
        return;
      }
      setState(() {
        _currentIndex = (_currentIndex + 1) % _images.length;
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 180,
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 233, 222, 159),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.12),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 700),
          switchInCurve: Curves.easeOutCubic,
          switchOutCurve: Curves.easeInCubic,
          transitionBuilder: (child, animation) {
            return FadeTransition(
              opacity: animation,
              child: ScaleTransition(
                scale: Tween<double>(begin: 1.15, end: 1.0).animate(
                  CurvedAnimation(
                    parent: animation,
                    curve: Curves.easeOutQuart,
                  ),
                ),
                child: child,
              ),
            );
          },
          child: Image.network(
            _images[_currentIndex],
            key: ValueKey<String>(_images[_currentIndex]),
            fit: BoxFit.cover,
            width: double.infinity,
            height: double.infinity,
            errorBuilder: (context, error, stackTrace) {
              return Container(
                color: Colors.grey[200],
                child: const Center(child: Icon(Icons.broken_image_outlined)),
              );
            },
          ),
        ),
      ),
    );
  }
}
