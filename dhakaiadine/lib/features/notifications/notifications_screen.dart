import 'package:flutter/material.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F2E4),
      appBar: AppBar(
        title: const Text('Notifications'),
        backgroundColor: const Color(0xFFF8F2E4),
        elevation: 0,
        actions: [
          TextButton(
            onPressed: () {},
            child: const Text(
              'Mark all read',
              style: TextStyle(color: Color(0xFFFFC107)),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Recent Updates',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.w700,
                color: const Color(0xFF212121),
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: _dummyNotifications.length,
                itemBuilder: (context, index) {
                  final notification = _dummyNotifications[index];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _NotificationCard(notification: notification),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NotificationCard extends StatelessWidget {
  const _NotificationCard({required this.notification});

  final NotificationItem notification;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: _getIconColor(notification.type).withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            _getIcon(notification.type),
            color: _getIconColor(notification.type),
            size: 24,
          ),
        ),
        title: Text(
          notification.title,
          style: TextStyle(
            fontWeight: notification.isRead ? FontWeight.w500 : FontWeight.w600,
            color: const Color(0xFF212121),
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              notification.message,
              style: const TextStyle(color: Color(0xFF757575)),
            ),
            const SizedBox(height: 8),
            Text(
              notification.time,
              style: const TextStyle(
                color: Color(0xFF757575),
                fontSize: 12,
              ),
            ),
          ],
        ),
        trailing: notification.isRead
            ? null
            : Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: Color(0xFFFFC107),
                  shape: BoxShape.circle,
                ),
              ),
      ),
    );
  }

  IconData _getIcon(String type) {
    switch (type) {
      case 'order':
        return Icons.receipt_long_rounded;
      case 'promotion':
        return Icons.local_offer_rounded;
      case 'delivery':
        return Icons.delivery_dining_rounded;
      default:
        return Icons.notifications_rounded;
    }
  }

  Color _getIconColor(String type) {
    switch (type) {
      case 'order':
        return Colors.green;
      case 'promotion':
        return const Color(0xFFFFC107);
      case 'delivery':
        return Colors.blue;
      default:
        return const Color(0xFF757575);
    }
  }
}

class NotificationItem {
  final String title;
  final String message;
  final String time;
  final String type;
  final bool isRead;

  NotificationItem({
    required this.title,
    required this.message,
    required this.time,
    required this.type,
    this.isRead = false,
  });
}

final List<NotificationItem> _dummyNotifications = [
  NotificationItem(
    title: 'Order Delivered!',
    message: 'Your order #A123 has been successfully delivered.',
    time: '5 minutes ago',
    type: 'delivery',
    isRead: false,
  ),
  NotificationItem(
    title: 'Special Offer',
    message: 'Get 20% off on your next order! Use code SAVE20',
    time: '1 hour ago',
    type: 'promotion',
    isRead: false,
  ),
  NotificationItem(
    title: 'Order Confirmed',
    message: 'Your order #A122 has been confirmed and is being prepared.',
    time: '2 hours ago',
    type: 'order',
    isRead: true,
  ),
  NotificationItem(
    title: 'New Menu Items',
    message: 'Check out our new traditional Bengali dishes!',
    time: '1 day ago',
    type: 'promotion',
    isRead: true,
  ),
];