class NotificationModel {
  final String id;
  final String title;
  final String body;
  final DateTime date;
  final bool isRead;
  final String type; // e.g. order, offer, coupon

  const NotificationModel({
    required this.id,
    required this.title,
    required this.body,
    required this.date,
    required this.isRead,
    required this.type,
  });

  NotificationModel copyWith({
    bool? isRead,
  }) {
    return NotificationModel(
      id: id,
      title: title,
      body: body,
      date: date,
      isRead: isRead ?? this.isRead,
      type: type,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'body': body,
      'date': date.toIso8601String(),
      'isRead': isRead,
      'type': type,
    };
  }

  factory NotificationModel.fromMap(Map<String, dynamic> map) {
    return NotificationModel(
      id: map['id']?.toString() ?? '',
      title: map['title']?.toString() ?? '',
      body: map['body']?.toString() ?? '',
      date: DateTime.tryParse(map['date']?.toString() ?? '') ?? DateTime.now(),
      isRead: map['isRead'] as bool? ?? false,
      type: map['type']?.toString() ?? 'order',
    );
  }
}
