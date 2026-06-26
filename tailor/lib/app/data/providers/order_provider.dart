import 'api_provider.dart';
import '../models/order_model.dart';

class OrderProvider {
  static Future<Map<String, dynamic>> createOrder({
    required int tailorId,
    required String type,
    String? designNotes,
    String? fittingDate,
    String? complexity,
    int estimatedDays = 7,
    String? imagePath,
  }) async {
    return await ApiProvider.postMultipart(
      '/api/orders',
      fields: {
        'tailor_id': tailorId.toString(),
        'type': type,
        'design_notes': designNotes ?? '',
        'fitting_date': fittingDate ?? '',
        'complexity': complexity ?? 'medium',
        'estimated_days': estimatedDays.toString(),
      },
      filePath: imagePath,
    );
  }

  static Future<List<OrderModel>> getMyOrders() async {
    final result = await ApiProvider.get('/api/orders/my');
    if (!result.containsKey('orders')) {
      final msg = result['msg'] ?? 'Response tidak valid dari server';
      throw Exception(msg);
    }
    final list = result['orders'] as List? ?? [];
    return list.map((e) => OrderModel.fromJson(e)).toList();
  }

  static Future<OrderModel> getOrderDetail(int id) async {
    final result = await ApiProvider.get('/api/orders/$id');
    return OrderModel.fromJson(result['order']);
  }

  static Future<Map<String, dynamic>> getTracking(int orderId) async {
    return await ApiProvider.get('/api/orders/$orderId/tracking');
  }

  static Future<Map<String, dynamic>> analyzeDesign(String imagePath) async {
    return await ApiProvider.postMultipart(
      '/api/ai/analyze',
      fields: {},
      filePath: imagePath,
      fileField: 'image',
    );
  }
}
