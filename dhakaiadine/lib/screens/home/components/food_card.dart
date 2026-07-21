import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../models/food_model.dart';
import '../../../../services/cart_service.dart';
import '../../../../routes/app_router.dart';
import '../../../../widgets/add_to_cart_sheet.dart';

class FoodCard extends StatelessWidget {
  const FoodCard({
    super.key,
    required this.food,
    required this.heroTag,
    required this.imageUrl,
    required this.name,
    required this.deliveryTime,
    required this.rating,
    required this.price,
    required this.onTap,
    this.discountBadge,
    this.isFavorite = false,
    this.onFavoriteTap,
  });

  final FoodModel food;
  final String heroTag;
  final String imageUrl;
  final String name;
  final String deliveryTime;
  final double rating;
  final double price;
  final VoidCallback onTap;
  final String? discountBadge;
  final bool isFavorite;
  final VoidCallback? onFavoriteTap;

  @override
  Widget build(BuildContext context) {
    final cartService = context.watch<CartService>();
    final quantity = cartService.getQuantity(food.id);
    final isInCart = quantity > 0;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: onTap,
            child: Ink(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    blurRadius: 18,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(10, 10, 10, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Stack(
                        children: [
                          Positioned.fill(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Hero(
                                tag: heroTag,
                                child: Image.network(imageUrl, fit: BoxFit.cover),
                              ),
                            ),
                          ),
                          if (discountBadge != null)
                            Positioned(
                              top: 8,
                              left: 8,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFFC107),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  discountBadge!,
                                  style: const TextStyle(
                                    color: Color(0xFF212121),
                                    fontSize: 10,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ),
                          Positioned(
                            top: 8,
                            right: 8,
                            child: GestureDetector(
                              onTap: onFavoriteTap,
                              child: Container(
                                padding: const EdgeInsets.all(6),
                                decoration: const BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  isFavorite ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                                  color: isFavorite ? const Color(0xFFEF4444) : const Color(0xFF6B7280),
                                  size: 16,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Color(0xFF212121),
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(
                          Icons.schedule_rounded,
                          color: Color(0xFF757575),
                          size: 14,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          deliveryTime,
                          style: const TextStyle(
                            color: Color(0xFF757575),
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const Spacer(),
                        const Icon(
                          Icons.star_rounded,
                          color: Color(0xFFFFB300),
                          size: 15,
                        ),
                        const SizedBox(width: 2),
                        Text(
                          rating.toStringAsFixed(1),
                          style: const TextStyle(
                            color: Color(0xFF212121),
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '৳${price.toStringAsFixed(2)}',
                      style: const TextStyle(
                        color: Color(0xFF000000),
                        fontWeight: FontWeight.w800,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 10),
                    _buildCardButton(context, isInCart),
                  ],
                ),
              ),
            ),
          ),
        ),
        if (quantity > 0)
          Positioned(
            top: -6,
            right: -6,
            child: AnimatedScale(
              scale: quantity > 0 ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 300),
              curve: Curves.elasticOut,
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: const BoxDecoration(
                  color: Color(0xFFF4B400),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 6,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                constraints: const BoxConstraints(
                  minWidth: 26,
                  minHeight: 26,
                ),
                child: Center(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 200),
                    transitionBuilder: (child, animation) => ScaleTransition(
                      scale: animation,
                      child: child,
                    ),
                    child: Text(
                      '$quantity',
                      key: ValueKey<int>(quantity),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildCardButton(BuildContext context, bool isInCart) {
    const navyColor = Color(0xFF1F2937);

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      transitionBuilder: (child, animation) {
        return FadeTransition(
          opacity: animation,
          child: ScaleTransition(
            scale: animation,
            child: child,
          ),
        );
      },
      child: isInCart
          ? _buildOrderNowButton(context)
          : _buildAddToCartButton(context, navyColor),
    );
  }

  Widget _buildAddToCartButton(BuildContext context, Color color) {
    return InkWell(
      key: const ValueKey('add_to_cart_btn'),
      onTap: () => showAddToCartBottomSheet(context, food),
      borderRadius: BorderRadius.circular(10),
      child: Container(
        height: 36,
        width: double.infinity,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(10),
        ),
        child: const Center(
          child: Text(
            'Add to Cart',
            style: TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildOrderNowButton(BuildContext context) {
    return InkWell(
      key: const ValueKey('order_now_btn'),
      onTap: () {
        Navigator.pushNamed(context, AppRouter.cart);
      },
      borderRadius: BorderRadius.circular(10),
      child: Container(
        height: 36,
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFFFFB300), Color(0xFFFF8F00)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(10),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.shopping_cart_outlined,
              color: Colors.white,
              size: 14,
            ),
            SizedBox(width: 6),
            Text(
              'Order Now',
              style: TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
