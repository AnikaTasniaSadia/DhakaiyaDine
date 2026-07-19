import 'dart:math';

import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/order_model.dart';
import 'cart_service.dart';

class OrderService {
  OrderService({SupabaseClient? client})
    : _client = client ?? Supabase.instance.client;

  final SupabaseClient _client;

  Future<OrderModel> createOrder({
    required CartService cart,
    required String deliveryMethod,
    required String paymentMethod,
    String? branch,
    String? tableNumber,
  }) async {
    final token = _generateToken();
    final uid = _client.auth.currentUser?.id;
    final orderPayload = {
      'user_id': uid,
      'token_number': token,
      'status': 'received',
      'total': cart.subtotal,
      'delivery_fee': cart.items.isEmpty ? 0 : CartService.deliveryFee,
      'grand_total': cart.grandTotal,
      'delivery_method': deliveryMethod,
      'payment_method': paymentMethod,
      'branch': branch,
      'table_number': tableNumber,
      'created_at': DateTime.now().toIso8601String(),
    };

    final inserted = await _client
        .from('orders')
        .insert(orderPayload)
        .select()
        .single();
    final orderId = inserted['id'].toString();

    final itemPayloads = cart.items
        .map((item) => item.toOrderItemMap(orderId))
        .toList(growable: false);

    if (itemPayloads.isNotEmpty) {
      await _client.from('order_items').insert(itemPayloads);
    }

    return OrderModel.fromMap(inserted);
  }

  Future<OrderModel?> fetchOrder(String orderId) async {
    final response = await _client
        .from('orders')
        .select()
        .eq('id', orderId)
        .maybeSingle();
    if (response == null) return null;
    return OrderModel.fromMap(response);
  }

  Stream<String> watchOrderStatus(String orderId) {
    return _client
        .from('orders')
        .stream(primaryKey: ['id'])
        .eq('id', orderId)
        .map((rows) {
          if (rows.isEmpty) return 'received';
          return rows.first['status']?.toString() ?? 'received';
        });
  }

  String _generateToken() {
    final random = Random();
    final number = 100 + random.nextInt(900);
    return 'A$number';
  }
}
