import 'package:get/get.dart';
import '../../../data/providers/informasi_provider.dart';

class InformasiController extends GetxController {
  final populer = <Map<String, dynamic>>[].obs;
  final tren = <Map<String, dynamic>>[].obs;
  final rating = <Map<String, dynamic>>[].obs;
  final isLoadingPopuler = false.obs;
  final isLoadingTren = false.obs;
  final isLoadingRating = false.obs;
  final tabIndex = 0.obs;

  @override
  void onInit() {
    super.onInit();
    loadAll();
  }

  void loadAll() {
    loadPopuler();
    loadTren();
    loadRating();
  }

  Future<void> loadPopuler() async {
    isLoadingPopuler.value = true;
    try {
      final result = await InformasiProvider.getPopuler();
      populer.value = (result['produk'] as List? ?? [])
          .map((e) => e as Map<String, dynamic>)
          .toList();
    } catch (_) {
      Get.snackbar('Error', 'Gagal memuat produk populer',
          snackPosition: SnackPosition.BOTTOM);
    } finally {
      isLoadingPopuler.value = false;
    }
  }

  Future<void> loadTren() async {
    isLoadingTren.value = true;
    try {
      final result = await InformasiProvider.getTren();
      tren.value = (result['tren'] as List? ?? [])
          .map((e) => e as Map<String, dynamic>)
          .toList();
    } catch (_) {
      Get.snackbar('Error', 'Gagal memuat tren fashion',
          snackPosition: SnackPosition.BOTTOM);
    } finally {
      isLoadingTren.value = false;
    }
  }

  Future<void> loadRating() async {
    isLoadingRating.value = true;
    try {
      final result = await InformasiProvider.getRating();
      rating.value = (result['rating'] as List? ?? [])
          .map((e) => e as Map<String, dynamic>)
          .toList();
    } catch (_) {
      Get.snackbar('Error', 'Gagal memuat rating fashion',
          snackPosition: SnackPosition.BOTTOM);
    } finally {
      isLoadingRating.value = false;
    }
  }

  void changeTab(int index) {
    tabIndex.value = index;
  }
}
