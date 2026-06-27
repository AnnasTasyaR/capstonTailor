import 'package:get/get.dart';
import '../../../data/providers/activity_log_provider.dart';

class ActivityLogController extends GetxController {
  final logs = <Map<String, dynamic>>[].obs;
  final isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadLogs();
  }

  Future<void> loadLogs() async {
    isLoading.value = true;
    try {
      logs.value = await ActivityLogProvider.getActivityLogs();
    } catch (_) {
      Get.snackbar('Error', 'Tidak dapat memuat aktivitas', snackPosition: SnackPosition.BOTTOM);
    } finally {
      isLoading.value = false;
    }
  }

  String activityIcon(String type) {
    switch (type) {
      case 'login':
        return 'login';
      case 'logout':
        return 'logout';
      case 'checkout':
        return 'checkout';
      default:
        return 'info';
    }
  }
}
