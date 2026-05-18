import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../cart/widgets/order_summary_card.dart';
import '../../routes/app_router.dart';
import '../../services/cart_service.dart';
import '../../services/order_service.dart';
import 'widgets/animated_checkout_button.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  String _deliveryMethod = 'home';
  String _paymentMethod = 'cash';
  String? _branch;
  final TextEditingController _tableController = TextEditingController();
  bool _isLoading = false;

  final List<String> _branches = const [
    'Dhanmondi',
    'Gulshan',
    'Banani',
    'Uttara',
  ];

  @override
  void dispose() {
    _tableController.dispose();
    super.dispose();
  }

  Future<void> _placeOrder() async {
    final cart = context.read<CartService>();
    final orderService = context.read<OrderService>();

    if (_deliveryMethod == 'dinein') {
      if (_branch == null || _tableController.text.trim().isEmpty) {
        _showError('Select branch and enter table number.');
        return;
      }
    }

    setState(() => _isLoading = true);
    try {
      final order = await orderService.createOrder(
        cart: cart,
        deliveryMethod: _deliveryMethod,
        paymentMethod: _paymentMethod,
        branch: _deliveryMethod == 'dinein' ? _branch : null,
        tableNumber: _deliveryMethod == 'dinein'
            ? _tableController.text.trim()
            : null,
      );

      cart.clear();
      if (!mounted) return;
      Navigator.pushReplacementNamed(
        context,
        AppRouter.orderConfirmation,
        arguments: order,
      );
    } catch (_) {
      _showError('Unable to place order right now.');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartService>();

    return Scaffold(
      backgroundColor: const Color(0xFFFFF8E1),
      appBar: AppBar(title: const Text('Checkout')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 10, 20, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _SectionTitle(title: 'Delivery Method'),
            const SizedBox(height: 12),
            _OptionRow(
              options: const [
                _OptionData('home', 'Home Delivery', Icons.delivery_dining),
                _OptionData('dinein', 'Dine-In', Icons.restaurant_rounded),
              ],
              value: _deliveryMethod,
              onChanged: (value) => setState(() => _deliveryMethod = value),
            ),
            const SizedBox(height: 20),
            if (_deliveryMethod == 'dinein') ...[
              _SectionTitle(title: 'Dine-In Details'),
              const SizedBox(height: 12),
              _DropdownCard(
                label: 'Select Branch',
                value: _branch,
                items: _branches,
                onChanged: (value) => setState(() => _branch = value),
              ),
              const SizedBox(height: 12),
              _InputCard(
                label: 'Table Number',
                controller: _tableController,
                hintText: 'e.g., A12',
              ),
              const SizedBox(height: 20),
            ],
            _SectionTitle(title: 'Payment Method'),
            const SizedBox(height: 12),
            _OptionRow(
              options: const [
                _OptionData('cash', 'Cash on Delivery', Icons.payments_rounded),
                _OptionData('card', 'Card', Icons.credit_card_rounded),
                _OptionData('mobile', 'Mobile Banking', Icons.phone_android),
              ],
              value: _paymentMethod,
              onChanged: (value) => setState(() => _paymentMethod = value),
            ),
            const SizedBox(height: 20),
            _SectionTitle(title: 'Order Summary'),
            const SizedBox(height: 12),
            OrderSummaryCard(
              subtotal: cart.subtotal,
              deliveryFee: cart.items.isEmpty ? 0 : CartService.deliveryFee,
              grandTotal: cart.grandTotal,
            ),
            const SizedBox(height: 20),
            AnimatedCheckoutButton(
              label: 'Place Order',
              isLoading: _isLoading,
              onPressed: _placeOrder,
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () => Navigator.pushNamed(context, AppRouter.cart),
              child: const Text('Back to Cart'),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleMedium?.copyWith(
        fontWeight: FontWeight.w700,
        color: const Color(0xFF212121),
      ),
    );
  }
}

class _OptionRow extends StatelessWidget {
  const _OptionRow({
    required this.options,
    required this.value,
    required this.onChanged,
  });

  final List<_OptionData> options;
  final String value;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: options
          .map(
            (option) => _OptionCard(
              data: option,
              isSelected: value == option.value,
              onTap: () => onChanged(option.value),
            ),
          )
          .toList(),
    );
  }
}

class _OptionCard extends StatelessWidget {
  const _OptionCard({
    required this.data,
    required this.isSelected,
    required this.onTap,
  });

  final _OptionData data;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOut,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: isSelected ? const Color(0xFFFFC107) : Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isSelected ? const Color(0xFFFFC107) : const Color(0xFFE0E0E0),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: InkWell(
        onTap: onTap,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(data.icon, color: const Color(0xFF212121), size: 18),
            const SizedBox(width: 8),
            Text(
              data.label,
              style: const TextStyle(
                color: Color(0xFF212121),
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DropdownCard extends StatelessWidget {
  const _DropdownCard({
    required this.label,
    required this.items,
    required this.value,
    required this.onChanged,
  });

  final String label;
  final List<String> items;
  final String? value;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: DropdownButtonFormField<String>(
        initialValue: value,
        decoration: InputDecoration(labelText: label, border: InputBorder.none),
        items: items
            .map((item) => DropdownMenuItem(value: item, child: Text(item)))
            .toList(),
        onChanged: onChanged,
      ),
    );
  }
}

class _InputCard extends StatelessWidget {
  const _InputCard({
    required this.label,
    required this.controller,
    required this.hintText,
  });

  final String label;
  final TextEditingController controller;
  final String hintText;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          hintText: hintText,
          border: InputBorder.none,
        ),
      ),
    );
  }
}

class _OptionData {
  const _OptionData(this.value, this.label, this.icon);

  final String value;
  final String label;
  final IconData icon;
}
