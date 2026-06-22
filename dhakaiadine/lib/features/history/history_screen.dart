import 'package:flutter/material.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F2E4),
      appBar: AppBar(
        title: const Text('Order History'),
        backgroundColor: const Color(0xFFF8F2E4),
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Your Orders',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.w700,
                color: const Color(0xFF212121),
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: _dummyOrders.length,
                itemBuilder: (context, index) {
                  final order = _dummyOrders[index];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _OrderCard(order: order),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OrderCard extends StatelessWidget {
  const _OrderCard({required this.order});

  final OrderItem order;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Order #${order.id}',
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF212121),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: _getStatusColor(order.status).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    order.status,
                    style: TextStyle(
                      color: _getStatusColor(order.status),
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              order.items,
              style: const TextStyle(color: Color(0xFF757575)),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  order.date,
                  style: const TextStyle(
                    color: Color(0xFF757575),
                    fontSize: 12,
                  ),
                ),
                Text(
                  '৳${order.amount}',
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF212121),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Delivered':
        return Colors.green;
      case 'Preparing':
        return const Color(0xFFFFC107);
      case 'Cancelled':
        return Colors.red;
      default:
        return const Color(0xFF757575);
    }
  }
}

class OrderItem {
  final String id;
  final String items;
  final String date;
  final String amount;
  final String status;

  OrderItem({
    required this.id,
    required this.items,
    required this.date,
    required this.amount,
    required this.status,
  });
}

final List<OrderItem> _dummyOrders = [
  OrderItem(
    id: 'A123',
    items: '2x Chicken Biryani, 1x Beef Tehari',
    date: 'Today, 2:30 PM',
    amount: '850',
    status: 'Delivered',
  ),
  OrderItem(
    id: 'A122',
    items: '1x Hilsa Fish Curry, 2x Rice',
    date: 'Yesterday, 7:45 PM',
    amount: '650',
    status: 'Delivered',
  ),
  OrderItem(
    id: 'A121',
    items: '3x Chicken Karahi, 1x Naan',
    date: '2 days ago, 1:15 PM',
    amount: '750',
    status: 'Delivered',
  ),
];