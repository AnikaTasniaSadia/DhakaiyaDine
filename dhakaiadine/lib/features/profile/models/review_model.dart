class ReviewModel {
  final String id;
  final String userName;
  final double rating;
  final String comment;
  final DateTime date;

  const ReviewModel({
    required this.id,
    required this.userName,
    required this.rating,
    required this.comment,
    required this.date,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userName': userName,
      'rating': rating,
      'comment': comment,
      'date': date.toIso8601String(),
    };
  }

  factory ReviewModel.fromMap(Map<String, dynamic> map) {
    return ReviewModel(
      id: map['id']?.toString() ?? '',
      userName: map['userName']?.toString() ?? 'Guest User',
      rating: (map['rating'] as num?)?.toDouble() ?? 5.0,
      comment: map['comment']?.toString() ?? '',
      date: DateTime.tryParse(map['date']?.toString() ?? '') ?? DateTime.now(),
    );
  }
}
