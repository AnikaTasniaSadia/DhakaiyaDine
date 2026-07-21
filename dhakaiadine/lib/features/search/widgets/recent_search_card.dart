import 'package:flutter/material.dart';

class RecentSearchCard extends StatelessWidget {
  final String query;
  final VoidCallback onTap;
  final VoidCallback onDismissed;

  const RecentSearchCard({
    super.key,
    required this.query,
    required this.onTap,
    required this.onDismissed,
  });

  @override
  Widget build(BuildContext context) {
    const navy = Color(0xFF1F2937);

    return Dismissible(
      key: Key('recent-$query-${DateTime.now().millisecondsSinceEpoch}'),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => onDismissed(),
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: const Color(0xFFFFEBEE),
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(
          Icons.delete_outline_rounded,
          color: Color(0xFFE53935),
          size: 20,
        ),
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE5E7EB)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.01),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: ListTile(
          dense: true,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
          leading: const Icon(Icons.history_rounded, color: Color(0xFF9CA3AF), size: 18),
          title: Text(
            query,
            style: const TextStyle(
              color: navy,
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
          ),
          trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 12, color: Color(0xFFD1D5DB)),
          onTap: onTap,
        ),
      ),
    );
  }
}
