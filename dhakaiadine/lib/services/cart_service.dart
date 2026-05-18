import 'package:flutter/foundation.dart';

import '../models/cart_model.dart';
import '../models/food_model.dart';

class CartService extends ChangeNotifier {
  static const double deliveryFee = 40;

  final Map<String, CartItem> _items = {};

  List<CartItem> get items => _items.values.toList(growable: false);

  int get itemCount => _items.length;

  double get subtotal =>
      _items.values.fold(0, (sum, item) => sum + item.totalPrice);

  double get grandTotal => subtotal + (items.isEmpty ? 0 : deliveryFee);

  int get totalItems =>
      _items.values.fold(0, (sum, item) => sum + item.quantity);

  void addItem(FoodModel food, {int quantity = 1}) {
    final existing = _items[food.id];
    if (existing != null) {
      _items[food.id] = existing.copyWith(
        quantity: existing.quantity + quantity,
      );
    } else {
      _items[food.id] = CartItem(food: food, quantity: quantity);
    }
    notifyListeners();
  }

  void updateQuantity(String foodId, int quantity) {
    if (!_items.containsKey(foodId)) return;
    if (quantity <= 0) {
      _items.remove(foodId);
    } else {
      _items[foodId] = _items[foodId]!.copyWith(quantity: quantity);
    }
    notifyListeners();
  }

  void removeItem(String foodId) {
    _items.remove(foodId);
    notifyListeners();
  }

  void clear() {
    _items.clear();
    notifyListeners();
  }
}
