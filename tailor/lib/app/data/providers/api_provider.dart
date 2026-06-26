import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http/io_client.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ApiProvider {
  static const String baseUrl = 'https://obvious-twins-robust.ngrok-free.dev';
  static const Duration _timeout = Duration(seconds: 15);

  // ── Secure Storage (Android Keystore / iOS Keychain) ─────────────────────
  static const _secureStorage = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
    iOptions: IOSOptions(accessibility: KeychainAccessibility.first_unlock),
  );

  // ✅ Custom HTTP client toleran SSL ngrok (development only)
  static http.Client _buildClient() {
    final httpClient = HttpClient()
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
    return IOClient(httpClient);
  }

  static Future<String?> getToken() async {
    return await _secureStorage.read(key: 'auth_token');
  }

  static Future<void> saveToken(String token) async {
    await _secureStorage.write(key: 'auth_token', value: token);
  }

  static Future<void> clearToken() async {
    await _secureStorage.delete(key: 'auth_token');
    await _secureStorage.delete(key: 'user_data');
  }

  static Future<Map<String, String>> _headers({bool withAuth = true}) async {
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'ngrok-skip-browser-warning': 'true',
    };
    if (withAuth) {
      final token = await getToken();
      if (token != null) headers['Authorization'] = 'Bearer $token';
    }
    return headers;
  }

  static Future<Map<String, dynamic>> get(String endpoint) async {
    final client = _buildClient();
    try {
      final response = await client
          .get(Uri.parse('$baseUrl$endpoint'), headers: await _headers())
          .timeout(_timeout);
      return _handleResponse(response);
    } finally {
      client.close();
    }
  }

  static Future<Map<String, dynamic>> post(
    String endpoint, {
    Map<String, dynamic>? body,
  }) async {
    final client = _buildClient();
    try {
      final response = await client
          .post(
            Uri.parse('$baseUrl$endpoint'),
            headers: await _headers(),
            body: body != null ? jsonEncode(body) : null,
          )
          .timeout(_timeout);
      return _handleResponse(response);
    } finally {
      client.close();
    }
  }

  static Future<Map<String, dynamic>> put(
    String endpoint, {
    Map<String, dynamic>? body,
  }) async {
    final client = _buildClient();
    try {
      final response = await client
          .put(
            Uri.parse('$baseUrl$endpoint'),
            headers: await _headers(),
            body: body != null ? jsonEncode(body) : null,
          )
          .timeout(_timeout);
      return _handleResponse(response);
    } finally {
      client.close();
    }
  }

  static Future<Map<String, dynamic>> delete(String endpoint) async {
    final client = _buildClient();
    try {
      final response = await client
          .delete(Uri.parse('$baseUrl$endpoint'), headers: await _headers())
          .timeout(_timeout);
      return _handleResponse(response);
    } finally {
      client.close();
    }
  }


  static Future<Map<String, dynamic>> postMultipart(
    String endpoint, {
    required Map<String, String> fields,
    String? filePath,
    String fileField = 'design_image',
  }) async {
    final uri = Uri.parse('$baseUrl$endpoint');
    final request = http.MultipartRequest('POST', uri);

    final headers = await _headers();
    request.headers.addAll(headers);

    request.fields.addAll(fields);
    if (filePath != null) {
      request.files.add(await http.MultipartFile.fromPath(fileField, filePath));
    }

    // ✅ MultipartRequest pakai send() biasa, SSL bypass via IOClient tidak support ini
    // Gunakan HttpClient langsung untuk multipart
    final httpClient = HttpClient()
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
    final ioClient = IOClient(httpClient);

    try {
      final streamedResponse = await request.send().timeout(_timeout);
      final response = await http.Response.fromStream(streamedResponse);
      return _handleResponse(response);
    } finally {
      ioClient.close();
    }
  }

  static Map<String, dynamic> _handleResponse(http.Response response) {
    final contentType = response.headers['content-type'] ?? '';
    if (!contentType.contains('application/json')) {
      return {
        '_statusCode': response.statusCode,
        'msg':
            'Server tidak merespons dengan benar. Cek apakah ngrok masih aktif.',
      };
    }
    try {
      final body = jsonDecode(response.body) as Map<String, dynamic>;
      body['_statusCode'] = response.statusCode;
      return body;
    } catch (_) {
      return {
        '_statusCode': response.statusCode,
        'msg': 'Format response tidak valid',
      };
    }
  }

  static String imageUrl(String filename) =>
      '$baseUrl/static/uploads/$filename';
}
