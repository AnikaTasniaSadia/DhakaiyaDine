import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../services/cart_service.dart';
import '../../../routes/app_router.dart';

class CustomAppBar extends StatelessWidget {
  const CustomAppBar({super.key});

  static const Color _textColor = Color(0xFF212121);

  @override
  Widget build(BuildContext context) {
    final cartService = context.watch<CartService>();
    final cartItemCount = cartService.totalItems;

    return Row(
      children: [
        const SizedBox(width: 42, height: 42),
        const Spacer(),
        Text(
          'Discover',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            color: _textColor,
            fontWeight: FontWeight.w700,
          ),
        ),
        const Spacer(),
        Row(
          children: [
            _IconContainer(
              icon: Icons.search_rounded,
              onTap: () => Navigator.pushNamed(context, AppRouter.search),
            ),
            const SizedBox(width: 10),
            Stack(
              clipBehavior: Clip.none,
              children: [
                _IconContainer(
                  icon: Icons.shopping_cart_outlined,
                  onTap: () => Navigator.pushNamed(context, AppRouter.cart),
                ),
                if (cartItemCount > 0)
                  Positioned(
                    top: -4,
                    right: -4,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: Color(0xFFF4B400),
                        shape: BoxShape.circle,
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 18,
                        minHeight: 18,
                      ),
                      child: Center(
                        child: Text(
                          '$cartItemCount',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ],
    );
  }
}

class _IconContainer extends StatelessWidget {
  const _IconContainer({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: onTap,
      child: Ink(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 12,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Icon(icon, color: const Color(0xFF212121), size: 21),
      ),
    );
  }
}
