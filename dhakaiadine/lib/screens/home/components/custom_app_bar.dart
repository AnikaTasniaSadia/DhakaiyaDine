import 'package:flutter/material.dart';

class CustomAppBar extends StatelessWidget {
  const CustomAppBar({super.key});

  static const Color _textColor = Color(0xFF212121);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _IconContainer(icon: Icons.menu_rounded, onTap: () {}),
        const Spacer(),
        Text(
          'Discover',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            color: _textColor,
            fontWeight: FontWeight.w700,
          ),
        ),
        const Spacer(),
        Row(
          children: [
            _IconContainer(icon: Icons.search_rounded, onTap: () {}),
            const SizedBox(width: 10),
            _IconContainer(
              icon: Icons.notifications_none_rounded,
              onTap: () {},
            ),
          ],
        ),
      ],
    );
  }
}

class _IconContainer extends StatelessWidget {
  const _IconContainer({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: onTap,
      child: Ink(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 12,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Icon(icon, color: const Color(0xFF212121), size: 21),
      ),
    );
  }
}
