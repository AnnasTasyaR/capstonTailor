import 'api_provider.dart';

class ActivityLogProvider {
  static Future<List<Map<String, dynamic>>> getActivityLogs() async {
    final result = await ApiProvider.get('/api/activity-logs');
    return List<Map<String, dynamic>>.from(result['activity_logs'] ?? []);
  }
}
