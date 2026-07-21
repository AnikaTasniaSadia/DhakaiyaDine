import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/profile_service.dart';

class RewardScreen extends StatelessWidget {
  const RewardScreen({super.key});

  static const _navy = Color(0xFF1F2937);
  static const _yellow = Color(0xFFF4B400);
  static const _bg = Color(0xFFFAF6EA);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: ProfileService.instance,
      child: Consumer<ProfileService>(
        builder: (context, service, _) {
          final profile = service.profile;
          final points = profile?.rewardPoints ?? 0;
          final level = points >= 500
              ? 'Platinum Member'
              : (points >= 200 ? 'Gold Member' : 'Bronze Member');
          
          final double progress = (points % 500) / 500.0;

          return Scaffold(
            backgroundColor: _bg,
            appBar: AppBar(
              title: const Text('Rewards Panel', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18)),
              backgroundColor: Colors.white,
              foregroundColor: _navy,
              elevation: 0.5,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back_ios_rounded),
                onPressed: () => Navigator.pop(context),
              ),
            ),
            body: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Reward points summary card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [_navy, Color(0xFF374151)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        const Text(
                          'Your Reward Points',
                          style: TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.stars_rounded, color: _yellow, size: 28),
                            const SizedBox(width: 8),
                            Text(
                              points.toString(),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 36,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                          decoration: BoxDecoration(
                            color: _yellow.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            level,
                            style: const TextStyle(
                              color: _yellow,
                              fontWeight: FontWeight.w800,
                              fontSize: 12,
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'Next Level Progress',
                                  style: TextStyle(color: Colors.white60, fontSize: 11, fontWeight: FontWeight.w600),
                                ),
                                Text(
                                  '$points/500 PTS',
                                  style: const TextStyle(color: _yellow, fontSize: 11, fontWeight: FontWeight.w800),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: LinearProgressIndicator(
                                value: progress.clamp(0.0, 1.0),
                                minHeight: 6,
                                backgroundColor: Colors.white24,
                                valueColor: const AlwaysStoppedAnimation<Color>(_yellow),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  const Text(
                    'Active Coupons',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: _navy),
                  ),
                  const SizedBox(height: 12),

                  _buildCouponCard('DD50', '৳50 Off on orders above ৳300', 'Expires: 28 July 2026'),
                  _buildCouponCard('BURGER30', '30% Off on all Burgers', 'Expires: 18 July 2026'),
                  _buildCouponCard('FREE_DEL', 'Free Delivery on any order', 'Expires: 31 July 2026'),

                  const SizedBox(height: 24),

                  const Text(
                    'Achievement Badges',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: _navy),
                  ),
                  const SizedBox(height: 12),

                  GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 3,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 0.9,
                    children: [
                      _buildBadgeCard('First Bite', 'Placed 1st order', Icons.check_circle_rounded, true),
                      _buildBadgeCard('Burger Boss', 'Ordered 5 Burgers', Icons.fastfood_rounded, true),
                      _buildBadgeCard('Dine Specialist', '3 Dine-In bookings', Icons.restaurant_rounded, false),
                      _buildBadgeCard('Review Legend', 'Wrote 3 reviews', Icons.rate_review_rounded, true),
                      _buildBadgeCard('Points Millionaire', 'Earned 500 PTS', Icons.monetization_on_rounded, false),
                      _buildBadgeCard('Local Fanatic', 'Ordered from 3 branches', Icons.storefront_rounded, false),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildCouponCard(String code, String desc, String expiry) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFECECEC)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: _yellow.withOpacity(0.12),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: _yellow, width: 1.5),
            ),
            child: Text(
              code,
              style: const TextStyle(color: _navy, fontWeight: FontWeight.w800, fontSize: 14),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  desc,
                  style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13, color: _navy),
                ),
                const SizedBox(height: 4),
                Text(
                  expiry,
                  style: const TextStyle(fontSize: 11, color: Color(0xFF6B7280), fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBadgeCard(String name, String desc, IconData icon, bool unlocked) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: unlocked ? Colors.white : Colors.white.withOpacity(0.5),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: unlocked ? _yellow.withOpacity(0.4) : const Color(0xFFECECEC),
          width: unlocked ? 1.5 : 1,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 28,
            color: unlocked ? _yellow : const Color(0xFF9CA3AF),
          ),
          const SizedBox(height: 8),
          Text(
            name,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              color: unlocked ? _navy : const Color(0xFF9CA3AF),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            desc,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 9,
              color: Color(0xFF6B7280),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
