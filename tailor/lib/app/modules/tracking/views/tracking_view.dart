import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../../theme/app_colors.dart';
import '../../../data/models/order_model.dart';
import '../controllers/tracking_controller.dart';

class TrackingView extends GetView<TrackingController> {
  const TrackingView({super.key});

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
              boxShadow: [
                BoxShadow(
                  blurRadius: 6,
                  color: Colors.black.withValues(alpha: 0.07),
                )
              ],
            ),
            child: const Icon(Icons.arrow_back_ios_new_rounded, size: 16, color: AppColors.textPrimary),
          ),
        ),
        title: Text(
          'Tracking Pesanan',
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: AppColors.primary),
            onPressed: controller.loadTracking,
          ),
        ],
        backgroundColor: AppColors.background,
        elevation: 0,
        centerTitle: true,
      ),
      body: Obx(() {
        if (controller.isLoading.value && controller.steps.isEmpty) {
          return const Center(child: CircularProgressIndicator(color: AppColors.primary));
        }
        return RefreshIndicator(
          color: AppColors.primary,
          onRefresh: controller.loadTracking,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildQueueCard(),
                const SizedBox(height: 20),
                _buildStatusBanner(),
                const SizedBox(height: 28),
                Text(
                  'Timeline Pesanan',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        blurRadius: 16,
                        color: Colors.black.withValues(alpha: 0.04),
                        offset: const Offset(0, 4),
                      )
                    ],
                  ),
                  child: _buildStepper(),
                ),
                const SizedBox(height: 30),
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget _buildQueueCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1B2A6B), Color(0xFF2D3E8F)],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            blurRadius: 16,
            color: AppColors.primary.withValues(alpha: 0.35),
            offset: const Offset(0, 6),
          )
        ],
      ),
      child: Row(
        children: [
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Nomor Antrian', style: GoogleFonts.poppins(color: Colors.white70, fontSize: 13)),
            const SizedBox(height: 4),
            Obx(() => Text('#${controller.queueNumber.value ?? '-'}',
                style: GoogleFonts.poppins(
                    fontSize: 38, fontWeight: FontWeight.w700, color: Colors.white))),
          ]),
          const Spacer(),
          Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
            Text('Estimasi Selesai', style: GoogleFonts.poppins(color: Colors.white70, fontSize: 13)),
            const SizedBox(height: 4),
            Obx(() => Text(
                controller.estimatedDone.value != null
                    ? _formatDate(controller.estimatedDone.value!)
                    : '-',
                style: GoogleFonts.poppins(fontWeight: FontWeight.w600, color: Colors.white, fontSize: 14))),
          ]),
        ],
      ),
    );
  }

  Widget _buildStatusBanner() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            blurRadius: 10,
            color: Colors.black.withValues(alpha: 0.05),
            offset: const Offset(0, 2),
          )
        ],
      ),
      child: Row(children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.info_outline_rounded, color: AppColors.primary, size: 22),
        ),
        const SizedBox(width: 14),
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Status Saat Ini', style: GoogleFonts.poppins(fontSize: 12, color: AppColors.textMuted)),
          Obx(() => Text(controller.statusLabel,
              style: GoogleFonts.poppins(fontWeight: FontWeight.w700, color: AppColors.primary, fontSize: 15))),
        ]),
        const Spacer(),
        if (controller.fittingDate.value != null)
          Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
            Text('Jadwal Fitting', style: GoogleFonts.poppins(fontSize: 12, color: AppColors.textMuted)),
            Text(_formatDate(controller.fittingDate.value!),
                style: GoogleFonts.poppins(fontWeight: FontWeight.w600, color: AppColors.textPrimary, fontSize: 13)),
          ]),
      ]),
    );
  }

  Widget _buildStepper() {
    return Obx(() {
      if (controller.steps.isEmpty) {
        return Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: Text('Tidak ada data tracking',
              style: GoogleFonts.poppins(color: AppColors.textMuted)),
          ),
        );
      }
      return Column(
        children: controller.steps.asMap().entries.map((entry) {
          final i = entry.key;
          final step = entry.value;
          final isLast = i == controller.steps.length - 1;
          return _StepItem(step: step, isLast: isLast);
        }).toList(),
      );
    });
  }

  String _formatDate(String isoDate) {
    try {
      final dt = DateTime.parse(isoDate).toLocal();
      return DateFormat('dd MMM yyyy', 'id_ID').format(dt);
    } catch (_) {
      return isoDate;
    }
  }
}

class _StepItem extends StatelessWidget {
  final TrackingStep step;
  final bool isLast;
  const _StepItem({required this.step, required this.isLast});

  @override
  Widget build(BuildContext context) {
    final activeColor = step.isCompleted ? AppColors.primary : AppColors.divider;
    final textColor = step.isCompleted ? AppColors.textPrimary : AppColors.textMuted;

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Timeline line + dot
          Column(children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 400),
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: step.isCurrent 
                    ? AppColors.primary 
                    : (step.isCompleted ? AppColors.primary.withValues(alpha: 0.1) : AppColors.background),
                shape: BoxShape.circle,
                border: Border.all(
                  color: step.isCurrent ? AppColors.primary : activeColor, 
                  width: step.isCurrent ? 0 : 1.5
                ),
              ),
              child: Center(
                child: Text(step.icon, 
                  style: TextStyle(
                    fontSize: 14, 
                    color: step.isCurrent ? Colors.white : (step.isCompleted ? AppColors.primary : AppColors.textMuted)
                  )
                ),
              ),
            ),
            if (!isLast)
              Expanded(
                child: Container(
                  width: 2,
                  color: step.isCompleted ? AppColors.primary.withValues(alpha: 0.3) : AppColors.divider,
                ),
              ),
          ]),
          const SizedBox(width: 16),
          // Content
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: isLast ? 0 : 24, top: 4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(step.label,
                      style: GoogleFonts.poppins(
                          fontWeight: step.isCurrent ? FontWeight.w600 : FontWeight.w500,
                          fontSize: 14, color: textColor)),
                  if (step.completedAt != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 2),
                      child: Text(_formatDate(step.completedAt!),
                          style: GoogleFonts.poppins(fontSize: 11, color: AppColors.textMuted)),
                    ),
                  if (step.isCurrent)
                    Container(
                      margin: const EdgeInsets.only(top: 8),
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text('Status saat ini',
                          style: GoogleFonts.poppins(fontSize: 11, color: AppColors.primary, fontWeight: FontWeight.w600)),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(String isoDate) {
    try {
      final dt = DateTime.parse(isoDate).toLocal();
      return DateFormat('dd MMM yyyy, HH:mm', 'id_ID').format(dt);
    } catch (_) {
      return isoDate;
    }
  }
}
