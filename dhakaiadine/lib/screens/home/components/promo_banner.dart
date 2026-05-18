import 'package:flutter/material.dart';

class PromoBanner extends StatefulWidget {
  const PromoBanner({
    super.key,
    required this.onOrderNow,
    required this.imageUrl,
  });

  final VoidCallback onOrderNow;
  final String imageUrl;

  @override
  State<PromoBanner> createState() => _PromoBannerState();
}

class _PromoBannerState extends State<PromoBanner> {
  double _buttonScale = 1;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 180,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFFFFC107),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Burgers Express',
                  style: TextStyle(
                    color: Color(0xFF212121),
                    fontWeight: FontWeight.w700,
                    fontSize: 18,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  '30% OFF',
                  style: TextStyle(
                    color: Color(0xFF000000),
                    fontWeight: FontWeight.w800,
                    fontSize: 32,
                    height: 1,
                  ),
                ),
                const Spacer(),
                GestureDetector(
                  onTapDown: (_) => setState(() => _buttonScale = 0.96),
                  onTapUp: (_) => setState(() => _buttonScale = 1),
                  onTapCancel: () => setState(() => _buttonScale = 1),
                  child: AnimatedScale(
                    duration: const Duration(milliseconds: 120),
                    scale: _buttonScale,
                    child: ElevatedButton(
                      onPressed: widget.onOrderNow,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF000000),
                        foregroundColor: Colors.white,
                        minimumSize: const Size(124, 42),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        elevation: 0,
                      ),
                      child: const Text(
                        'Order Now',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Align(
              alignment: Alignment.centerRight,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: Hero(
                  tag: 'promo-burger',
                  child: Image.network(
                    widget.imageUrl,
                    fit: BoxFit.cover,
                    width: 150,
                    height: 138,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
