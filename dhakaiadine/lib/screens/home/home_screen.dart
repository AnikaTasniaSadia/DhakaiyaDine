import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:provider/provider.dart';

import '../../models/food_model.dart';
import '../../routes/app_router.dart';
import '../../services/favorite_service.dart';
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

  final List<FoodModel> _foods = [
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
      id: 'Chicken burger',
      name: 'Crispy chicken Burger',
      description:
          'Crispy chicken with caramelized onions, cheese, tomatoand house sauce on a toasted bun.',
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
    FoodModel(
      id: 'chinese',
      name: 'Chinese fried rice',
      description:
          'Deliciously seasoned fried rice with a mix of vegetables and your choice of protein.',
      price: 310,
      discountedPrice: 60,
      rating: 4.8,
      deliveryTime: '45 min',
      category: 'Chinese',
      imageUrl:
          'https://images.unsplash.com/photo-1603133872878-684f208fb84b?w=600&auto=format&fit=crop&q=60&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxzZWFyY2h8Mnx8ZnJpZWQlMjByaWNlfGVufDB8fDB8fHww',
    ),
    FoodModel(
      id: 'pasta',
      name: 'Pasta',
      description:
          'Creamy pasta tossed with a rich sauce, herbs, and a savory finish.',
      price: 260,
      discountedPrice: 220,
      rating: 4.5,
      deliveryTime: '35 min',
      category: 'Italian',
      imageUrl:
          'https://images.unsplash.com/photo-1621996346565-e3dbc646d9a9?w=600&auto=format&fit=crop&q=60&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxzZWFyY2h8Mnx8cGFzdGF8ZW58MHx8MHx8fDA%3D',
    ),
    FoodModel(
      id: 'shawarma',
      name: 'Shawarma',
      description:
          'Warm, spiced shawarma with sliced meat, fresh veggies, and tangy sauce in a soft wrap.',
      price: 220,
      discountedPrice: 0,
      rating: 4.6,
      deliveryTime: '30 min',
      category: 'Wraps',
      imageUrl:
          'https://images.unsplash.com/photo-1719282431723-9d0f4370d4bc?w=600&auto=format&fit=crop&q=60&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxzZWFyY2h8MTJ8fHNoYXdhcm1hfGVufDB8fDB8fHww',
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
      imageUrl:
          'https://images.unsplash.com/photo-1556679343-c7306c1976bc?w=600&auto=format&fit=crop&q=60&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxzZWFyY2h8Mnx8bGVtb24lMjBpY2VkJTIwdGVhfGVufDB8fDB8fHww',
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
      imageUrl:
          'https://images.unsplash.com/photo-1653542773369-51cce8d08250?w=600&auto=format&fit=crop&q=60&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxzZWFyY2h8OHx8bWFuZ28lMjBqdWljZXxlbnwwfHwwfHx8MA%3D%3D',
    ),
    FoodModel(
      id: 'cappuccino',
      name: 'Cappuccino',
      description:
          'Rich espresso topped with steamed milk and a silky foam layer.',
      price: 180,
      discountedPrice: 150,
      rating: 4.4,
      deliveryTime: '10 min',
      category: 'Drinks',
      imageUrl:
          'https://plus.unsplash.com/premium_photo-1674327105280-b86494dfc690?w=600&auto=format&fit=crop&q=60&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxzZWFyY2h8MXx8Y2FwcHVjaGlub3xlbnwwfHwwfHx8MA%3D%3D',
    ),
    FoodModel(
      id: 'orange-juice',
      name: 'Orange Juice',
      description:
          'Fresh orange juice served chilled for a bright and zesty refreshment.',
      price: 130,
      discountedPrice: 105,
      rating: 4.6,
      deliveryTime: '12 min',
      category: 'Drinks',
      imageUrl:
          'https://images.unsplash.com/photo-1618046364546-81e9d03d39a6?w=600&auto=format&fit=crop&q=60&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxzZWFyY2h8MTl8fG9yYW5nZSUyMGp1aWNlfGVufDB8fDB8fHww',
    ),
  ];

  int _selectedCategoryIndex = 0;
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
    final favoriteService = context.watch<FavoriteService>();

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
                    sliver: SliverGrid.builder(
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
                        final isFav = favoriteService.isFavorite(food.id);

                        return FoodCard(
                          food: food,
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
                          isFavorite: isFav,
                          onFavoriteTap: () {
                            favoriteService.toggleFavorite(food.id);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  isFav
                                      ? 'Removed from favorites'
                                      : 'Added to favorites',
                                ),
                                duration: const Duration(milliseconds: 800),
                              ),
                            );
                          },
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
