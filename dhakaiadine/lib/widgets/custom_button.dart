import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/connectivity_provider.dart';

class CustomButton extends StatefulWidget {
  const CustomButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.isLoading = false,
    this.isOutlined = false,
    this.disableOffline = false,
  });

  final String label;
  final VoidCallback onPressed;
  final bool isLoading;
  final bool isOutlined;
  final bool disableOffline;

  @override
  State<CustomButton> createState() => _CustomButtonState();
}

class _CustomButtonState extends State<CustomButton> {
  double _scale = 1;

  @override
  Widget build(BuildContext context) {
    final connectivity = Provider.of<ConnectivityProvider>(context);
    final isOfflineDisabled = widget.disableOffline && !connectivity.isConnected;

    final buttonChild = widget.isLoading
        ? const SizedBox(
            width: 22,
            height: 22,
            child: CircularProgressIndicator(
              strokeWidth: 2.4,
              valueColor: AlwaysStoppedAnimation<Color>(
                Color.fromARGB(255, 255, 255, 255),
              ),
            ),
          )
        : Text(widget.label);

    final disabledStyle = widget.isOutlined
        ? OutlinedButton.styleFrom(
            foregroundColor: Colors.grey,
            minimumSize: const Size(double.infinity, 54),
            side: const BorderSide(width: 1.4, color: Colors.grey),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          )
        : ElevatedButton.styleFrom(
            backgroundColor: Colors.grey.shade300,
            foregroundColor: Colors.grey.shade600,
            minimumSize: const Size(double.infinity, 54),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          );

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTapDown: isOfflineDisabled ? null : (_) => setState(() => _scale = 0.97),
          onTapUp: isOfflineDisabled ? null : (_) => setState(() => _scale = 1),
          onTapCancel: isOfflineDisabled ? null : () => setState(() => _scale = 1),
          onTap: isOfflineDisabled
              ? () {
                  ScaffoldMessenger.of(context).hideCurrentSnackBar();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      backgroundColor: const Color(0xFFD32F2F),
                      content: Text('${widget.label} is unavailable offline.'),
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
            duration: const Duration(milliseconds: 110),
            child: IgnorePointer(
              ignoring: true, // Let GestureDetector handle taps
              child: SizedBox(
                width: double.infinity,
                child: widget.isOutlined
                    ? OutlinedButton(
                        onPressed: () {},
                        style: isOfflineDisabled
                            ? disabledStyle
                            : OutlinedButton.styleFrom(
                                foregroundColor: Colors.black,
                                minimumSize: const Size(double.infinity, 54),
                                side: const BorderSide(width: 1.4, color: Colors.black),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),
                        child: Text(widget.label),
                      )
                    : ElevatedButton(
                        onPressed: () {},
                        style: isOfflineDisabled
                            ? disabledStyle
                            : ElevatedButton.styleFrom(
                                backgroundColor: Theme.of(context).colorScheme.primary,
                                foregroundColor: Theme.of(context).colorScheme.onPrimary,
                                minimumSize: const Size(double.infinity, 54),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),
                        child: buttonChild,
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
                'Unavailable offline',
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
