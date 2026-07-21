import 'package:flutter/material.dart';
import '../models/review_model.dart';

class ReviewCard extends StatelessWidget {
  const ReviewCard({super.key, required this.review});

  final ReviewModel review;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                review.userName,
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                  color: Color(0xFF1F2937),
                ),
              ),
              Text(
                _formatDate(review.date),
                style: const TextStyle(
                  fontSize: 11,
                  color: Color(0xFF9CA3AF),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: List.generate(5, (index) {
              return Icon(
                index < review.rating.toInt() ? Icons.star_rounded : Icons.star_outline_rounded,
                color: const Color(0xFFF4B400),
                size: 16,
              );
            }),
          ),
          const SizedBox(height: 10),
          Text(
            review.comment,
            style: const TextStyle(
              fontSize: 13,
              height: 1.4,
              color: Color(0xFF374151),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
