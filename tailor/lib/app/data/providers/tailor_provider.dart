import 'api_provider.dart';
import '../models/tailor_model.dart';

class TailorProvider {
  static Future<List<TailorModel>> getTailors({String? type, String? search, String? sort}) async {
    String endpoint = '/api/tailors?';
    if (type != null && type.isNotEmpty) endpoint += 'type=$type&';
    if (search != null && search.isNotEmpty) endpoint += 'search=$search&';
    if (sort != null && sort.isNotEmpty) endpoint += 'sort=$sort&';
    final result = await ApiProvider.get(endpoint);
    final list = result['tailors'] as List? ?? [];
    return list.map((e) => TailorModel.fromJson(e)).toList();
  }

  static Future<List<TailorModel>> getTopTailors({int limit = 5}) async {
    final result = await ApiProvider.get('/api/tailors/top?limit=$limit');
    final list = result['tailors'] as List? ?? [];
    return list.map((e) => TailorModel.fromJson(e)).toList();
  }

  static Future<TailorModel> getTailorDetail(int id) async {
    final result = await ApiProvider.get('/api/tailors/$id');
    return TailorModel.fromJson(result['tailor']);
  }
}
