import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../../theme/app_colors.dart';
import '../../../data/models/order_model.dart';
import '../../../routes/app_pages.dart';
import '../controllers/orders_controller.dart';

class OrdersView extends GetView<OrdersController> {
  final bool showBackButton;
  const OrdersView({super.key, this.showBackButton = true});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: showBackButton
            ? GestureDetector(
                onTap: () => Get.back(),
                child: Container(
                  margin: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(blurRadius: 6, color: Colors.black.withValues(alpha: 0.07))
                    ],
                  ),
                  child: const Icon(Icons.arrow_back_ios_new_rounded,
                      size: 16, color: AppColors.textPrimary),
                ),
              )
            : null,
        title: Text(
          'Pesanan Saya',
          style: GoogleFonts.poppins(
              fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
        ),
        backgroundColor: AppColors.background,
        elevation: 0,
        actions: [
          // Manual refresh button
          Obx(() => controller.isLoading.value
              ? const SizedBox(
                  width: 40,
                  child: Center(
                    child: SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                          color: AppColors.primary, strokeWidth: 2),
                    ),
                  ),
                )
              : IconButton(
                  icon: const Icon(Icons.refresh_rounded, color: AppColors.primary),
                  onPressed: controller.loadOrders,
                  tooltip: 'Refresh',
                )),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator(color: AppColors.primary));
        }

        // ── Error State ───────────────────────────────────────────────────
        if (controller.hasError.value) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      color: AppColors.error.withValues(alpha: 0.08),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.wifi_off_rounded,
                        color: AppColors.error, size: 34),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Gagal Memuat Pesanan',
                    style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary),
                  ),
                  const SizedBox(height: 8),
                  Obx(() => Text(
                        controller.errorMessage.value,
                        textAlign: TextAlign.center,
                        style: GoogleFonts.poppins(
                            fontSize: 13, color: AppColors.textMuted, height: 1.5),
                      )),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: controller.loadOrders,
                    icon: const Icon(Icons.refresh_rounded, size: 18),
                    label: Text('Coba Lagi',
                        style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 12),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        // ── Empty State ───────────────────────────────────────────────────
        if (controller.orders.isEmpty) {
          return RefreshIndicator(
            color: AppColors.primary,
            onRefresh: controller.loadOrders,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: SizedBox(
                height: MediaQuery.of(context).size.height * 0.7,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.08),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.receipt_long_outlined,
                          size: 38, color: AppColors.primary),
                    ),
                    const SizedBox(height: 16),
                    Text('Belum Ada Pesanan',
                        style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary)),
                    const SizedBox(height: 8),
                    Text('Mulai memesan dari penjahit terdekat',
                        style: GoogleFonts.poppins(
                            color: AppColors.textMuted, fontSize: 13)),
                    const SizedBox(height: 24),
                    Text(
                      'Tarik ke bawah untuk refresh',
                      style: GoogleFonts.poppins(
                          fontSize: 12, color: AppColors.textMuted),
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        // ── Orders List ───────────────────────────────────────────────────
        return RefreshIndicator(
          color: AppColors.primary,
          onRefresh: controller.loadOrders,
          child: ListView.builder(
            padding: const EdgeInsets.all(20),
            itemCount: controller.orders.length,
            itemBuilder: (_, i) => _OrderCard(order: controller.orders[i]),
          ),
        );
      }),
    );
  }
}

// ── Order Card ────────────────────────────────────────────────────────────────
class _OrderCard extends StatelessWidget {
  final OrderModel order;
  const _OrderCard({required this.order});

  Color get _statusColor {
    switch (order.status) {
      case 'selesai':
      case 'siap_diambil':
        return AppColors.success;
      case 'rejected':
        return AppColors.error;
      case 'pending':
        return AppColors.warning;
      default:
        return AppColors.info;
    }
  }

  String get _statusLabel {
    switch (order.status) {
      case 'pending':       return 'Menunggu';
      case 'accepted':      return 'Diterima';
      case 'fitting':       return 'Fitting';
      case 'diproses':      return 'Diproses';
      case 'dijahit':       return 'Dijahit';
      case 'selesai':       return 'Selesai';
      case 'siap_diambil':  return 'Siap Diambil';
      case 'rejected':      return 'Ditolak';
      default:              return order.status;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Get.toNamed(Routes.TRACKING, arguments: order.id),
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(blurRadius: 10, color: Colors.black.withValues(alpha: 0.06))
          ],
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '#${order.queueNumber ?? order.id}',
                style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                    fontSize: 13),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                order.type.toUpperCase(),
                style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                    fontSize: 13),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: _statusColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                _statusLabel,
                style: GoogleFonts.poppins(
                    fontSize: 11, fontWeight: FontWeight.w600, color: _statusColor),
              ),
            ),
          ]),
          const SizedBox(height: 12),
          Row(children: [
            const Icon(Icons.content_cut, size: 14, color: AppColors.textMuted),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                order.tailorName ?? '-',
                style: GoogleFonts.poppins(
                    color: AppColors.textSecondary, fontSize: 13),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ]),
          const SizedBox(height: 8),
          Row(children: [
            if (order.estimatedDone != null) ...[
              const Icon(Icons.event_outlined, size: 14, color: AppColors.textMuted),
              const SizedBox(width: 6),
              Text(
                'Est: ${_fmt(order.estimatedDone!)}',
                style: GoogleFonts.poppins(color: AppColors.textMuted, fontSize: 12),
              ),
            ],
            const Spacer(),
            Text(
              'Lihat Detail →',
              style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600),
            ),
          ]),
        ]),
      ),
    );
  }

  String _fmt(String iso) {
    try {
      return DateFormat('dd MMM yyyy').format(DateTime.parse(iso));
    } catch (_) {
      return iso;
    }
  }
}
