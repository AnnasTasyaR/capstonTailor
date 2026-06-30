import 'api_provider.dart';

class InformasiProvider {
  static Future<Map<String, dynamic>> getPopuler({String? gender}) async {
    String path = '/api/informasi/populer';
    if (gender != null && gender.isNotEmpty) {
      path += '?gender=$gender';
    }
    return ApiProvider.get(path);
  }

  static Future<Map<String, dynamic>> getTren() async {
    return ApiProvider.get('/api/informasi/tren');
  }

  static Future<Map<String, dynamic>> getRating({String? gender}) async {
    String path = '/api/informasi/rating';
    if (gender != null && gender.isNotEmpty) {
      path += '?gender=$gender';
    }
    return ApiProvider.get(path);
  }
}
