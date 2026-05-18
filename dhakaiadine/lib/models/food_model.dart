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
}
