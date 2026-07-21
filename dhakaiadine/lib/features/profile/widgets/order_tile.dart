import 'package:flutter/material.dart';

class OrderTile extends StatelessWidget {
  const OrderTile({
    super.key,
    required this.order,
    required this.onViewDetails,
    required this.onOrderAgain,
  });

  final Map<String, dynamic> order;
  final VoidCallback onViewDetails;
  final VoidCallback onOrderAgain;

  @override
  Widget build(BuildContext context) {
    final status = order['status']?.toString() ?? 'completed';
    final dateStr = order['order_date']?.toString() ?? '';
    final formattedDate = _formatDateStr(dateStr);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 12,
            offset: const Offset(0, 6),
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
                  Text(
                    order['food_name']?.toString() ?? 'Food Item',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF1F2937),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Token #${order['token_number'] ?? ''} • $formattedDate',
                    style: const TextStyle(
                      fontSize: 11,
                      color: Color(0xFF6B7280),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              _buildStatusBadge(status),
            ],
          ),
          const Divider(height: 24, thickness: 1, color: Color(0xFFECECEC)),
          Row(
            children: [
              _buildDetailInfo('Branch', order['branch']?.toString() ?? 'Gulshan'),
              const SizedBox(width: 24),
              _buildDetailInfo('Payment', order['payment_method']?.toString().toUpperCase() ?? 'COD'),
              const SizedBox(width: 24),
              _buildDetailInfo('Amount', '৳${order['amount'] ?? '0.00'}', isBold: true),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: onViewDetails,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF1F2937),
                    side: const BorderSide(color: Color(0xFF1F2937)),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: const Text('View Details', style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: onOrderAgain,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFF4B400),
                    foregroundColor: const Color(0xFF1F2937),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: const Text('Order Again', style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w800)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDetailInfo(String label, String value, {bool isBold = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 10, color: Color(0xFF9CA3AF), fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: TextStyle(
            fontSize: 12.5,
            color: const Color(0xFF1F2937),
            fontWeight: isBold ? FontWeight.w800 : FontWeight.w700,
          ),
        ),
      ],
    );
  }

  Widget _buildStatusBadge(String status) {
    Color color;
    Color bgColor;
    switch (status.toLowerCase()) {
      case 'completed':
        color = const Color(0xFF22C55E);
        bgColor = const Color(0xFF22C55E).withOpacity(0.12);
        break;
      case 'pending':
      case 'preparing':
      case 'cooking':
        color = const Color(0xFFF4B400);
        bgColor = const Color(0xFFF4B400).withOpacity(0.12);
        break;
      case 'cancelled':
        color = const Color(0xFFEF4444);
        bgColor = const Color(0xFFEF4444).withOpacity(0.12);
        break;
      default:
        color = const Color(0xFF3B82F6);
        bgColor = const Color(0xFF3B82F6).withOpacity(0.12);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        status.toUpperCase(),
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }

  String _formatDateStr(String dateStr) {
    final parsed = DateTime.tryParse(dateStr);
    if (parsed == null) return dateStr;
    return '${parsed.day}/${parsed.month}/${parsed.year}';
  }
}
