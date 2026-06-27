import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../data/models/tailor_model.dart';
import '../../../data/models/notification_model.dart';
import '../../../data/providers/tailor_provider.dart';
import '../../../data/providers/auth_provider.dart';
import '../../../data/providers/notification_provider.dart';
import '../../../data/models/user_model.dart';
import '../../../theme/app_colors.dart';

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

  Worker? _searchDebounce;
  Timer? _notifPollTimer;
  int _prevUnreadCount = 0;
  bool _isFirstPoll = true;
  final Set<int> _shownNotifIds = {};

  @override
  void onInit() {
    super.onInit();
    loadUser();
    loadTailors();
    loadTopTailors();
    loadNotifications();

    _searchDebounce = debounce(
      searchQuery,
      (_) => loadTailors(),
      time: const Duration(milliseconds: 500),
    );

    _startPolling();
  }

  @override
  void onClose() {
    _searchDebounce?.dispose();
    _notifPollTimer?.cancel();
    super.onClose();
  }

  void _startPolling() {
    _notifPollTimer = Timer.periodic(const Duration(seconds: 15), (_) {
      _pollNotifications();
    });
  }

  Future<void> _pollNotifications() async {
    try {
      final result = await NotificationProvider.getNotifications();
      final newUnread = result.where((n) => !n.isRead).length;

      if (!_isFirstPoll && newUnread > _prevUnreadCount) {
        final diff = newUnread - _prevUnreadCount;
        final newest = result.take(diff).toList();
        for (final n in newest) {
          if (_shownNotifIds.add(n.id)) {
            _showNotifSnackbar(n.message);
          }
        }
        if (_shownNotifIds.length > 100) _shownNotifIds.clear();
      }
      _isFirstPoll = false;

      notifications.value = result;
      unreadCount.value = newUnread;
      _prevUnreadCount = newUnread;
    } catch (_) {}
  }

  void _showNotifSnackbar(String message) {
    final ctx = Get.context;
    final topPad = ctx != null ? MediaQuery.of(ctx).padding.top : 0.0;
    Get.rawSnackbar(
      snackPosition: SnackPosition.TOP,
      backgroundColor: Colors.white,
      borderRadius: 14,
      margin: EdgeInsets.only(top: topPad + 8, left: 16, right: 16),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      duration: const Duration(seconds: 4),
      boxShadows: [
        BoxShadow(
          blurRadius: 20,
          color: Colors.black.withValues(alpha: 0.12),
          offset: const Offset(0, 4),
        ),
      ],
      icon: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: AppColors.primary.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: const Icon(Icons.notifications_outlined, color: AppColors.primary, size: 20),
      ),
      messageText: Text(
        message,
        style: GoogleFonts.poppins(
          fontSize: 13,
          fontWeight: FontWeight.w500,
          color: AppColors.textPrimary,
        ),
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
      isDismissible: true,
      forwardAnimationCurve: Curves.easeOutCubic,
    );
  }

  Future<void> loadUser() async {
    user.value = await AuthProvider.getCurrentUser();
  }

  Future<void> loadNotifications() async {
    try {
      final result = await NotificationProvider.getNotifications();
      notifications.value = result;
      _prevUnreadCount = result.where((n) => !n.isRead).length;
      unreadCount.value = _prevUnreadCount;
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
    } finally {
      topTailorsLoading.value = false;
    }
  }

  void setFilter(String label) {
    if (selectedFilter.value == label) {
      selectedFilter.value = '';
    } else {
      selectedFilter.value = label;
    }
    loadTailors();
  }

  void search(String query) {
    searchQuery.value = query;
  }
}
