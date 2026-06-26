import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../data/models/user_model.dart';
import '../../../data/providers/auth_provider.dart';
import '../../../data/providers/profile_provider.dart';
import '../../../routes/app_pages.dart';

class ProfileController extends GetxController {
  final user = Rx<UserModel?>(null);
  final isLoading = false.obs;
  final isSaving = false.obs;

  // Edit fields
  final editName = ''.obs;
  final editPhone = ''.obs;

  // Password change
  final oldPassword = ''.obs;
  final newPassword = ''.obs;
  final confirmNewPassword = ''.obs;
  final isChangingPass = false.obs;

  // Notifications toggle
  final notificationsEnabled = true.obs;

  @override
  void onInit() {
    super.onInit();
    loadProfile();
  }

  Future<void> loadProfile() async {
    isLoading.value = true;
    try {
      // First load from cache
      final cached = await AuthProvider.getCurrentUser();
      if (cached != null) {
        user.value = cached;
        editName.value = cached.name;
        editPhone.value = cached.phone ?? '';
      }
      // Then fetch fresh
      final fresh = await ProfileProvider.getProfile();
      user.value = fresh;
      editName.value = fresh.name;
      editPhone.value = fresh.phone ?? '';
    } catch (_) {} finally {
      isLoading.value = false;
    }
  }

  Future<void> saveProfile() async {
    if (editName.value.trim().isEmpty) {
      Get.snackbar('Error', 'Nama tidak boleh kosong', snackPosition: SnackPosition.BOTTOM);
      return;
    }
    isSaving.value = true;
    try {
      final result = await ProfileProvider.updateProfile(
        name: editName.value.trim(),
        phone: editPhone.value.trim(),
      );
      if (result['_statusCode'] == 200) {
        Get.snackbar('Berhasil', 'Profil berhasil diperbarui', snackPosition: SnackPosition.BOTTOM);
        await loadProfile();
        Get.back();
      } else {
        Get.snackbar('Gagal', result['msg'] ?? 'Gagal memperbarui profil', snackPosition: SnackPosition.BOTTOM);
      }
    } catch (_) {
      Get.snackbar('Error', 'Tidak dapat terhubung ke server', snackPosition: SnackPosition.BOTTOM);
    } finally {
      isSaving.value = false;
    }
  }

  Future<void> changePassword() async {
    if (newPassword.value.length < 6) {
      Get.snackbar('Error', 'Password baru minimal 6 karakter', snackPosition: SnackPosition.BOTTOM);
      return;
    }
    if (newPassword.value != confirmNewPassword.value) {
      Get.snackbar('Error', 'Konfirmasi password tidak cocok', snackPosition: SnackPosition.BOTTOM);
      return;
    }
    isChangingPass.value = true;
    try {
      final result = await ProfileProvider.changePassword(oldPassword.value, newPassword.value);
      if (result['_statusCode'] == 200) {
        Get.snackbar('Berhasil', 'Password berhasil diubah', snackPosition: SnackPosition.BOTTOM);
        Get.back();
        oldPassword.value = '';
        newPassword.value = '';
        confirmNewPassword.value = '';
      } else {
        Get.snackbar('Gagal', result['msg'] ?? 'Gagal mengubah password', snackPosition: SnackPosition.BOTTOM);
      }
    } catch (_) {
      Get.snackbar('Error', 'Tidak dapat terhubung ke server', snackPosition: SnackPosition.BOTTOM);
    } finally {
      isChangingPass.value = false;
    }
  }

  void confirmLogout() {
    Get.dialog(
      AlertDialog(
        title: const Text('Konfirmasi Logout'),
        content: const Text('Apakah Anda yakin ingin keluar?'),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Batal')),
          TextButton(
            onPressed: () async {
              Get.back();
              await AuthProvider.logout();
              Get.offAllNamed(Routes.LOGIN);
            },
            child: const Text('Logout', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
