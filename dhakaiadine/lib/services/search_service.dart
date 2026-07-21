import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/food_model.dart';
import 'favorite_service.dart'; // To reuse FavoriteService.allFoods

class SearchService extends ChangeNotifier {
  SearchService._() {
    _init();
  }

  static final SearchService instance = SearchService._();

  SharedPreferences? _prefs;
  List<String> _recentSearches = [];
  String _query = '';
  List<FoodModel> _searchResults = [];

  List<String> get recentSearches => _recentSearches;
  String get query => _query;
  List<FoodModel> get searchResults => _searchResults;

  Future<void> _init() async {
    _prefs = await SharedPreferences.getInstance();
    final listStr = _prefs?.getString('recent_searches');
    if (listStr != null) {
      try {
        _recentSearches = List<String>.from(json.decode(listStr));
      } catch (_) {}
    }
    notifyListeners();
  }

  void updateQuery(String newQuery) {
    _query = newQuery;
    _performSearch();
  }

  void _performSearch() {
    if (_query.trim().isEmpty) {
      _searchResults = [];
      notifyListeners();
      return;
    }

    final lowerQuery = _query.toLowerCase();
    _searchResults = FavoriteService.allFoods.where((food) {
      final name = food.name.toLowerCase();
      final category = food.category.toLowerCase();
      final desc = food.description.toLowerCase();
      final priceStr = food.price.toString();
      final discPriceStr = food.discountedPrice.toString();

      return name.contains(lowerQuery) ||
          category.contains(lowerQuery) ||
          desc.contains(lowerQuery) ||
          priceStr.contains(lowerQuery) ||
          discPriceStr.contains(lowerQuery);
    }).toList();

    notifyListeners();
  }

  Future<void> addRecentSearch(String search) async {
    if (search.trim().isEmpty) return;
    
    // Remove if already exists to move it to top
    _recentSearches.remove(search);
    _recentSearches.insert(0, search);

    // Limit to 10 recent searches
    if (_recentSearches.length > 10) {
      _recentSearches = _recentSearches.sublist(0, 10);
    }

    await _prefs?.setString('recent_searches', json.encode(_recentSearches));
    notifyListeners();
  }

  Future<void> removeRecentSearch(String search) async {
    _recentSearches.remove(search);
    await _prefs?.setString('recent_searches', json.encode(_recentSearches));
    notifyListeners();
  }

  Future<void> clearRecentSearches() async {
    _recentSearches.clear();
    await _prefs?.remove('recent_searches');
    notifyListeners();
  }
}
