class AppNotification {
  final String id;
  final String userId;
  final String title;
  final String body;
  final String type;
  final String? orderId;
  final bool isRead;
  final DateTime createdAt;

  const AppNotification({
    required this.id,
    required this.userId,
    required this.title,
    this.body = '',
    this.type = 'general',
    this.orderId,
    this.isRead = false,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'user_id': userId,
        'title': title,
        'body': body,
        'type': type,
        'order_id': orderId,
        'is_read': isRead,
        'created_at': createdAt.toIso8601String(),
      };

  factory AppNotification.fromJson(Map<String, dynamic> json) => AppNotification(
        id: json['id'],
        userId: json['user_id'],
        title: json['title'],
        body: json['body'] ?? '',
        type: json['type'] ?? 'general',
        orderId: json['order_id'],
        isRead: json['is_read'] ?? false,
        createdAt: DateTime.parse(json['created_at']),
      );
}