import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/food_model.dart';
import '../services/cart_service.dart';
import '../routes/app_router.dart';

void showAddToCartBottomSheet(BuildContext context, FoodModel food) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => AddToCartSheet(food: food),
  );
}

class AddToCartSheet extends StatefulWidget {
  const AddToCartSheet({super.key, required this.food});

  final FoodModel food;

  @override
  State<AddToCartSheet> createState() => _AddToCartSheetState();
}

class _AddToCartSheetState extends State<AddToCartSheet> {
  int _quantity = 1;
  final TextEditingController _noteController = TextEditingController();

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final food = widget.food;
    final unitPrice = food.discountedPrice > 0 ? food.discountedPrice : food.price;
    final subtotal = unitPrice * _quantity;

    // Premium styling constants
    const goldColor = Color(0xFFF4B400);
    const navyColor = Color(0xFF1F2937);
    const creamColor = Color(0xFFFAF6EA);

    return Container(
      decoration: const BoxDecoration(
        color: creamColor,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(24),
        ),
      ),
      padding: EdgeInsets.only(
        top: 8,
        left: 20,
        right: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Drag Handle
            Center(
              child: Container(
                width: 48,
                height: 5,
                decoration: BoxDecoration(
                  color: navyColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Large Food Image (Hero Animated)
            Center(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Hero(
                  tag: 'food-sheet-${food.id}',
                  child: Image.network(
                    food.imageUrl,
                    width: double.infinity,
                    height: 200,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      width: double.infinity,
                      height: 200,
                      color: Colors.grey[200],
                      child: const Icon(
                        Icons.fastfood_rounded,
                        size: 64,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Food Name & Price Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        food.name,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          color: navyColor,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        food.category,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: navyColor.withValues(alpha: 0.6),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '৳${unitPrice.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    color: goldColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),

            // Rating & Delivery Info Row
            Row(
              children: [
                const Icon(
                  Icons.star_rounded,
                  color: goldColor,
                  size: 18,
                ),
                const SizedBox(width: 4),
                Text(
                  food.rating.toStringAsFixed(1),
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: navyColor,
                  ),
                ),
                const SizedBox(width: 16),
                const Icon(
                  Icons.schedule_rounded,
                  color: Colors.grey,
                  size: 16,
                ),
                const SizedBox(width: 4),
                Text(
                  food.deliveryTime,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Description
            Text(
              food.description,
              style: TextStyle(
                fontSize: 14,
                color: navyColor.withValues(alpha: 0.75),
                height: 1.5,
              ),
            ),
            const SizedBox(height: 16),
            const Divider(color: Colors.black12, height: 1),
            const SizedBox(height: 16),

            // Quantity Selector
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Quantity',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: navyColor,
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      _buildQuantityButton(
                        icon: Icons.remove_rounded,
                        onTap: _quantity > 1
                            ? () => setState(() => _quantity--)
                            : null,
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 200),
                          transitionBuilder: (child, animation) => ScaleTransition(
                            scale: animation,
                            child: FadeTransition(
                              opacity: animation,
                              child: child,
                            ),
                          ),
                          child: Text(
                            '$_quantity',
                            key: ValueKey<int>(_quantity),
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              color: navyColor,
                            ),
                          ),
                        ),
                      ),
                      _buildQuantityButton(
                        icon: Icons.add_rounded,
                        onTap: _quantity < 20
                            ? () => setState(() => _quantity++)
                            : null,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Optional Special Instructions TextField
            const Text(
              'Special Instructions (Optional)',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: navyColor,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _noteController,
              decoration: InputDecoration(
                hintText: 'e.g., Less spicy, No onion, Extra cheese',
                hintStyle: TextStyle(
                  color: navyColor.withValues(alpha: 0.4),
                  fontSize: 13,
                ),
                fillColor: Colors.white,
                filled: true,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Colors.black12),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Colors.black12),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: goldColor, width: 1.5),
                ),
              ),
              style: const TextStyle(fontSize: 14, color: navyColor),
              maxLines: 2,
            ),
            const SizedBox(height: 20),

            // Price Summary
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.black12),
              ),
              child: Column(
                children: [
                  _buildSummaryRow(
                    label: 'Unit Price',
                    value: '৳${unitPrice.toStringAsFixed(2)}',
                  ),
                  const SizedBox(height: 8),
                  _buildSummaryRow(
                    label: 'Quantity',
                    value: 'x $_quantity',
                  ),
                  const Divider(color: Colors.black12, height: 16),
                  _buildSummaryRow(
                    label: 'Subtotal',
                    value: '৳${subtotal.toStringAsFixed(2)}',
                    isTotal: true,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: navyColor,
                      side: const BorderSide(color: navyColor, width: 1.5),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: const Text(
                      'Continue Shopping',
                      style: TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      final cartService = context.read<CartService>();
                      final note = _noteController.text.trim();

                      cartService.addItem(
                        food,
                        quantity: _quantity,
                        note: note.isNotEmpty ? note : null,
                      );

                      Navigator.pop(context);

                      // Show beautiful success Snackbar
                      ScaffoldMessenger.of(context).hideCurrentSnackBar();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          backgroundColor: navyColor,
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          content: Row(
                            children: [
                              const Icon(
                                Icons.check_circle_rounded,
                                color: Color(0xFF4CAF50), // Green Success Icon
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  '${food.name} added to cart.',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          action: SnackBarAction(
                            label: 'View Cart',
                            textColor: goldColor,
                            onPressed: () {
                              Navigator.pushNamed(context, AppRouter.cart);
                            },
                          ),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: goldColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      elevation: 0,
                    ),
                    child: const Text(
                      'Add To Cart',
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuantityButton({required IconData icon, VoidCallback? onTap}) {
    const navyColor = Color(0xFF1F2937);
    final isEnabled = onTap != null;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(30),
      child: Container(
        width: 40,
        height: 40,
        decoration: const BoxDecoration(shape: BoxShape.circle),
        child: Icon(
          icon,
          color: isEnabled ? navyColor : navyColor.withValues(alpha: 0.3),
          size: 20,
        ),
      ),
    );
  }

  Widget _buildSummaryRow({
    required String label,
    required String value,
    bool isTotal = false,
  }) {
    const navyColor = Color(0xFF1F2937);
    const goldColor = Color(0xFFF4B400);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: isTotal ? 16 : 14,
            fontWeight: isTotal ? FontWeight.w800 : FontWeight.w500,
            color: navyColor.withValues(alpha: isTotal ? 1.0 : 0.6),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: isTotal ? 18 : 14,
            fontWeight: isTotal ? FontWeight.w900 : FontWeight.w700,
            color: isTotal ? goldColor : navyColor,
          ),
        ),
      ],
    );
  }
}
