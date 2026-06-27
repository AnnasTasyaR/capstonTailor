import 'api_provider.dart';
import '../models/notification_model.dart';

class NotificationProvider {
  static Future<List<NotificationModel>> getNotifications() async {
    final result = await ApiProvider.get('/api/notifications');
    final list = result['notifications'] as List? ?? [];
    return list.map((e) => NotificationModel.fromJson(e)).toList();
  }

  static Future<void> markAsRead(int id) async {
    await ApiProvider.put('/api/notifications/$id/read');
  }

  static Future<void> markAllAsRead() async {
    await ApiProvider.put('/api/notifications/read-all');
  }

  static Future<Map<String, dynamic>> getUnreadCount() async {
    return await ApiProvider.get('/api/notifications');
  }
}
