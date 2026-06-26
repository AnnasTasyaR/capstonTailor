import 'api_provider.dart';
import '../models/notification_model.dart';

class NotificationProvider {
  static Future<List<NotificationModel>> getNotifications() async {
    final result = await ApiProvider.get('/api/notifications');
    final list = result['notifications'] as List? ?? [];
    return list.map((e) => NotificationModel.fromJson(e)).toList();
  }
}
