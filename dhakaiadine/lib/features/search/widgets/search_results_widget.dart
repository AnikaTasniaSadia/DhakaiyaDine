import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../models/food_model.dart';
import '../../../services/favorite_service.dart';
import '../../../services/cart_service.dart';

class SearchResultsWidget extends StatefulWidget {
  final List<FoodModel> results;
  final String query;
  final ValueChanged<String> onSelectFood;

  const SearchResultsWidget({
    super.key,
    required this.results,
    required this.query,
    required this.onSelectFood,
  });

  @override
  State<SearchResultsWidget> createState() => _SearchResultsWidgetState();
}

class _SearchResultsWidgetState extends State<SearchResultsWidget>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animationController;
  late final Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeIn,
    );
    _animationController.forward();
  }

  @override
  void didUpdateWidget(covariant SearchResultsWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Restart animation on new results
    _animationController.reset();
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const navy = Color(0xFF1F2937);
    const yellow = Color(0xFFF4B400);

    return FadeTransition(
      opacity: _fadeAnimation,
      child: ListView.builder(
        physics: const BouncingScrollPhysics(),
        itemCount: widget.results.length,
        itemBuilder: (context, index) {
          final food = widget.results[index];
          final price = food.discountedPrice > 0 ? food.discountedPrice : food.price;

          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: const Color(0xFFECECEC)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.02),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(18),
              child: InkWell(
                onTap: () => widget.onSelectFood(food.name),
                child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Row(
                    children: [
                      // Food Image
                      Hero(
                        tag: 'search-result-${food.id}',
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.network(
                            food.imageUrl,
                            width: 80,
                            height: 80,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) => Container(
                              width: 80,
                              height: 80,
                              color: Colors.grey.shade200,
                              child: const Icon(Icons.fastfood_rounded, color: Colors.grey),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      // Details
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              food.name,
                              style: const TextStyle(
                                fontWeight: FontWeight.w800,
                                fontSize: 14,
                                color: navy,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              food.category,
                              style: const TextStyle(
                                fontSize: 11,
                                color: Color(0xFF6B7280),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Row(
                              children: [
                                Text(
                                  '৳${price.toStringAsFixed(0)}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w900,
                                    color: yellow,
                                    fontSize: 14,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                const Icon(Icons.star_rounded, color: yellow, size: 14),
                                const SizedBox(width: 2),
                                Text(
                                  food.rating.toStringAsFixed(1),
                                  style: const TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    color: navy,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      // Actions: Favorite and Add to Cart
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Consumer<FavoriteService>(
                            builder: (context, favoriteService, _) {
                              final isFav = favoriteService.isFavorite(food.id);
                              return IconButton(
                                icon: Icon(
                                  isFav ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                                  color: isFav ? Colors.redAccent : const Color(0xFF6B7280),
                                  size: 20,
                                ),
                                onPressed: () {
                                  favoriteService.toggleFavorite(food.id);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        isFav ? 'Removed from favorites' : 'Added to favorites',
                                      ),
                                      duration: const Duration(seconds: 1),
                                      behavior: SnackBarBehavior.floating,
                                    ),
                                  );
                                },
                              );
                            },
                          ),
                          const SizedBox(height: 4),
                          ElevatedButton(
                            onPressed: () {
                              context.read<CartService>().addItem(food);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('${food.name} added to cart!'),
                                  duration: const Duration(seconds: 1),
                                  behavior: SnackBarBehavior.floating,
                                ),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: navy,
                              foregroundColor: Colors.white,
                              elevation: 0,
                              minimumSize: const Size(64, 30),
                              padding: const EdgeInsets.symmetric(horizontal: 10),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: const Text(
                              'Add',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
