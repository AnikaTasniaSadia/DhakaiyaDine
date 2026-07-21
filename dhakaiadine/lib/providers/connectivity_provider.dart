import 'dart:async';
import 'package:flutter/material.dart';
import '../services/network_service.dart';
import '../services/order_tracking_service.dart';

class ConnectivityProvider extends ChangeNotifier {
  ConnectivityProvider() {
    _init();
  }

  final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey =
      GlobalKey<ScaffoldMessengerState>();

  bool _isConnected = true;
  bool _continueOffline = false;
  bool _initialized = false;

  bool get isConnected => _isConnected;
  bool get continueOffline => _continueOffline;

  void _init() {
    // Initial check
    NetworkService.instance.checkInternet().then((connected) {
      _isConnected = connected;
      _initialized = true;
      OrderTrackingService.instance.setOffline(!connected);
      notifyListeners();
    });

    // Listen to changes
    NetworkService.instance.onConnectivityChanged.listen((connected) {
      if (!_initialized) {
        _isConnected = connected;
        _initialized = true;
        OrderTrackingService.instance.setOffline(!connected);
        notifyListeners();
        return;
      }

      if (_isConnected != connected) {
        _isConnected = connected;
        OrderTrackingService.instance.setOffline(!connected);
        if (_isConnected) {
          _continueOffline = false;
          _showOnlineSnackBar();
        } else {
          _showOfflineSnackBar();
        }
        notifyListeners();
      }
    });
  }

  void setContinueOffline(bool value) {
    _continueOffline = value;
    notifyListeners();
  }

  Future<void> checkConnection() async {
    final connected = await NetworkService.instance.checkInternet();
    if (_isConnected != connected) {
      _isConnected = connected;
      OrderTrackingService.instance.setOffline(!connected);
      if (_isConnected) {
        _continueOffline = false;
        _showOnlineSnackBar();
      } else {
        _showOfflineSnackBar();
      }
      notifyListeners();
    }
  }

  void _showOfflineSnackBar() {
    scaffoldMessengerKey.currentState?.hideCurrentSnackBar();
    scaffoldMessengerKey.currentState?.showSnackBar(
      SnackBar(
        backgroundColor: const Color(0xFFD32F2F), // Red
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 4),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        content: const Row(
          children: [
            Icon(Icons.wifi_off_rounded, color: Colors.white),
            SizedBox(width: 12),
            Text(
              'No Internet Connection',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showOnlineSnackBar() {
    scaffoldMessengerKey.currentState?.hideCurrentSnackBar();
    scaffoldMessengerKey.currentState?.showSnackBar(
      SnackBar(
        backgroundColor: const Color(0xFF2E7D32), // Green
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        content: const Row(
          children: [
            Icon(Icons.check_circle_rounded, color: Colors.white),
            SizedBox(width: 12),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Back Online',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'Internet connection restored.',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
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
}
