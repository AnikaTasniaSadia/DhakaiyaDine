import 'dart:typed_data';

import 'package:supabase_flutter/supabase_flutter.dart';

class AdminOverview {
  const AdminOverview({
    required this.todayOrders,
    required this.revenue,
    required this.customers,
    required this.branches,
    required this.foods,
    required this.tables,
    required this.reviews,
    required this.banners,
  });

  final int todayOrders;
  final double revenue;
  final int customers;
  final int branches;
  final int foods;
  final int tables;
  final int reviews;
  final int banners;
}

class AdminRepository {
  AdminRepository._();

  static final AdminRepository instance = AdminRepository._();

  final SupabaseClient _client = Supabase.instance.client;

  Stream<List<Map<String, dynamic>>> watchCollection(String tableName) {
    return _client.from(tableName).stream(primaryKey: ['id']).order('created_at');
  }

  Future<AdminOverview> loadOverview() async {
    try {
      final today = DateTime.now();
      final start = DateTime(today.year, today.month, today.day).toIso8601String();
      final end = DateTime(today.year, today.month, today.day + 1).toIso8601String();

      final [orders, branches, foods, tables, reviews, banners, users, sales] =
          await Future.wait([
        _client.from('orders').select('id').limit(200),
        _client.from('branches').select('id'),
        _client.from('foods').select('id'),
        _client.from('tables').select('id'),
        _client.from('reviews').select('id'),
        _client.from('banners').select('id'),
        _client.from('users').select('id'),
        _client
            .from('orders')
            .select('grand_total, created_at')
            .gte('created_at', start)
            .lt('created_at', end),
      ]);

      final salesRows = sales as List<dynamic>;
      final revenue = salesRows.fold<double>(0, (sum, row) {
        final value = row['grand_total'];
        if (value is num) {
          return sum + value.toDouble();
        }
        return sum;
      });

      return AdminOverview(
        todayOrders: (orders as List).length,
        revenue: revenue,
        customers: (users as List).length,
        branches: (branches as List).length,
        foods: (foods as List).length,
        tables: (tables as List).length,
        reviews: (reviews as List).length,
        banners: (banners as List).length,
      );
    } catch (_) {
      return const AdminOverview(
        todayOrders: 0,
        revenue: 0,
        customers: 0,
        branches: 0,
        foods: 0,
        tables: 0,
        reviews: 0,
        banners: 0,
      );
    }
  }

  Future<void> upsertRecord(String tableName, {String? id, required Map<String, dynamic> payload}) async {
    if (id == null || id.isEmpty) {
      await _client.from(tableName).insert(payload);
      return;
    }

    await _client.from(tableName).update(payload).eq('id', id);
  }

  Future<void> deleteRecord(String tableName, String id) async {
    await _client.from(tableName).delete().eq('id', id);
  }

  Future<void> createBranch(Map<String, dynamic> payload) async {
    await _client.from('branches').insert(payload);
  }

  Future<void> updateBranch(String id, Map<String, dynamic> payload) async {
    await _client.from('branches').update(payload).eq('id', id);
  }

  Future<void> deleteBranch(String id) async {
    await _client.from('branches').delete().eq('id', id);
  }

  Future<void> createFood(Map<String, dynamic> payload) async {
    await _client.from('foods').insert(payload);
  }

  Future<void> updateFood(String id, Map<String, dynamic> payload) async {
    await _client.from('foods').update(payload).eq('id', id);
  }

  Future<void> deleteFood(String id) async {
    await _client.from('foods').delete().eq('id', id);
  }

  Future<void> createBanner(Map<String, dynamic> payload) async {
    await _client.from('banners').insert(payload);
  }

  Future<void> updateBanner(String id, Map<String, dynamic> payload) async {
    await _client.from('banners').update(payload).eq('id', id);
  }

  Future<void> deleteBanner(String id) async {
    await _client.from('banners').delete().eq('id', id);
  }

  Future<void> createTable(Map<String, dynamic> payload) async {
    await _client.from('tables').insert(payload);
  }

  Future<void> updateTable(String id, Map<String, dynamic> payload) async {
    await _client.from('tables').update(payload).eq('id', id);
  }

  Future<void> deleteTable(String id) async {
    await _client.from('tables').delete().eq('id', id);
  }

  Future<void> updateOrderStatus(String id, String status) async {
    await _client.from('orders').update({'status': status}).eq('id', id);
  }

  Future<void> deleteReview(String id) async {
    await _client.from('reviews').delete().eq('id', id);
  }

  Future<void> replyReview(String id, String reply) async {
    await _client.from('reviews').update({'reply': reply}).eq('id', id);
  }

  Future<void> uploadImage({
    required String bucket,
    required String fileName,
    required String mimeType,
    required List<int> bytes,
  }) async {
    await _client.storage.from(bucket).uploadBinary(
      fileName,
      Uint8List.fromList(bytes),
      fileOptions: const FileOptions(cacheControl: '3600', upsert: false),
    );
  }
}
