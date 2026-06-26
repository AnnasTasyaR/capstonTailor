import 'api_provider.dart';

class InformasiProvider {
  static Future<Map<String, dynamic>> getPopuler() async {
    return ApiProvider.get('/api/informasi/populer');
  }

  static Future<Map<String, dynamic>> getTren() async {
    return ApiProvider.get('/api/informasi/tren');
  }

  static Future<Map<String, dynamic>> getRating() async {
    return ApiProvider.get('/api/informasi/rating');
  }
}
