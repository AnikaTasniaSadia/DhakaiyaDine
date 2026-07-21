import 'package:flutter/material.dart';

import '../../../routes/app_router.dart';
import '../../../services/rbac_service.dart';

class RoleGuard extends StatefulWidget {
  const RoleGuard({super.key, required this.child});

  final Widget child;

  @override
  State<RoleGuard> createState() => _RoleGuardState();
}

class _RoleGuardState extends State<RoleGuard> {
  String? _role;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadRole();
  }

  Future<void> _loadRole() async {
    final role = await RbacService.instance.resolveRole();
    if (!mounted) return;
    setState(() {
      _role = role;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    if (RbacService.canAccessAdmin(_role)) {
      return widget.child;
    }
    return const _UnauthorizedView();
  }
}

class _UnauthorizedView extends StatelessWidget {
  const _UnauthorizedView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.lock_outline, size: 64),
              const SizedBox(height: 16),
              Text(
                'Access restricted',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 8),
              const Text('This area is for restaurant staff members only.'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => Navigator.of(
                  context,
                ).pushNamedAndRemoveUntil(AppRouter.home, (route) => false),
                child: const Text('Back to customer app'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
