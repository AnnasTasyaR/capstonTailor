import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import '../../../theme/app_colors.dart';
import '../controllers/order_controller.dart';

class OrderFormView extends GetView<OrderController> {
  const OrderFormView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: GestureDetector(
          onTap: () => Get.back(),
          child: Container(
            margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              boxShadow: [BoxShadow(blurRadius: 6, color: Colors.black.withValues(alpha: 0.07))],
            ),
            child: const Icon(Icons.arrow_back_ios_new_rounded, size: 16, color: AppColors.textPrimary),
          ),
        ),
        title: Text(
          'Buat Pesanan',
          style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
        ),
        backgroundColor: AppColors.background,
        elevation: 0,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Tailor Info Banner
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.06),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
              ),
              child: Row(children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.content_cut_rounded, color: Colors.white, size: 22),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(
                      controller.tailor.shopName,
                      style: GoogleFonts.poppins(fontWeight: FontWeight.w700, fontSize: 15, color: AppColors.textPrimary),
                    ),
                    Text(
                      controller.serviceType.toUpperCase(),
                      style: GoogleFonts.poppins(fontSize: 12, color: AppColors.primary, fontWeight: FontWeight.w600),
                    ),
                  ]),
                ),
              ]),
            ),
            const SizedBox(height: 28),

            // Image Upload
            _SectionTitle('Gambar Desain'),
            const SizedBox(height: 12),
            Obx(() => GestureDetector(
              onTap: () => _showImagePicker(context),
              child: Container(
                height: 190,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: AppColors.primary.withValues(alpha: 0.3),
                    style: BorderStyle.solid,
                    width: 1.5,
                  ),
                  boxShadow: [BoxShadow(blurRadius: 10, color: Colors.black.withValues(alpha: 0.04))],
                ),
                child: controller.selectedImagePath.value != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Image.file(File(controller.selectedImagePath.value!), fit: BoxFit.cover))
                    : Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                        Container(
                          width: 64,
                          height: 64,
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.08),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.add_photo_alternate_outlined, size: 32, color: AppColors.primary),
                        ),
                        const SizedBox(height: 12),
                        Text('Tambah Foto Desain', style: GoogleFonts.poppins(color: AppColors.primary, fontWeight: FontWeight.w600)),
                        Text('Tap untuk pilih gambar', style: GoogleFonts.poppins(fontSize: 12, color: AppColors.textMuted)),
                      ]),
              ),
            )),
            const SizedBox(height: 16),

            // AI Analyze Button
            Obx(() => SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: controller.isAnalyzing.value ? null : controller.analyzeDesign,
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.primary,
                  side: const BorderSide(color: AppColors.primary),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                icon: controller.isAnalyzing.value
                    ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary))
                    : const Icon(Icons.auto_awesome_outlined),
                label: Text(
                  controller.isAnalyzing.value ? 'Menganalisis...' : 'Analisis dengan AI',
                  style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                ),
              ),
            )),

            // AI Result Badge
            Obx(() => controller.aiResult.value != null
                ? Container(
                    margin: const EdgeInsets.only(top: 12),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
                    ),
                    child: Row(children: [
                      Container(
                        width: 40, height: 40,
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.analytics_outlined, color: AppColors.primary, size: 20),
                      ),
                      const SizedBox(width: 12),
                      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text('Hasil Analisis AI', style: GoogleFonts.poppins(fontWeight: FontWeight.w700, fontSize: 13, color: AppColors.textPrimary)),
                        Text('Kompleksitas: ${controller.complexity.value.toUpperCase()}',
                            style: GoogleFonts.poppins(color: AppColors.primary, fontWeight: FontWeight.w600, fontSize: 12)),
                        Text('Estimasi: ${controller.estimatedDays.value} hari',
                            style: GoogleFonts.poppins(fontSize: 12, color: AppColors.textSecondary)),
                      ]),
                    ]),
                  )
                : const SizedBox()),

            const SizedBox(height: 24),
            _SectionTitle('Catatan Desain'),
            const SizedBox(height: 12),
            TextField(
              onChanged: (v) => controller.designNotes.value = v,
              maxLines: 4,
              style: GoogleFonts.poppins(fontSize: 13, color: AppColors.textPrimary),
              decoration: InputDecoration(
                hintText: 'Ceritakan detail pesanan Anda (ukuran, warna, model, dll)',
                hintStyle: GoogleFonts.poppins(fontSize: 13, color: AppColors.textMuted),
              ),
            ),
            const SizedBox(height: 24),

            _SectionTitle('Tanggal Fitting (Opsional)'),
            const SizedBox(height: 12),
            Obx(() => GestureDetector(
              onTap: () => controller.pickFittingDate(context),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.divider),
                ),
                child: Row(children: [
                  Container(
                    width: 36, height: 36,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.08),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.calendar_today_outlined, color: AppColors.primary, size: 18),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    controller.formattedFittingDate,
                    style: GoogleFonts.poppins(
                      color: controller.fittingDate.value != null ? AppColors.textPrimary : AppColors.textMuted,
                      fontSize: 14,
                    ),
                  ),
                ]),
              ),
            )),
            const SizedBox(height: 40),

            Obx(() => SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: controller.isSubmitting.value ? null : controller.submitOrder,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: controller.isSubmitting.value
                    ? const SizedBox(height: 22, width: 22, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5))
                    : Text('Checkout Pesanan', style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w700)),
              ),
            )),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  void _showImagePicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 8),
            Container(width: 40, height: 4, decoration: BoxDecoration(color: AppColors.divider, borderRadius: BorderRadius.circular(2))),
            const SizedBox(height: 8),
            ListTile(
              leading: Container(
                width: 40, height: 40,
                decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: 0.1), shape: BoxShape.circle),
                child: const Icon(Icons.camera_alt_outlined, color: AppColors.primary),
              ),
              title: Text('Ambil Foto', style: GoogleFonts.poppins(fontWeight: FontWeight.w500)),
              onTap: () { Get.back(); controller.pickImage(ImageSource.camera); },
            ),
            ListTile(
              leading: Container(
                width: 40, height: 40,
                decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: 0.1), shape: BoxShape.circle),
                child: const Icon(Icons.photo_library_outlined, color: AppColors.primary),
              ),
              title: Text('Pilih dari Galeri', style: GoogleFonts.poppins(fontWeight: FontWeight.w500)),
              onTap: () { Get.back(); controller.pickImage(ImageSource.gallery); },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String text;
  const _SectionTitle(this.text);
  @override
  Widget build(BuildContext context) => Text(
    text,
    style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
  );
}
