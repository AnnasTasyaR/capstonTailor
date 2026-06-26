import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../theme/app_colors.dart';
import '../controllers/informasi_controller.dart';

class InformasiView extends GetView<InformasiController> {
  const InformasiView({super.key});

  @override
  Widget build(BuildContext context) {
    Get.put(InformasiController());
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(100),
          child: _buildHeader(),
        ),
        body: Column(
          children: [
            TabBar(
              onTap: (i) => controller.changeTab(i),
              indicatorColor: AppColors.primary,
              indicatorWeight: 3,
              labelColor: AppColors.primary,
              unselectedLabelColor: AppColors.textMuted,
              labelStyle: GoogleFonts.poppins(
                  fontSize: 12, fontWeight: FontWeight.w600),
              unselectedLabelStyle: GoogleFonts.poppins(fontSize: 12),
              tabs: const [
                Tab(text: 'Populer', icon: Icon(Icons.trending_up, size: 18)),
                Tab(text: 'Tren Harian', icon: Icon(Icons.show_chart, size: 18)),
                Tab(text: 'Rating', icon: Icon(Icons.star, size: 18)),
              ],
            ),
            Expanded(
              child: TabBarView(
                children: [
                  _PopulerTab(),
                  _TrenTab(),
                  _RatingTab(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF1B2A6B), Color(0xFF2D3E8F)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      padding: EdgeInsets.fromLTRB(24, MediaQuery.of(Get.context!).padding.top + 8, 8, 12),
      child: Row(
        children: [
          Container(
            width: 40, height: 40,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.asset(
                'assets/images/logo.png',
                width: 40, height: 40, fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Analitik Fashion',
                  style: GoogleFonts.poppins(
                    fontSize: 18, fontWeight: FontWeight.w700, color: Colors.white,
                  ),
                ),
                Text('Update setiap hari',
                  style: GoogleFonts.poppins(
                    fontSize: 11, color: Colors.white.withValues(alpha: 0.7),
                  ),
                ),
              ],
            ),
          ),
          Obx(() => IconButton(
            onPressed: controller.isLoadingPopuler.value ||
                controller.isLoadingTren.value ||
                controller.isLoadingRating.value
                ? null
                : () => controller.loadAll(),
            icon: controller.isLoadingPopuler.value ||
                controller.isLoadingTren.value ||
                controller.isLoadingRating.value
                ? const SizedBox(
                    width: 20, height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2, color: Colors.white,
                    ),
                  )
                : const Icon(Icons.refresh_rounded, color: Colors.white),
            tooltip: 'Refresh data',
          )),
        ],
      ),
    );
  }
}

// ── Tab 1: Populer ────────────────────────────────────────────────────────────
class _PopulerTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GetBuilder<InformasiController>(builder: (c) {
      if (c.isLoadingPopuler.value) {
        return const Center(child: CircularProgressIndicator());
      }
      if (c.populer.isEmpty) {
        return const Center(
          child: Text('Belum ada data'),
        );
      }
      return RefreshIndicator(
        onRefresh: () => c.loadPopuler(),
        child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: c.populer.length,
                  itemBuilder: (_, i) {
          final item = c.populer[i];
          final sold = item['historical_sold'] ?? 0;
          return _ProductCard(
            rank: i + 1,
            title: item['title'] ?? '',
            category: item['category'] ?? '',
            value: '$sold terjual',
            price: item['price'] ?? 0,
            color: i < 3
                ? const Color(0xFF1B2A6B)
                : AppColors.textSecondary,
          );
        },
      ),
      );
    });
  }
}

// ── Tab 2: Tren Harian ────────────────────────────────────────────────────────
class _TrenTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GetBuilder<InformasiController>(builder: (c) {
      if (c.isLoadingTren.value) {
        return const Center(child: CircularProgressIndicator());
      }
      if (c.tren.isEmpty) {
        return const Center(child: Text('Belum ada data tren'));
      }
      final totalOrders = c.tren.fold<int>(0, (s, t) => s + ((t['orders'] as int?) ?? 0));
      final avgOrders = (totalOrders / c.tren.length).round();
      final maxDay = c.tren.reduce(
          (a, b) => (a['orders'] ?? 0) > (b['orders'] ?? 0) ? a : b);
      final maxOrders = maxDay['orders'] ?? 1;
      final last7 = c.tren.sublist(c.tren.length > 7 ? c.tren.length - 7 : 0);

      return RefreshIndicator(
        onRefresh: () => c.loadTren(),
        child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // ── Summary Cards ──────────────────────────────────────────────────
          Row(
            children: [
              _SummaryCard(
                label: 'Total Order',
                value: '$totalOrders',
                icon: Icons.shopping_bag_rounded,
                color: const Color(0xFF1B2A6B),
              ),
              const SizedBox(width: 10),
              _SummaryCard(
                label: 'Rata-rata/hari',
                value: '$avgOrders',
                icon: Icons.show_chart_rounded,
                color: const Color(0xFF3B82F6),
              ),
              const SizedBox(width: 10),
              _SummaryCard(
                label: 'Puncak',
                value: '$maxOrders',
                icon: Icons.trending_up_rounded,
                color: const Color(0xFFF59E0B),
              ),
            ],
          ),
          // ── Card: Grafik 7 Hari Terakhir ─────────────────────────────────────
          _ChartCard(last7: last7, maxOrders: maxOrders, maxDay: maxDay),
          const SizedBox(height: 20),
          Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: const Color(0xFFF59E0B).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.whatshot_rounded,
                      size: 18, color: Color(0xFFF59E0B)),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      'Puncak order: ${maxDay['date']} ($maxOrders order)',
                      style: GoogleFonts.poppins(
                        fontSize: 12, fontWeight: FontWeight.w600,
                        color: const Color(0xFF92400E),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          Center(
            child: Text(
              'Data diperbarui setiap hari (WIB)',
              style: GoogleFonts.poppins(
                fontSize: 11,
                color: AppColors.textMuted,
              ),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
      );
    });
  }
}

// ── Summary Card ──────────────────────────────────────────────────────────────
class _SummaryCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;
  const _SummaryCard({
    required this.label, required this.value,
    required this.icon, required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              blurRadius: 8,
              color: Colors.black.withValues(alpha: 0.04),
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              width: 32, height: 32,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, size: 16, color: color),
            ),
            const SizedBox(height: 8),
            Text(value,
              style: GoogleFonts.poppins(
                fontSize: 16, fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
              ),
            ),
            Text(label,
              style: GoogleFonts.poppins(
                fontSize: 9, color: AppColors.textMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

String _dayName(String dateStr) {
  if (dateStr.length < 10) return dateStr;
  final date = DateTime.tryParse(dateStr);
  if (date == null) return dateStr;
  const days = ['Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab', 'Min'];
  return days[date.weekday - 1];
}

// ── Chart Card ─────────────────────────────────────────────────────────────────
class _ChartCard extends StatelessWidget {
  final List<Map<String, dynamic>> last7;
  final int maxOrders;
  final Map<String, dynamic> maxDay;
  const _ChartCard({
    required this.last7,
    required this.maxOrders,
    required this.maxDay,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            blurRadius: 10,
            color: Colors.black.withValues(alpha: 0.04),
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.bar_chart_rounded,
                  size: 18, color: Color(0xFF1B2A6B)),
              const SizedBox(width: 8),
              Text('Grafik Order 7 Hari Terakhir',
                style: GoogleFonts.poppins(
                  fontSize: 13, fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text('Tinggi batang = jumlah order hari itu. Angka di atas = jumlah order.',
            style: GoogleFonts.poppins(
              fontSize: 10, color: AppColors.textMuted,
            ),
          ),
          const SizedBox(height: 20),
          // Chart area
          SizedBox(
            height: 130,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(
                  width: 28,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [maxOrders, maxOrders * 3 ~/ 4, maxOrders ~/ 2, maxOrders ~/ 4, 0].map((v) {
                      final val = v > maxOrders ? maxOrders : v;
                      return Text('$val',
                        style: GoogleFonts.poppins(
                          fontSize: 8, color: AppColors.textMuted,
                        ),
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Stack(
                    children: [
                      Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: List.generate(5, (_) => Divider(
                          height: 1,
                          color: AppColors.divider.withValues(alpha: 0.4),
                        )),
                      ),
                      Positioned.fill(
                        child: Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: last7.map((t) {
                              final orders = (t['orders'] as int?) ?? 0;
                              final ratio = maxOrders > 0
                                  ? orders / maxOrders
                                  : 0.0;
                              final dateStr = t['date'] as String;
                              final isToday =
                                  dateStr == last7.last['date'];
                              return Expanded(
                                child: Column(
                                  mainAxisAlignment:
                                      MainAxisAlignment.end,
                                  children: [
                                    Container(
                                      height: (100.0 * ratio)
                                          .clamp(4.0, 100.0),
                                      decoration: BoxDecoration(
                                        color: isToday
                                            ? const Color(0xFF1B2A6B)
                                            : const Color(0xFF3B82F6),
                                        borderRadius:
                                            BorderRadius.vertical(
                                          top: Radius.circular(
                                              isToday ? 6 : 4),
                                        ),
                                      ),
                                      alignment: Alignment.topCenter,
                                      child: Padding(
                                        padding:
                                            const EdgeInsets.only(top: 2),
                                        child: Text('$orders',
                                          style: GoogleFonts.poppins(
                                            fontSize: 9,
                                            fontWeight: FontWeight.w700,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          // Day labels
          Padding(
            padding: const EdgeInsets.only(left: 28),
            child: Row(
              children: last7.map((t) {
                final dateStr = t['date'] as String;
                final isToday = dateStr == last7.last['date'];
                return Expanded(
                  child: Column(
                    children: [
                      Text(_dayName(dateStr),
                        style: GoogleFonts.poppins(
                          fontSize: 9,
                          color: isToday
                              ? AppColors.primary
                              : AppColors.textMuted,
                          fontWeight: isToday
                              ? FontWeight.w700
                              : FontWeight.w400,
                        ),
                      ),
                      Text(dateStr.length >= 10
                          ? dateStr.substring(8, 10)
                          : dateStr,
                        style: GoogleFonts.poppins(
                          fontSize: 10,
                          fontWeight: isToday
                              ? FontWeight.w700
                              : FontWeight.w500,
                          color: isToday
                              ? AppColors.primary
                              : AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 14),
          // Legend
          Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _LegendDot(color: const Color(0xFF1B2A6B), label: 'Hari ini'),
                const SizedBox(width: 16),
                _LegendDot(color: const Color(0xFF3B82F6), label: 'Hari sebelumnya'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _LegendDot extends StatelessWidget {
  final Color color;
  final String label;
  const _LegendDot({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10, height: 10,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 4),
        Text(label,
          style: GoogleFonts.poppins(
            fontSize: 10, color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}

// ── Tab 3: Rating ─────────────────────────────────────────────────────────────
class _RatingTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GetBuilder<InformasiController>(builder: (c) {
      if (c.isLoadingRating.value) {
        return const Center(child: CircularProgressIndicator());
      }
      if (c.rating.isEmpty) {
        return const Center(child: Text('Belum ada data rating'));
      }
      return RefreshIndicator(
        onRefresh: () => c.loadRating(),
        child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: c.rating.length,
        itemBuilder: (_, i) {
          final item = c.rating[i];
          final avg = (item['rating_avg'] ?? 0).toDouble();
          final count = item['rating_count'] ?? 0;
          return _RatingCard(
            rank: i + 1,
            title: item['title'] ?? '',
            category: item['category'] ?? '',
            rating: avg,
            count: count,
          );
        },
      ),
      );
    });
  }
}

// ── Widget Bantuan ────────────────────────────────────────────────────────────

class _ProductCard extends StatelessWidget {
  final int rank;
  final String title;
  final String category;
  final String value;
  final dynamic price;
  final Color color;
  const _ProductCard({
    required this.rank,
    required this.title,
    required this.category,
    required this.value,
    required this.price,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final priceVal = (price is int ? price : double.tryParse(price.toString()) ?? 0);
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            blurRadius: 8,
            color: Colors.black.withValues(alpha: 0.04),
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Text(
                '$rank',
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: color,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  category,
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    color: AppColors.textMuted,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                value,
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                ),
              ),
              Text(
                'Rp ${_fmt(priceVal)}',
                style: GoogleFonts.poppins(
                  fontSize: 11,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _fmt(int n) {
    return n.toString().replaceAllMapped(
        RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.');
  }
}

class _RatingCard extends StatelessWidget {
  final int rank;
  final String title;
  final String category;
  final double rating;
  final int count;
  const _RatingCard({
    required this.rank,
    required this.title,
    required this.category,
    required this.rating,
    required this.count,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            blurRadius: 8,
            color: Colors.black.withValues(alpha: 0.04),
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: const Color(0xFFF59E0B).withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Text(
                '$rank',
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFFF59E0B),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  category,
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    color: AppColors.textMuted,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Row(
                children: [
                  const Icon(Icons.star, size: 16, color: Color(0xFFF59E0B)),
                  const SizedBox(width: 4),
                  Text(
                    rating.toStringAsFixed(1),
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
              Text(
                '$count ulasan',
                style: GoogleFonts.poppins(
                  fontSize: 11,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Tren Chart ────────────────────────────────────────────────────────────────

