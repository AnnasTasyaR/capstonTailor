import 'dart:async';
import 'package:get/get.dart';
import '../../../data/models/order_model.dart';
import '../../../data/providers/order_provider.dart';

class TrackingController extends GetxController {
  final orderId = 0.obs;
  final isLoading = false.obs;
  final queueNumber = Rx<int?>(null);
  final currentStatus = ''.obs;
  final estimatedDone = Rx<String?>(null);
  final fittingDate = Rx<String?>(null);
  final steps = <TrackingStep>[].obs;
  Timer? _timer;

  @override
  void onInit() {
    super.onInit();
    final arg = Get.arguments;
    if (arg is int) orderId.value = arg;
    loadTracking();
    // Auto-refresh every 30 seconds
    _timer = Timer.periodic(const Duration(seconds: 30), (_) => loadTracking());
  }

  @override
  void onClose() {
    _timer?.cancel();
    super.onClose();
  }

  Future<void> loadTracking() async {
    if (orderId.value == 0) return;
    isLoading.value = true;
    try {
      final result = await OrderProvider.getTracking(orderId.value);
      queueNumber.value = result['queue_number'];
      currentStatus.value = result['current_status'] ?? '';
      estimatedDone.value = result['estimated_done'];
      fittingDate.value = result['fitting_date'];
      final list = result['steps'] as List? ?? [];
      steps.value = list.map((e) => TrackingStep.fromJson(e)).toList();
    } catch (e) {
      // Silent fail on auto-refresh
    } finally {
      isLoading.value = false;
    }
  }

  String get statusLabel {
    const labels = {
      'pending': 'Menunggu Konfirmasi',
      'accepted': 'Pesanan Diterima',
      'fitting': 'Jadwal Fitting',
      'diproses': 'Sedang Diproses',
      'dijahit': 'Sedang Dijahit',
      'selesai': 'Selesai',
      'siap_diambil': 'Siap Diambil',
      'rejected': 'Ditolak',
    };
    return labels[currentStatus.value] ?? currentStatus.value;
  }
}
