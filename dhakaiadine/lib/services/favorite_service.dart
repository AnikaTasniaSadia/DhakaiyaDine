import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/food_model.dart';

class FavoriteService extends ChangeNotifier {
  FavoriteService._() {
    _init();
  }

  static final FavoriteService instance = FavoriteService._();

  SharedPreferences? _prefs;
  List<String> _favorites = [];

  List<String> get favoriteIds => _favorites;

  static const List<FoodModel> allFoods = [
    FoodModel(
      id: 'beef-burger',
      name: 'Beef Smash Burger',
      description: 'Juicy beef patty with caramelized onions, cheddar, and house sauce on a toasted bun.',
      price: 350,
      discountedPrice: 280,
      rating: 4.7,
      deliveryTime: '40 min',
      category: 'Burger',
      imageUrl: 'https://images.unsplash.com/photo-1568901346375-23c9450c58cd?auto=format&fit=crop&w=900&q=80',
    ),
    FoodModel(
      id: 'Chicken burger',
      name: 'Crispy chicken Burger',
      description: 'Crispy chicken with caramelized onions, cheese, tomato and house sauce on a toasted bun.',
      price: 280,
      discountedPrice: 250,
      rating: 4.8,
      deliveryTime: '40 min',
      category: 'Burger',
      imageUrl: 'https://i.ibb.co.com/hRhz9m7b/Burger.jpg',
    ),
    FoodModel(
      id: 'pepperoni-pizza',
      name: 'Pepperoni Pizza',
      description: 'Classic pepperoni pizza with mozzarella, tomato sauce, and crispy edges.',
      price: 1120,
      discountedPrice: 0,
      rating: 4.6,
      deliveryTime: '35 min',
      category: 'Pizza',
      imageUrl: 'https://images.unsplash.com/photo-1513104890138-7c749659a591?auto=format&fit=crop&w=900&q=80',
    ),
    FoodModel(
      id: 'crispy-fries',
      name: 'Crispy French Fries',
      description: 'Golden potato fries with a crunchy bite and a hint of sea salt.',
      price: 150,
      discountedPrice: 135,
      rating: 4.4,
      deliveryTime: '25 min',
      category: 'Fries',
      imageUrl: 'https://images.unsplash.com/photo-1576107232684-1279f390859f?auto=format&fit=crop&w=900&q=80',
    ),
    FoodModel(
      id: 'bbq-platter',
      name: 'BBQ Meat Platter',
      description: 'Smoky BBQ meats served with grilled veggies and a tangy glaze.',
      price: 560,
      discountedPrice: 0,
      rating: 4.8,
      deliveryTime: '50 min',
      category: 'Meat',
      imageUrl: 'https://images.unsplash.com/photo-1544025162-d76694265947?auto=format&fit=crop&w=900&q=80',
    ),
    FoodModel(
      id: 'chinese',
      name: 'Chinese fried rice',
      description: 'Deliciously seasoned fried rice with a mix of vegetables and your choice of protein.',
      price: 310,
      discountedPrice: 60,
      rating: 4.8,
      deliveryTime: '45 min',
      category: 'Chinese',
      imageUrl: 'https://images.unsplash.com/photo-1603133872878-684f208fb84b?w=600&auto=format&fit=crop&q=60&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxzZWFyY2h8Mnx8ZnJpZWQlMjByaWNlfGVufDB8fDB8fHww',
    ),
    FoodModel(
      id: 'pasta',
      name: 'Pasta',
      description: 'Creamy pasta tossed with a rich sauce, herbs, and a savory finish.',
      price: 260,
      discountedPrice: 220,
      rating: 4.5,
      deliveryTime: '35 min',
      category: 'Italian',
      imageUrl: 'https://images.unsplash.com/photo-1621996346565-e3dbc646d9a9?w=600&auto=format&fit=crop&q=60&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxzZWFyY2h8Mnx8cGFzdGF8ZW58MHx8MHx8fDA%3D',
    ),
    FoodModel(
      id: 'shawarma',
      name: 'Shawarma',
      description: 'Warm, spiced shawarma with sliced meat, fresh veggies, and tangy sauce in a soft wrap.',
      price: 220,
      discountedPrice: 0,
      rating: 4.6,
      deliveryTime: '30 min',
      category: 'Wraps',
      imageUrl: 'https://images.unsplash.com/photo-1719282431723-9d0f4370d4bc?w=600&auto=format&fit=crop&q=60&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxzZWFyY2h8MTJ8fHNoYXdhcm1hfGVufDB8fDB8fHww',
    ),
    FoodModel(
      id: 'lemon-iced-tea',
      name: 'Lemon Iced Tea',
      description: 'Refreshing iced tea with lemon and mint served over ice.',
      price: 120,
      discountedPrice: 95,
      rating: 4.5,
      deliveryTime: '15 min',
      category: 'Drinks',
      imageUrl: 'https://images.unsplash.com/photo-1556679343-c7306c1976bc?w=600&auto=format&fit=crop&q=60&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxzZWFyY2h8Mnx8bGVtb24lMjBpY2VkJTIwdGVhfGVufDB8fDB8fHww',
    ),
    FoodModel(
      id: 'mango-juice',
      name: 'Mango Juice',
      description: 'Sweet and chilled mango juice made from ripe mangoes.',
      price: 140,
      discountedPrice: 110,
      rating: 4.6,
      deliveryTime: '12 min',
      category: 'Drinks',
      imageUrl: 'https://images.unsplash.com/photo-1653542773369-51cce8d08250?w=600&auto=format&fit=crop&q=60&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxzZWFyY2h8OHx8bWFuZ28lMjBqdWljZXxlbnwwfHwwfHx8MA%3D%3D',
    ),
    FoodModel(
      id: 'cappuccino',
      name: 'Cappuccino',
      description: 'Rich espresso topped with steamed milk and a silky foam layer.',
      price: 180,
      discountedPrice: 150,
      rating: 4.4,
      deliveryTime: '10 min',
      category: 'Drinks',
      imageUrl: 'https://plus.unsplash.com/premium_photo-1674327105280-b86494dfc690?w=600&auto=format&fit=crop&q=60&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxzZWFyY2h8MXx8Y2FwcHVjaGlub3xlbnwwfHwwfHx8MA%3D%3D',
    ),
    FoodModel(
      id: 'orange-juice',
      name: 'Orange Juice',
      description: 'Fresh orange juice served chilled for a bright and zesty refreshment.',
      price: 130,
      discountedPrice: 105,
      rating: 4.6,
      deliveryTime: '12 min',
      category: 'Drinks',
      imageUrl: 'https://images.unsplash.com/photo-1618046364546-81e9d03d39a6?w=600&auto=format&fit=crop&q=60&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxzZWFyY2h8MTJf/orange-juice',
    ),
  ];

  List<FoodModel> get favoriteFoods {
    return allFoods.where((food) => _favorites.contains(food.id)).toList();
  }

  Future<void> _init() async {
    _prefs = await SharedPreferences.getInstance();
    final listStr = _prefs?.getString('favorites_data');
    if (listStr != null) {
      try {
        _favorites = List<String>.from(json.decode(listStr));
      } catch (_) {}
    }
    notifyListeners();
  }

  Future<void> toggleFavorite(String foodId) async {
    if (_favorites.contains(foodId)) {
      _favorites.remove(foodId);
    } else {
      _favorites.add(foodId);
    }
    await _prefs?.setString('favorites_data', json.encode(_favorites));
    notifyListeners();
  }

  bool isFavorite(String foodId) {
    return _favorites.contains(foodId);
  }
}
