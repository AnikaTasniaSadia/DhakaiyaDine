import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';

import '../../../models/food_model.dart';
import '../../../services/cart_service.dart';
import '../../../routes/app_router.dart';

class EmptyCartWidget extends StatefulWidget {
  const EmptyCartWidget({super.key});

  @override
  State<EmptyCartWidget> createState() => _EmptyCartWidgetState();
}

class _EntryPointStateHelper {
  static void navigateToHome(BuildContext context) {
    if (Navigator.canPop(context)) {
      Navigator.pop(context);
    } else {
      Navigator.pushReplacementNamed(context, AppRouter.home);
    }
  }
}

class _EmptyCartWidgetState extends State<EmptyCartWidget>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animationController;
  late final Animation<double> _fadeAnimation;
  late final Animation<double> _slideAnimation;

  // Fake/existing food data for recommendations
  final List<FoodModel> _recommendedFoods = const [
    FoodModel(
      id: 'beef-burger',
      name: 'Beef Smash Burger',
      description: 'Juicy beef smash patty with cheddar and house sauce.',
      price: 350,
      discountedPrice: 280,
      rating: 4.7,
      deliveryTime: '40 min',
      category: 'Burger',
      imageUrl: 'https://images.unsplash.com/photo-1568901346375-23c9450c58cd?auto=format&fit=crop&w=900&q=80',
    ),
    FoodModel(
      id: 'pepperoni-pizza',
      name: 'Pepperoni Pizza',
      description: 'Classic pepperoni pizza with mozzarella and tomato sauce.',
      price: 1120,
      discountedPrice: 990,
      rating: 4.6,
      deliveryTime: '35 min',
      category: 'Pizza',
      imageUrl: 'https://images.unsplash.com/photo-1513104890138-7c749659a591?auto=format&fit=crop&w=900&q=80',
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
      imageUrl: 'https://images.unsplash.com/photo-1513558161293-cdaf765ed2fd?auto=format&fit=crop&w=900&q=80',
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
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeIn,
    );

    _slideAnimation = Tween<double>(begin: 40, end: 0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOutBack,
      ),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFFAF6EA), // Cream background
      child: AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) {
          return Opacity(
            opacity: _fadeAnimation.value,
            child: Transform.translate(
              offset: Offset(0, _slideAnimation.value),
              child: child,
            ),
          );
        },
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 10),
              // Lottie Animation (Catsleeping.json, 260x260, loops automatically)
              Center(
                child: SizedBox(
                  width: 260,
                  height: 260,
                  child: Lottie.asset(
                    'assets/newanimation/Catsleeping.json',
                    repeat: true,
                    reverse: false,
                    animate: true,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // Title: Your Cart is Empty
              const Text(
                'Your Cart is Empty',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1F2937), // Dark Navy
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              // Message
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.0),
                child: Text(
                  "Looks like you haven't added any delicious food yet.\nStart exploring our menu and discover your favorite meals.",
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 24),
              // Feature Card
              Card(
                color: Colors.white,
                elevation: 4,
                shadowColor: Colors.black.withOpacity(0.08),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: const [
                      _FeatureItem(emoji: '🍔', text: 'Burgers'),
                      _FeatureItem(emoji: '🍕', text: 'Pizza'),
                      _FeatureItem(emoji: '🥤', text: 'Drinks'),
                      _FeatureItem(emoji: '🍟', text: 'Fries'),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              // Primary Button (Explore Menu)
              _AnimatedButton(
                onTap: () => _EntryPointStateHelper.navigateToHome(context),
                backgroundColor: const Color(0xFFF4B400), // Gold
                child: const Center(
                  child: Text(
                    'Explore Menu',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              // Secondary Button (View Popular Items)
              OutlinedButton(
                onPressed: () => _EntryPointStateHelper.navigateToHome(context),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 54),
                  side: const BorderSide(color: Color(0xFF1F2937), width: 1.5),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: const Text(
                  'View Popular Items',
                  style: TextStyle(
                    color: Color(0xFF1F2937), // Dark Navy
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 32),
              // Recommended section
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Recommended For You',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1F2937),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 220,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      physics: const BouncingScrollPhysics(),
                      itemCount: _recommendedFoods.length,
                      itemBuilder: (context, index) {
                        final food = _recommendedFoods[index];
                        return _RecommendedFoodCard(food: food);
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              // Empty Cart Tips Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.amber.shade50,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.amber.shade200, width: 1),
                ),
                child: Row(
                  children: const [
                    Text(
                      '💡',
                      style: TextStyle(fontSize: 24),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Add your favorite meals to the cart and enjoy a faster checkout experience.',
                        style: TextStyle(
                          fontSize: 13,
                          color: Color(0xFF7F5F00),
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}

class _FeatureItem extends StatelessWidget {
  final String emoji;
  final String text;

  const _FeatureItem({required this.emoji, required this.text});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          emoji,
          style: const TextStyle(fontSize: 28),
        ),
        const SizedBox(height: 6),
        Text(
          text,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Color(0xFF4B5563),
          ),
        ),
      ],
    );
  }
}

class _AnimatedButton extends StatefulWidget {
  final VoidCallback onTap;
  final Color backgroundColor;
  final Widget child;

  const _AnimatedButton({
    required this.onTap,
    required this.backgroundColor,
    required this.child,
  });

  @override
  State<_AnimatedButton> createState() => _AnimatedButtonState();
}

class _AnimatedButtonState extends State<_AnimatedButton> {
  double _scale = 1.0;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _scale = 0.95),
      onTapUp: (_) {
        setState(() => _scale = 1.0);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _scale = 1.0),
      child: AnimatedScale(
        scale: _scale,
        duration: const Duration(milliseconds: 100),
        child: Container(
          width: double.infinity,
          height: 54,
          decoration: BoxDecoration(
            color: widget.backgroundColor,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: widget.backgroundColor.withOpacity(0.3),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: widget.child,
        ),
      ),
    );
  }
}

class _RecommendedFoodCard extends StatelessWidget {
  final FoodModel food;

  const _RecommendedFoodCard({required this.food});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 150,
      margin: const EdgeInsets.only(right: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Food Image
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            child: Hero(
              tag: 'recommended-${food.id}',
              child: Image.network(
                food.imageUrl,
                height: 100,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  color: Colors.grey.shade200,
                  height: 100,
                  child: const Icon(Icons.fastfood, color: Colors.grey),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Name
                Text(
                  food.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1F2937),
                  ),
                ),
                const SizedBox(height: 2),
                // Rating & Price
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '৳${food.price.toStringAsFixed(0)}',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFF4B400),
                      ),
                    ),
                    Row(
                      children: [
                        const Icon(Icons.star_rounded, color: Colors.amber, size: 14),
                        const SizedBox(width: 2),
                        Text(
                          food.rating.toString(),
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                // Add to Cart Button
                SizedBox(
                  width: double.infinity,
                  height: 30,
                  child: ElevatedButton(
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
                      backgroundColor: const Color(0xFF1F2937),
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.zero,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      'Add to Cart',
                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
