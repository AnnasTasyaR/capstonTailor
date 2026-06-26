import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import '../../../../data/providers/auth_provider.dart';
import '../../../../routes/app_pages.dart';

class VerifyEmailController extends GetxController {
  final email = ''.obs;
  final code = ''.obs;
  final isLoading = false.obs;
  final isResending = false.obs;

  @override
  void onInit() {
    super.onInit();
    email.value = Get.arguments as String? ?? '';
    if (email.value.isNotEmpty) {
      sendCode();
    }
  }

  Future<void> sendCode() async {
    isResending.value = true;
    try {
      final result = await AuthProvider.sendVerification(email.value).timeout(
        const Duration(seconds: 15),
        onTimeout: () => {'_statusCode': 408, 'msg': 'Request timeout'},
      );
      if (result['_statusCode'] == 200) {
        Get.snackbar(
          'Terkirim',
          'Kode verifikasi telah dikirim ke ${email.value}',
          snackPosition: SnackPosition.BOTTOM,
        );
      } else {
        Get.snackbar(
          'Gagal',
          result['msg'] ?? 'Gagal mengirim kode',
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e, stackTrace) {
      debugPrint('Send verification error: $e');
      debugPrint('Stack: $stackTrace');
      Get.snackbar(
        'Error',
        'Tidak dapat terhubung ke server',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isResending.value = false;
    }
  }

  Future<void> verify() async {
    if (code.value.trim().length != 6) {
      Get.snackbar(
        'Error',
        'Masukkan kode 6 digit',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    isLoading.value = true;
    try {
      final result = await AuthProvider.verifyEmail(
        email.value,
        code.value.trim(),
      ).timeout(
        const Duration(seconds: 15),
        onTimeout: () => {'_statusCode': 408, 'msg': 'Request timeout'},
      );

      if (result['_statusCode'] == 200 && result['token'] != null) {
        Get.snackbar(
          'Berhasil',
          'Email berhasil diverifikasi!',
          snackPosition: SnackPosition.BOTTOM,
        );
        Get.offAllNamed(Routes.DASHBOARD);
      } else {
        Get.snackbar(
          'Gagal',
          result['msg'] ?? 'Verifikasi gagal',
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e, stackTrace) {
      debugPrint('Verify email error: $e');
      debugPrint('Stack: $stackTrace');
      Get.snackbar(
        'Error',
        'Tidak dapat terhubung ke server',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }
}
