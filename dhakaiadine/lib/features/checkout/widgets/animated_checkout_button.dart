import 'package:flutter/material.dart';

class AnimatedCheckoutButton extends StatefulWidget {
  const AnimatedCheckoutButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.isLoading = false,
  });

  final String label;
  final VoidCallback onPressed;
  final bool isLoading;

  @override
  State<AnimatedCheckoutButton> createState() => _AnimatedCheckoutButtonState();
}

class _AnimatedCheckoutButtonState extends State<AnimatedCheckoutButton> {
  double _scale = 1;

  @override
  Widget build(BuildContext context) {
    final isDisabled = widget.isLoading;

    return GestureDetector(
      onTapDown: isDisabled ? null : (_) => setState(() => _scale = 0.97),
      onTapUp: isDisabled ? null : (_) => setState(() => _scale = 1),
      onTapCancel: isDisabled ? null : () => setState(() => _scale = 1),
      onTap: isDisabled ? null : widget.onPressed,
      child: AnimatedScale(
        scale: _scale,
        duration: const Duration(milliseconds: 120),
        child: Container(
          height: 56,
          decoration: BoxDecoration(
            color: const Color(0xFFFFC107),
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.14),
                blurRadius: 16,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Center(
            child: widget.isLoading
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.4,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        Color(0xFF000000),
                      ),
                    ),
                  )
                : Text(
                    widget.label,
                    style: const TextStyle(
                      color: Color(0xFF000000),
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}
