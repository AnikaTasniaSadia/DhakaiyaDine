import 'food_model.dart';

class CartItem {
  const CartItem({
    required this.food,
    required this.quantity,
    this.note,
  });

  final FoodModel food;
  final int quantity;
  final String? note;

  double get unitPrice =>
      food.discountedPrice > 0 ? food.discountedPrice : food.price;

  double get totalPrice => unitPrice * quantity;

  CartItem copyWith({int? quantity, String? note}) {
    return CartItem(
      food: food,
      quantity: quantity ?? this.quantity,
      note: note ?? this.note,
    );
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
      'note': note,
    };
  }

  Map<String, dynamic> toJson() {
    return {
      'food': food.toJson(),
      'quantity': quantity,
      'note': note,
    };
  }

  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
      food: FoodModel.fromJson(json['food'] as Map<String, dynamic>),
      quantity: json['quantity'] as int,
      note: json['note'] as String?,
    );
  }
}
