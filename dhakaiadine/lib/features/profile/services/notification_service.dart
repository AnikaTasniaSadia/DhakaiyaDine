import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/notification_model.dart';

class NotificationService extends ChangeNotifier {
  NotificationService._() {
    _init();
  }

  static final NotificationService instance = NotificationService._();

  SharedPreferences? _prefs;
  List<NotificationModel> _notifications = [];

  List<NotificationModel> get notifications => _notifications;

  Future<void> _init() async {
    _prefs = await SharedPreferences.getInstance();
    _loadNotifications();
  }

  void _loadNotifications() {
    final listStr = _prefs?.getString('notifications_data');
    if (listStr != null) {
      try {
        final List decoded = json.decode(listStr);
        _notifications = decoded.map((e) => NotificationModel.fromMap(e)).toList();
        return;
      } catch (_) {}
    }

    // Seed default mock notifications
    _notifications = [
      NotificationModel(
        id: 'notif-1',
        title: 'Order Ready!',
        body: 'Your food is ready for pickup. Please collect your order from Counter A.',
        date: DateTime.now().subtract(const Duration(minutes: 15)),
        isRead: false,
        type: 'order',
      ),
      NotificationModel(
        id: 'notif-2',
        title: 'Burger Festival 30% OFF 🍔',
        body: 'Get 30% discount on all premium burgers today! Use code BURGER30.',
        date: DateTime.now().subtract(const Duration(hours: 2)),
        isRead: false,
        type: 'offer',
      ),
      NotificationModel(
        id: 'notif-3',
        title: 'Coupon Received 🎟️',
        body: 'You received a reward coupon worth ৳100. Check your rewards panel.',
        date: DateTime.now().subtract(const Duration(days: 1)),
        isRead: true,
        type: 'coupon',
      ),
      NotificationModel(
        id: 'notif-4',
        title: 'New Branch Opened!',
        body: 'Dhakaia Dine Gulshan branch is now open to serve you better.',
        date: DateTime.now().subtract(const Duration(days: 3)),
        isRead: true,
        type: 'offer',
      ),
    ];
    _saveNotifications();
  }

  Future<void> markAsRead(String id) async {
    final idx = _notifications.indexWhere((element) => element.id == id);
    if (idx != -1) {
      _notifications[idx] = _notifications[idx].copyWith(isRead: true);
      await _saveNotifications();
      notifyListeners();
    }
  }

  Future<void> deleteNotification(String id) async {
    _notifications.removeWhere((element) => element.id == id);
    await _saveNotifications();
    notifyListeners();
  }

  Future<void> clearAll() async {
    _notifications.clear();
    await _saveNotifications();
    notifyListeners();
  }

  Future<void> addNotification(String title, String body, String type) async {
    final notif = NotificationModel(
      id: 'notif-${DateTime.now().millisecondsSinceEpoch}',
      title: title,
      body: body,
      date: DateTime.now(),
      isRead: false,
      type: type,
    );
    _notifications.insert(0, notif);
    await _saveNotifications();
    notifyListeners();
  }

  Future<void> _saveNotifications() async {
    final data = _notifications.map((e) => e.toMap()).toList();
    await _prefs?.setString('notifications_data', json.encode(data));
  }
}
