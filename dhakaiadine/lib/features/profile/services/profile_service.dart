import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../services/auth_service.dart';
import '../models/profile_model.dart';
import '../models/review_model.dart';

class ProfileService extends ChangeNotifier {
  ProfileService._() {
    _init();
  }

  static final ProfileService instance = ProfileService._();

  SharedPreferences? _prefs;
  ProfileModel? _profile;
  List<ReviewModel> _reviews = [];
  List<Map<String, dynamic>> _addresses = [];
  List<String> _favorites = []; // List of food ids
  List<Map<String, dynamic>> _orders = []; // Local order history

  ProfileModel? get profile => _profile;
  List<ReviewModel> get reviews => _reviews;
  List<Map<String, dynamic>> get addresses => _addresses;
  List<String> get favorites => _favorites;
  List<Map<String, dynamic>> get orders => _orders;

  Future<void> _init() async {
    _prefs = await SharedPreferences.getInstance();
    await loadAll();
  }

  Future<void> loadAll() async {
    _prefs ??= await SharedPreferences.getInstance();
    
    _loadProfile();
    _loadReviews();
    _loadAddresses();
    _loadFavorites();
    _loadOrders();
    notifyListeners();
  }

  // ── USER PROFILE ─────────────────────────────────────────────────────────
  void _loadProfile() {
    final uid = AuthService.instance.currentUserId ?? 'guest-uid';
    final email = AuthService.instance.currentUserEmail ?? 'guest@gmail.com';
    final dataStr = _prefs?.getString('profile_$uid');
    
    if (dataStr != null) {
      try {
        _profile = ProfileModel.fromMap(json.decode(dataStr));
        return;
      } catch (_) {}
    }

    // Default template
    final names = email.split('@').first;
    final capitalized = names.isNotEmpty
        ? names[0].toUpperCase() + names.substring(1)
        : 'User';

    _profile = ProfileModel(
      id: uid,
      name: capitalized,
      email: email,
      phone: '01700000000',
      membershipBadge: 'Gold Member',
      joinDate: 'July 2026',
      rewardPoints: 320,
      profileCompletion: 0.8,
    );
  }

  Future<void> updateProfile({
    required String name,
    required String phone,
    String? dob,
    String? gender,
    String? address,
    String? avatarUrl,
  }) async {
    if (_profile == null) return;
    
    // Calculate profile completion
    double completion = 0.4; // name + email
    if (phone.trim().isNotEmpty) completion += 0.15;
    if (dob != null && dob.trim().isNotEmpty) completion += 0.15;
    if (gender != null && gender.trim().isNotEmpty) completion += 0.15;
    if (address != null && address.trim().isNotEmpty) completion += 0.15;

    _profile = _profile!.copyWith(
      name: name,
      phone: phone,
      dob: dob,
      gender: gender,
      address: address,
      avatarUrl: avatarUrl,
      profileCompletion: completion,
    );

    final uid = AuthService.instance.currentUserId ?? 'guest-uid';
    await _prefs?.setString('profile_$uid', json.encode(_profile!.toMap()));

    // Also update Supabase database as best effort
    try {
      if (uid != 'guest-uid' && !uid.startsWith('local-')) {
        await Supabase.instance.client.from('users').update({
          'name': name.trim(),
          'phone': phone.trim(),
        }).eq('id', uid);
      }
    } catch (e) {
      debugPrint('⚠️ Supabase profile update failed: $e');
    }

    notifyListeners();
  }

  // ── REVIEWS ──────────────────────────────────────────────────────────────
  void _loadReviews() {
    final listStr = _prefs?.getString('reviews_data');
    if (listStr != null) {
      try {
        final List decoded = json.decode(listStr);
        _reviews = decoded.map((e) => ReviewModel.fromMap(e)).toList();
        return;
      } catch (_) {}
    }

    // Default Seed reviews matching user prompt exactly
    final seedReviews = [
      _review('Saad Al Kayser', 'বার্গারটা খেয়ে মনে হলো ডায়েট কাল থেকে শুরু করব! 😆🍔'),
      _review('MD. Akram Hossain', 'পিজ্জার শেষ স্লাইস নিয়ে বন্ধুর সাথে সম্পর্ক প্রায় শেষ হয়ে যাচ্ছিল! 🍕😂'),
      _review('Abdur Rab Dhruba', 'স্বাদের কারণে প্লেট খালি, পকেট না! দামও একদম ঠিকঠাক। 💯'),
      _review('Abdullah Masud', 'পরিবেশ এত সুন্দর যে খাওয়ার আগে ২০টা ছবি তুলতেই হলো! 📸✨'),
      _review('Masud Rana', 'একবার খেলে আবার আসতেই হবে—এটা মনে হয় খাবারের গোপন জাদু! 🤩'),
      _review('Nafis Ahmed', 'চিকেনটা এত জুসি ছিল, প্লেটটাও পরিষ্কার করে ফেলেছি! 🍗😋'),
      _review('Rakib Hasan', 'ফ্রাইগুলো এত মজার ছিল, গুনে গুনে খাওয়ার প্ল্যান এক মিনিটও টিকেনি! 🍟🤣'),
      _review('Tanvir Hossain', 'খাবার দেখে ডায়েট পালিয়ে গেছে, আমিও ওকে আর খুঁজিনি! 😂'),
      _review('Mahmudul Hasan', 'এখানে এসে বুঝলাম \'আরেকটা অর্ডার করি?\' একটা স্বাভাবিক অনুভূতি! 😄🍴'),
      _review('Sabbir Ahmed', 'চিজ এত ছিল যে টানতে টানতে ভিডিও বানিয়ে ফেললাম! 🧀📹'),
      _review('Arafat Rahman', 'খাবার এত ভালো যে বিল আসার আগেই আবার কী খাব ভাবছিলাম! 😆'),
      _review('Rahat Islam', 'পরিবার নিয়ে এসেছিলাম, সবাই নিজের প্লেট লুকিয়ে খাচ্ছিল! 😂🍽️'),
      _review('Imran Hossain', 'এখানকার খাবার খেলে মন ভালো হওয়া একদম ফ্রি! ❤️'),
      _review('Siam Ahmed', 'এত সুস্বাদু ছিল যে শেষ কামড়টা খেয়ে একটু আবেগপ্রবণ হয়ে গিয়েছিলাম! 🥹🍔'),
    ];

    _reviews = seedReviews;
    _saveReviews();
  }

  ReviewModel _review(String name, String comment) {
    return ReviewModel(
      id: 'rev-${DateTime.now().millisecondsSinceEpoch}-${name.hashCode.abs()}',
      userName: name,
      rating: 5.0,
      comment: comment,
      date: DateTime.now().subtract(const Duration(days: 2)),
    );
  }

  Future<void> addReview({required String userName, required double rating, required String comment}) async {
    final rev = ReviewModel(
      id: 'rev-${DateTime.now().millisecondsSinceEpoch}',
      userName: userName,
      rating: rating,
      comment: comment,
      date: DateTime.now(),
    );
    _reviews.insert(0, rev);
    await _saveReviews();

    // Reward points for leaving review
    if (_profile != null) {
      _profile = _profile!.copyWith(rewardPoints: _profile!.rewardPoints + 20);
      final uid = AuthService.instance.currentUserId ?? 'guest-uid';
      await _prefs?.setString('profile_$uid', json.encode(_profile!.toMap()));
    }

    notifyListeners();
  }

  Future<void> _saveReviews() async {
    final data = _reviews.map((e) => e.toMap()).toList();
    await _prefs?.setString('reviews_data', json.encode(data));
  }

  // ── SAVED ADDRESSES ──────────────────────────────────────────────────────
  void _loadAddresses() {
    final listStr = _prefs?.getString('addresses_data');
    if (listStr != null) {
      try {
        _addresses = List<Map<String, dynamic>>.from(json.decode(listStr));
        return;
      } catch (_) {}
    }

    // Default Seed addresses
    _addresses = [
      {'id': 'addr-1', 'label': 'Home', 'details': 'House 42, Road 11, Dhanmondi, Dhaka', 'type': 'home'},
      {'id': 'addr-2', 'label': 'Office', 'details': 'Level 6, Labaid Tower, Gulshan 2, Dhaka', 'type': 'office'},
    ];
    _saveAddresses();
  }

  Future<void> addAddress(String label, String details, String type) async {
    final id = 'addr-${DateTime.now().millisecondsSinceEpoch}';
    _addresses.add({'id': id, 'label': label, 'details': details, 'type': type});
    await _saveAddresses();
    notifyListeners();
  }

  Future<void> deleteAddress(String id) async {
    _addresses.removeWhere((element) => element['id'] == id);
    await _saveAddresses();
    notifyListeners();
  }

  Future<void> editAddress(String id, String label, String details, String type) async {
    final idx = _addresses.indexWhere((element) => element['id'] == id);
    if (idx != -1) {
      _addresses[idx] = {'id': id, 'label': label, 'details': details, 'type': type};
      await _saveAddresses();
      notifyListeners();
    }
  }

  Future<void> _saveAddresses() async {
    await _prefs?.setString('addresses_data', json.encode(_addresses));
  }

  // ── FAVORITES ────────────────────────────────────────────────────────────
  void _loadFavorites() {
    final listStr = _prefs?.getString('favorites_data');
    if (listStr != null) {
      try {
        _favorites = List<String>.from(json.decode(listStr));
        return;
      } catch (_) {}
    }
    _favorites = [];
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

  // ── ORDERS ───────────────────────────────────────────────────────────────
  void _loadOrders() {
    final listStr = _prefs?.getString('orders_data');
    if (listStr != null) {
      try {
        _orders = List<Map<String, dynamic>>.from(json.decode(listStr));
        return;
      } catch (_) {}
    }

    // Default Seed orders
    _orders = [
      {
        'id': 'ord-102',
        'food_name': 'Chicken Burger',
        'food_image': 'assets/logo.png',
        'quantity': 2,
        'order_date': DateTime.now().subtract(const Duration(days: 3)).toIso8601String(),
        'branch': 'Dhanmondi',
        'payment_method': 'bKash',
        'amount': 320.0,
        'status': 'completed',
        'token_number': 'DD1024',
      },
      {
        'id': 'ord-103',
        'food_name': 'Cheese Pizza',
        'food_image': 'assets/logo.png',
        'quantity': 1,
        'order_date': DateTime.now().subtract(const Duration(days: 5)).toIso8601String(),
        'branch': 'Gulshan',
        'payment_method': 'card',
        'amount': 520.0,
        'status': 'completed',
        'token_number': 'DD1025',
      },
    ];
    _saveOrders();
  }

  Future<void> addOrder(Map<String, dynamic> order) async {
    _orders.insert(0, order);
    await _saveOrders();
    notifyListeners();
  }

  Future<void> _saveOrders() async {
    await _prefs?.setString('orders_data', json.encode(_orders));
  }
}
