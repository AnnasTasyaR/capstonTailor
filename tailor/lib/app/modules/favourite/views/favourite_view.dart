import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../theme/app_colors.dart';
import '../controllers/favourite_controller.dart';
import '../../../routes/app_pages.dart';

class FavouriteView extends GetView<FavouriteController> {
  const FavouriteView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'Favourite',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w700, color: AppColors.textPrimary),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator(color: AppColors.primary));
        }
        if (controller.favourites.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.favorite_border_rounded, size: 80, color: AppColors.divider),
                const SizedBox(height: 16),
                Text(
                  'Belum ada penjahit favorit',
                  style: GoogleFonts.poppins(fontSize: 16, color: AppColors.textMuted),
                ),
                const SizedBox(height: 8),
                Text(
                  'Tambahkan penjahit ke favorit dari halaman detail',
                  style: GoogleFonts.poppins(fontSize: 13, color: AppColors.textMuted),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        }
        return RefreshIndicator(
          color: AppColors.primary,
          onRefresh: controller.loadFavourites,
          child: ListView.builder(
            padding: const EdgeInsets.all(20),
            itemCount: controller.favourites.length,
            itemBuilder: (_, i) {
              final tailor = controller.favourites[i];
              return GestureDetector(
                onTap: () => Get.toNamed(Routes.TAILOR_DETAIL, arguments: tailor),
                child: Container(
                  margin: const EdgeInsets.only(bottom: 14),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [BoxShadow(blurRadius: 10, color: Colors.black.withValues(alpha: 0.05))],
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: AppColors.primary.withValues(alpha: 0.15), width: 2),
                          color: AppColors.surface,
                        ),
                        child: const ClipOval(
                          child: Icon(Icons.person, size: 32, color: AppColors.textMuted),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              tailor.shopName,
                              style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 14, color: AppColors.textPrimary),
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                const Icon(Icons.star_rounded, color: AppColors.starColor, size: 14),
                                const SizedBox(width: 3),
                                Text(
                                  tailor.rating.toStringAsFixed(1),
                                  style: GoogleFonts.poppins(fontSize: 12, color: AppColors.textSecondary),
                                ),
                                if (tailor.address != null) ...[
                                  const SizedBox(width: 10),
                                  const Icon(Icons.location_on_outlined, size: 13, color: AppColors.textMuted),
                                  const SizedBox(width: 2),
                                  Expanded(
                                    child: Text(
                                      tailor.address!,
                                      style: GoogleFonts.poppins(fontSize: 11, color: AppColors.textMuted),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ]
                              ],
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.favorite_rounded, color: AppColors.heartRed),
                        onPressed: () => controller.removeFavourite(tailor.id),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      }),
    );
  }
}
