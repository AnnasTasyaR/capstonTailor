import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

class CustomizeController extends GetxController {
  final selectedColorIndex = 0.obs;
  final selectedPartIndex = 0.obs;
  final uploadedImagePath = Rx<String?>(null);

  void selectColor(int index) {
    selectedColorIndex.value = index;
  }

  void selectPart(int index) {
    selectedPartIndex.value = index;
  }

  Future<void> uploadDesign() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
    if (picked != null) {
      uploadedImagePath.value = picked.path;
      Get.snackbar('Berhasil', 'Desain berhasil diunggah', snackPosition: SnackPosition.BOTTOM);
    }
  }

  void callTailor() {
    Get.snackbar('Call Tailor', 'Fitur Call Tailor akan segera hadir', snackPosition: SnackPosition.BOTTOM);
  }

  void addToCart() {
    Get.snackbar('Add to Cart', 'Desain ditambahkan ke keranjang', snackPosition: SnackPosition.BOTTOM);
  }

  void orderNow() {
    // Navigate to OrderFormView. Since it expects a tailor, we might need a generic or dummy one if not passed.
    // However, usually "Custom" service is attached to a specific tailor. 
    // Here we will just prompt the user to select a tailor first if we don't have one, or just route with dummy.
    Get.snackbar('Informasi', 'Silakan pilih penjahit terlebih dahulu dari halaman utama untuk melanjutkan pesanan', 
      snackPosition: SnackPosition.BOTTOM, duration: const Duration(seconds: 4));
    // After 2 seconds, redirect to home
    Future.delayed(const Duration(seconds: 2), () {
      Get.until((route) => Get.currentRoute == '/home');
    });
  }
}
