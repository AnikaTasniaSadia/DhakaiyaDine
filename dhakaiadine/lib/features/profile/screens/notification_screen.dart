import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/notification_service.dart';
import '../widgets/notification_tile.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  static const _navy = Color(0xFF1F2937);
  static const _bg = Color(0xFFFAF6EA);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: NotificationService.instance,
      child: Consumer<NotificationService>(
        builder: (context, service, _) {
          final notifications = service.notifications;

          return Scaffold(
            backgroundColor: _bg,
            appBar: AppBar(
              title: const Text('Notifications', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18)),
              backgroundColor: Colors.white,
              foregroundColor: _navy,
              elevation: 0.5,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back_ios_rounded),
                onPressed: () => Navigator.pop(context),
              ),
              actions: [
                if (notifications.isNotEmpty)
                  TextButton(
                    onPressed: () {
                      service.clearAll();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('All notifications cleared')),
                      );
                    },
                    child: const Text(
                      'Clear All',
                      style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.w700),
                    ),
                  ),
              ],
            ),
            body: notifications.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.notifications_none_outlined, size: 72, color: Color(0xFF9CA3AF)),
                        const SizedBox(height: 16),
                        const Text(
                          'No Notifications Yet',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: _navy),
                        ),
                        const SizedBox(height: 6),
                        const Text(
                          'We\'ll notify you when something important happens.',
                          style: TextStyle(fontSize: 13, color: Color(0xFF6B7280)),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    itemCount: notifications.length,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    itemBuilder: (context, index) {
                      final notif = notifications[index];
                      return NotificationTile(
                        notification: notif,
                        onTap: () {
                          service.markAsRead(notif.id);
                        },
                        onDelete: () {
                          service.deleteNotification(notif.id);
                        },
                      );
                    },
                  ),
          );
        },
      ),
    );
  }
}
