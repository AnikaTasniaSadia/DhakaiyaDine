import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/order_model.dart';
import '../../services/order_service.dart';
import 'widgets/token_card.dart';

class OrderTrackingScreen extends StatefulWidget {
  const OrderTrackingScreen({super.key, required this.order});

  final OrderModel order;

  @override
  State<OrderTrackingScreen> createState() => _OrderTrackingScreenState();
}

class _OrderTrackingScreenState extends State<OrderTrackingScreen>
    with TickerProviderStateMixin {
  late final AnimationController _timerController;
  late final AnimationController _pulseController;
  late final StreamSubscription<String>? _statusSubscription;

  String _status = 'received';

  @override
  void initState() {
    super.initState();
    _status = widget.order.status;
    _timerController = AnimationController(
      vsync: this,
      duration: const Duration(minutes: 1),
    )..forward();

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _statusSubscription = _startStatusListener();
  }

  StreamSubscription<String>? _startStatusListener() {
    if (widget.order.id.isEmpty) {
      _timerController.addListener(_updateStatusFromTimer);
      return null;
    }

    return context
        .read<OrderService>()
        .watchOrderStatus(widget.order.id)
        .listen((status) {
          if (!mounted) return;
          setState(() => _status = status);
        });
  }

  void _updateStatusFromTimer() {
    if (!mounted) return;
    final progress = _timerController.value;
    final nextStatus = _statusFromProgress(progress);
    if (nextStatus != _status) {
      setState(() => _status = nextStatus);
    }
  }

  String _statusFromProgress(double progress) {
    if (progress < 0.33) return 'received';
    if (progress < 0.7) return 'preparing';
    return 'ready';
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'preparing':
        return const Color(0xFFFF9800);
      case 'ready':
        return const Color(0xFF4CAF50);
      default:
        return const Color(0xFFFFC107);
    }
  }

  String _statusLabel(String status) {
    switch (status) {
      case 'preparing':
        return 'Preparing your food...';
      case 'ready':
        return 'Your food is ready';
      default:
        return 'We received your order';
    }
  }

  String _formatRemaining() {
    final totalMs = _timerController.duration!.inMilliseconds;
    final remainingMs = (totalMs * (1 - _timerController.value)).round();
    final remaining = Duration(milliseconds: remainingMs).inSeconds;
    final minutes = (remaining ~/ 60).toString().padLeft(2, '0');
    final seconds = (remaining % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds remaining';
  }

  bool _isLowTime() {
    final totalMs = _timerController.duration!.inMilliseconds;
    final remainingMs = (totalMs * (1 - _timerController.value)).round();
    final remaining = Duration(milliseconds: remainingMs).inSeconds;
    return remaining <= 120 && _status != 'ready';
  }

  @override
  void dispose() {
    _statusSubscription?.cancel();
    _timerController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final statusColor = _statusColor(_status);

    if (_isLowTime() && !_pulseController.isAnimating) {
      _pulseController.repeat(reverse: true);
    } else if (!_isLowTime() && _pulseController.isAnimating) {
      _pulseController.stop();
    }

    return Scaffold(
      backgroundColor: const Color(0xFFFFF8E1),
      appBar: AppBar(title: const Text('Order Tracking')),
      body: AnimatedBuilder(
        animation: _timerController,
        builder: (context, _) {
          return Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TokenCard(
                  tokenNumber: widget.order.tokenNumber,
                  statusText: _statusLabel(_status),
                  remainingTime: _formatRemaining(),
                  progress: _timerController.value,
                  statusColor: statusColor,
                  pulse: _pulseController,
                ),
                const SizedBox(height: 24),
                _StatusTimeline(currentStatus: _status),
                const Spacer(),
                if (_status == 'ready')
                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.08),
                          blurRadius: 18,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: const Color(0xFF4CAF50),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: const Icon(
                            Icons.check_rounded,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Text(
                            'Your food is ready for pickup',
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF212121),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _StatusTimeline extends StatelessWidget {
  const _StatusTimeline({required this.currentStatus});

  final String currentStatus;

  @override
  Widget build(BuildContext context) {
    final steps = const [
      _StatusStep('received', 'Received', Color(0xFFFFC107)),
      _StatusStep('preparing', 'Preparing', Color(0xFFFF9800)),
      _StatusStep('ready', 'Ready', Color(0xFF4CAF50)),
    ];

    return Column(
      children: steps
          .map(
            (step) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 220),
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: _isActive(step.key) ? step.color : Colors.white,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: step.color, width: 2),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    step.label,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: _isActive(step.key)
                          ? const Color(0xFF212121)
                          : const Color(0xFF757575),
                    ),
                  ),
                ],
              ),
            ),
          )
          .toList(),
    );
  }

  bool _isActive(String key) {
    const order = ['received', 'preparing', 'ready'];
    return order.indexOf(key) <= order.indexOf(currentStatus);
  }
}

class _StatusStep {
  const _StatusStep(this.key, this.label, this.color);

  final String key;
  final String label;
  final Color color;
}
