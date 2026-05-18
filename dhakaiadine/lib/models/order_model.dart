class OrderModel {
  const OrderModel({
    required this.id,
    required this.tokenNumber,
    required this.status,
    required this.total,
    required this.deliveryFee,
    required this.grandTotal,
    required this.createdAt,
    required this.deliveryMethod,
    required this.paymentMethod,
    this.branch,
    this.tableNumber,
  });

  final String id;
  final String tokenNumber;
  final String status;
  final double total;
  final double deliveryFee;
  final double grandTotal;
  final DateTime createdAt;
  final String deliveryMethod;
  final String paymentMethod;
  final String? branch;
  final String? tableNumber;

  factory OrderModel.fromMap(Map<String, dynamic> data) {
    return OrderModel(
      id: data['id']?.toString() ?? '',
      tokenNumber: data['token_number']?.toString() ?? '',
      status: data['status']?.toString() ?? 'received',
      total: (data['total'] as num?)?.toDouble() ?? 0,
      deliveryFee: (data['delivery_fee'] as num?)?.toDouble() ?? 0,
      grandTotal: (data['grand_total'] as num?)?.toDouble() ?? 0,
      createdAt:
          DateTime.tryParse(data['created_at']?.toString() ?? '') ??
          DateTime.now(),
      deliveryMethod: data['delivery_method']?.toString() ?? 'home',
      paymentMethod: data['payment_method']?.toString() ?? 'cash',
      branch: data['branch']?.toString(),
      tableNumber: data['table_number']?.toString(),
    );
  }
}
