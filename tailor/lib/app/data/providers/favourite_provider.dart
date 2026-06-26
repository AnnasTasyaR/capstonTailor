import 'api_provider.dart';
import '../models/tailor_model.dart';

class FavouriteProvider {
  static Future<List<TailorModel>> getFavourites() async {
    final result = await ApiProvider.get('/api/favourites');
    final list = result['favourites'] as List? ?? [];
    return list
        .map((e) => TailorModel.fromJson(e['tailor'] as Map<String, dynamic>))
        .toList();
  }

  static Future<Map<String, dynamic>> addFavourite(int tailorId) async {
    return ApiProvider.post('/api/favourites/$tailorId');
  }

  static Future<Map<String, dynamic>> removeFavourite(int tailorId) async {
    return ApiProvider.delete('/api/favourites/$tailorId');
  }
}
