import 'package:flutter/material.dart';

class PlaceholderManagementScreen extends StatelessWidget {
  const PlaceholderManagementScreen({super.key, required this.title, required this.icon});

  final String title;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 64, color: Colors.amber.shade700),
            const SizedBox(height: 12),
            Text('Management for $title is ready for expansion.', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            const Text('The repository layer and realtime listeners are already wired for this module.'),
          ],
        ),
      ),
    );
  }
}
