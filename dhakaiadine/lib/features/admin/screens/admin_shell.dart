import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../routes/app_router.dart';
import '../../../services/auth_service.dart';
import 'admin_dashboard_screen.dart';
import 'admin_management_screen.dart';

class AdminShell extends StatefulWidget {
  const AdminShell({super.key});

  @override
  State<AdminShell> createState() => _AdminShellState();
}

class _AdminShellState extends State<AdminShell> {
  int _selectedIndex = 0;

  final _pages = <Widget>[
    const AdminDashboardScreen(),
    AdminManagementScreen(
      title: 'Branches',
      tableName: 'branches',
      itemLabel: 'Branch',
      fields: [
        AdminFieldDefinition(key: 'name', label: 'Name'),
        AdminFieldDefinition(key: 'address', label: 'Address'),
        AdminFieldDefinition(key: 'opening_hours', label: 'Opening Hours'),
        AdminFieldDefinition(key: 'image_url', label: 'Image URL'),
      ],
    ),
    AdminManagementScreen(
      title: 'Foods',
      tableName: 'foods',
      itemLabel: 'Food',
      fields: [
        AdminFieldDefinition(key: 'name', label: 'Name'),
        AdminFieldDefinition(key: 'price', label: 'Price', isNumber: true),
        AdminFieldDefinition(
          key: 'discount',
          label: 'Discount',
          isNumber: true,
        ),
        AdminFieldDefinition(key: 'available', label: 'Available'),
        AdminFieldDefinition(key: 'image_url', label: 'Image URL'),
      ],
    ),
    AdminManagementScreen(
      title: 'Banners',
      tableName: 'banners',
      itemLabel: 'Banner',
      fields: [
        AdminFieldDefinition(key: 'title', label: 'Title'),
        AdminFieldDefinition(key: 'image_url', label: 'Image URL'),
        AdminFieldDefinition(key: 'active', label: 'Active'),
      ],
    ),
    AdminManagementScreen(
      title: 'Tables',
      tableName: 'tables',
      itemLabel: 'Table',
      fields: [
        AdminFieldDefinition(key: 'name', label: 'Name'),
        AdminFieldDefinition(key: 'status', label: 'Status'),
        AdminFieldDefinition(
          key: 'capacity',
          label: 'Capacity',
          isNumber: true,
        ),
      ],
    ),
    AdminManagementScreen(
      title: 'Orders',
      tableName: 'orders',
      itemLabel: 'Order',
      fields: [
        AdminFieldDefinition(key: 'token_number', label: 'Token'),
        AdminFieldDefinition(key: 'status', label: 'Status'),
        AdminFieldDefinition(
          key: 'grand_total',
          label: 'Grand Total',
          isNumber: true,
        ),
      ],
    ),
    AdminManagementScreen(
      title: 'Reviews',
      tableName: 'reviews',
      itemLabel: 'Review',
      fields: [
        AdminFieldDefinition(key: 'customer_name', label: 'Customer Name'),
        AdminFieldDefinition(key: 'rating', label: 'Rating', isNumber: true),
        AdminFieldDefinition(
          key: 'comment',
          label: 'Comment',
          isMultiline: true,
        ),
        AdminFieldDefinition(key: 'reply', label: 'Reply'),
      ],
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dhakaiya Dine Admin'),
        actions: [
          IconButton(
            onPressed: () async {
              await AuthService.instance.signOut();
              if (!mounted) return;
              Navigator.of(
                context,
              ).pushNamedAndRemoveUntil(AppRouter.login, (route) => false);
            },
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: _pages[_selectedIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) =>
            setState(() => _selectedIndex = index),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          NavigationDestination(icon: Icon(Icons.store), label: 'Branches'),
          NavigationDestination(
            icon: Icon(Icons.restaurant_menu),
            label: 'Foods',
          ),
          NavigationDestination(
            icon: Icon(Icons.photo_library),
            label: 'Banners',
          ),
          NavigationDestination(icon: Icon(Icons.table_bar), label: 'Tables'),
          NavigationDestination(
            icon: Icon(Icons.receipt_long),
            label: 'Orders',
          ),
          NavigationDestination(icon: Icon(Icons.star_rate), label: 'Reviews'),
        ],
      ),
    );
  }
}

class _PlaceholderPage extends StatelessWidget {
  const _PlaceholderPage({required this.title, required this.icon});

  final String title;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 56, color: Colors.amber.shade700),
          const SizedBox(height: 12),
          Text(title, style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),
          const Text('Management screens will be wired here in the next step.'),
        ],
      ),
    );
  }
}
