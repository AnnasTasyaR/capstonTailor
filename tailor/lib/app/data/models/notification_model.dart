class NotificationModel {
  final int id;
  final int userId;
  final String message;
  final bool isRead;
  final String? createdAt;

  NotificationModel({
    required this.id,
    required this.userId,
    required this.message,
    this.isRead = false,
    this.createdAt,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'] ?? 0,
      userId: json['user_id'] ?? 0,
      message: json['message'] ?? '',
      isRead: json['is_read'] ?? false,
      createdAt: json['created_at'],
    );
  }
}
