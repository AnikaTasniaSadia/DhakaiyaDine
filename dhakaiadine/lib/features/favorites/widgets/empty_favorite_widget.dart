import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';

import '../../../models/food_model.dart';
import '../../../routes/app_router.dart';
import '../../../services/favorite_service.dart';
import '../../../widgets/add_to_cart_sheet.dart';

class EmptyFavoriteWidget extends StatefulWidget {
  const EmptyFavoriteWidget({super.key});

  @override
  State<EmptyFavoriteWidget> createState() => _EmptyFavoriteWidgetState();
}

class _EmptyFavoriteWidgetState extends State<EmptyFavoriteWidget>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fade;

  static const _navy = Color(0xFF1F2937);
  static const _yellow = Color(0xFFF4B400);

  // Reusing popular foods from FavoriteService static data.
  final List<FoodModel> _popularFoods = [
    FoodModel(
      id: 'crispy-chicken-burger',
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
  ];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..forward();
    _fade = CurvedAnimation(parent: _controller, curve: Curves.easeOut);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fade,
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Column(
          children: [
            Lottie.asset(
              'assets/newanimation/Hungry.json',
              width: 260,
              height: 260,
              repeat: true,
              fit: BoxFit.contain,
            ),
            const SizedBox(height: 12),
            const Text(
              'No Favorite Foods Yet',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: _navy,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Your favorite meals will appear here.\nTap the ❤️ icon on any food item to save it for quick access later.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 32),
            
            // Suggestion Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 16,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Why add favorites?',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: _navy,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildBenefitItem('❤️', 'Quickly reorder your favorite meals'),
                  const SizedBox(height: 12),
                  _buildBenefitItem('🍔', 'Access your favorite foods anytime'),
                  const SizedBox(height: 12),
                  _buildBenefitItem('⭐', 'Save today\'s special offers'),
                  const SizedBox(height: 12),
                  _buildBenefitItem('🎉', 'Never lose your favorite dishes'),
                ],
              ),
            ),
            const SizedBox(height: 32),
            
            // Popular Foods Section
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Popular Choices',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: _navy,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 250,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                itemCount: _popularFoods.length,
                clipBehavior: Clip.none,
                itemBuilder: (context, index) {
                  return _buildPopularFoodCard(context, _popularFoods[index]);
                },
              ),
            ),
            const SizedBox(height: 32),
            
            // Buttons
            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pushNamedAndRemoveUntil(context, AppRouter.home, (route) => false);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: _yellow,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  'Explore Menu',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 54,
              child: OutlinedButton(
                onPressed: () {
                  Navigator.pushNamedAndRemoveUntil(context, AppRouter.home, (route) => false);
                },
                style: OutlinedButton.styleFrom(
                  foregroundColor: _navy,
                  side: const BorderSide(color: _navy, width: 1.5),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: const Text(
                  'Today\'s Special',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            const SizedBox(height: 32),
            
            // Tip Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: _yellow.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Row(
                children: [
                  Text('💡', style: TextStyle(fontSize: 24)),
                  SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      'Tip: Tap the heart icon on any food to save it here for quick ordering later.',
                      style: TextStyle(
                        fontSize: 13,
                        color: _navy,
                        height: 1.4,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildBenefitItem(String emoji, String text) {
    return Row(
      children: [
        Text(emoji, style: const TextStyle(fontSize: 18)),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF4B5563),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPopularFoodCard(BuildContext context, FoodModel food) {
    final price = food.discountedPrice > 0 ? food.discountedPrice : food.price;
    final favoriteService = context.watch<FavoriteService>();
    final isFavorite = favoriteService.isFavorite(food.id);

    return Container(
      width: 170,
      margin: const EdgeInsets.only(right: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Food Image overlay
            Expanded(
              flex: 4,
              child: Stack(
                children: [
                  Positioned.fill(
                    child: Image.network(
                      food.imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: const Color(0xFFFAF6EA),
                          child: const Icon(Icons.restaurant_rounded, color: _yellow, size: 40),
                        );
                      },
                    ),
                  ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: GestureDetector(
                      onTap: () {
                        favoriteService.toggleFavorite(food.id);
                      },
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                        child: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 300),
                          transitionBuilder: (child, anim) => ScaleTransition(scale: anim, child: child),
                          child: Icon(
                            isFavorite ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                            key: ValueKey(isFavorite),
                            color: isFavorite ? Colors.redAccent : Colors.grey.shade400,
                            size: 16,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Food Details
            Expanded(
              flex: 4,
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          food.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 13,
                            color: _navy,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '৳${price.toStringAsFixed(0)}',
                              style: const TextStyle(
                                fontWeight: FontWeight.w900,
                                fontSize: 13,
                                color: _yellow,
                              ),
                            ),
                            Row(
                              children: [
                                const Icon(Icons.star_rounded, color: _yellow, size: 14),
                                const SizedBox(width: 2),
                                Text(
                                  food.rating.toStringAsFixed(1),
                                  style: const TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    color: _navy,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          showAddToCartBottomSheet(context, food);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _navy,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          elevation: 0,
                        ),
                        child: const Text('Add to Cart', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
