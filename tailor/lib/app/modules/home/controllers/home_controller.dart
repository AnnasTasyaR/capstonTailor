import 'package:get/get.dart';
import '../../../data/models/tailor_model.dart';
import '../../../data/models/notification_model.dart';
import '../../../data/providers/tailor_provider.dart';
import '../../../data/providers/auth_provider.dart';
import '../../../data/providers/notification_provider.dart';
import '../../../data/models/user_model.dart';

// Category label → API filter type mapping
const _categoryMap = {
  'cloths': 'custom',
  'bags': 'permak',
  'shoes': 'permak',
  'uniform': 'seragam',
  'suit': 'custom',
};

class HomeController extends GetxController {
  final tailors = <TailorModel>[].obs;
  final topTailors = <TailorModel>[].obs;
  final isLoading = false.obs;
  final topTailorsLoading = true.obs;
  final selectedFilter = ''.obs;
  final searchQuery = ''.obs;
  final user = Rx<UserModel?>(null);
  final notifications = <NotificationModel>[].obs;
  final unreadCount = 0.obs;
  final hasError = false.obs;
  final errorMessage = ''.obs;

  // Simple debounce timer
  Worker? _searchDebounce;

  @override
  void onInit() {
    super.onInit();
    loadUser();
    loadTailors();
    loadTopTailors();
    loadNotifications();

    // Debounce search: wait 500ms after last keystroke before querying
    _searchDebounce = debounce(
      searchQuery,
      (_) => loadTailors(),
      time: const Duration(milliseconds: 500),
    );
  }

  @override
  void onClose() {
    _searchDebounce?.dispose();
    super.onClose();
  }

  Future<void> loadUser() async {
    user.value = await AuthProvider.getCurrentUser();
  }

  Future<void> loadNotifications() async {
    try {
      final result = await NotificationProvider.getNotifications();
      notifications.value = result;
      unreadCount.value = result.where((n) => !n.isRead).length;
    } catch (_) {}
  }

  Future<void> loadTailors() async {
    isLoading.value = true;
    hasError.value = false;
    errorMessage.value = '';
    try {
      final apiType = _categoryMap[selectedFilter.value.toLowerCase()];
      final result = await TailorProvider.getTailors(
        type: apiType,
        search: searchQuery.value.isEmpty ? null : searchQuery.value,
      );
      tailors.value = result;
    } catch (e) {
      hasError.value = true;
      final msg = e.toString();
      if (msg.contains('TimeoutException') || msg.contains('timeout')) {
        errorMessage.value = 'Koneksi timeout. Pastikan backend & ngrok aktif.';
      } else if (msg.contains('SocketException') || msg.contains('Connection refused')) {
        errorMessage.value = 'Tidak bisa terhubung ke server. Cek koneksi internet.';
      } else {
        errorMessage.value = 'Gagal memuat data: $msg';
      }
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadTopTailors() async {
    topTailorsLoading.value = true;
    try {
      topTailors.value = await TailorProvider.getTopTailors(limit: 5);
    } catch (_) {
      // silently fail — view will show empty state
    } finally {
      topTailorsLoading.value = false;
    }
  }

  void setFilter(String label) {
    if (selectedFilter.value == label) {
      // Tap same category → clear filter
      selectedFilter.value = '';
    } else {
      selectedFilter.value = label;
    }
    loadTailors();
  }

  void search(String query) {
    searchQuery.value = query;
    // Debounce is handled by the Worker above
  }
}
