import 'food_model.dart';

class CartItem {
  const CartItem({required this.food, required this.quantity});

  final FoodModel food;
  final int quantity;

  double get unitPrice =>
      food.discountedPrice > 0 ? food.discountedPrice : food.price;

  double get totalPrice => unitPrice * quantity;

  CartItem copyWith({int? quantity}) {
    return CartItem(food: food, quantity: quantity ?? this.quantity);
  }

  Map<String, dynamic> toOrderItemMap(String orderId) {
    return {
      'order_id': orderId,
      'food_id': food.id,
      'name': food.name,
      'image_url': food.imageUrl,
      'unit_price': unitPrice,
      'quantity': quantity,
      'total_price': totalPrice,
    };
  }
}
