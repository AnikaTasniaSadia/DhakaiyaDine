import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../providers/connectivity_provider.dart';

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
    final connectivity = Provider.of<ConnectivityProvider>(context);
    final isOfflineDisabled = !connectivity.isConnected;
    final isDisabled = widget.isLoading || isOfflineDisabled;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        GestureDetector(
          onTapDown: isDisabled ? null : (_) => setState(() => _scale = 0.97),
          onTapUp: isDisabled ? null : (_) => setState(() => _scale = 1),
          onTapCancel: isDisabled ? null : () => setState(() => _scale = 1),
          onTap: isOfflineDisabled
              ? () {
                  ScaffoldMessenger.of(context).hideCurrentSnackBar();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      backgroundColor: const Color(0xFFD32F2F),
                      content: const Text('Checkout is unavailable offline.'),
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  );
                }
              : (widget.isLoading ? null : widget.onPressed),
          child: AnimatedScale(
            scale: isOfflineDisabled ? 1.0 : _scale,
            duration: const Duration(milliseconds: 120),
            child: Container(
              height: 56,
              decoration: BoxDecoration(
                color: isOfflineDisabled
                    ? Colors.grey.shade400
                    : const Color(0xFFFFC107),
                borderRadius: BorderRadius.circular(18),
                boxShadow: isOfflineDisabled
                    ? []
                    : [
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
                        style: TextStyle(
                          color: isOfflineDisabled
                              ? Colors.grey.shade700
                              : const Color(0xFF000000),
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                        ),
                      ),
              ),
            ),
          ),
        ),
        if (isOfflineDisabled) ...[
          const SizedBox(height: 6),
          const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.cloud_off_rounded, size: 14, color: Colors.grey),
              SizedBox(width: 6),
              Text(
                'Checkout unavailable offline',
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }
}
