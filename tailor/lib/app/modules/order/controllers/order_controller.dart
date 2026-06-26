import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import '../../../data/models/tailor_model.dart';
import '../../../data/providers/order_provider.dart';
import '../../../routes/app_pages.dart';

class OrderController extends GetxController {
  late TailorModel tailor;
  late String serviceType;

  final selectedImagePath = Rx<String?>(null);
  final designNotes = ''.obs;
  final complexity = 'sedang'.obs;
  final estimatedDays = 7.obs;
  final fittingDate = Rx<DateTime?>(null);
  final isAnalyzing = false.obs;
  final isSubmitting = false.obs;
  final aiResult = Rx<Map<String, dynamic>?>(null);

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments as Map?;
    if (args != null) {
      tailor = args['tailor'] as TailorModel;
      serviceType = args['type'] as String;
    }
  }

  Future<void> pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: source, imageQuality: 80);
    if (picked != null) selectedImagePath.value = picked.path;
  }

  Future<void> analyzeDesign() async {
    if (selectedImagePath.value == null) {
      Get.snackbar('Error', 'Upload gambar desain terlebih dahulu',
          snackPosition: SnackPosition.BOTTOM);
      return;
    }
    isAnalyzing.value = true;
    try {
      final result = await OrderProvider.analyzeDesign(selectedImagePath.value!);
      aiResult.value = result;
      complexity.value = result['complexity'] ?? 'sedang';
      estimatedDays.value = result['estimated_days'] ?? 7;
      Get.snackbar('Analisis Selesai',
          'Kompleksitas: ${complexity.value} | Estimasi: ${estimatedDays.value} hari',
          snackPosition: SnackPosition.BOTTOM);
    } catch (e) {
      Get.snackbar('Error', 'Gagal menganalisis gambar', snackPosition: SnackPosition.BOTTOM);
    } finally {
      isAnalyzing.value = false;
    }
  }

  Future<void> pickFittingDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 3)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 60)),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: const ColorScheme.light(primary: Color(0xFFC9813A)),
        ),
        child: child!,
      ),
    );
    if (picked != null) fittingDate.value = picked;
  }

  Future<void> submitOrder() async {
    isSubmitting.value = true;
    try {
      final result = await OrderProvider.createOrder(
        tailorId: tailor.id,
        type: serviceType,
        designNotes: designNotes.value,
        fittingDate: fittingDate.value?.toIso8601String(),
        complexity: complexity.value,
        estimatedDays: estimatedDays.value,
        imagePath: selectedImagePath.value,
      );
      if (result['_statusCode'] == 201) {
        final order = result['order'] as Map<String, dynamic>;
        Get.snackbar('Berhasil', 'Pesanan berhasil dibuat!', snackPosition: SnackPosition.BOTTOM);
        Get.offNamed(Routes.TRACKING, arguments: order['id']);
      } else {
        Get.snackbar('Gagal', result['msg'] ?? 'Gagal membuat pesanan',
            snackPosition: SnackPosition.BOTTOM);
      }
    } catch (e) {
      Get.snackbar('Error', 'Tidak dapat terhubung ke server', snackPosition: SnackPosition.BOTTOM);
    } finally {
      isSubmitting.value = false;
    }
  }

  String get formattedFittingDate => fittingDate.value != null
      ? DateFormat('dd MMMM yyyy', 'id_ID').format(fittingDate.value!)
      : 'Pilih tanggal fitting';
}
