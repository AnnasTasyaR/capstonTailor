import 'package:get/get.dart';
import '../../../data/models/order_model.dart';
import '../../../data/providers/order_provider.dart';

class OrdersController extends GetxController {
  final orders = <OrderModel>[].obs;
  final isLoading = false.obs;
  final hasError = false.obs;
  final errorMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();
    loadOrders();
  }

  Future<void> loadOrders() async {
    isLoading.value = true;
    hasError.value = false;
    errorMessage.value = '';
    try {
      final result = await OrderProvider.getMyOrders();
      orders.value = result;
    } catch (e) {
      hasError.value = true;
      final msg = e.toString();
      if (msg.contains('TimeoutException') || msg.contains('timeout')) {
        errorMessage.value = 'Koneksi timeout. Pastikan backend & ngrok aktif.';
      } else if (msg.contains('SocketException') || msg.contains('Connection refused')) {
        errorMessage.value = 'Tidak bisa terhubung ke server.';
      } else if (msg.contains('not JSON') || msg.contains('non-JSON')) {
        errorMessage.value = 'Server tidak merespons dengan benar. Cek apakah ngrok masih aktif.';
      } else {
        errorMessage.value = 'Gagal memuat pesanan: $msg';
      }
    } finally {
      isLoading.value = false;
    }
  }
}
