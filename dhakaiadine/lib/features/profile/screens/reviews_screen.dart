import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ReviewsScreen extends StatefulWidget {
  const ReviewsScreen({super.key});

  @override
  State<ReviewsScreen> createState() => _ReviewsScreenState();
}

class _ReviewsScreenState extends State<ReviewsScreen>
    with SingleTickerProviderStateMixin {
  static const _yellow = Color(0xFFF4B400);
  static const _navy = Color(0xFF1F2937);
  static const _bg = Color(0xFFFAF6EA);

  late final AnimationController _ctrl;
  late final Animation<double> _fade;

  List<Map<String, dynamic>> _reviews = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fade = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    _loadReviews();
  }

  Future<void> _loadReviews() async {
    final uid = Supabase.instance.client.auth.currentUser?.id;
    if (uid == null) {
      setState(() => _loading = false);
      _ctrl.forward();
      return;
    }
    try {
      final res = await Supabase.instance.client
          .from('reviews')
          .select()
          .eq('user_id', uid)
          .order('created_at', ascending: false);
      if (mounted) {
        setState(() {
          _reviews = List<Map<String, dynamic>>.from(res);
          _loading = false;
        });
        _ctrl.forward();
      }
    } catch (e) {
      if (mounted) {
        setState(() => _loading = false);
        _ctrl.forward();
      }
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        title: const Text('My Reviews'),
        backgroundColor: _navy,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: _yellow))
          : _reviews.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.star_rounded, size: 64, color: _yellow),
                  const SizedBox(height: 16),
                  const Text(
                    'No Reviews Yet',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: _navy,
                    ),
                  ),
                ],
              ),
            )
          : FadeTransition(
              opacity: _fade,
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: _reviews.length,
                itemBuilder: (ctx, i) => _ReviewCard(review: _reviews[i]),
              ),
            ),
    );
  }
}

class _ReviewCard extends StatelessWidget {
  const _ReviewCard({required this.review});

  final Map<String, dynamic> review;

  @override
  Widget build(BuildContext context) {
    final rating = (review['rating'] as num?)?.toInt() ?? 0;
    final comment = review['comment'] as String? ?? '';
    final createdAt = review['created_at'] as String? ?? '';
    final foodName = review['food_name'] as String? ?? 'Unknown Food';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      foodName,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1F2937),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      createdAt.split('T')[0],
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF7A8599),
                      ),
                    ),
                  ],
                ),
              ),
              Row(
                children: List.generate(5, (i) {
                  return Icon(
                    Icons.star_rounded,
                    size: 18,
                    color: i < rating
                        ? const Color(0xFFF4B400)
                        : Colors.grey[300],
                  );
                }),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            comment,
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF3E4A63),
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
