import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../theme/app_colors.dart';
import '../controllers/activity_log_controller.dart';

class ActivityLogView extends GetView<ActivityLogController> {
  const ActivityLogView({super.key});

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
          'Aktivitas Saya',
          style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
        ),
        backgroundColor: AppColors.background,
        elevation: 0,
        centerTitle: true,
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        if (controller.logs.isEmpty) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.history_rounded, size: 64, color: AppColors.textMuted.withValues(alpha: 0.5)),
                const SizedBox(height: 16),
                Text('Belum ada aktivitas', style: GoogleFonts.poppins(fontSize: 16, color: AppColors.textMuted)),
              ],
            ),
          );
        }
        return ListView.separated(
          padding: const EdgeInsets.all(20),
          itemCount: controller.logs.length,
          separatorBuilder: (_, __) => const SizedBox(height: 8),
          itemBuilder: (context, index) {
            final log = controller.logs[index];
            final type = log['activity_type'] as String? ?? '';
            final desc = log['description'] as String? ?? '';
            final createdAt = log['created_at'] as String? ?? '';

            IconData icon;
            Color iconColor;
            String label;
            switch (type) {
              case 'login':
                icon = Icons.login_rounded;
                iconColor = AppColors.success;
                label = 'Login';
                break;
              case 'logout':
                icon = Icons.logout_rounded;
                iconColor = AppColors.error;
                label = 'Logout';
                break;
              case 'checkout':
                icon = Icons.receipt_long_rounded;
                iconColor = AppColors.primary;
                label = 'Pesanan Baru';
                break;
              case 'order_update':
                icon = Icons.update_rounded;
                iconColor = const Color(0xFFF59E0B);
                label = 'Status Pesanan';
                break;
              default:
                icon = Icons.info_outline;
                iconColor = AppColors.textMuted;
                label = type;
            }

            return Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                boxShadow: [BoxShadow(blurRadius: 8, color: Colors.black.withValues(alpha: 0.04))],
              ),
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: iconColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(icon, color: iconColor, size: 22),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(label, style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 14, color: AppColors.textPrimary)),
                        if (desc.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 2),
                            child: Text(desc, style: GoogleFonts.poppins(fontSize: 12, color: AppColors.textSecondary), maxLines: 1, overflow: TextOverflow.ellipsis),
                          ),
                      ],
                    ),
                  ),
                  if (createdAt.isNotEmpty)
                    Text(
                      _formatTime(createdAt),
                      style: GoogleFonts.poppins(fontSize: 11, color: AppColors.textMuted),
                    ),
                ],
              ),
            );
          },
        );
      }),
    );
  }

  String _formatTime(String iso) {
    try {
      final dt = DateTime.parse(iso);
      final now = DateTime.now();
      final diff = now.difference(dt);
      if (diff.inMinutes < 1) return 'Baru saja';
      if (diff.inMinutes < 60) return '${diff.inMinutes}m';
      if (diff.inHours < 24) return '${diff.inHours}j';
      return '${diff.inDays}h';
    } catch (_) {
      return '';
    }
  }
}
