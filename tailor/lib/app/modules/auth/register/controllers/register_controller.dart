import 'package:get/get.dart';
import '../../../../data/providers/auth_provider.dart';
import '../../../../routes/app_pages.dart';

class RegisterController extends GetxController {
  final name = ''.obs;
  final email = ''.obs;
  final username = ''.obs;
  final password = ''.obs;
  final confirmPassword = ''.obs;
  final isLoading = false.obs;
  final obscurePass = true.obs;
  final obscureConfirm = true.obs;

  Future<void> register() async {
    if (name.value.trim().isEmpty || email.value.trim().isEmpty ||
        username.value.trim().isEmpty || password.value.isEmpty) {
      Get.snackbar('Error', 'Semua field wajib diisi', snackPosition: SnackPosition.BOTTOM);
      return;
    }
    if (password.value.length < 6) {
      Get.snackbar('Error', 'Password minimal 6 karakter', snackPosition: SnackPosition.BOTTOM);
      return;
    }
    if (password.value != confirmPassword.value) {
      Get.snackbar('Error', 'Password tidak cocok', snackPosition: SnackPosition.BOTTOM);
      return;
    }

    isLoading.value = true;
    try {
      final result = await AuthProvider.register(
        name: name.value.trim(),
        email: email.value.trim(),
        username: username.value.trim(),
        password: password.value,
      );
      if (result['_statusCode'] == 201) {
        if (result['needs_verification'] == true) {
          Get.toNamed(Routes.VERIFY_EMAIL, arguments: result['email']);
          return;
        }
        Get.snackbar('Berhasil', 'Registrasi berhasil! Silakan login.', snackPosition: SnackPosition.BOTTOM);
        Get.offNamed(Routes.LOGIN);
      } else {
        Get.snackbar('Gagal', result['msg'] ?? 'Registrasi gagal', snackPosition: SnackPosition.BOTTOM);
      }
    } catch (e) {
      Get.snackbar('Error', 'Tidak dapat terhubung ke server', snackPosition: SnackPosition.BOTTOM);
    } finally {
      isLoading.value = false;
    }
  }
}
