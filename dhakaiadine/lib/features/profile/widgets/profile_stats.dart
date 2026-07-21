import 'package:flutter/material.dart';

class ProfileStats extends StatelessWidget {
  const ProfileStats({
    super.key,
    required this.orders,
    required this.favorites,
    required this.reviews,
    required this.rewardPoints,
  });

  final int orders;
  final int favorites;
  final int reviews;
  final int rewardPoints;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildStatItem('Orders', orders, Icons.shopping_bag_rounded),
          _buildDivider(),
          _buildStatItem('Favorites', favorites, Icons.favorite_rounded),
          _buildDivider(),
          _buildStatItem('Reviews', reviews, Icons.star_rate_rounded),
          _buildDivider(),
          _buildStatItem('Points', rewardPoints, Icons.card_membership_rounded, isPoints: true),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Container(
      height: 32,
      width: 1,
      color: const Color(0xFFECECEC),
    );
  }

  Widget _buildStatItem(String label, int value, IconData icon, {bool isPoints = false}) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, size: 20, color: const Color(0xFFF4B400)),
          const SizedBox(height: 6),
          TweenAnimationBuilder<double>(
            tween: Tween<double>(begin: 0, end: value.toDouble()),
            duration: const Duration(milliseconds: 800),
            curve: Curves.easeOutCubic,
            builder: (context, val, _) {
              return Text(
                val.toInt().toString(),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF1F2937),
                ),
              );
            },
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: Color(0xFF6B7280),
            ),
          ),
        ],
      ),
    );
  }
}
