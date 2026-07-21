import 'package:flutter/material.dart';

class SearchBarWidget extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final ValueChanged<String> onSubmitted;
  final VoidCallback onClear;

  const SearchBarWidget({
    super.key,
    required this.controller,
    required this.onChanged,
    required this.onSubmitted,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    const navy = Color(0xFF1F2937);
    const yellow = Color(0xFFF4B400);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFECECEC)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          const Icon(Icons.search_rounded, color: yellow, size: 22),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              controller: controller,
              onChanged: onChanged,
              onSubmitted: onSubmitted,
              style: const TextStyle(
                color: navy,
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
              decoration: const InputDecoration(
                hintText: 'Search by food name, category, description...',
                border: InputBorder.none,
                hintStyle: TextStyle(color: Color(0xFF9CA3AF), fontSize: 13),
              ),
            ),
          ),
          if (controller.text.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.close_rounded, color: Color(0xFF6B7280), size: 18),
              onPressed: onClear,
            ),
        ],
      ),
    );
  }
}
