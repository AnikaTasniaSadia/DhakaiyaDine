import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/profile_service.dart';
import '../widgets/review_card.dart';

class ReviewsScreen extends StatefulWidget {
  const ReviewsScreen({super.key});

  @override
  State<ReviewsScreen> createState() => _ReviewsScreenState();
}

class _ReviewsScreenState extends State<ReviewsScreen> {
  static const _navy = Color(0xFF1F2937);
  static const _yellow = Color(0xFFF4B400);
  static const _bg = Color(0xFFFAF6EA);

  final TextEditingController _commentCtrl = TextEditingController();
  double _rating = 5.0;

  @override
  void dispose() {
    _commentCtrl.dispose();
    super.dispose();
  }

  void _showAddReviewSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      backgroundColor: _bg,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
                left: 16,
                right: 16,
                top: 16,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: _navy.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Write a Review',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: _navy),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Rate your overall experience:',
                    style: TextStyle(fontSize: 13, color: Color(0xFF6B7280), fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(5, (index) {
                      final starIndex = index + 1;
                      return IconButton(
                        onPressed: () {
                          setSheetState(() {
                            _rating = starIndex.toDouble();
                          });
                        },
                        icon: Icon(
                          starIndex <= _rating ? Icons.star_rounded : Icons.star_outline_rounded,
                          color: _yellow,
                          size: 36,
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Your Feedback',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: _navy),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: const Color(0xFFECECEC)),
                    ),
                    child: TextField(
                      controller: _commentCtrl,
                      maxLines: 3,
                      decoration: const InputDecoration(
                        hintText: 'Share your thoughts about our food and service...',
                        border: InputBorder.none,
                        hintStyle: TextStyle(fontSize: 13),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () async {
                        if (_commentCtrl.text.trim().isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Please enter a comment')),
                          );
                          return;
                        }

                        final profile = ProfileService.instance.profile;
                        final userName = profile?.name ?? 'User';

                        await ProfileService.instance.addReview(
                          userName: userName,
                          rating: _rating,
                          comment: _commentCtrl.text.trim(),
                        );

                        if (context.mounted) {
                          _commentCtrl.clear();
                          _rating = 5.0;
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Review submitted! Earned +20 Reward Points.')),
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _yellow,
                        foregroundColor: _navy,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                      child: const Text('Submit Review', style: TextStyle(fontWeight: FontWeight.w800)),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: ProfileService.instance,
      child: Consumer<ProfileService>(
        builder: (context, service, _) {
          final reviews = service.reviews;

          return Scaffold(
            backgroundColor: _bg,
            appBar: AppBar(
              title: const Text('Reviews & Feedback', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18)),
              backgroundColor: Colors.white,
              foregroundColor: _navy,
              elevation: 0.5,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back_ios_rounded),
                onPressed: () => Navigator.pop(context),
              ),
            ),
            body: Column(
              children: [
                Expanded(
                  child: reviews.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.rate_review_outlined, size: 72, color: Color(0xFF9CA3AF)),
                              const SizedBox(height: 16),
                              const Text(
                                'No Reviews Yet',
                                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: _navy),
                              ),
                              const SizedBox(height: 6),
                              const Text(
                                'Be the first to share your experience!',
                                style: TextStyle(fontSize: 13, color: Color(0xFF6B7280)),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          itemCount: reviews.length,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          itemBuilder: (context, index) {
                            final review = reviews[index];
                            return ReviewCard(review: review);
                          },
                        ),
                ),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    border: Border(top: BorderSide(color: Color(0xFFECECEC))),
                  ),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () => _showAddReviewSheet(context),
                      icon: const Icon(Icons.edit_note_rounded, size: 22),
                      label: const Text('Write a Review', style: TextStyle(fontWeight: FontWeight.w800)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _yellow,
                        foregroundColor: _navy,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
