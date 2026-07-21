import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/favorite_service.dart';
import '../../widgets/add_to_cart_sheet.dart';
import 'widgets/empty_favorite_widget.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  static const _navy = Color(0xFF1F2937);
  static const _yellow = Color(0xFFF4B400);
  static const _bg = Color(0xFFFAF6EA);

  @override
  Widget build(BuildContext context) {
    final favoriteService = context.watch<FavoriteService>();
    final favoriteFoods = favoriteService.favoriteFoods;

    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        title: const Text(
          'My Favorites',
          style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18, color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: _navy,
        elevation: 0,
      ),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 500),
        child: favoriteFoods.isEmpty
            ? const EmptyFavoriteWidget(key: ValueKey('empty_state'))
            : GridView.builder(
                key: const ValueKey('grid_state'),
                padding: const EdgeInsets.all(16),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 0.72,
                ),
              itemCount: favoriteFoods.length,
              itemBuilder: (context, index) {
                final food = favoriteFoods[index];
                final price = food.discountedPrice > 0 ? food.discountedPrice : food.price;

                return Container(
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
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('Removed from favorites'),
                                        duration: Duration(milliseconds: 800),
                                      ),
                                    );
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.all(6),
                                    decoration: const BoxDecoration(
                                      color: Colors.white,
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.favorite_rounded,
                                      color: Colors.redAccent,
                                      size: 16,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Food Details
                        Expanded(
                          flex: 3,
                          child: Padding(
                            padding: const EdgeInsets.all(10.0),
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
                                    const SizedBox(height: 2),
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
              },
            ),
      ),
    );
  }
}
