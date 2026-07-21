import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class SearchingWidget extends StatelessWidget {
  const SearchingWidget({super.key});

  @override
  Widget build(BuildContext context) {
    const navy = Color(0xFF1F2937);

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 40),
          // Searching.json (160x160)
          SizedBox(
            height: 160,
            width: 160,
            child: Lottie.asset(
              'assets/newanimation/Searching.json',
              repeat: true,
              animate: true,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Searching...',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: navy,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Finding the best dishes for you.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              color: Color(0xFF6B7280),
            ),
          ),
        ],
      ),
    );
  }
}
