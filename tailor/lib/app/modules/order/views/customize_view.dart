import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../theme/app_colors.dart';
import '../controllers/customize_controller.dart';

class CustomizeView extends GetView<CustomizeController> {
  const CustomizeView({super.key});

  final List<Color> _colors = const [
    Color(0xFF2ECC71),
    Color(0xFF1B2A6B),
    Color(0xFF1F3A8A),
  ];

  final List<Map<String, dynamic>> _parts = const [
    {'icon': Icons.circle_outlined, 'label': 'Collar'},
    {'icon': Icons.straighten, 'label': 'Sleeves'},
    {'icon': Icons.category_outlined, 'label': 'Pocket'},
    {'icon': Icons.view_column_outlined, 'label': 'Placket'},
    {'icon': Icons.view_week_outlined, 'label': 'Half placket'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            _buildAppBar(),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    _buildShirtPreview(),
                    _buildPriceRow(),
                    _buildDivider(),
                    _buildCustomizationParts(),
                    _buildDivider(),
                    _buildActionButtons(),
                    _buildDivider(),
                    _buildBottomButtons(),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Get.back(),
            child: Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    blurRadius: 6,
                    color: Colors.black.withValues(alpha: 0.07),
                  ),
                ],
              ),
              child: const Icon(Icons.arrow_back_ios_new_rounded, size: 16, color: AppColors.textPrimary),
            ),
          ),
          const Spacer(),
          Text(
            'Customize your shirt',
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const Spacer(),
          const SizedBox(width: 38),
        ],
      ),
    );
  }

  Widget _buildShirtPreview() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 220,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    blurRadius: 12,
                    color: Colors.black.withValues(alpha: 0.07),
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Center(child: _ShirtIllustration()),
            ),
          ),
          const SizedBox(width: 12),
          Column(
            children: List.generate(_colors.length, (i) {
              return Obx(() {
                final isSelected = controller.selectedColorIndex.value == i;
                return GestureDetector(
                  onTap: () => controller.selectColor(i),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.only(bottom: 10),
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: _colors[i],
                      shape: BoxShape.circle,
                      border: isSelected
                          ? Border.all(color: _colors[i], width: 3)
                          : null,
                      boxShadow: isSelected
                          ? [BoxShadow(blurRadius: 8, color: _colors[i].withValues(alpha: 0.5))]
                          : [BoxShadow(blurRadius: 4, color: Colors.black.withValues(alpha: 0.15))],
                    ),
                    child: isSelected
                        ? const Icon(Icons.check, color: Colors.white, size: 16)
                        : null,
                  ),
                );
              });
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildPriceRow() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        children: [
          Text(
            '\$15.75',
            style: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              'View in 3D',
              style: GoogleFonts.poppins(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 2),
      child: Divider(color: AppColors.divider, height: 1),
    );
  }

  Widget _buildCustomizationParts() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: List.generate(_parts.length, (i) {
          return Obx(() {
            final isSelected = controller.selectedPartIndex.value == i;
            return GestureDetector(
              onTap: () => controller.selectPart(i),
              child: Column(
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.primary.withValues(alpha: 0.1)
                          : Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: isSelected ? AppColors.primary : AppColors.divider,
                        width: isSelected ? 1.5 : 1,
                      ),
                      boxShadow: [
                        BoxShadow(
                          blurRadius: 6,
                          color: Colors.black.withValues(alpha: 0.05),
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Icon(
                      _parts[i]['icon'] as IconData,
                      size: 22,
                      color: isSelected ? AppColors.primary : AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    _parts[i]['label'] as String,
                    style: GoogleFonts.poppins(
                      fontSize: 10,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                      color: isSelected ? AppColors.primary : AppColors.textMuted,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          });
        }),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      child: Row(
        children: [
          Expanded(
            child: SizedBox(
              height: 48,
              child: ElevatedButton.icon(
                onPressed: controller.uploadDesign,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                icon: const Icon(Icons.upload_outlined, size: 18),
                label: Obx(() => Text(
                  controller.uploadedImagePath.value != null ? 'Desain Diunggah' : 'Upload Design',
                  style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w600),
                )),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: SizedBox(
              height: 48,
              child: OutlinedButton.icon(
                onPressed: controller.callTailor,
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.textPrimary,
                  side: const BorderSide(color: AppColors.inputBorder),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                icon: const Icon(Icons.phone_outlined, size: 18),
                label: Text(
                  'Call Tailor',
                  style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomButtons() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      child: Row(
        children: [
          Expanded(
            child: SizedBox(
              height: 52,
              child: OutlinedButton(
                onPressed: controller.addToCart,
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.textPrimary,
                  side: const BorderSide(color: AppColors.inputBorder),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: Text(
                  'Add to card',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: SizedBox(
              height: 52,
              child: ElevatedButton(
                onPressed: controller.orderNow,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: Text(
                  'Order',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Shirt Illustration ────────────────────────────────────────────────────────
class _ShirtIllustration extends StatelessWidget {
  const _ShirtIllustration();

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: const Size(140, 180),
      painter: _ShirtPainter(),
    );
  }
}

class _ShirtPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    const shirtColor = Color(0xFF1B2A6B);
    const shadowColor = Color(0xFF0F1A4E);
    final buttonColor = Colors.white.withValues(alpha: 0.6);
    const highlightColor = Color(0xFF2D3E8F);

    final paint = Paint()..isAntiAlias = true;
    final w = size.width;
    final h = size.height;

    // Body
    paint.color = shirtColor;
    final bodyPath = Path();
    bodyPath.moveTo(w * 0.2, h * 0.18);
    bodyPath.lineTo(w * 0.0, h * 0.32);
    bodyPath.lineTo(w * 0.18, h * 0.42);
    bodyPath.lineTo(w * 0.18, h);
    bodyPath.lineTo(w * 0.82, h);
    bodyPath.lineTo(w * 0.82, h * 0.42);
    bodyPath.lineTo(w, h * 0.32);
    bodyPath.lineTo(w * 0.8, h * 0.18);
    bodyPath.lineTo(w * 0.62, h * 0.12);
    bodyPath.lineTo(w * 0.5, h * 0.25);
    bodyPath.lineTo(w * 0.38, h * 0.12);
    bodyPath.close();
    canvas.drawPath(bodyPath, paint);

    // Collar shadow
    paint.color = shadowColor;
    final collarPath = Path();
    collarPath.moveTo(w * 0.38, h * 0.12);
    collarPath.lineTo(w * 0.5, h * 0.25);
    collarPath.lineTo(w * 0.62, h * 0.12);
    collarPath.lineTo(w * 0.55, h * 0.06);
    collarPath.lineTo(w * 0.5, h * 0.1);
    collarPath.lineTo(w * 0.45, h * 0.06);
    collarPath.close();
    canvas.drawPath(collarPath, paint);

    // Left sleeve shading
    final leftSleeveShade = Path();
    leftSleeveShade.moveTo(w * 0.2, h * 0.18);
    leftSleeveShade.lineTo(w * 0.05, h * 0.3);
    leftSleeveShade.lineTo(w * 0.12, h * 0.38);
    leftSleeveShade.lineTo(w * 0.18, h * 0.35);
    leftSleeveShade.close();
    canvas.drawPath(leftSleeveShade, paint);

    // Right sleeve shading
    final rightSleeveShade = Path();
    rightSleeveShade.moveTo(w * 0.8, h * 0.18);
    rightSleeveShade.lineTo(w * 0.95, h * 0.3);
    rightSleeveShade.lineTo(w * 0.88, h * 0.38);
    rightSleeveShade.lineTo(w * 0.82, h * 0.35);
    rightSleeveShade.close();
    canvas.drawPath(rightSleeveShade, paint);

    // Body highlight strip
    canvas.drawPath(
      Path()
        ..moveTo(w * 0.35, h * 0.25)
        ..lineTo(w * 0.42, h * 0.25)
        ..lineTo(w * 0.42, h * 0.85)
        ..lineTo(w * 0.35, h * 0.85)
        ..close(),
      Paint()
        ..color = shadowColor.withValues(alpha: 0.3)
        ..isAntiAlias = true,
    );

    // Buttons
    paint.color = buttonColor;
    for (int i = 0; i < 5; i++) {
      canvas.drawCircle(Offset(w * 0.5, h * (0.32 + i * 0.12)), 3, paint);
    }

    // Pocket outline
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(w * 0.22, h * 0.42, w * 0.18, h * 0.12),
        const Radius.circular(4),
      ),
      Paint()
        ..color = highlightColor.withValues(alpha: 0.5)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5
        ..isAntiAlias = true,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
