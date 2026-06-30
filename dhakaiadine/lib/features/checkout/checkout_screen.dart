import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lottie/lottie.dart';
import 'dart:math';
import '../../models/order_model.dart';
import '../cart/widgets/order_summary_card.dart';
import '../../routes/app_router.dart';
import '../../services/cart_service.dart';
import '../../services/order_service.dart';
import 'widgets/animated_checkout_button.dart';

enum _TableStatus { available, occupied, reserved }

class _RestaurantTable {
  const _RestaurantTable({
    required this.number,
    required this.capacity,
    required this.status,
  });

  final String number;
  final int capacity;
  final _TableStatus status;

  bool get isSelectable => status == _TableStatus.available;
}

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen>
    with SingleTickerProviderStateMixin {
  String _deliveryMethod = 'home';
  String _paymentMethod = 'cash';
  String? _branch;
  String? _selectedTableNumber;
  int? _selectedTableCapacity;

  late final AnimationController _layoutFadeController;
  late final Animation<double> _layoutFadeAnimation;

  final List<_RestaurantTable> _tables = const [
    _RestaurantTable(number: 'T1', capacity: 2, status: _TableStatus.available),
    _RestaurantTable(number: 'T2', capacity: 2, status: _TableStatus.occupied),
    _RestaurantTable(number: 'T3', capacity: 2, status: _TableStatus.reserved),
    _RestaurantTable(number: 'T4', capacity: 4, status: _TableStatus.available),
    _RestaurantTable(number: 'T5', capacity: 4, status: _TableStatus.available),
    _RestaurantTable(number: 'T6', capacity: 4, status: _TableStatus.occupied),
    _RestaurantTable(number: 'T7', capacity: 6, status: _TableStatus.available),
    _RestaurantTable(number: 'T8', capacity: 6, status: _TableStatus.reserved),
  ];

  bool _counterConfirmed = false;

  bool get _isDineInReady =>
      _branch != null && _selectedTableNumber != null && _counterConfirmed;

  void _selectTable(_RestaurantTable table) {
    if (!table.isSelectable) return;
    setState(() {
      _selectedTableNumber = table.number;
      _selectedTableCapacity = table.capacity;
      _counterConfirmed = false;
    });
  }

  void _confirmCounter() {
    if (_branch == null) {
      _showError('Please select a branch first.');
      return;
    }
    if (_selectedTableNumber == null) {
      _showError('Please select a table before confirming at the counter.');
      return;
    }
    setState(() {
      _counterConfirmed = true;
    });
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        const SnackBar(content: Text('Table confirmed at counter. Ready to place order.')),
      );
  }

  // Card payment controllers
  final TextEditingController _cardNameController = TextEditingController();
  final TextEditingController _cardNumberController = TextEditingController();
  final TextEditingController _expiryController = TextEditingController();
  final TextEditingController _cvcController = TextEditingController();
  final Map<String, String?> _cardErrors = {};
  bool _isLoading = false;

  final List<String> _branches = const [
    'Dhanmondi',
    'Gulshan',
    'Banani',
    'Uttara',
  ];

  @override
  void initState() {
    super.initState();
    _layoutFadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _layoutFadeAnimation = CurvedAnimation(
      parent: _layoutFadeController,
      curve: Curves.easeOut,
    );
    _layoutFadeController.forward();
  }

  @override
  void dispose() {
    _layoutFadeController.dispose();
    _cardNameController.dispose();
    _cardNumberController.dispose();
    _expiryController.dispose();
    _cvcController.dispose();
    super.dispose();
  }

  Future<void> _placeOrder() async {
    final cart = context.read<CartService>();
    final orderService = context.read<OrderService>();

    if (_deliveryMethod == 'dinein') {
      if (_branch == null || _selectedTableNumber == null) {
        _showError('Select branch and choose a table.');
        return;
      }
    }
    // Card payment flow: validate fields, show loading, then success dialog
    if (_paymentMethod == 'card') {
      _cardErrors.clear();
      if (_cardNumberController.text.trim().isEmpty) {
        _cardErrors['number'] = 'Card number is required';
      }
      if (_expiryController.text.trim().isEmpty) {
        _cardErrors['expiry'] = 'Expiry date is required';
      }
      if (_cvcController.text.trim().isEmpty) {
        _cardErrors['cvc'] = 'CVC is required';
      }

      if (_cardErrors.isNotEmpty) {
        setState(() {});
        _showError('Please fill card details correctly.');
        return;
      }

      setState(() => _isLoading = true);
      try {
        // show brief loading for card processing demo
        await Future.delayed(const Duration(seconds: 2));

        final order = await orderService.createOrder(
          cart: cart,
          deliveryMethod: _deliveryMethod,
          paymentMethod: _paymentMethod,
          branch: _deliveryMethod == 'dinein' ? _branch : null,
          tableNumber: _deliveryMethod == 'dinein'
              ? _selectedTableNumber
              : null,
        );

        cart.clear();
        if (!mounted) return;
        setState(() => _isLoading = false);
        // show professional success dialog with Track Order
        await _showSuccessDialog(order);
      } catch (_) {
        // Fallback demo order for offline/demo mode
        final demoOrder = OrderModel(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          tokenNumber: 'DD${(Random().nextInt(9000) + 1000)}',
          status: 'received',
          total: cart.subtotal,
          deliveryFee: cart.items.isEmpty ? 0 : CartService.deliveryFee,
          grandTotal: cart.grandTotal,
          createdAt: DateTime.now(),
          deliveryMethod: _deliveryMethod,
          paymentMethod: _paymentMethod,
          branch: _deliveryMethod == 'dinein' ? _branch : null,
          tableNumber: _deliveryMethod == 'dinein' ? _selectedTableNumber : null,
        );

        cart.clear();
        if (!mounted) return;
        setState(() => _isLoading = false);
        await _showSuccessDialog(demoOrder);
      }

      return;
    }

    // Default flow for other payment methods
    setState(() => _isLoading = true);
    try {
      // simulate processing
      await Future.delayed(const Duration(seconds: 2));

      final order = await orderService.createOrder(
        cart: cart,
        deliveryMethod: _deliveryMethod,
        paymentMethod: _paymentMethod,
        branch: _deliveryMethod == 'dinein' ? _branch : null,
        tableNumber: _deliveryMethod == 'dinein'
            ? _selectedTableNumber
            : null,
      );

      cart.clear();
      if (!mounted) return;
      setState(() => _isLoading = false);
      await _showSuccessDialog(order);
    } catch (_) {
      // Fallback demo order for offline/demo mode
      final demoOrder = OrderModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        tokenNumber: 'DD${(Random().nextInt(9000) + 1000)}',
        status: 'received',
        total: cart.subtotal,
        deliveryFee: cart.items.isEmpty ? 0 : CartService.deliveryFee,
        grandTotal: cart.grandTotal,
        createdAt: DateTime.now(),
        deliveryMethod: _deliveryMethod,
        paymentMethod: _paymentMethod,
        branch: _deliveryMethod == 'dinein' ? _branch : null,
        tableNumber: _deliveryMethod == 'dinein' ? _selectedTableNumber : null,
      );

      cart.clear();
      if (!mounted) return;
      setState(() => _isLoading = false);
      await _showSuccessDialog(demoOrder);
    }
  }

  Future<void> _showSuccessDialog(dynamic order) async {
    if (!mounted) return;
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return _SuccessDialog(order: order);
      },
    );
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  Color _tableStatusColor(_TableStatus status) {
    switch (status) {
      case _TableStatus.available:
        return const Color(0xFF22C55E);
      case _TableStatus.occupied:
        return const Color(0xFFEF4444);
      case _TableStatus.reserved:
        return const Color(0xFFF97316);
    }
  }

  String _tableStatusLabel(_TableStatus status) {
    switch (status) {
      case _TableStatus.available:
        return 'Available';
      case _TableStatus.occupied:
        return 'Occupied';
      case _TableStatus.reserved:
        return 'Reserved';
    }
  }

  Widget _buildTableSelectionSection() {
    final smallTables = _tables.where((table) => table.capacity == 2).toList();
    final mediumTables = _tables.where((table) => table.capacity == 4).toList();
    final largeTables = _tables.where((table) => table.capacity == 6).toList();

    return FadeTransition(
      opacity: _layoutFadeAnimation,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 18,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Restaurant Floor Plan',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF1F2937),
                      ),
                ),
                const SizedBox(height: 10),
                Text(
                  'Tap a table to reserve your seat in style.',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: const Color(0xFF6B7280),
                      ),
                ),
                const SizedBox(height: 18),
                _buildLegendRow(),
                const SizedBox(height: 16),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFAF6EA),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Text(
                        'Entrance',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF1F2937),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        alignment: WrapAlignment.spaceBetween,
                        runSpacing: 14,
                        spacing: 14,
                        children: smallTables
                            .map((table) => _buildTableCard(table, BoxShape.circle, 105))
                            .toList(),
                      ),
                      const SizedBox(height: 20),
                      Wrap(
                        alignment: WrapAlignment.spaceBetween,
                        runSpacing: 14,
                        spacing: 14,
                        children: mediumTables
                            .map((table) => _buildTableCard(table, BoxShape.circle, 110))
                            .toList(),
                      ),
                      const SizedBox(height: 18),
                      Wrap(
                        alignment: WrapAlignment.spaceEvenly,
                        runSpacing: 14,
                        spacing: 14,
                        children: largeTables
                            .map((table) => _buildTableCard(table, BoxShape.rectangle, 140))
                            .toList(),
                      ),
                      const SizedBox(height: 18),
                      InkWell(
                        onTap: _confirmCounter,
                        borderRadius: BorderRadius.circular(16),
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          decoration: BoxDecoration(
                            color: _counterConfirmed
                                ? const Color(0xFF22C55E)
                                : const Color(0xFF1F2937),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Text(
                            _counterConfirmed ? 'Counter Confirmed' : 'Counter',
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: Color(0xFFF4B400),
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFFFFF),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.04),
                        blurRadius: 14,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Selected Table',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF1F2937),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        _selectedTableNumber != null
                            ? '$_selectedTableNumber • $_selectedTableCapacity Persons'
                            : 'No table selected yet',
                        style: TextStyle(
                          color: _selectedTableNumber != null
                              ? const Color(0xFF1F2937)
                              : const Color(0xFF6B7280),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLegendRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildLegendChip('Available', const Color(0xFF22C55E)),
        _buildLegendChip('Occupied', const Color(0xFFEF4444)),
        _buildLegendChip('Reserved', const Color(0xFFF97316)),
        _buildLegendChip('Selected', const Color(0xFFF4B400)),
      ],
    );
  }

  Widget _buildLegendChip(String label, Color color) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: const TextStyle(
            color: Color(0xFF374151),
            fontWeight: FontWeight.w600,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildTableCard(_RestaurantTable table, BoxShape shape, double size) {
    final isSelected = _selectedTableNumber == table.number;
    final borderColor = isSelected ? const Color(0xFFF4B400) : Colors.transparent;
    final backgroundColor = isSelected
        ? const Color(0xFFF4B400)
        : _tableStatusColor(table.status).withOpacity(0.2);
    final statusColor = isSelected ? const Color(0xFF1F2937) : _tableStatusColor(table.status);

    return AnimatedScale(
      duration: const Duration(milliseconds: 240),
      scale: isSelected ? 1.05 : 1,
      curve: Curves.easeOutBack,
      child: GestureDetector(
        onTap: table.isSelectable ? () => _selectTable(table) : null,
        child: Container(
          width: size,
          height: shape == BoxShape.rectangle ? 110 : size,
          constraints: shape == BoxShape.rectangle
              ? const BoxConstraints(minHeight: 110)
              : const BoxConstraints(minWidth: 105, minHeight: 105),
          decoration: BoxDecoration(
            color: backgroundColor,
            shape: shape,
            borderRadius: shape == BoxShape.rectangle ? BorderRadius.circular(18) : null,
            border: Border.all(color: borderColor, width: 2),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 16,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                table.number,
                style: TextStyle(
                  color: statusColor,
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '${table.capacity} Seats',
                style: TextStyle(
                  color: statusColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _tableStatusLabel(table.status),
                style: TextStyle(
                  color: statusColor.withOpacity(0.8),
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartService>();
  final isOrderButtonDisabled = _isLoading ||
      (_deliveryMethod == 'dinein' && !_isDineInReady);

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
              const SizedBox(height: 16),
              _buildTableSelectionSection(),
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
            const SizedBox(height: 12),
            // Animated card payment details show when 'Card' is selected
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 360),
              transitionBuilder: (child, animation) {
                final offsetAnim = Tween<Offset>(
                  begin: const Offset(0, 0.08),
                  end: Offset.zero,
                ).animate(animation);
                return FadeTransition(
                  opacity: animation,
                  child: SlideTransition(position: offsetAnim, child: child),
                );
              },
              child: _paymentMethod == 'card'
                  ? _buildCardPaymentSection(context)
                  : const SizedBox.shrink(),
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
            AbsorbPointer(
              absorbing: isOrderButtonDisabled,
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 220),
                opacity: isOrderButtonDisabled ? 0.62 : 1,
                child: AnimatedCheckoutButton(
                  label: 'Place Order',
                  isLoading: _isLoading,
                  onPressed: _placeOrder,
                ),
              ),
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

  Widget _buildCardPaymentSection(BuildContext context) {
    return Container(
      key: const ValueKey('card_section'),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 14,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Demo card UI
          Container(
            height: 160,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              gradient: const LinearGradient(
                colors: [Color(0xFF1F2937), Color(0xFF283344)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: const [
                    Text(
                      'Dhakaia Dine',
                      style: TextStyle(
                        color: Color(0xFFF4B400),
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    Icon(Icons.credit_card, color: Colors.white),
                  ],
                ),
                Text(
                  _cardNumberController.text.isEmpty
                      ? '**** **** **** 1234'
                      : _cardNumberController.text,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    letterSpacing: 2,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Card Holder',
                          style: TextStyle(color: Colors.white70),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _cardNameController.text.isEmpty
                              ? 'Full Name'
                              : _cardNameController.text,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        const Text(
                          'Expiry',
                          style: TextStyle(color: Colors.white70),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _expiryController.text.isEmpty
                              ? 'MM/YY'
                              : _expiryController.text,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          // Inputs
          _buildField('Card Holder Name', controller: _cardNameController, keyboardType: TextInputType.name),
          const SizedBox(height: 10),
          _buildField(
            'Card Number',
            controller: _cardNumberController,
            errorText: _cardErrors['number'],
            isCardNumber: true,
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _buildField(
                  'Expiry (MM/YY)',
                  controller: _expiryController,
                  errorText: _cardErrors['expiry'],
                  isExpiry: true,
                  keyboardType: TextInputType.number,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildField(
                  'CVC',
                  controller: _cvcController,
                  errorText: _cardErrors['cvc'],
                  keyboardType: TextInputType.number,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildField(
    String label, {
    required TextEditingController controller,
    String? errorText,
    bool isCardNumber = false,
    bool isExpiry = false,
    TextInputType? keyboardType,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFECECEC)),
          ),
          child: TextField(
            controller: controller,
            keyboardType: keyboardType,
            decoration: InputDecoration(
              labelText: label,
              border: InputBorder.none,
              isDense: true,
            ),
            onChanged: (val) {
              if (isCardNumber) {
                final digits = val.replaceAll(RegExp(r'[^0-9]'), '');
                final limited = digits.length > 16 ? digits.substring(0, 16) : digits;
                final groups = <String>[];
                for (var i = 0; i < limited.length; i += 4) {
                  groups.add(limited.substring(i, i + 4 > limited.length ? limited.length : i + 4));
                }
                final formatted = groups.join(' ');
                if (formatted != controller.text) {
                  controller.value = TextEditingValue(
                    text: formatted,
                    selection: TextSelection.collapsed(offset: formatted.length),
                  );
                }
                setState(() {});
                return;
              }

              if (isExpiry) {
                final digits = val.replaceAll(RegExp(r'[^0-9]'), '');
                final limited = digits.length > 4 ? digits.substring(0, 4) : digits;
                String formatted;
                if (limited.length <= 2) {
                  formatted = limited;
                } else {
                  formatted = '${limited.substring(0, 2)}/${limited.substring(2)}';
                }
                if (formatted != controller.text) {
                  controller.value = TextEditingValue(
                    text: formatted,
                    selection: TextSelection.collapsed(offset: formatted.length),
                  );
                }
                setState(() {});
                return;
              }

              setState(() {});
            },
          ),
        ),
        if (errorText != null) ...[
          const SizedBox(height: 6),
          Text(
            errorText,
            style: const TextStyle(color: Color(0xFFD32F2F), fontSize: 12),
          ),
        ],
      ],
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

class _SuccessDialog extends StatefulWidget {
  const _SuccessDialog({required this.order});

  final dynamic order;

  @override
  State<_SuccessDialog> createState() => _SuccessDialogState();
}

class _SuccessDialogState extends State<_SuccessDialog>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final token = widget.order?.tokenNumber ?? '';
    return Dialog(
      backgroundColor: Colors.transparent,
      child: FadeTransition(
        opacity: CurvedAnimation(parent: _controller, curve: Curves.easeIn),
        child: ScaleTransition(
          scale: CurvedAnimation(parent: _controller, curve: Curves.elasticOut),
          child: Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: const Color(0xFFFAF6EA),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  height: 140,
                  child: Lottie.asset(
                    'assets/Animations/order_success.json',
                    repeat: false,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Order Placed Successfully!',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 18,
                    color: Color(0xFF1F2937),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Token #$token',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF374151),
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Thank you for choosing Dhakaia Dine.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Color(0xFF374151)),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          side: const BorderSide(color: Color(0xFF1F2937)),
                        ),
                        onPressed: () {
                          Navigator.pop(context);
                          Navigator.pushNamedAndRemoveUntil(
                            context,
                            AppRouter.home,
                            (r) => false,
                          );
                        },
                        child: const Text(
                          'Back to Home',
                          style: TextStyle(color: Color(0xFF1F2937)),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFF4B400),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: () {
                          Navigator.pop(context);
                          if (widget.order != null) {
                            Navigator.pushReplacementNamed(
                              context,
                              AppRouter.orderTracking,
                              arguments: widget.order,
                            );
                          }
                        },
                        child: const Text(
                          'Track Order',
                          style: TextStyle(color: Color(0xFF1F2937)),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
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
