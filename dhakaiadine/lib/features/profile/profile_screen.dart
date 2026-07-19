import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../routes/app_router.dart';
import '../../screens/home/components/bottom_nav_bar.dart';
import '../../services/auth_service.dart';
import 'screens/order_history_screen.dart';
import 'screens/reviews_screen.dart';
import 'screens/saved_addresses_screen.dart';
import 'screens/edit_profile_screen.dart';
import 'screens/notification_screen.dart';
import 'screens/help_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with SingleTickerProviderStateMixin {
  static const _yellow = Color(0xFFF4B400);
  static const _navy = Color(0xFF1F2937);
  static const _bg = Color(0xFFFAF6EA);
  static const _surface = Color(0xFFFFFBF2);

  static const _textPrimary = Color(0xFF1F2937);
  static const _textSecondary = Color(0xFF6B7280);

  late final AnimationController _ctrl;
  late final Animation<double> _fade;
  late final Animation<Offset> _slide;

  Map<String, dynamic>? _profile;
  bool _loading = true;
  int _orders = 0;
  int _favorites = 0;
  int _reviews = 0;
  int _rewardPoints = 0;
  double _totalSpent = 0.0;
  String _membershipLevel = 'Bronze';
  Map<String, dynamic>? _activeOrder;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fade = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    _slide = Tween<Offset>(
      begin: const Offset(0, 0.06),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic));
    _loadData();
  }

  Future<void> _loadData() async {
    final uid = Supabase.instance.client.auth.currentUser?.id;
    if (uid == null) {
      setState(() => _loading = false);
      _ctrl.forward();
      return;
    }
    try {
      final client = Supabase.instance.client;
      final profileData = await AuthService.instance.getUserProfile(uid);
      final ordersRes = await client
          .from('orders')
          .select('id')
          .eq('user_id', uid)
          .count(CountOption.exact);
      final favsRes = await client
          .from('favorites')
          .select('id')
          .eq('user_id', uid)
          .count(CountOption.exact);
      final reviewsRes = await client
          .from('reviews')
          .select('id')
          .eq('user_id', uid)
          .count(CountOption.exact);

      final ordersData = await client
          .from('orders')
          .select('grand_total, status, token_number')
          .eq('user_id', uid)
          .order('created_at', ascending: false);

      double totalAmount = 0.0;
      for (var order in ordersData) {
        totalAmount += (order['grand_total'] as num?)?.toDouble() ?? 0.0;
      }

      Map<String, dynamic>? active;
      for (var order in ordersData) {
        if (order['status'] != 'completed' && order['status'] != 'cancelled') {
          active = order;
          break;
        }
      }

      final memberLevel = _calculateMembership(totalAmount);
      final points = (totalAmount * 10).toInt();

      if (mounted) {
        setState(() {
          _profile = profileData;
          _orders = ordersRes.count;
          _favorites = favsRes.count;
          _reviews = reviewsRes.count;
          _totalSpent = totalAmount;
          _rewardPoints = points;
          _membershipLevel = memberLevel;
          _activeOrder = active;
          _loading = false;
        });
        _ctrl.forward();
      }
    } catch (_) {
      if (mounted) {
        setState(() => _loading = false);
        _ctrl.forward();
      }
    }
  }

  String _calculateMembership(double totalSpent) {
    if (totalSpent >= 50000) return 'Platinum';
    if (totalSpent >= 20000) return 'Gold';
    if (totalSpent >= 10000) return 'Silver';
    return 'Bronze';
  }

  Future<void> _logout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Log Out',
          style: TextStyle(fontWeight: FontWeight.w700, color: _navy),
        ),
        content: const Text('Are you sure you want to log out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel', style: TextStyle(color: _navy)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: _yellow,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text(
              'Log Out',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
    if (confirmed == true && mounted) {
      await AuthService.instance.signOut();
      if (mounted) {
        Navigator.pushNamedAndRemoveUntil(
          context,
          AppRouter.login,
          (_) => false,
        );
      }
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: _yellow))
          : FadeTransition(
              opacity: _fade,
              child: SlideTransition(
                position: _slide,
                child: CustomScrollView(
                  physics: const BouncingScrollPhysics(),
                  slivers: [
                    _buildSliverHeader(),
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 24),
                            _buildRewardCard(),
                            const SizedBox(height: 16),
                            _buildMembershipCard(),
                            const SizedBox(height: 16),
                            _buildStats(),
                            const SizedBox(height: 28),
                            if (_activeOrder != null) ...[
                              _buildActiveOrderCard(),
                              const SizedBox(height: 28),
                            ],
                            _sectionLabel('Quick Actions'),
                            const SizedBox(height: 12),
                            _buildQuickActions(),
                            const SizedBox(height: 28),
                            _sectionLabel('Account'),
                            const SizedBox(height: 12),
                            _buildAccountSection(),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
      bottomNavigationBar: DhakaiaBottomNavBar(
        activeIndex: 3,
        onChanged: (i) {
          if (i == 0) {
            Navigator.pushNamedAndRemoveUntil(
              context,
              AppRouter.home,
              (_) => false,
            );
          } else if (i == 1) {
            Navigator.pushReplacementNamed(context, AppRouter.favorites);
          } else if (i == 2) {
            Navigator.pushReplacementNamed(context, AppRouter.search);
          }
        },
      ),
    );
  }

  // ── Header ────────────────────────────────────────────────────────────────

  Widget _buildSliverHeader() {
    final name = _profile?['name'] as String? ?? 'Sowrav Dey';
    final email =
        _profile?['email'] as String? ??
        Supabase.instance.client.auth.currentUser?.email ??
        '';
    final initials = name.trim().isNotEmpty
        ? name.trim().split(' ').map((w) => w[0]).take(2).join().toUpperCase()
        : 'G';

    return SliverToBoxAdapter(
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.topCenter,
        children: [
          // Navy arc background
          Container(
            height: 210,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF1F2937), Color(0xFF111827)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(40),
                bottomRight: Radius.circular(40),
              ),
            ),
          ),
          // Title
          const Positioned(
            top: 56,
            child: Text(
              'My Profile',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.3,
              ),
            ),
          ),
          // Avatar + name + badge — floats below the arc
          Padding(
            padding: const EdgeInsets.only(top: 120, bottom: 16),
            child: Column(
              children: [
                Container(
                  width: 96,
                  height: 96,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: _yellow, width: 3.5),
                    color: Color(0xFF111827),
                    boxShadow: [
                      BoxShadow(
                        color: _navy.withValues(alpha: 0.35),
                        blurRadius: 18,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      initials,
                      style: const TextStyle(
                        color: _yellow,
                        fontSize: 32,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  name,
                  style: const TextStyle(
                    color: _navy,
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  email,
                  style: const TextStyle(
                    color: Color(0xFF7A8599),
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 10),
                _MemberBadge(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Stats ─────────────────────────────────────────────────────────────────

  Widget _buildStats() {
    return _card(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Row(
          children: [
            _StatItem(label: 'Orders', value: _orders),
            _vDivider(),
            _StatItem(label: 'Favorites', value: _favorites),
            _vDivider(),
            _StatItem(label: 'Reviews', value: _reviews),
          ],
        ),
      ),
    );
  }

  // ── Quick Actions ─────────────────────────────────────────────────────────

  Widget _buildQuickActions() {
    final items = [
      _QuickActionData(
        icon: Icons.receipt_long_rounded,
        label: 'Order History',
        bg: const Color(0xFFFFECB3),
        iconColor: _navy,
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const OrderHistoryScreen()),
        ),
      ),
      _QuickActionData(
        icon: Icons.favorite_rounded,
        label: 'Favorites',
        bg: const Color(0xFFFFE0E0),
        iconColor: Colors.redAccent,
        onTap: () => Navigator.pushNamed(context, AppRouter.favorites),
      ),
      _QuickActionData(
        icon: Icons.star_rounded,
        label: 'Reviews',
        bg: const Color(0xFFE8F5E9),
        iconColor: Colors.green,
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const ReviewsScreen()),
        ),
      ),
      _QuickActionData(
        icon: Icons.location_on_rounded,
        label: 'Saved Addresses',
        bg: const Color(0xFFE3F2FD),
        iconColor: Colors.blue,
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const SavedAddressesScreen()),
        ),
      ),
    ];

    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 1.65,
      children: items.map((d) => _QuickActionCard(data: d)).toList(),
    );
  }

  // ── Account Section ───────────────────────────────────────────────────────

  Widget _buildAccountSection() {
    return _card(
      child: Column(
        children: [
          _AccountTile(
            icon: Icons.edit_rounded,
            label: 'Edit Profile',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const EditProfileScreen()),
            ),
          ),
          _tileDivider(),
          _AccountTile(
            icon: Icons.notifications_rounded,
            label: 'Notifications',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const NotificationScreen()),
            ),
          ),
          _tileDivider(),
          _AccountTile(
            icon: Icons.help_outline_rounded,
            label: 'Help & Support',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const HelpScreen()),
            ),
          ),
          _tileDivider(),
          _AccountTile(
            icon: Icons.logout_rounded,
            label: 'Logout',
            labelColor: Colors.redAccent,
            iconColor: Colors.redAccent,
            onTap: _logout,
            showArrow: false,
          ),
        ],
      ),
    );
  }

  Widget _buildRewardCard() {
    return _card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Row(
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: _yellow.withOpacity(0.15),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.card_giftcard_rounded,
                color: _yellow,
                size: 32,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Reward Points',
                    style: TextStyle(
                      fontSize: 12,
                      color: Color(0xFF7A8599),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '$_rewardPoints Points',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      color: _yellow,
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

  Widget _buildMembershipCard() {
    final colors = {
      'Bronze': const Color(0xFFCD7F32),
      'Silver': const Color(0xFFC0C0C0),
      'Gold': _yellow,
      'Platinum': const Color(0xFFE5E4E2),
    };
    final levelColor = colors[_membershipLevel] ?? const Color(0xFFCD7F32);

    return _card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Row(
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: levelColor.withOpacity(0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.workspace_premium_rounded,
                color: levelColor,
                size: 32,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Membership',
                    style: TextStyle(
                      fontSize: 12,
                      color: Color(0xFF7A8599),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _membershipLevel,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: levelColor,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Total spent: ৳${_totalSpent.toStringAsFixed(0)}',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF7A8599),
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

  Widget _buildActiveOrderCard() {
    if (_activeOrder == null) return const SizedBox.shrink();
    final token = _activeOrder!['token_number'] ?? 'N/A';
    final status = _activeOrder!['status'] ?? 'pending';

    return _card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Active Order',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: _navy,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Token Number',
                      style: TextStyle(fontSize: 11, color: Color(0xFF7A8599)),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      token,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: _yellow,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF22C55E).withOpacity(0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    status.toUpperCase(),
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF22C55E),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: _yellow,
                  foregroundColor: _navy,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onPressed: () {},
                icon: const Icon(Icons.location_on_rounded, size: 18),
                label: const Text(
                  'Track Order',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  Widget _card({required Widget child}) => Container(
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.06),
          blurRadius: 16,
          offset: const Offset(0, 4),
        ),
      ],
    ),
    child: child,
  );

  Widget _sectionLabel(String text) => Text(
    text,
    style: const TextStyle(
      color: _navy,
      fontSize: 16,
      fontWeight: FontWeight.w700,
      letterSpacing: 0.2,
    ),
  );

  Widget _vDivider() =>
      Container(width: 1, height: 40, color: const Color(0xFFE8E0D0));

  Widget _tileDivider() => const Divider(
    height: 1,
    indent: 56,
    endIndent: 20,
    color: Color(0xFFF0EBE0),
  );
}

// ── Reusable sub-widgets ──────────────────────────────────────────────────────

class _MemberBadge extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFFC107), Color(0xFFFFE082)],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFFC107).withValues(alpha: 0.4),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.workspace_premium_rounded,
            size: 14,
            color: Color(0xFF3E4A63),
          ),
          SizedBox(width: 5),
          Text(
            'Gold Member',
            style: TextStyle(
              color: Color(0xFF3E4A63),
              fontSize: 12,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  const _StatItem({required this.label, required this.value});

  final String label;
  final int value;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Text(
            '$value',
            style: const TextStyle(
              color: Color(0xFF3E4A63),
              fontSize: 22,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              color: Color(0xFF7A8599),
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickActionData {
  const _QuickActionData({
    required this.icon,
    required this.label,
    required this.bg,
    required this.iconColor,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final Color bg;
  final Color iconColor;
  final VoidCallback onTap;
}

class _QuickActionCard extends StatelessWidget {
  const _QuickActionCard({required this.data});

  final _QuickActionData data;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: data.onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: data.bg,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(data.icon, color: data.iconColor, size: 20),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                data.label,
                style: const TextStyle(
                  color: Color(0xFF3E4A63),
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AccountTile extends StatelessWidget {
  const _AccountTile({
    required this.icon,
    required this.label,
    required this.onTap,
    this.labelColor,
    this.iconColor,
    this.showArrow = true,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color? labelColor;
  final Color? iconColor;
  final bool showArrow;

  @override
  Widget build(BuildContext context) {
    const yellow = Color(0xFFFFC107);
    const navy = Color(0xFF3E4A63);

    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: const Color(0xFFF8F2E4),
                borderRadius: BorderRadius.circular(11),
              ),
              child: Icon(icon, color: iconColor ?? yellow, size: 20),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  color: labelColor ?? navy,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            if (showArrow)
              const Icon(
                Icons.arrow_forward_ios_rounded,
                size: 14,
                color: Color(0xFFBBBBBB),
              ),
          ],
        ),
      ),
    );
  }
}
