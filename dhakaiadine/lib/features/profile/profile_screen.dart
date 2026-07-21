import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../routes/app_router.dart';
import '../../services/auth_service.dart';
import 'services/profile_service.dart';
import 'services/notification_service.dart';
import 'screens/reward_screen.dart';
import 'widgets/profile_header.dart';
import 'widgets/profile_stats.dart';
import 'widgets/quick_action_card.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with SingleTickerProviderStateMixin {
  static const _navy = Color(0xFF1F2937);
  static const _yellow = Color(0xFFF4B400);
  static const _bg = Color(0xFFFAF6EA);

  late final AnimationController _ctrl;
  late final Animation<double> _fade;
  late final Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 650),
    )..forward();
    _fade = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    _slide = Tween<Offset>(
      begin: const Offset(0, 0.05),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic));

    // Ensure we trigger a reload of local profile data on load
    ProfileService.instance.loadAll();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _showSettingsBottomSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      backgroundColor: _bg,
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: _navy.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'App Settings',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: _navy),
                ),
                const SizedBox(height: 12),
                ListTile(
                  leading: const Icon(Icons.dark_mode_rounded, color: _yellow),
                  title: const Text('Dark Mode (Coming Soon)', style: TextStyle(fontWeight: FontWeight.w600)),
                  trailing: Switch(
                    value: false,
                    onChanged: (val) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Dark Mode will be available in future releases.')),
                      );
                    },
                    activeThumbColor: _yellow,
                  ),
                  contentPadding: EdgeInsets.zero,
                ),
                const Divider(color: Color(0xFFECECEC)),
                ListTile(
                  leading: const Icon(Icons.language_rounded, color: _yellow),
                  title: const Text('Language', style: TextStyle(fontWeight: FontWeight.w600)),
                  trailing: const Text('English (US)', style: TextStyle(color: Color(0xFF6B7280), fontWeight: FontWeight.bold)),
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('English is the default language.')),
                    );
                  },
                  contentPadding: EdgeInsets.zero,
                ),
                const Divider(color: Color(0xFFECECEC)),
                ListTile(
                  leading: const Icon(Icons.privacy_tip_rounded, color: _yellow),
                  title: const Text('Privacy Policy', style: TextStyle(fontWeight: FontWeight.w600)),
                  onTap: () {
                    Navigator.pop(context);
                    _showInfoDialog('Privacy Policy', 'Your privacy is extremely important to us. Dhakaia Dine secures and handles your data with the highest industry standards. No data is shared with third parties.');
                  },
                  contentPadding: EdgeInsets.zero,
                ),
                const Divider(color: Color(0xFFECECEC)),
                ListTile(
                  leading: const Icon(Icons.description_rounded, color: _yellow),
                  title: const Text('Terms of Service', style: TextStyle(fontWeight: FontWeight.w600)),
                  onTap: () {
                    Navigator.pop(context);
                    _showInfoDialog('Terms of Service', 'Welcome to Dhakaia Dine. By using our application, you agree to comply with our academic/demo use terms. No real currency transactions are processed.');
                  },
                  contentPadding: EdgeInsets.zero,
                ),
                const SizedBox(height: 8),
                const Center(
                  child: Text(
                    'Version 1.0.0 (Demo Mode)',
                    style: TextStyle(color: Color(0xFF9CA3AF), fontSize: 11, fontWeight: FontWeight.w500),
                  ),
                ),
                const SizedBox(height: 12),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showInfoDialog(String title, String details) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: _bg,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text(title, style: const TextStyle(fontWeight: FontWeight.w800, color: _navy)),
          content: Text(details, style: const TextStyle(color: Color(0xFF374151), height: 1.4)),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close', style: TextStyle(color: _navy, fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: ScaleTransition(
            scale: CurvedAnimation(parent: _ctrl, curve: Curves.elasticOut),
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: _bg,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.15),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.redAccent.withOpacity(0.12),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.warning_amber_rounded,
                      color: Colors.redAccent,
                      size: 40,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Logout Confirmation',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: _navy,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Are you sure you want to log out of Dhakaia Dine?',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 13,
                      color: Color(0xFF6B7280),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(context),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: _navy,
                            side: const BorderSide(color: _navy),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                          child: const Text('Cancel', style: TextStyle(fontWeight: FontWeight.w700)),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () async {
                            Navigator.pop(context);
                            await AuthService.instance.signOut();
                            if (mounted) {
                              Navigator.pushNamedAndRemoveUntil(
                                context,
                                AppRouter.login,
                                (route) => false,
                              );
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.redAccent,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                          child: const Text('Logout', style: TextStyle(fontWeight: FontWeight.w800)),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: ProfileService.instance),
        ChangeNotifierProvider.value(value: NotificationService.instance),
      ],
      child: Consumer2<ProfileService, NotificationService>(
        builder: (context, profileService, notificationService, _) {
          final profile = profileService.profile;
          if (profile == null) {
            return const Scaffold(
              backgroundColor: _bg,
              body: Center(child: CircularProgressIndicator(color: _yellow)),
            );
          }

          final unreadCount = notificationService.notifications.where((n) => !n.isRead).length;

          return Scaffold(
            backgroundColor: _bg,
            appBar: AppBar(
              title: const Text(
                'My Profile',
                style: TextStyle(fontWeight: FontWeight.w800, color: Colors.white, fontSize: 18),
              ),
              backgroundColor: _navy,
              elevation: 0,
              centerTitle: true,
              actions: [
                Stack(
                  alignment: Alignment.center,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.notifications_rounded, color: Colors.white),
                      onPressed: () => Navigator.pushNamed(context, AppRouter.notifications),
                    ),
                    if (unreadCount > 0)
                      Positioned(
                        top: 10,
                        right: 10,
                        child: Container(
                          padding: const EdgeInsets.all(2),
                          decoration: const BoxDecoration(
                            color: _yellow,
                            shape: BoxShape.circle,
                          ),
                          constraints: const BoxConstraints(
                            minWidth: 14,
                            minHeight: 14,
                          ),
                          child: Text(
                            unreadCount.toString(),
                            style: const TextStyle(
                              color: _navy,
                              fontSize: 9,
                              fontWeight: FontWeight.w900,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
            body: SlideTransition(
              position: _slide,
              child: FadeTransition(
                opacity: _fade,
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      // Curved curved profile header
                      ProfileHeader(profile: profile),

                      const SizedBox(height: 16),

                      // Statistics Card
                      ProfileStats(
                        orders: profileService.orders.length,
                        favorites: profileService.favorites.length,
                        reviews: profileService.reviews.length,
                        rewardPoints: profile.rewardPoints,
                      ),

                      const SizedBox(height: 16),

                      // Quick action menu cards
                      QuickActionCard(
                        title: 'Edit Profile',
                        subtitle: 'Update your name, phone, birth date & gender',
                        icon: Icons.edit_rounded,
                        onTap: () => Navigator.pushNamed(context, AppRouter.editProfile),
                      ),
                      QuickActionCard(
                        title: 'Order History',
                        subtitle: 'View all your previous completed & pending orders',
                        icon: Icons.receipt_long_rounded,
                        onTap: () => Navigator.pushNamed(context, AppRouter.orderHistory),
                      ),
                      QuickActionCard(
                        title: 'Favorites Panel',
                        subtitle: 'Browse your bookmarked favorite items',
                        icon: Icons.favorite_rounded,
                        onTap: () => Navigator.pushNamed(context, AppRouter.favorites),
                      ),
                      QuickActionCard(
                        title: 'Saved Addresses',
                        subtitle: 'Manage your home, office & other delivery addresses',
                        icon: Icons.location_on_rounded,
                        onTap: () => Navigator.pushNamed(context, AppRouter.savedAddresses),
                      ),
                      QuickActionCard(
                        title: 'Rewards Panel',
                        subtitle: 'Check coupons, reward progress & badges',
                        icon: Icons.card_membership_rounded,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const RewardScreen()),
                          );
                        },
                      ),
                      QuickActionCard(
                        title: 'Reviews & Feedback',
                        subtitle: 'Share your dining feedback and see community reviews',
                        icon: Icons.rate_review_rounded,
                        onTap: () => Navigator.pushNamed(context, AppRouter.reviews),
                      ),
                      QuickActionCard(
                        title: 'App Settings',
                        subtitle: 'Control language preferences, dark mode & policies',
                        icon: Icons.settings_rounded,
                        onTap: _showSettingsBottomSheet,
                      ),
                      QuickActionCard(
                        title: 'Help & Customer Support',
                        subtitle: 'Find FAQs, contact channels & file tickets',
                        icon: Icons.help_outline_rounded,
                        onTap: () => Navigator.pushNamed(context, AppRouter.help),
                      ),
                      QuickActionCard(
                        title: 'Logout',
                        subtitle: 'Securely sign out of your account session',
                        icon: Icons.logout_rounded,
                        onTap: _showLogoutDialog,
                      ),

                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
