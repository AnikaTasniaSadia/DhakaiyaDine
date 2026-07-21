import 'package:flutter/material.dart';

import '../../../routes/app_router.dart';
import '../../../services/auth_service.dart';
import '../services/admin_repository.dart';
import '../widgets/stat_card.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  late final Future<AdminOverview> _overviewFuture;

  @override
  void initState() {
    super.initState();
    _overviewFuture = AdminRepository.instance.loadOverview();
  }

  Future<void> _signOut() async {
    await AuthService.instance.signOut();
    if (!mounted) return;
    Navigator.of(context).pushNamedAndRemoveUntil(AppRouter.login, (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    final userEmail = AuthService.instance.currentUserEmail;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        actions: [
          IconButton(onPressed: _signOut, icon: const Icon(Icons.logout)),
        ],
      ),
      body: FutureBuilder<AdminOverview>(
        future: _overviewFuture,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final overview = snapshot.data!;
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text(
                'Welcome back, ${userEmail ?? 'Admin'}',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 16),
              Text(
                'Real-time control center for Dhakaiya Dine.',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 20),
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 1.15,
                children: [
                  StatCard(title: 'Today\'s Orders', value: overview.todayOrders.toString(), icon: Icons.receipt_long),
                  StatCard(title: 'Revenue', value: '৳${overview.revenue.toStringAsFixed(0)}', icon: Icons.attach_money),
                  StatCard(title: 'Customers', value: overview.customers.toString(), icon: Icons.people),
                  StatCard(title: 'Branches', value: overview.branches.toString(), icon: Icons.store),
                  StatCard(title: 'Foods', value: overview.foods.toString(), icon: Icons.restaurant),
                  StatCard(title: 'Tables', value: overview.tables.toString(), icon: Icons.table_bar),
                  StatCard(title: 'Reviews', value: overview.reviews.toString(), icon: Icons.star_rate),
                  StatCard(title: 'Banners', value: overview.banners.toString(), icon: Icons.panorama),
                ],
              ),
              const SizedBox(height: 20),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Role access', style: Theme.of(context).textTheme.titleMedium),
                      const SizedBox(height: 8),
                      Text('Current role: ${AuthService.instance.currentUserId ?? 'pending'}'),
                      const SizedBox(height: 8),
                      Text('Allowed roles: admin, manager, kitchen, counter'),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
