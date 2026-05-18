import 'package:flutter/material.dart';

import 'components/bottom_nav_bar.dart';
import 'components/category_widget.dart';
import 'components/custom_app_bar.dart';
import 'components/food_card.dart';
import 'components/promo_banner.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  static const Color _backgroundColor = Color(0xFFFFF8E1);
  static const Color _textColor = Color(0xFF212121);

  final List<_CategoryData> _categories = const [
    _CategoryData('Burger', Icons.lunch_dining_rounded),
    _CategoryData('Pizza', Icons.local_pizza_rounded),
    _CategoryData('Fries', Icons.fastfood_rounded),
    _CategoryData('Drinks', Icons.local_drink_rounded),
    _CategoryData('Meat', Icons.set_meal_rounded),
  ];

  final List<_FoodItemData> _foods = const [
    _FoodItemData(
      id: 'beef-burger',
      name: 'Beef Smash Burger',
      price: 350,
      rating: 4.7,
      deliveryTime: '40 min',
      imageUrl:
          'https://images.unsplash.com/photo-1568901346375-23c9450c58cd?auto=format&fit=crop&w=900&q=80',
      discount: '30% OFF',
    ),
    _FoodItemData(
      id: 'pepperoni-pizza',
      name: 'Pepperoni Pizza',
      price: 1120,
      rating: 4.6,
      deliveryTime: '35 min',
      imageUrl:
          'https://images.unsplash.com/photo-1513104890138-7c749659a591?auto=format&fit=crop&w=900&q=80',
    ),
    _FoodItemData(
      id: 'crispy-fries',
      name: 'Crispy French Fries',
      price: 150,
      rating: 4.4,
      deliveryTime: '25 min',
      imageUrl:
          'https://images.unsplash.com/photo-1576107232684-1279f390859f?auto=format&fit=crop&w=900&q=80',
      discount: '10% OFF',
    ),
    _FoodItemData(
      id: 'bbq-platter',
      name: 'BBQ Meat Platter',
      price: 560,
      rating: 4.8,
      deliveryTime: '50 min',
      imageUrl:
          'https://images.unsplash.com/photo-1544025162-d76694265947?auto=format&fit=crop&w=900&q=80',
    ),
  ];

  int _selectedCategoryIndex = 0;
  int _activeNavIndex = 0;
  bool _showContent = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      setState(() {
        _showContent = true;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _backgroundColor,
      body: SafeArea(
        child: AnimatedOpacity(
          opacity: _showContent ? 1 : 0,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeOut,
          child: AnimatedSlide(
            offset: _showContent ? Offset.zero : const Offset(0, 0.05),
            duration: const Duration(milliseconds: 450),
            curve: Curves.easeOutCubic,
            child: CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const CustomAppBar(),
                        const SizedBox(height: 20),
                        PromoBanner(
                          onOrderNow: () {},
                          imageUrl:
                              'https://images.unsplash.com/photo-1550547660-d9450f859349?auto=format&fit=crop&w=1000&q=80',
                        ),
                        const SizedBox(height: 24),
                        SizedBox(
                          height: 94,
                          child: ListView.separated(
                            scrollDirection: Axis.horizontal,
                            physics: const BouncingScrollPhysics(),
                            itemCount: _categories.length,
                            separatorBuilder: (_, __) =>
                                const SizedBox(width: 12),
                            itemBuilder: (context, index) {
                              final item = _categories[index];
                              return CategoryWidget(
                                label: item.label,
                                icon: item.icon,
                                isSelected: _selectedCategoryIndex == index,
                                onTap: () {
                                  setState(() {
                                    _selectedCategoryIndex = index;
                                  });
                                },
                              );
                            },
                          ),
                        ),
                        const SizedBox(height: 28),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Popular Items',
                              style: Theme.of(context).textTheme.titleLarge
                                  ?.copyWith(
                                    color: _textColor,
                                    fontWeight: FontWeight.w700,
                                  ),
                            ),
                            TextButton(
                              onPressed: () {},
                              child: const Text(
                                'See More',
                                style: TextStyle(
                                  color: Color(0xFF212121),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                  sliver: SliverGrid.builder(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 14,
                          mainAxisSpacing: 14,
                          childAspectRatio: 0.72,
                        ),
                    itemCount: _foods.length,
                    itemBuilder: (context, index) {
                      final food = _foods[index];
                      return FoodCard(
                        heroTag: 'food-${food.id}',
                        imageUrl: food.imageUrl,
                        name: food.name,
                        deliveryTime: food.deliveryTime,
                        rating: food.rating,
                        price: food.price,
                        discountBadge: food.discount,
                        onTap: () {},
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: DhakaiaBottomNavBar(
        activeIndex: _activeNavIndex,
        onChanged: (index) {
          setState(() {
            _activeNavIndex = index;
          });
        },
      ),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return const HomeScreen();
  }
}

class _CategoryData {
  const _CategoryData(this.label, this.icon);

  final String label;
  final IconData icon;
}

class _FoodItemData {
  const _FoodItemData({
    required this.id,
    required this.name,
    required this.price,
    required this.rating,
    required this.deliveryTime,
    required this.imageUrl,
    this.discount,
  });

  final String id;
  final String name;
  final double price;
  final double rating;
  final String deliveryTime;
  final String imageUrl;
  final String? discount;
}
