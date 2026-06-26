import 'package:get/get.dart';
import '../../../data/models/tailor_model.dart';
import '../../../data/providers/favourite_provider.dart';

class FavouriteController extends GetxController {
  final favourites = <TailorModel>[].obs;
  final isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadFavourites();
  }

  Future<void> loadFavourites() async {
    isLoading.value = true;
    try {
      favourites.value = await FavouriteProvider.getFavourites();
    } catch (_) {
      Get.snackbar('Error', 'Gagal memuat favorit', snackPosition: SnackPosition.BOTTOM);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> removeFavourite(int tailorId) async {
    try {
      await FavouriteProvider.removeFavourite(tailorId);
      favourites.removeWhere((t) => t.id == tailorId);
      Get.snackbar('Berhasil', 'Dihapus dari favorit', snackPosition: SnackPosition.BOTTOM);
    } catch (_) {}
  }
}
