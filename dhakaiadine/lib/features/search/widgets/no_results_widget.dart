import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'search_suggestion_chip.dart';

class NoResultsWidget extends StatelessWidget {
  final ValueChanged<String> onSelectChip;

  const NoResultsWidget({
    super.key,
    required this.onSelectChip,
  });

  @override
  Widget build(BuildContext context) {
    const navy = Color(0xFF1F2937);

    final suggestions = ['Burger', 'Pizza', 'Coffee', 'Chicken', 'Desserts'];

    return Center(
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 20),
            // foodie.json
            SizedBox(
              height: 180,
              width: 180,
              child: Lottie.asset(
                'assets/newanimation/foodie.json',
                repeat: true,
                animate: true,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'No Matching Food Found',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: navy,
              ),
            ),
            const SizedBox(height: 6),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.0),
              child: Text(
                "We couldn't find any dishes matching your search.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13,
                  color: Color(0xFF6B7280),
                ),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Suggestions',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: navy,
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              alignment: WrapAlignment.center,
              children: suggestions.map((chip) {
                return SearchSuggestionChip(
                  label: chip,
                  onTap: () => onSelectChip(chip),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
