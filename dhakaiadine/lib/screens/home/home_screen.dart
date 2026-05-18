import 'package:flutter/material.dart';

import '../../models/food_model.dart';
import '../../routes/app_router.dart';
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

  final List<FoodModel> _foods = const [
    FoodModel(
      id: 'beef-burger',
      name: 'Beef Smash Burger',
      description:
          'Juicy beef patty with caramelized onions, cheddar, and house sauce on a toasted bun.',
      price: 350,
      discountedPrice: 280,
      rating: 4.7,
      deliveryTime: '40 min',
      category: 'Burger',
      imageUrl:
          'https://images.unsplash.com/photo-1568901346375-23c9450c58cd?auto=format&fit=crop&w=900&q=80',
    ),
    FoodModel(
      id: 'pepperoni-pizza',
      name: 'Pepperoni Pizza',
      description:
          'Classic pepperoni pizza with mozzarella, tomato sauce, and crispy edges.',
      price: 1120,
      discountedPrice: 0,
      rating: 4.6,
      deliveryTime: '35 min',
      category: 'Pizza',
      imageUrl:
          'https://images.unsplash.com/photo-1513104890138-7c749659a591?auto=format&fit=crop&w=900&q=80',
    ),
    FoodModel(
      id: 'crispy-fries',
      name: 'Crispy French Fries',
      description:
          'Golden potato fries with a crunchy bite and a hint of sea salt.',
      price: 150,
      discountedPrice: 135,
      rating: 4.4,
      deliveryTime: '25 min',
      category: 'Fries',
      imageUrl:
          'https://images.unsplash.com/photo-1576107232684-1279f390859f?auto=format&fit=crop&w=900&q=80',
    ),
    FoodModel(
      id: 'bbq-platter',
      name: 'BBQ Meat Platter',
      description:
          'Smoky BBQ meats served with grilled veggies and a tangy glaze.',
      price: 560,
      discountedPrice: 0,
      rating: 4.8,
      deliveryTime: '50 min',
      category: 'Meat',
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
                        price: food.discountedPrice > 0
                            ? food.discountedPrice
                            : food.price,
                        discountBadge: food.discountedPrice > 0
                            ? 'Offer'
                            : null,
                        onTap: () {
                          Navigator.pushNamed(
                            context,
                            AppRouter.foodDetails,
                            arguments: food,
                          );
                        },
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
