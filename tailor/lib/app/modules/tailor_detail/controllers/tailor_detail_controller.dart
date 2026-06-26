import 'package:get/get.dart';
import '../../../data/models/tailor_model.dart';
import '../../../data/providers/tailor_provider.dart';
import '../../../routes/app_pages.dart';

class TailorDetailController extends GetxController {
  final tailor = Rx<TailorModel?>(null);
  final isLoading = false.obs;
  final selectedService = ''.obs;

  @override
  void onInit() {
    super.onInit();
    final arg = Get.arguments;
    if (arg is TailorModel) {
      tailor.value = arg;
    } else if (arg is int) {
      loadTailor(arg);
    }
  }

  Future<void> loadTailor(int id) async {
    isLoading.value = true;
    try {
      tailor.value = await TailorProvider.getTailorDetail(id);
    } catch (e) {
      Get.snackbar('Error', 'Gagal memuat data penjahit', snackPosition: SnackPosition.BOTTOM);
    } finally {
      isLoading.value = false;
    }
  }

  void selectService(String type) => selectedService.value = type;

  void orderNow() {
    if (selectedService.value.isEmpty) {
      Get.snackbar('Pilih Layanan', 'Pilih jenis jahit terlebih dahulu',
          snackPosition: SnackPosition.BOTTOM);
      return;
    }
    Get.toNamed(Routes.ORDER_FORM,
        arguments: {'tailor': tailor.value, 'type': selectedService.value});
  }
}
