import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lottie/lottie.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../models/order_model.dart';
import '../../routes/app_router.dart';
import '../../services/order_tracking_service.dart';

const List<String> _statusOrder = [
  'received',
  'accepted',
  'preparing',
  'cooking',
  'ready/On delivery',
  'collected/delivered',
];

class OrderTrackingScreen extends StatefulWidget {
  const OrderTrackingScreen({super.key, required this.order});

  final OrderModel order;

  @override
  State<OrderTrackingScreen> createState() => _OrderTrackingScreenState();
}

class _OrderTrackingScreenState extends State<OrderTrackingScreen> {
  List<Map<String, dynamic>> _orderItems = [];
  String? _lastStatus;

  @override
  void initState() {
    super.initState();
    _loadOrderItems();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final service = context.read<OrderTrackingService>();
      _lastStatus = service.activeStatus;
      service.addListener(_onStatusChanged);
      if (!service.isActive || service.activeOrderId != widget.order.id) {
        service.startTracking(
          orderId: widget.order.id,
          token: widget.order.tokenNumber ?? 'DD1024',
          amount: widget.order.grandTotal,
          paymentMethod: widget.order.paymentMethod,
          orderType: widget.order.deliveryMethod == 'delivery'
              ? 'Delivery'
              : 'Dine-In',
          tableNumber: widget.order.tableNumber,
        );
      }
    });
  }

  Future<void> _loadOrderItems() async {
    if (widget.order.id.isEmpty) return;
    try {
      final res = await Supabase.instance.client
          .from('order_items')
          .select()
          .eq('order_id', widget.order.id);
      if (mounted) {
        setState(() {
          _orderItems = List<Map<String, dynamic>>.from(res);
        });
      }
    } catch (e) {
      debugPrint('Error loading order items: $e');
    }
  }

  String _formatRemainingTime(OrderTrackingService service) {
    if (service.activeStatus == 'ready/On delivery' ||
        service.activeStatus == 'collected/delivered') {
      return '00:00';
    }
    final int remaining = (120 - service.secondsElapsed).clamp(0, 120);
    final minutes = (remaining ~/ 60).toString().padLeft(2, '0');
    final seconds = (remaining % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  double _getProgressFraction(OrderTrackingService service) {
    if (service.activeStatus == 'ready/On delivery' ||
        service.activeStatus == 'collected/delivered') {
      return 1.0;
    }
    return (service.secondsElapsed / 120.0).clamp(0.0, 1.0);
  }

  void _showFoodReadyDialog(
    BuildContext context,
    OrderTrackingService service,
  ) {
    if (service.dialogShown) return;
    service.dialogShown = true;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFFFAF6EA),
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.12),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  height: 150,
                  child: Lottie.asset(
                    'assets/newanimation/Delivery.json',
                    repeat: false,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Your food is ready!',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 20,
                    color: Color(0xFF1F2937),
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Please collect your order from Counter A',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF4B5563),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Token: ${service.activeToken}',
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 16,
                    color: Color(0xFFF4B400),
                  ),
                ),
                const SizedBox(height: 18),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      service.collectFood();
                      Navigator.pop(ctx);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFF4B400),
                      foregroundColor: const Color(0xFF1F2937),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text('Collect Food'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  String _getLiveStatusMessage(String status) {
    switch (status) {
      case 'received':
        return 'We received your order.';
      case 'accepted':
        return 'Chef has accepted your order.';
      case 'preparing':
        return 'Chef has started preparing your meal.';
      case 'cooking':
        return 'Your food is being cooked to perfection.';
      case 'ready':
        return 'Your food is ready! Please collect your order from Counter A.';
      case 'collected':
        return 'Your order has been collected. Thank you!';
      default:
        return 'Processing your order...';
    }
  }

  @override
  void dispose() {
    try {
      context.read<OrderTrackingService>().removeListener(_onStatusChanged);
    } catch (_) {}
    super.dispose();
  }

  void _onStatusChanged() {
    if (!mounted) return;
    final service = context.read<OrderTrackingService>();
    final newStatus = service.activeStatus;
    if (newStatus != _lastStatus) {
      final oldStatus = _lastStatus;
      _lastStatus = newStatus;
      if (oldStatus != null) {
        _showStatusNotification(newStatus);
      }
    }
  }

  void _showStatusNotification(String status) {
    final info = getOrderStatusInfo(status);

    IconData iconData;
    switch (status) {
      case 'received':
        iconData = Icons.receipt_long_rounded;
        break;
      case 'accepted':
        iconData = Icons.thumb_up_alt_rounded;
        break;
      case 'preparing':
        iconData = Icons.room_service_rounded;
        break;
      case 'cooking':
        iconData = Icons.outdoor_grill_rounded;
        break;
      case 'ready/On delivery':
        iconData = Icons.check_circle_rounded;
        break;
      case 'collected/delivered':
        iconData = Icons.done_all_rounded;
        break;
      default:
        iconData = Icons.info_rounded;
    }

    const goldColor = Color(0xFFF4B400);
    const navyColor = Color(0xFF1F2937);

    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: navyColor,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: goldColor, width: 1.5),
        ),
        content: Row(
          children: [
            Icon(iconData, color: goldColor, size: 24),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    info.title,
                    style: const TextStyle(
                      color: goldColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    info.notificationMessage,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final trackingService = context.watch<OrderTrackingService>();

    if (widget.order.id.isEmpty && !trackingService.isActive) {
      return Scaffold(
        backgroundColor: const Color(0xFFFAF6EA),
        appBar: AppBar(
          title: const Text('Order Tracking'),
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.shopping_bag_outlined,
                size: 72,
                color: Color(0xFF9CA3AF),
              ),
              const SizedBox(height: 16),
              const Text(
                'No Active Orders',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF1F2937),
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Browse our menu and place your order first.',
                style: TextStyle(fontSize: 13, color: Color(0xFF6B7280)),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  Navigator.pushReplacementNamed(context, AppRouter.home);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFF4B400),
                  foregroundColor: const Color(0xFF1F2937),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('Order Now'),
              ),
            ],
          ),
        ),
      );
    }

    if (trackingService.activeStatus == 'ready/On delivery' &&
        !trackingService.dialogShown) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showFoodReadyDialog(context, trackingService);
      });
    }

    final isDineIn = widget.order.deliveryMethod == 'dinein';

    return Scaffold(
      backgroundColor: const Color(0xFFFAF6EA),
      appBar: AppBar(
        title: const Text(
          'Order Tracking',
          style: TextStyle(
            color: Color(0xFF1F2937),
            fontWeight: FontWeight.w800,
            fontSize: 18,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0.5,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_rounded,
            color: Color(0xFF1F2937),
          ),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.notifications_none_rounded,
              color: Color(0xFF1F2937),
            ),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('No new notifications')),
              );
            },
          ),
          IconButton(
            icon: const Icon(
              Icons.help_outline_rounded,
              color: Color(0xFF1F2937),
            ),
            onPressed: () {
              Navigator.pushNamed(context, AppRouter.help);
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        child: Column(
          children: [
            // Countdown Widget (Only if not collected)
            if (trackingService.activeStatus != 'collected/delivered') ...[
              CountdownWidget(
                timeLabel: _formatRemainingTime(trackingService),
                progress: _getProgressFraction(trackingService),
              ),
              const SizedBox(height: 24),
            ],

            // Live status card with message
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 360),
              child: Container(
                key: ValueKey(trackingService.activeStatus),
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  vertical: 14,
                  horizontal: 16,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF1F2937),
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.restaurant_rounded,
                      color: Color(0xFFF4B400),
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        _getLiveStatusMessage(trackingService.activeStatus),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Chef progress card
            ChefProgress(status: trackingService.activeStatus),
            const SizedBox(height: 16),

            // Order summary card
            OrderSummaryCard(
              order: widget.order,
              statusLabel: trackingService.activeStatus.toUpperCase(),
              remainingTime:
                  '${(120 - trackingService.secondsElapsed).clamp(0, 120) ~/ 60} Min',
            ),
            const SizedBox(height: 24),

            // Redesigned status card with Lottie animations below Order Summary
            OrderStatusCard(
              status: trackingService.activeStatus,
              remainingTime: _formatRemainingTime(trackingService),
            ),
            const SizedBox(height: 24),

            // Timeline card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 16,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Tracking Status',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF1F2937),
                    ),
                  ),
                  const SizedBox(height: 20),
                  TrackingTimeline(currentStatus: trackingService.activeStatus),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Rating card (Only if status is collected)
            if (trackingService.activeStatus == 'collected/delivered') ...[
              RatingCard(
                onLeaveReview: (rating, comment) {
                  // Review submission logic
                },
              ),
              const SizedBox(height: 16),
            ],

            // Expandable details list
            OrderItemsCard(
              items: _orderItems,
              totalAmount: widget.order.grandTotal,
            ),
            const SizedBox(height: 16),

            // Dine in Table info card
            if (isDineIn && widget.order.tableNumber != null) ...[
              TableInformationCard(
                branch: widget.order.branch ?? 'Gulshan',
                tableNumber: widget.order.tableNumber!,
              ),
              const SizedBox(height: 16),
            ],

            // Payment card
            PaymentInformationCard(
              paymentMethod: widget.order.paymentMethod,
              orderId: widget.order.id,
            ),
            const SizedBox(height: 24),

            // Action Buttons
            ActionButtons(
              onRefresh: () {
                _loadOrderItems();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Status refreshed')),
                );
              },
              onCall: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Calling Restaurant at +8801700000000'),
                  ),
                );
              },
              onCancel: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Order cannot be cancelled after acceptance'),
                  ),
                );
              },
              onReorder: () async {
                await Future.delayed(const Duration(seconds: 1));
                if (!mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Items added to cart')),
                );
                Navigator.pushNamed(context, AppRouter.cart);
              },
              canCancel: trackingService.activeStatus == 'received',
            ),
            const SizedBox(height: 24),

            // Support info card
            SupportCard(
              onCall: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Calling support...')),
                );
              },
              onChat: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Opening Chat Support...')),
                );
              },
              onFAQ: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Opening FAQ Section...')),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class CountdownWidget extends StatelessWidget {
  const CountdownWidget({
    super.key,
    required this.timeLabel,
    required this.progress,
  });

  final String timeLabel;
  final double progress;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            SizedBox(
              width: 140,
              height: 140,
              child: CircularProgressIndicator(
                value: 1.0,
                strokeWidth: 8,
                valueColor: AlwaysStoppedAnimation<Color>(
                  const Color(0xFF1F2937).withValues(alpha: 0.1),
                ),
              ),
            ),
            SizedBox(
              width: 140,
              height: 140,
              child: CircularProgressIndicator(
                value: progress,
                strokeWidth: 8,
                valueColor: const AlwaysStoppedAnimation<Color>(
                  Color(0xFFF4B400),
                ),
                strokeCap: StrokeCap.round,
              ),
            ),
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  timeLabel,
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF1F2937),
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Remaining',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF6B7280),
                  ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 12),
        const Text(
          'Estimated Food Preparation Time',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: Color(0xFF1F2937),
          ),
        ),
      ],
    );
  }
}

class ChefProgress extends StatelessWidget {
  const ChefProgress({super.key, required this.status});

  final String status;

  double _getPercentage() {
    switch (status) {
      case 'received':
        return 0.05;
      case 'accepted':
        return 0.10;
      case 'preparing':
        return 0.20;
      case 'cooking':
        return 0.35;
      case 'ready/On delivery':
        return 0.80;
      case 'collected/delivered':
        return 1.0;
      default:
        return 0.0;
    }
  }

  String _getProgressTitle() {
    switch (status) {
      case 'received':
        return 'Received';
      case 'accepted':
        return 'Accepted';
      case 'preparing':
        return 'Preparing';
      case 'cooking':
        return 'Cooking';
      case 'ready/On delivery':
        return 'Ready';
      case 'collected/delivered':
        return 'Collected';
      default:
        return 'Preparing Food';
    }
  }

  String _getProgressText(double progress) {
    if (status == 'collected/delivered') {
      return 'Completed';
    }
    return '${(progress * 100).toInt()}%';
  }

  @override
  Widget build(BuildContext context) {
    final progress = _getPercentage();
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _getProgressTitle(),
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1F2937),
                ),
              ),
              Text(
                _getProgressText(progress),
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFFF4B400),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: TweenAnimationBuilder<double>(
              tween: Tween<double>(begin: 0.0, end: progress),
              duration: const Duration(milliseconds: 600),
              curve: Curves.easeOut,
              builder: (context, val, _) {
                return LinearProgressIndicator(
                  value: val,
                  minHeight: 6,
                  backgroundColor: const Color(0xFFFAF6EA),
                  valueColor: const AlwaysStoppedAnimation<Color>(
                    Color(0xFFF4B400),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class OrderSummaryCard extends StatelessWidget {
  const OrderSummaryCard({
    super.key,
    required this.order,
    required this.statusLabel,
    required this.remainingTime,
  });

  final OrderModel order;
  final String statusLabel;
  final String remainingTime;

  @override
  Widget build(BuildContext context) {
    final isDineIn = order.deliveryMethod == 'dinein';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.85),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(0.6), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Order Token',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF6B7280),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    order.tokenNumber,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF1F2937),
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFF4B400).withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  statusLabel,
                  style: const TextStyle(
                    color: Color(0xFFF4B400),
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          const Divider(height: 24, thickness: 1, color: Color(0xFFECECEC)),
          _buildInfoRow(
            Icons.access_time_rounded,
            'Estimated Time',
            remainingTime,
          ),
          const SizedBox(height: 10),
          _buildInfoRow(
            Icons.storefront_rounded,
            'Branch',
            order.branch ?? 'Gulshan',
          ),
          const SizedBox(height: 10),
          _buildInfoRow(
            Icons.calendar_today_rounded,
            'Order Time',
            _formatTime(order.createdAt),
          ),
          const SizedBox(height: 10),
          _buildInfoRow(
            Icons.payment_rounded,
            'Payment Method',
            order.paymentMethod.toUpperCase(),
          ),
          const SizedBox(height: 10),
          _buildInfoRow(
            Icons.restaurant_menu_rounded,
            'Order Type',
            isDineIn ? 'Dine-In' : 'Delivery',
          ),
          if (isDineIn && order.tableNumber != null) ...[
            const SizedBox(height: 10),
            _buildInfoRow(
              Icons.table_restaurant_rounded,
              'Table',
              order.tableNumber!,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 18, color: const Color(0xFF6B7280)),
        const SizedBox(width: 8),
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            color: Color(0xFF6B7280),
            fontWeight: FontWeight.w500,
          ),
        ),
        const Spacer(),
        Text(
          value,
          style: const TextStyle(
            fontSize: 13,
            color: Color(0xFF1F2937),
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }

  String _formatTime(DateTime dateTime) {
    final hour = dateTime.hour > 12
        ? dateTime.hour - 12
        : (dateTime.hour == 0 ? 12 : dateTime.hour);
    final ampm = dateTime.hour >= 12 ? 'PM' : 'AM';
    final minute = dateTime.minute.toString().padLeft(2, '0');
    return '$hour:$minute $ampm';
  }
}

class TrackingTimeline extends StatelessWidget {
  const TrackingTimeline({super.key, required this.currentStatus});

  final String currentStatus;

  @override
  Widget build(BuildContext context) {
    final steps = const [
      _TimelineStepData(
        statusKey: 'received',
        title: 'Received',
        description: 'We received your order.',
        icon: Icons.receipt_long_rounded,
      ),
      _TimelineStepData(
        statusKey: 'accepted',
        title: 'Accepted',
        description: 'Chef has accepted your order.',
        icon: Icons.thumb_up_alt_rounded,
      ),
      _TimelineStepData(
        statusKey: 'preparing',
        title: 'Preparing',
        description: 'Chef has started preparing your meal.',
        icon: Icons.room_service_rounded,
      ),
      _TimelineStepData(
        statusKey: 'cooking',
        title: 'Cooking',
        description: 'Your food is being cooked to perfection.',
        icon: Icons.outdoor_grill_rounded,
      ),
      _TimelineStepData(
        statusKey: 'ready/On delivery',
        title: 'Ready',
        description: 'Please collect your order from Counter A.',
        icon: Icons.check_circle_rounded,
      ),
      _TimelineStepData(
        statusKey: 'collected/delivered',
        title: 'Collected',
        description: 'Your order has been collected.',
        icon: Icons.done_all_rounded,
      ),
    ];

    final currentIndex = _statusOrder.indexOf(currentStatus);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: List.generate(steps.length, (index) {
        final step = steps[index];
        final isCompleted = index < currentIndex;
        final isCurrent = index == currentIndex;
        final isUpcoming = index > currentIndex;

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              children: [
                _buildTimelineIndicator(
                  context,
                  isCompleted,
                  isCurrent,
                  isUpcoming,
                  step.icon,
                ),
                if (index < steps.length - 1)
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    width: 2.5,
                    height: 40,
                    color: isCompleted
                        ? const Color(0xFF22C55E)
                        : const Color(0xFFE5E7EB),
                  ),
              ],
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(top: 2),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AnimatedDefaultTextStyle(
                      duration: const Duration(milliseconds: 300),
                      style: TextStyle(
                        fontSize: 14,
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w700,
                        color: isUpcoming
                            ? const Color(0xFF9CA3AF)
                            : const Color(0xFF1F2937),
                      ),
                      child: Text(step.title),
                    ),
                    const SizedBox(height: 4),
                    AnimatedDefaultTextStyle(
                      duration: const Duration(milliseconds: 300),
                      style: TextStyle(
                        fontSize: 12,
                        fontFamily: 'Poppins',
                        color: isUpcoming
                            ? const Color(0xFF9CA3AF)
                            : const Color(0xFF6B7280),
                        fontWeight: FontWeight.w500,
                      ),
                      child: Text(step.description),
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildTimelineIndicator(
    BuildContext context,
    bool isCompleted,
    bool isCurrent,
    bool isUpcoming,
    IconData iconData,
  ) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 350),
      transitionBuilder: (child, animation) {
        return ScaleTransition(scale: animation, child: child);
      },
      child: isCompleted
          ? Container(
              key: const ValueKey('completed'),
              width: 32,
              height: 32,
              decoration: const BoxDecoration(
                color: Color(0xFF22C55E),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check_rounded,
                color: Colors.white,
                size: 16,
              ),
            )
          : isCurrent
          ? _PulseTimelineIndicator(
              key: const ValueKey('current'),
              iconData: iconData,
            )
          : Container(
              key: const ValueKey('upcoming'),
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFFE5E7EB), width: 2),
              ),
              child: Icon(iconData, color: const Color(0xFF9CA3AF), size: 16),
            ),
    );
  }
}

class _TimelineStepData {
  final String statusKey;
  final String title;
  final String description;
  final IconData icon;

  const _TimelineStepData({
    required this.statusKey,
    required this.title,
    required this.description,
    required this.icon,
  });
}

class _PulseTimelineIndicator extends StatefulWidget {
  const _PulseTimelineIndicator({super.key, required this.iconData});

  final IconData iconData;

  @override
  State<_PulseTimelineIndicator> createState() =>
      _PulseTimelineIndicatorState();
}

class _PulseTimelineIndicatorState extends State<_PulseTimelineIndicator>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scaleAnimation;
  late final Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat(reverse: true);

    _scaleAnimation = Tween<double>(
      begin: 0.9,
      end: 1.15,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
    _opacityAnimation = Tween<double>(
      begin: 0.5,
      end: 0.15,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        AnimatedBuilder(
          animation: _controller,
          builder: (context, _) {
            return Container(
              width: 44 * _scaleAnimation.value,
              height: 44 * _scaleAnimation.value,
              decoration: BoxDecoration(
                color: const Color(
                  0xFFF4B400,
                ).withOpacity(_opacityAnimation.value),
                shape: BoxShape.circle,
              ),
            );
          },
        ),
        Container(
          width: 32,
          height: 32,
          decoration: const BoxDecoration(
            color: Color(0xFFF4B400),
            shape: BoxShape.circle,
          ),
          child: Icon(
            widget.iconData,
            color: const Color(0xFF1F2937),
            size: 16,
          ),
        ),
      ],
    );
  }
}

class RatingCard extends StatefulWidget {
  const RatingCard({super.key, required this.onLeaveReview});

  final Function(int rating, String comment) onLeaveReview;

  @override
  State<RatingCard> createState() => _RatingCardState();
}

class _RatingCardState extends State<RatingCard> {
  int _rating = 5;
  final TextEditingController _commentCtrl = TextEditingController();

  @override
  void dispose() {
    _commentCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFFFAF6EA),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: const Color(0xFFF4B400).withValues(alpha: 0.3),
          width: 1.5,
        ),
      ),
      child: Column(
        children: [
          const Text(
            'Thank You!',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: Color(0xFF1F2937),
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Hope you enjoyed your meal.',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: Color(0xFF6B7280),
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'Rate Your Experience',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1F2937),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(5, (index) {
              final starIndex = index + 1;
              return IconButton(
                onPressed: () => setState(() => _rating = starIndex),
                icon: Icon(
                  starIndex <= _rating
                      ? Icons.star_rounded
                      : Icons.star_outline_rounded,
                  color: const Color(0xFFF4B400),
                  size: 32,
                ),
              );
            }),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFECECEC)),
            ),
            child: TextField(
              controller: _commentCtrl,
              decoration: const InputDecoration(
                hintText: 'Leave a comment (optional)...',
                border: InputBorder.none,
                hintStyle: TextStyle(fontSize: 13),
              ),
            ),
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                widget.onLeaveReview(_rating, _commentCtrl.text);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Thank you for your feedback!')),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1F2937),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('Leave Review'),
            ),
          ),
        ],
      ),
    );
  }
}

class OrderItemsCard extends StatefulWidget {
  const OrderItemsCard({
    super.key,
    required this.items,
    required this.totalAmount,
  });

  final List<Map<String, dynamic>> items;
  final double totalAmount;

  @override
  State<OrderItemsCard> createState() => _OrderItemsCardState();
}

class _OrderItemsCardState extends State<OrderItemsCard> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          ListTile(
            title: const Text(
              'Order Details',
              style: TextStyle(
                fontWeight: FontWeight.w700,
                color: Color(0xFF1F2937),
                fontSize: 14,
              ),
            ),
            subtitle: Text(
              '${widget.items.length} items',
              style: const TextStyle(fontSize: 12, color: Color(0xFF6B7280)),
            ),
            trailing: Icon(
              _expanded ? Icons.expand_less_rounded : Icons.expand_more_rounded,
              color: const Color(0xFF1F2937),
            ),
            onTap: () => setState(() => _expanded = !_expanded),
          ),
          AnimatedSize(
            duration: const Duration(milliseconds: 240),
            curve: Curves.easeInOut,
            child: _expanded
                ? Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Divider(height: 16, color: Color(0xFFECECEC)),
                        ...widget.items.map(
                          (item) => Padding(
                            padding: const EdgeInsets.symmetric(vertical: 6),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  '${item['name']} ×${item['quantity']}',
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF374151),
                                  ),
                                ),
                                Text(
                                  '৳${((item['unit_price'] as num?)?.toDouble() ?? 0) * ((item['quantity'] as num?)?.toInt() ?? 0)}',
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFF1F2937),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const Divider(height: 24, color: Color(0xFFECECEC)),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Total Amount',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF1F2937),
                              ),
                            ),
                            Text(
                              '৳${widget.totalAmount.toStringAsFixed(2)}',
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFFF4B400),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  )
                : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }
}

class TableInformationCard extends StatelessWidget {
  const TableInformationCard({
    super.key,
    required this.branch,
    required this.tableNumber,
  });

  final String branch;
  final String tableNumber;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.table_restaurant_rounded,
                color: Color(0xFFF4B400),
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Table Information',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF1F2937),
                ),
              ),
            ],
          ),
          const Divider(height: 20, thickness: 1, color: Color(0xFFECECEC)),
          _buildInfoRow('Branch', branch),
          const SizedBox(height: 8),
          _buildInfoRow('Selected Table', tableNumber),
          const SizedBox(height: 8),
          _buildInfoRow('Table Capacity', '4 Persons'),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Table Status',
                style: TextStyle(
                  color: Color(0xFF6B7280),
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFE5E7EB),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'Reserved',
                  style: TextStyle(
                    color: Color(0xFF1F2937),
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Color(0xFF6B7280),
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            color: Color(0xFF1F2937),
            fontSize: 13,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

class PaymentInformationCard extends StatelessWidget {
  const PaymentInformationCard({
    super.key,
    required this.paymentMethod,
    required this.orderId,
  });

  final String paymentMethod;
  final String orderId;

  @override
  Widget build(BuildContext context) {
    final txnId = 'TXN${orderId.hashCode.abs().toString().padLeft(9, '0')}';
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.payment_rounded,
                color: Color(0xFFF4B400),
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Payment Details',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF1F2937),
                ),
              ),
            ],
          ),
          const Divider(height: 20, thickness: 1, color: Color(0xFFECECEC)),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Payment Status',
                style: TextStyle(
                  color: Color(0xFF6B7280),
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF22C55E).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'Paid',
                  style: TextStyle(
                    color: Color(0xFF22C55E),
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          _buildInfoRow('Payment Method', paymentMethod.toUpperCase()),
          const SizedBox(height: 8),
          _buildInfoRow('Transaction ID', txnId),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Color(0xFF6B7280),
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            color: Color(0xFF1F2937),
            fontSize: 13,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

class ActionButtons extends StatelessWidget {
  const ActionButtons({
    super.key,
    required this.onRefresh,
    required this.onCall,
    required this.onCancel,
    required this.onReorder,
    required this.canCancel,
  });

  final VoidCallback onRefresh;
  final VoidCallback onCall;
  final VoidCallback onCancel;
  final VoidCallback onReorder;
  final bool canCancel;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: onRefresh,
                icon: const Icon(Icons.refresh_rounded, size: 18),
                label: const Text('Refresh Status'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFF4B400),
                  foregroundColor: const Color(0xFF1F2937),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: onCall,
                icon: const Icon(Icons.phone_rounded, size: 18),
                label: const Text('Call Restaurant'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFF1F2937),
                  side: const BorderSide(color: Color(0xFF1F2937)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            if (canCancel)
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: onCancel,
                  icon: const Icon(Icons.cancel_rounded, size: 18),
                  label: const Text('Cancel Order'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFFEF4444),
                    side: const BorderSide(color: Color(0xFFEF4444)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),
            if (canCancel) const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: onReorder,
                icon: const Icon(Icons.shopping_bag_rounded, size: 18),
                label: const Text('Reorder'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1F2937),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class SupportCard extends StatelessWidget {
  const SupportCard({
    super.key,
    required this.onCall,
    required this.onChat,
    required this.onFAQ,
  });

  final VoidCallback onCall;
  final VoidCallback onChat;
  final VoidCallback onFAQ;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Need Help?',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w700,
              color: const Color(0xFF1F2937),
            ),
          ),
          const SizedBox(height: 12),
          _buildSupportOption(Icons.phone_rounded, 'Call Restaurant', onCall),
          _buildSupportOption(
            Icons.chat_bubble_outline_rounded,
            'Chat Support',
            onChat,
          ),
          _buildSupportOption(
            Icons.help_outline_rounded,
            'FAQ & Guides',
            onFAQ,
          ),
        ],
      ),
    );
  }

  Widget _buildSupportOption(IconData icon, String label, VoidCallback onTap) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: const Color(0xFFFAF6EA),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: const Color(0xFFF4B400), size: 18),
      ),
      title: Text(
        label,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: Color(0xFF1F2937),
        ),
      ),
      trailing: const Icon(
        Icons.arrow_forward_ios_rounded,
        size: 14,
        color: Color(0xFF6B7280),
      ),
      onTap: onTap,
      contentPadding: EdgeInsets.zero,
    );
  }
}

class OrderStatusInfo {
  final String lottiePath;
  final String title;
  final String message;
  final double progress;
  final String notificationMessage;

  const OrderStatusInfo({
    required this.lottiePath,
    required this.title,
    required this.message,
    required this.progress,
    required this.notificationMessage,
  });
}

OrderStatusInfo getOrderStatusInfo(String status) {
  switch (status) {
    case 'received':
      return const OrderStatusInfo(
        lottiePath: 'assets/Animations/order_success.json',
        title: 'Received',
        message: 'We received your order.',
        progress: 0.10,
        notificationMessage: 'We received your order.',
      );
    case 'accepted':
      return const OrderStatusInfo(
        lottiePath: 'assets/newanimation/Accepted.json',
        title: 'Accepted',
        message: 'Chef has accepted your order.',
        progress: 0.15,
        notificationMessage: 'Chef has accepted your order.',
      );
    case 'preparing':
      return const OrderStatusInfo(
        lottiePath: 'assets/newanimation/Preparing.json',
        title: 'Preparing',
        message: 'Chef has started preparing your meal.',
        progress: 0.20,
        notificationMessage: 'Chef has started preparing your meal.',
      );
    case 'cooking':
      return const OrderStatusInfo(
        lottiePath: 'assets/newanimation/cooking.json',
        title: 'Cooking',
        message: 'Your food is being cooked to perfection.',
        progress: 0.30,
        notificationMessage: 'Your food is now being cooked.',
      );
    case 'ready/On delivery':
      return const OrderStatusInfo(
        lottiePath: 'assets/newanimation/Delivery.json',
        title: 'Ready',
        message: 'Your food is ready!',
        progress: 0.60,
        notificationMessage: 'Your food is ready!',
      );
    case 'collected/delivered':
      return const OrderStatusInfo(
        lottiePath: 'assets/Animations/order_success.json',
        title: 'Collected',
        message: 'Your order has been collected. Thank you!',
        progress: 1.00,
        notificationMessage: 'Thank you! Enjoy your meal.',
      );
    default:
      return const OrderStatusInfo(
        lottiePath: 'assets/Animations/order_success.json',
        title: 'Processing',
        message: 'Processing your order...',
        progress: 0.0,
        notificationMessage: 'Processing your order...',
      );
  }
}

class OrderStatusAnimation extends StatelessWidget {
  const OrderStatusAnimation({
    super.key,
    required this.status,
    this.width = 220,
    this.height = 220,
  });

  final String status;
  final double width;
  final double height;

  @override
  Widget build(BuildContext context) {
    final info = getOrderStatusInfo(status);

    return SizedBox(
      width: width,
      height: height,
      child: Lottie.asset(
        info.lottiePath,
        repeat: true,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) => Container(
          width: width,
          height: height,
          color: Colors.grey[200],
          child: const Icon(
            Icons.fastfood_rounded,
            size: 64,
            color: Colors.grey,
          ),
        ),
      ),
    );
  }
}

class OrderStatusCard extends StatelessWidget {
  const OrderStatusCard({
    super.key,
    required this.status,
    required this.remainingTime,
  });

  final String status;
  final String remainingTime;

  @override
  Widget build(BuildContext context) {
    final info = getOrderStatusInfo(status);
    const goldColor = Color(0xFFF4B400);
    const navyColor = Color(0xFF1F2937);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Center(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 500),
              transitionBuilder: (child, animation) {
                return FadeTransition(
                  opacity: animation,
                  child: ScaleTransition(scale: animation, child: child),
                );
              },
              child: OrderStatusAnimation(
                key: ValueKey<String>(status),
                status: status,
                width: 220,
                height: 220,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            info.title,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: navyColor,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            info.message,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: navyColor.withOpacity(0.65),
              height: 1.4,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 20),
          const Divider(color: Colors.black12, height: 1),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Remaining Time',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    remainingTime,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: navyColor,
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Text(
                    'Progress',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    status == 'collected/delivered'
                        ? 'Completed'
                        : '${(info.progress * 100).toInt()}%',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: goldColor,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
