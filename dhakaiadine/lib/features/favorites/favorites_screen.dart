import 'package:flutter/material.dart';


class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF8E1),
      appBar: AppBar(title: const Text('Favorites')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.favorite_border_rounded,
                size: 72,
                color: Color(0xFFBDBDBD),
              ),
              const SizedBox(height: 16),
              Text(
                'No favorites yet',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF212121),
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Tap the heart icon to save your favorite dishes.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Color(0xFF757575)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
