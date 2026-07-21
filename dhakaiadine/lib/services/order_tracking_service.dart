import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OrderTrackingService extends ChangeNotifier {
  OrderTrackingService._() {
    _init();
  }

  static final OrderTrackingService instance = OrderTrackingService._();

  SharedPreferences? _prefs;
  Timer? _simulationTimer;

  // Active tracking state
  String? _activeOrderId;
  String? _activeToken;
  String _activeStatus = 'received';
  int _secondsElapsed = 0;
  double _amount = 0.0;
  String _paymentMethod = 'COD';
  String _orderType = 'Delivery';
  String? _tableNumber;
  bool _dialogShown = false;
  bool _isOffline = false;

  // Getters
  String? get activeOrderId => _activeOrderId;
  String? get activeToken => _activeToken;
  String get activeStatus => _activeStatus;
  int get secondsElapsed => _secondsElapsed;
  double get amount => _amount;
  String get paymentMethod => _paymentMethod;
  String get orderType => _orderType;
  String? get tableNumber => _tableNumber;
  bool get isActive => _activeOrderId != null;
  bool get dialogShown => _dialogShown;
  bool get isOffline => _isOffline;

  void setOffline(bool offline) {
    if (_isOffline == offline) return;
    _isOffline = offline;
    if (_isOffline) {
      _simulationTimer?.cancel();
    } else {
      if (isActive && _activeStatus != 'collected/delivered') {
        _resumeSimulation();
      }
    }
    notifyListeners();
  }

  set dialogShown(bool val) {
    _dialogShown = val;
    _saveState();
    notifyListeners();
  }

  Future<void> _init() async {
    _prefs = await SharedPreferences.getInstance();
    _loadState();
  }

  void _loadState() {
    final hasActive = _prefs?.getBool('track_is_active') ?? false;
    if (hasActive) {
      _activeOrderId = _prefs?.getString('track_order_id');
      _activeToken = _prefs?.getString('track_token');
      _activeStatus = _prefs?.getString('track_status') ?? 'received';
      _secondsElapsed = _prefs?.getInt('track_elapsed') ?? 0;
      _amount = _prefs?.getDouble('track_amount') ?? 0.0;
      _paymentMethod = _prefs?.getString('track_payment') ?? 'COD';
      _orderType = _prefs?.getString('track_type') ?? 'Delivery';
      _tableNumber = _prefs?.getString('track_table');
      _dialogShown = _prefs?.getBool('track_dialog_shown') ?? false;

      // Resume simulation if it's not fully collected
      if (_activeStatus != 'collected/delivered') {
        _resumeSimulation();
      }
    }
  }

  void _saveState() {
    _prefs?.setBool('track_is_active', isActive);
    if (isActive) {
      _prefs?.setString('track_order_id', _activeOrderId!);
      _prefs?.setString('track_token', _activeToken!);
      _prefs?.setString('track_status', _activeStatus);
      _prefs?.setInt('track_elapsed', _secondsElapsed);
      _prefs?.setDouble('track_amount', _amount);
      _prefs?.setString('track_payment', _paymentMethod);
      _prefs?.setString('track_type', _orderType);
      if (_tableNumber != null) {
        _prefs?.setString('track_table', _tableNumber!);
      } else {
        _prefs?.remove('track_table');
      }
      _prefs?.setBool('track_dialog_shown', _dialogShown);
    } else {
      _prefs?.remove('track_order_id');
      _prefs?.remove('track_token');
      _prefs?.remove('track_status');
      _prefs?.remove('track_elapsed');
      _prefs?.remove('track_amount');
      _prefs?.remove('track_payment');
      _prefs?.remove('track_type');
      _prefs?.remove('track_table');
      _prefs?.remove('track_dialog_shown');
    }
  }

  void startTracking({
    required String orderId,
    required String token,
    required double amount,
    required String paymentMethod,
    required String orderType,
    String? tableNumber,
  }) {
    _simulationTimer?.cancel();
    _activeOrderId = orderId;
    _activeToken = token;
    _activeStatus = 'received';
    _secondsElapsed = 0;
    _amount = amount;
    _paymentMethod = paymentMethod;
    _orderType = orderType;
    _tableNumber = tableNumber;
    _dialogShown = false;

    _saveState();
    notifyListeners();
    _resumeSimulation();
  }

  void _resumeSimulation() {
    if (_isOffline) return;
    _simulationTimer?.cancel();
    _simulationTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_isOffline) {
        timer.cancel();
        return;
      }
      if (_activeOrderId == null || _activeStatus == 'collected/delivered') {
        timer.cancel();
        return;
      }

      _secondsElapsed++;

      // Automatically transition status based on seconds elapsed
      final oldStatus = _activeStatus;
      if (_secondsElapsed >= 120) {
        _activeStatus = 'collected/delivered';
        timer.cancel();
      } else if (_secondsElapsed >= 100) {
        _activeStatus = 'ready/On delivery';
      } else if (_secondsElapsed >= 70) {
        _activeStatus = 'cooking';
      } else if (_secondsElapsed >= 40) {
        _activeStatus = 'preparing';
      } else if (_secondsElapsed >= 20) {
        _activeStatus = 'accepted';
      } else {
        _activeStatus = 'received';
      }

      if (oldStatus != _activeStatus) {
        // Status updated
        _saveState();
      }

      notifyListeners();
    });
  }

  void collectFood() {
    _activeStatus = 'collected/delivered';
    _simulationTimer?.cancel();
    _saveState();
    notifyListeners();
  }

  void clearTracking() {
    _simulationTimer?.cancel();
    _activeOrderId = null;
    _activeToken = null;
    _activeStatus = 'received';
    _secondsElapsed = 0;
    _dialogShown = false;
    _saveState();
    notifyListeners();
  }
}
