class FoodModel {
  const FoodModel({
    required this.id,
    required this.name,
    required this.description,
    required this.imageUrl,
    required this.price,
    required this.discountedPrice,
    required this.rating,
    required this.deliveryTime,
    required this.category,
  });

  final String id;
  final String name;
  final String description;
  final String imageUrl;
  final double price;
  final double discountedPrice;
  final double rating;
  final String deliveryTime;
  final String category;

  factory FoodModel.fromMap(Map<String, dynamic> map) {
    return FoodModel(
      id: map['id']?.toString() ?? '',
      name: map['name']?.toString() ?? '',
      description: map['description']?.toString() ?? '',
      imageUrl: map['image_url']?.toString() ?? '',
      price: (map['price'] as num?)?.toDouble() ?? 0,
      discountedPrice: (map['discounted_price'] as num?)?.toDouble() ?? 0,
      rating: (map['rating'] as num?)?.toDouble() ?? 0,
      deliveryTime: map['delivery_time']?.toString() ?? '',
      category: map['category']?.toString() ?? '',
    );
  }
}
