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
  final selectedGender = 'all'.obs;

  static const genders = ['all', 'Pria', 'Wanita'];

  @override
  void onInit() {
    super.onInit();
    loadAll();
  }

  void setGender(String g) {
    selectedGender.value = g;
    loadAll(force: true);
  }

  String get _genderParam {
    final g = selectedGender.value;
    return g == 'all' ? '' : g;
  }

  void loadAll({bool force = false}) {
    loadPopuler(force: force);
    loadTren(force: force);
    loadRating(force: force);
  }

  Future<void> loadPopuler({bool force = false}) async {
    if (populer.isNotEmpty && !force) return;
    isLoadingPopuler.value = true;
    try {
      final result = await InformasiProvider.getPopuler(gender: _genderParam);
      populer.value = (result['produk'] as List? ?? [])
          .map((e) => e as Map<String, dynamic>)
          .toList();
    } catch (_) {
      Get.snackbar('Error', 'Gagal memuat produk populer',
          snackPosition: SnackPosition.BOTTOM);
    } finally {
      isLoadingPopuler.value = false;
      update();
    }
  }

  Future<void> loadTren({bool force = false}) async {
    if (tren.isNotEmpty && !force) return;
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
      update();
    }
  }

  Future<void> loadRating({bool force = false}) async {
    if (rating.isNotEmpty && !force) return;
    isLoadingRating.value = true;
    try {
      final result = await InformasiProvider.getRating(gender: _genderParam);
      rating.value = (result['rating'] as List? ?? [])
          .map((e) => e as Map<String, dynamic>)
          .toList();
    } catch (_) {
      Get.snackbar('Error', 'Gagal memuat rating fashion',
          snackPosition: SnackPosition.BOTTOM);
    } finally {
      isLoadingRating.value = false;
      update();
    }
  }

  void changeTab(int index) {
    tabIndex.value = index;
  }
}
