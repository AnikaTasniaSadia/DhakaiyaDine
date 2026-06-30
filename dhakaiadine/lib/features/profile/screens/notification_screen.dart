import 'package:flutter/material.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen>
    with SingleTickerProviderStateMixin {
  static const _yellow = Color(0xFFF4B400);
  static const _navy = Color(0xFF1F2937);
  static const _bg = Color(0xFFFAF6EA);

  late final AnimationController _ctrl;
  late final Animation<double> _fade;

  final List<_NotificationItem> _notifications = [
    _NotificationItem(
      title: 'Order Delivered',
      message: 'Your order #DD1234 has been delivered successfully',
      icon: Icons.local_shipping_rounded,
      color: Colors.green,
      time: '2 hours ago',
    ),
    _NotificationItem(
      title: 'Special Offer',
      message: 'Get 20% off on your next order. Use code HUNGRY20',
      icon: Icons.local_offer_rounded,
      color: _yellow,
      time: '5 hours ago',
    ),
    _NotificationItem(
      title: 'Food Ready',
      message: 'Your order is ready for pickup at the counter',
      icon: Icons.done_rounded,
      color: Colors.blue,
      time: '1 day ago',
    ),
    _NotificationItem(
      title: 'New Menu Item',
      message: 'Check out our new special biriyani collection',
      icon: Icons.restaurant_rounded,
      color: Colors.orange,
      time: '2 days ago',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fade = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    _ctrl.forward();
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
      appBar: AppBar(
        title: const Text('Notifications'),
        backgroundColor: _navy,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: FadeTransition(
        opacity: _fade,
        child: ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: _notifications.length,
          itemBuilder: (ctx, i) =>
              _NotificationCard(notification: _notifications[i]),
        ),
      ),
    );
  }
}

class _NotificationItem {
  _NotificationItem({
    required this.title,
    required this.message,
    required this.icon,
    required this.color,
    required this.time,
  });

  final String title;
  final String message;
  final IconData icon;
  final Color color;
  final String time;
}

class _NotificationCard extends StatelessWidget {
  const _NotificationCard({required this.notification});

  final _NotificationItem notification;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: notification.color.withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(notification.icon, color: notification.color, size: 24),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  notification.title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1F2937),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  notification.message,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF7A8599),
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  notification.time,
                  style: const TextStyle(
                    fontSize: 11,
                    color: Color(0xFFBBBBBB),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
