import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../../../../data/providers/auth_provider.dart';
import '../../../../routes/app_pages.dart';

class LoginController extends GetxController {
  final loginId = ''.obs;
  final password = ''.obs;
  final isLoading = false.obs;
  final isGoogleLoading = false.obs;
  final obscurePassword = true.obs;

  final _googleSignIn = GoogleSignIn(
    scopes: ['email', 'profile'],
    // Web Client ID dari Google Cloud Console — digunakan backend untuk verifikasi ID token
    serverClientId: '552186394199-2n5qtmnv2tam9bm6jq0mf866i2qijtrg.apps.googleusercontent.com',
  );

  void togglePassword() => obscurePassword.value = !obscurePassword.value;

  Future<void> login() async {
    if (loginId.value.trim().isEmpty || password.value.trim().isEmpty) {
      Get.snackbar(
        'Error',
        'Email/username dan password harus diisi',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    isLoading.value = true;
    try {
      final result = await AuthProvider.login(
        loginId.value.trim(),
        password.value,
      ).timeout(
        const Duration(seconds: 15),
        onTimeout: () => {'_statusCode': 408, 'msg': 'Request timeout'},
      );

      if (result['_statusCode'] == 200) {
        Get.snackbar(
          'Berhasil',
          'Login berhasil!',
          snackPosition: SnackPosition.BOTTOM,
        );
        Get.offAllNamed(Routes.DASHBOARD);
      } else {
        Get.snackbar(
          'Gagal',
          result['msg'] ?? 'Login gagal',
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e, stackTrace) {
      debugPrint('Login error: $e');
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

  Future<void> signInWithGoogle() async {
    isGoogleLoading.value = true;
    try {
      // Sign out first to force account picker
      await _googleSignIn.signOut();

      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        // User cancelled the sign-in
        return;
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final String? idToken = googleAuth.idToken;
      if (idToken == null) {
        Get.snackbar(
          'Error',
          'Gagal mendapatkan token Google',
          snackPosition: SnackPosition.BOTTOM,
        );
        return;
      }

      // Send token to backend
      final result = await AuthProvider.loginWithGoogle(idToken).timeout(
        const Duration(seconds: 15),
        onTimeout: () => {'_statusCode': 408, 'msg': 'Request timeout'},
      );

      if (result['_statusCode'] == 200) {
        if (result['needs_verification'] == true) {
          Get.toNamed(Routes.VERIFY_EMAIL, arguments: result['email']);
          return;
        }
        Get.snackbar(
          'Berhasil',
          'Login dengan Google berhasil!',
          snackPosition: SnackPosition.BOTTOM,
        );
        Get.offAllNamed(Routes.DASHBOARD);
      } else {
        Get.snackbar(
          'Gagal',
          result['msg'] ?? 'Login Google gagal',
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e, stackTrace) {
      debugPrint('Google Sign-In error: $e');
      debugPrint('Stack: $stackTrace');
      Get.snackbar(
        'Error',
        'Login Google gagal. Pastikan koneksi internet tersedia.',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isGoogleLoading.value = false;
    }
  }
}
