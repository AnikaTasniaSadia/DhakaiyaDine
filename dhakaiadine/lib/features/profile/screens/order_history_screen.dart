import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/profile_service.dart';
import '../widgets/order_tile.dart';

class OrderHistoryScreen extends StatefulWidget {
  const OrderHistoryScreen({super.key});

  @override
  State<OrderHistoryScreen> createState() => _OrderHistoryScreenState();
}

class _OrderHistoryScreenState extends State<OrderHistoryScreen> {
  static const _navy = Color(0xFF1F2937);
  static const _yellow = Color(0xFFF4B400);
  static const _bg = Color(0xFFFAF6EA);

  String _searchQuery = '';
  String _sortOption = 'Newest';

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: ProfileService.instance,
      child: Consumer<ProfileService>(
        builder: (context, service, _) {
          final orders = service.orders;

          // Filter by search query
          var filteredOrders = orders.where((o) {
            final name = o['food_name']?.toString().toLowerCase() ?? '';
            final token = o['token_number']?.toString().toLowerCase() ?? '';
            final query = _searchQuery.toLowerCase();
            return name.contains(query) || token.contains(query);
          }).toList();

          // Filter/Sort option
          if (_sortOption == 'Newest') {
            filteredOrders.sort((a, b) => b['order_date'].toString().compareTo(a['order_date'].toString()));
          } else if (_sortOption == 'Oldest') {
            filteredOrders.sort((a, b) => a['order_date'].toString().compareTo(b['order_date'].toString()));
          } else if (_sortOption == 'Pending') {
            filteredOrders = filteredOrders.where((o) => o['status'].toString().toLowerCase() == 'pending' || o['status'].toString().toLowerCase() == 'preparing').toList();
          } else if (_sortOption == 'Completed') {
            filteredOrders = filteredOrders.where((o) => o['status'].toString().toLowerCase() == 'completed').toList();
          } else if (_sortOption == 'Cancelled') {
            filteredOrders = filteredOrders.where((o) => o['status'].toString().toLowerCase() == 'cancelled').toList();
          }

          return Scaffold(
            backgroundColor: _bg,
            appBar: AppBar(
              title: const Text('Order History', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18)),
              backgroundColor: Colors.white,
              foregroundColor: _navy,
              elevation: 0.5,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back_ios_rounded),
                onPressed: () => Navigator.pop(context),
              ),
            ),
            body: Column(
              children: [
                // Search and Filter Bar
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                  child: Row(
                    children: [
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: const Color(0xFFECECEC)),
                          ),
                          child: TextField(
                            onChanged: (val) {
                              setState(() {
                                _searchQuery = val;
                              });
                            },
                            decoration: const InputDecoration(
                              icon: Icon(Icons.search_rounded, color: _yellow),
                              hintText: 'Search orders...',
                              border: InputBorder.none,
                              hintStyle: TextStyle(fontSize: 14),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: const Color(0xFFECECEC)),
                        ),
                        child: DropdownButton<String>(
                          value: _sortOption,
                          underline: const SizedBox(),
                          icon: const Icon(Icons.filter_list_rounded, color: _yellow),
                          items: ['Newest', 'Oldest', 'Pending', 'Completed', 'Cancelled']
                              .map((opt) => DropdownMenuItem(value: opt, child: Text(opt, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold))))
                              .toList(),
                          onChanged: (val) {
                            if (val != null) {
                              setState(() {
                                _sortOption = val;
                              });
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                ),

                // Order history list
                Expanded(
                  child: filteredOrders.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.receipt_long_outlined, size: 72, color: Color(0xFF9CA3AF)),
                              const SizedBox(height: 16),
                              const Text(
                                'No Orders Found',
                                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: _navy),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                _searchQuery.isEmpty ? 'You haven\'t ordered anything yet.' : 'Try searching for something else.',
                                style: const TextStyle(fontSize: 13, color: Color(0xFF6B7280)),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          itemCount: filteredOrders.length,
                          padding: const EdgeInsets.only(bottom: 24),
                          itemBuilder: (context, index) {
                            final order = filteredOrders[index];
                            return OrderTile(
                              order: order,
                              onViewDetails: () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Order Token: ${order['token_number']}')),
                                );
                              },
                              onOrderAgain: () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Added to cart. Please check your cart.')),
                                );
                              },
                            );
                          },
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
