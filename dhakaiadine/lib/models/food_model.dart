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

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'imageUrl': imageUrl,
      'price': price,
      'discountedPrice': discountedPrice,
      'rating': rating,
      'deliveryTime': deliveryTime,
      'category': category,
    };
  }

  factory FoodModel.fromJson(Map<String, dynamic> json) {
    return FoodModel(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      imageUrl: json['imageUrl'] as String,
      price: (json['price'] as num).toDouble(),
      discountedPrice: (json['discountedPrice'] as num).toDouble(),
      rating: (json['rating'] as num).toDouble(),
      deliveryTime: json['deliveryTime'] as String,
      category: json['category'] as String,
    );
  }
}
