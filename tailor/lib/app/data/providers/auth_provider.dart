import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'api_provider.dart';
import '../models/user_model.dart';

class AuthProvider {
  static const _secureStorage = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
    iOptions: IOSOptions(accessibility: KeychainAccessibility.first_unlock),
  );

  static Future<Map<String, dynamic>> login(
      String loginId, String password) async {
    final result = await ApiProvider.post('/api/auth/login', body: {
      'login_id': loginId,
      'password': password,
    });

    if (result['_statusCode'] == 200) {
      await ApiProvider.saveToken(result['token']);
      // Store user data in encrypted storage
      await _secureStorage.write(
          key: 'user_data', value: jsonEncode(result['user']));
    }
    return result;
  }

  static Future<Map<String, dynamic>> loginWithGoogle(String idToken) async {
    final result = await ApiProvider.post('/api/auth/google', body: {
      'id_token': idToken,
    });

    if (result['_statusCode'] == 200 && result['needs_verification'] != true) {
      await ApiProvider.saveToken(result['token']);
      await _secureStorage.write(
          key: 'user_data', value: jsonEncode(result['user']));
    }
    return result;
  }

  static Future<Map<String, dynamic>> sendVerification(String email) async {
    return await ApiProvider.post('/api/auth/send-verification', body: {
      'email': email,
    });
  }

  static Future<Map<String, dynamic>> verifyEmail(
      String email, String code) async {
    final result = await ApiProvider.post('/api/auth/verify-email', body: {
      'email': email,
      'code': code,
    });

    if (result['_statusCode'] == 200 && result['token'] != null) {
      await ApiProvider.saveToken(result['token']);
      await _secureStorage.write(
          key: 'user_data', value: jsonEncode(result['user']));
    }
    return result;
  }

  static Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String username,
    required String password,
    String? phone,
  }) async {
    return await ApiProvider.post('/api/auth/register', body: {
      'name': name,
      'email': email,
      'username': username,
      'password': password,
      'phone': phone ?? '',
    });
  }

  static Future<void> logout() async {
    try {
      await ApiProvider.post('/api/auth/logout');
    } catch (_) {}
    // Clear ALL secure storage on logout
    await ApiProvider.clearToken();
  }

  static Future<UserModel?> getCurrentUser() async {
    final data = await _secureStorage.read(key: 'user_data');
    if (data != null) {
      try {
        return UserModel.fromJson(jsonDecode(data));
      } catch (_) {
        // Corrupt data — clear it
        await _secureStorage.delete(key: 'user_data');
      }
    }
    return null;
  }

  static Future<bool> isLoggedIn() async {
    final token = await ApiProvider.getToken();
    return token != null && token.isNotEmpty;
  }
}
