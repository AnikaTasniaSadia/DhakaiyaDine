import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import '../../models/food_model.dart';
import '../../routes/app_router.dart';
import '../../services/food_service.dart';
import 'components/bottom_nav_bar.dart';
import 'components/category_widget.dart';
import 'components/custom_app_bar.dart';
import 'components/food_card.dart';
import 'components/promo_banner.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, this.onMenuVisibilityChanged});

  final ValueChanged<bool>? onMenuVisibilityChanged;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  static const Color _backgroundColor = Color(0xFFFFF8E1);
  static const Color _textColor = Color(0xFF212121);

  final List<_CategoryData> _categories = const [
    _CategoryData('All', Icons.grid_view_rounded),
    _CategoryData('Burger', Icons.lunch_dining_rounded),
    _CategoryData('Pizza', Icons.local_pizza_rounded),
    _CategoryData('Fries', Icons.fastfood_rounded),
    _CategoryData('Drinks', Icons.local_drink_rounded),
    _CategoryData('Meat', Icons.set_meal_rounded),
    _CategoryData('Chinese', Icons.ramen_dining_rounded),
    _CategoryData('Italian', Icons.dinner_dining_rounded),
    _CategoryData('Wraps', Icons.wrap_text_rounded),
  ];

  List<FoodModel> _foods = [];
  bool _foodsLoading = true;

  int _selectedCategoryIndex = 0;
  int _activeNavIndex = 0;
  bool _showContent = false;

  List<FoodModel> get _filteredFoods {
    if (_selectedCategoryIndex == 0) {
      return _foods; // Show all foods when "All" is selected
    }
    final selectedCategory = _categories[_selectedCategoryIndex].label;
    return _foods.where((food) => food.category == selectedCategory).toList();
  }

  @override
  void initState() {
    super.initState();
    _loadFoods();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      setState(() => _showContent = true);
    });
  }

  Future<void> _loadFoods() async {
    final foods = await FoodService.instance.fetchMenu();
    if (!mounted) return;
    setState(() {
      _foods = foods;
      _foodsLoading = false;
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
            child: NotificationListener<UserScrollNotification>(
              onNotification: (notification) {
                if (notification.direction == ScrollDirection.reverse) {
                  widget.onMenuVisibilityChanged?.call(false);
                } else if (notification.direction == ScrollDirection.forward) {
                  widget.onMenuVisibilityChanged?.call(true);
                }
                return false;
              },
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
                                'https://i.ibb.co/hJMSRdtY/food-web-banner-31.jpg',
                          ),
                          const SizedBox(height: 24),
                          SizedBox(
                            height: 94,
                            child: ListView.separated(
                              scrollDirection: Axis.horizontal,
                              physics: const BouncingScrollPhysics(),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                              ),
                              itemCount: _categories.length,
                              separatorBuilder: (_, __) =>
                                  const SizedBox(width: 6),
                              itemBuilder: (context, index) {
                                final item = _categories[index];

                                return SizedBox(
                                  width:
                                      MediaQuery.of(context).size.width / 4.5,
                                  child: CategoryWidget(
                                    label: item.label,
                                    icon: item.icon,
                                    isSelected: _selectedCategoryIndex == index,
                                    onTap: () {
                                      setState(() {
                                        _selectedCategoryIndex = index;
                                      });
                                    },
                                  ),
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
                    sliver: _foodsLoading
                        ? const SliverToBoxAdapter(
                            child: Center(
                              child: Padding(
                                padding: EdgeInsets.all(40),
                                child: CircularProgressIndicator(
                                  color: Color(0xFFFFC107),
                                ),
                              ),
                            ),
                          )
                        : SliverGrid.builder(
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 14,
                            mainAxisSpacing: 14,
                            childAspectRatio: 0.72,
                          ),
                      itemCount: _filteredFoods.length,
                      itemBuilder: (context, index) {
                        final food = _filteredFoods[index];
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
      ),
      bottomNavigationBar: DhakaiaBottomNavBar(
        activeIndex: _activeNavIndex,
        onChanged: (index) {
          setState(() {
            _activeNavIndex = index;
          });
          if (index == 1) {
            Navigator.pushNamed(context, AppRouter.favorites);
          } else if (index == 2) {
            Navigator.pushNamed(context, AppRouter.search);
          } else if (index == 3) {
            Navigator.pushNamed(context, AppRouter.profile);
          }
        },
      ),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key, this.onMenuVisibilityChanged});

  final ValueChanged<bool>? onMenuVisibilityChanged;

  @override
  Widget build(BuildContext context) {
    return HomeScreen(onMenuVisibilityChanged: onMenuVisibilityChanged);
  }
}

class _CategoryData {
  const _CategoryData(this.label, this.icon);

  final String label;
  final IconData icon;
}
