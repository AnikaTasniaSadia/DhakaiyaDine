import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

import '../../../models/food_model.dart';
import '../../../services/favorite_service.dart';
import '../../../routes/app_router.dart';
import 'search_suggestion_chip.dart';
import 'recent_search_card.dart';

class EmptySearchWidget extends StatelessWidget {
  final List<String> recentSearches;
  final VoidCallback onClearAllRecents;
  final ValueChanged<String> onRemoveRecent;
  final ValueChanged<String> onSelectChip;

  const EmptySearchWidget({
    super.key,
    required this.recentSearches,
    required this.onClearAllRecents,
    required this.onRemoveRecent,
    required this.onSelectChip,
  });

  @override
  Widget build(BuildContext context) {
    const navy = Color(0xFF1F2937);

    final allFoods = FavoriteService.allFoods;
    final recommended = allFoods.take(4).toList();
    final trending = allFoods.skip(4).take(4).toList();
    final special = allFoods.skip(8).toList();

    final popularChips = ['Burger', 'Pizza', 'Chicken', 'Coffee', 'Drinks', 'Fries'];

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 10),
          // Lottie animation: foodie.json
          Center(
            child: SizedBox(
              height: 200,
              width: 200,
              child: Lottie.asset(
                'assets/newanimation/foodie.json',
                repeat: true,
                animate: true,
              ),
            ),
          ),
          const SizedBox(height: 12),
          const Center(
            child: Text(
              'Discover Delicious Foods',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: navy,
              ),
            ),
          ),
          const SizedBox(height: 6),
          const Center(
            child: Text(
              'Search for burgers, pizza, biryani, desserts, drinks and more.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                color: Color(0xFF6B7280),
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Popular Search Chips
          const Text(
            'Popular Searches',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: navy),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: popularChips.map((chip) {
              return SearchSuggestionChip(
                label: chip,
                onTap: () => onSelectChip(chip),
              );
            }).toList(),
          ),
          const SizedBox(height: 24),

          // Recent Searches
          if (recentSearches.isNotEmpty) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Recent Searches',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: navy),
                ),
                TextButton(
                  onPressed: onClearAllRecents,
                  child: const Text(
                    'Clear All',
                    style: TextStyle(
                      color: Colors.redAccent,
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            ...recentSearches.map((search) {
              return RecentSearchCard(
                query: search,
                onTap: () => onSelectChip(search),
                onDismissed: () => onRemoveRecent(search),
              );
            }),
            const SizedBox(height: 24),
          ],

          // Recommended lists
          _buildHorizontalFoodSection(context, 'Recommended Foods', recommended),
          const SizedBox(height: 24),
          _buildHorizontalFoodSection(context, 'Trending', trending),
          const SizedBox(height: 24),
          _buildHorizontalFoodSection(context, "Today's Special", special),
          const SizedBox(height: 30),
        ],
      ),
    );
  }

  Widget _buildHorizontalFoodSection(BuildContext context, String title, List<FoodModel> foods) {
    const navy = Color(0xFF1F2937);
    const yellow = Color(0xFFF4B400);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: navy),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 180,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            itemCount: foods.length,
            itemBuilder: (context, index) {
              final food = foods[index];
              final price = food.discountedPrice > 0 ? food.discountedPrice : food.price;

              return GestureDetector(
                onTap: () {
                  Navigator.pushNamed(
                    context,
                    AppRouter.foodDetails,
                    arguments: food,
                  );
                },
                child: Container(
                  width: 140,
                  margin: const EdgeInsets.only(right: 14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFECECEC)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.02),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ClipRRect(
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                        child: Image.network(
                          food.imageUrl,
                          height: 90,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => Container(
                            height: 90,
                            color: Colors.grey.shade200,
                            child: const Icon(Icons.fastfood_rounded, color: Colors.grey),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              food.name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: navy,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  '৳${price.toStringAsFixed(0)}',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: yellow,
                                  ),
                                ),
                                Row(
                                  children: [
                                    const Icon(Icons.star_rounded, color: yellow, size: 12),
                                    Text(
                                      food.rating.toStringAsFixed(1),
                                      style: const TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                        color: navy,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
