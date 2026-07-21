import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/cart_model.dart';
import '../models/food_model.dart';

class CartService extends ChangeNotifier {
  CartService() {
    _init();
  }

  static const double deliveryFee = 40;
  static const String _cartKey = 'dhakaiadine_cart_items';
  SharedPreferences? _prefs;

  final Map<String, CartItem> _items = {};

  List<CartItem> get items => _items.values.toList(growable: false);

  int get itemCount => _items.length;

  double get subtotal =>
      _items.values.fold(0, (sum, item) => sum + item.totalPrice);

  double get grandTotal => subtotal + (items.isEmpty ? 0 : deliveryFee);

  int get totalItems =>
      _items.values.fold(0, (sum, item) => sum + item.quantity);

  Future<void> _init() async {
    _prefs = await SharedPreferences.getInstance();
    _loadFromPrefs();
  }

  void _loadFromPrefs() {
    if (_prefs == null) return;
    final cartData = _prefs!.getString(_cartKey);
    if (cartData != null) {
      try {
        final List<dynamic> decodedList = json.decode(cartData) as List<dynamic>;
        _items.clear();
        for (final item in decodedList) {
          final cartItem = CartItem.fromJson(item as Map<String, dynamic>);
          _items[cartItem.food.id] = cartItem;
        }
        notifyListeners();
      } catch (e) {
        debugPrint('Error loading cart from SharedPreferences: $e');
      }
    }
  }

  Future<void> _saveToPrefs() async {
    if (_prefs == null) return;
    final List<Map<String, dynamic>> itemsList = _items.values
        .map((item) => item.toJson())
        .toList();
    await _prefs!.setString(_cartKey, json.encode(itemsList));
  }

  int getQuantity(String foodId) => _items[foodId]?.quantity ?? 0;

  bool isInCart(String foodId) => _items.containsKey(foodId);

  CartItem? getCartItem(String foodId) => _items[foodId];

  void addItem(FoodModel food, {int quantity = 1, String? note}) {
    final existing = _items[food.id];
    if (existing != null) {
      _items[food.id] = existing.copyWith(
        quantity: existing.quantity + quantity,
        note: note ?? existing.note,
      );
    } else {
      _items[food.id] = CartItem(food: food, quantity: quantity, note: note);
    }
    _saveToPrefs();
    notifyListeners();
  }

  void updateQuantity(String foodId, int quantity) {
    if (!_items.containsKey(foodId)) return;
    if (quantity <= 0) {
      _items.remove(foodId);
    } else {
      _items[foodId] = _items[foodId]!.copyWith(quantity: quantity);
    }
    _saveToPrefs();
    notifyListeners();
  }

  void removeItem(String foodId) {
    _items.remove(foodId);
    _saveToPrefs();
    notifyListeners();
  }

  void clear() {
    _items.clear();
    _saveToPrefs();
    notifyListeners();
  }
}
