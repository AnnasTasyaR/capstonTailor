import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../theme/app_colors.dart';
import '../../../routes/app_pages.dart';
import '../../../data/models/tailor_model.dart';
import '../controllers/explore_controller.dart';

class ExploreView extends GetView<ExploreController> {
  const ExploreView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'Explore',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
            fontSize: 18,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        automaticallyImplyLeading: false,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: AppColors.divider),
        ),
      ),
      body: Column(
        children: [
          // ── Search Bar ────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
            child: TextField(
              controller: controller.searchTextController,
              onChanged: controller.search,
              style: GoogleFonts.poppins(fontSize: 13, color: AppColors.textPrimary),
              decoration: InputDecoration(
                hintText: 'Cari penjahit terbaik...',
                hintStyle: GoogleFonts.poppins(fontSize: 13, color: AppColors.textMuted),
                prefixIcon: const Icon(Icons.search_rounded, color: AppColors.textMuted, size: 20),
                suffixIcon: Obx(() => controller.searchQuery.value.isNotEmpty
                    ? GestureDetector(
                        onTap: controller.clearSearch,
                        child: const Icon(Icons.close_rounded, color: AppColors.textMuted, size: 18),
                      )
                    : const SizedBox.shrink()),
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.divider),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.divider),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
                ),
              ),
            ),
          ),

          // ── Filter Chips ──────────────────────────────────────────────
          SizedBox(
            height: 40,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                _FilterChip(label: 'Semua', value: '', controller: controller),
                _FilterChip(label: 'Custom Baju', value: 'custom', controller: controller),
                _FilterChip(label: 'Permak', value: 'permak', controller: controller),
                _FilterChip(label: 'Seragam', value: 'seragam', controller: controller),
              ],
            ),
          ),
          const SizedBox(height: 8),

          // ── Count Header ──────────────────────────────────────────────
          Obx(() {
            if (controller.isLoading.value || controller.tailors.isEmpty) {
              return const SizedBox.shrink();
            }
            return Padding(
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 0),
              child: Row(
                children: [
                  Text(
                    '${controller.tailors.length} penjahit ditemukan',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: AppColors.textMuted,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            );
          }),
          const SizedBox(height: 8),

          // ── Results ───────────────────────────────────────────────────
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return ListView.builder(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                  itemCount: 4,
                  itemBuilder: (_, i) => const _TailorCardSkeleton(),
                );
              }
              if (controller.tailors.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 90,
                        height: 90,
                        decoration: BoxDecoration(
                          color: AppColors.divider.withValues(alpha: 0.4),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.search_off_rounded, size: 44, color: AppColors.textMuted),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'Penjahit tidak ditemukan',
                        style: GoogleFonts.poppins(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Coba ubah kata kunci atau filter',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: AppColors.textMuted,
                        ),
                      ),
                      const SizedBox(height: 20),
                      GestureDetector(
                        onTap: controller.loadTailors,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            'Coba Lagi',
                            style: GoogleFonts.poppins(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }
              return RefreshIndicator(
                color: AppColors.primary,
                onRefresh: controller.loadTailors,
                child: ListView.builder(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                  itemCount: controller.tailors.length,
                  itemBuilder: (_, i) => _ExploreTailorCard(tailor: controller.tailors[i]),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}

// ── Filter Chip (reactive via Obx internally) ─────────────────────────────────
class _FilterChip extends StatelessWidget {
  final String label;
  final String value;
  final ExploreController controller;

  const _FilterChip({required this.label, required this.value, required this.controller});

  @override
  Widget build(BuildContext context) {
    // Obx here ensures this widget rebuilds when selectedFilter changes
    return Obx(() {
      final isActive = controller.selectedFilter.value == value;
      return GestureDetector(
        onTap: () => controller.setFilter(value),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.only(right: 8),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: isActive ? AppColors.primary : Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isActive ? AppColors.primary : AppColors.divider,
            ),
            boxShadow: isActive
                ? [BoxShadow(blurRadius: 8, color: AppColors.primary.withValues(alpha: 0.25))]
                : [],
          ),
          child: Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: isActive ? Colors.white : AppColors.textSecondary,
            ),
          ),
        ),
      );
    });
  }
}

// ── Skeleton Loader ───────────────────────────────────────────────────────────
class _TailorCardSkeleton extends StatelessWidget {
  const _TailorCardSkeleton();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [BoxShadow(blurRadius: 8, color: Colors.black.withValues(alpha: 0.04))],
      ),
      child: Row(
        children: [
          Container(
            width: 64, height: 64,
            decoration: BoxDecoration(shape: BoxShape.circle, color: AppColors.divider.withValues(alpha: 0.5)),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(height: 14, width: 140, decoration: BoxDecoration(color: AppColors.divider.withValues(alpha: 0.5), borderRadius: BorderRadius.circular(4))),
                const SizedBox(height: 8),
                Container(height: 11, width: 100, decoration: BoxDecoration(color: AppColors.divider.withValues(alpha: 0.3), borderRadius: BorderRadius.circular(4))),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Container(height: 22, width: 60, decoration: BoxDecoration(color: AppColors.divider.withValues(alpha: 0.3), borderRadius: BorderRadius.circular(6))),
                    const SizedBox(width: 6),
                    Container(height: 22, width: 60, decoration: BoxDecoration(color: AppColors.divider.withValues(alpha: 0.3), borderRadius: BorderRadius.circular(6))),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Tailor Card ───────────────────────────────────────────────────────────────
class _ExploreTailorCard extends StatelessWidget {
  final TailorModel tailor;
  const _ExploreTailorCard({required this.tailor});

  @override
  Widget build(BuildContext context) {
    final openServices = tailor.availability.where((a) => a.isOpen).toList();

    return GestureDetector(
      onTap: () => Get.toNamed(Routes.TAILOR_DETAIL, arguments: tailor),
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              blurRadius: 10,
              color: Colors.black.withValues(alpha: 0.05),
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Avatar
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.primary.withValues(alpha: 0.15), width: 2),
                color: AppColors.surface,
              ),
              child: tailor.shopImage != null
                  ? ClipOval(
                      child: Image.network(
                        tailor.shopImage!,
                        fit: BoxFit.cover,
                        errorBuilder: (context, err, stack) =>
                            const Icon(Icons.person, size: 34, color: AppColors.textMuted),
                      ),
                    )
                  : const ClipOval(
                      child: Icon(Icons.person, size: 34, color: AppColors.textMuted),
                    ),
            ),
            const SizedBox(width: 16),
            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Shop name + verified badge
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          tailor.shopName,
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.w700,
                            fontSize: 14,
                            color: AppColors.textPrimary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (tailor.isVerified) ...[
                        const SizedBox(width: 4),
                        const Icon(Icons.verified_rounded, color: AppColors.primary, size: 16),
                      ],
                    ],
                  ),
                  const SizedBox(height: 4),
                  // Rating + Address
                  Row(
                    children: [
                      const Icon(Icons.star_rounded, color: AppColors.starColor, size: 14),
                      const SizedBox(width: 3),
                      Text(
                        tailor.rating.toStringAsFixed(1),
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '(${tailor.totalOrders} orders)',
                        style: GoogleFonts.poppins(fontSize: 10, color: AppColors.textMuted),
                      ),
                    ],
                  ),
                  if (tailor.address != null && tailor.address!.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        const Icon(Icons.location_on_outlined, size: 12, color: AppColors.textMuted),
                        const SizedBox(width: 2),
                        Expanded(
                          child: Text(
                            tailor.address!,
                            style: GoogleFonts.poppins(fontSize: 11, color: AppColors.textMuted),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                  const SizedBox(height: 8),
                  // Service badges
                  openServices.isNotEmpty
                      ? Wrap(
                          spacing: 6,
                          runSpacing: 4,
                          children: openServices
                              .take(3)
                              .map((a) => Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                    decoration: BoxDecoration(
                                      color: AppColors.primary.withValues(alpha: 0.08),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      _serviceLabel(a.type),
                                      style: GoogleFonts.poppins(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.primary,
                                      ),
                                    ),
                                  ))
                              .toList(),
                        )
                      : Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            'Layanan tersedia',
                            style: GoogleFonts.poppins(
                              fontSize: 10,
                              fontWeight: FontWeight.w500,
                              color: AppColors.textMuted,
                            ),
                          ),
                        ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            // Arrow
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: AppColors.primary),
            ),
          ],
        ),
      ),
    );
  }

  String _serviceLabel(String type) {
    switch (type.toLowerCase()) {
      case 'custom': return 'Custom Baju';
      case 'permak': return 'Permak';
      case 'seragam': return 'Seragam';
      default: return type;
    }
  }
}
