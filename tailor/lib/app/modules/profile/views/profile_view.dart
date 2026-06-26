import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../theme/app_colors.dart';
import '../controllers/profile_controller.dart';

class ProfileView extends GetView<ProfileController> {
  final bool showBackButton;
  const ProfileView({super.key, this.showBackButton = true});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leading: showBackButton
            ? GestureDetector(
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
              )
            : null,
        title: Text(
          'Profil Saya',
          style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
        ),
        backgroundColor: AppColors.background,
        elevation: 0,
        centerTitle: true,
      ),
      body: Obx(() {
        final u = controller.user.value;
        return SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              // Avatar
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF1B2A6B), Color(0xFF2D3E8F)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      blurRadius: 16,
                      color: AppColors.primary.withValues(alpha: 0.3),
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    (u?.name.isNotEmpty == true) ? u!.name[0].toUpperCase() : 'U',
                    style: GoogleFonts.poppins(
                      fontSize: 40,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                u?.name ?? '-',
                style: GoogleFonts.poppins(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                u?.email ?? '-',
                style: GoogleFonts.poppins(color: AppColors.textMuted, fontSize: 13),
              ),
              if (u?.phone != null) ...[
                const SizedBox(height: 4),
                Text(
                  u!.phone!,
                  style: GoogleFonts.poppins(color: AppColors.textMuted, fontSize: 13),
                ),
              ],
              const SizedBox(height: 32),

              // Menu Items
              _MenuCard(children: [
                _MenuItem(
                  icon: Icons.person_outline,
                  title: 'Edit Profil',
                  onTap: () => _showEditProfile(context),
                ),
                _MenuItem(
                  icon: Icons.receipt_long_outlined,
                  title: 'Pesanan Saya',
                  onTap: () => Get.toNamed('/orders'),
                ),
                _MenuItem(
                  icon: Icons.favorite_outline_rounded,
                  title: 'Penjahit Favorit',
                  onTap: () => Get.toNamed('/favourite'),
                ),
              ]),
              const SizedBox(height: 16),
              _MenuCard(children: [
                _MenuItem(
                  icon: Icons.lock_outline,
                  title: 'Keamanan Akun',
                  subtitle: 'Ubah password',
                  onTap: () => _showChangePassword(context),
                ),
                Obx(() => _MenuItem(
                  icon: Icons.notifications_outlined,
                  title: 'Notifikasi',
                  subtitle: controller.notificationsEnabled.value ? 'Aktif' : 'Nonaktif',
                  trailing: Switch(
                    value: controller.notificationsEnabled.value,
                    onChanged: (v) => controller.notificationsEnabled.value = v,
                    activeThumbColor: AppColors.primary,
                    activeTrackColor: AppColors.primary.withValues(alpha: 0.4),
                  ),
                  onTap: null,
                )),
              ]),
              const SizedBox(height: 16),
              _MenuCard(children: [
                _MenuItem(
                  icon: Icons.logout_rounded,
                  title: 'Logout',
                  titleColor: AppColors.error,
                  iconColor: AppColors.error,
                  onTap: controller.confirmLogout,
                ),
              ]),
            ],
          ),
        );
      }),
    );
  }

  void _showEditProfile(BuildContext context) {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(28),
        decoration: const BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Edit Profil',
              style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
            ),
            const SizedBox(height: 24),
            TextField(
              controller: TextEditingController(text: controller.editName.value),
              onChanged: (v) => controller.editName.value = v,
              decoration: InputDecoration(
                labelText: 'Nama Lengkap',
                labelStyle: GoogleFonts.poppins(color: AppColors.textMuted),
                prefixIcon: const Icon(Icons.person_outline, color: AppColors.primary),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: TextEditingController(text: controller.editPhone.value),
              onChanged: (v) => controller.editPhone.value = v,
              keyboardType: TextInputType.phone,
              decoration: InputDecoration(
                labelText: 'No. Telepon',
                labelStyle: GoogleFonts.poppins(color: AppColors.textMuted),
                prefixIcon: const Icon(Icons.phone_outlined, color: AppColors.primary),
              ),
            ),
            const SizedBox(height: 24),
            Obx(() => SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: controller.isSaving.value ? null : controller.saveProfile,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  elevation: 0,
                ),
                child: controller.isSaving.value
                    ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5))
                    : Text('Simpan', style: GoogleFonts.poppins(fontWeight: FontWeight.w600, color: Colors.white)),
              ),
            )),
            const SizedBox(height: 12),
          ],
        ),
      ),
      isScrollControlled: true,
    );
  }

  void _showChangePassword(BuildContext context) {
    final o1 = true.obs, o2 = true.obs, o3 = true.obs;
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(28),
        decoration: const BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Ubah Password',
              style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
            ),
            const SizedBox(height: 24),
            Obx(() => TextField(
              onChanged: (v) => controller.oldPassword.value = v,
              obscureText: o1.value,
              decoration: InputDecoration(
                labelText: 'Password Lama',
                labelStyle: GoogleFonts.poppins(color: AppColors.textMuted),
                prefixIcon: const Icon(Icons.lock_outline, color: AppColors.primary),
                suffixIcon: IconButton(
                  icon: Icon(o1.value ? Icons.visibility_off_outlined : Icons.visibility_outlined, color: AppColors.textMuted),
                  onPressed: () => o1.toggle(),
                ),
              ),
            )),
            const SizedBox(height: 16),
            Obx(() => TextField(
              onChanged: (v) => controller.newPassword.value = v,
              obscureText: o2.value,
              decoration: InputDecoration(
                labelText: 'Password Baru',
                labelStyle: GoogleFonts.poppins(color: AppColors.textMuted),
                prefixIcon: const Icon(Icons.lock_outline, color: AppColors.primary),
                suffixIcon: IconButton(
                  icon: Icon(o2.value ? Icons.visibility_off_outlined : Icons.visibility_outlined, color: AppColors.textMuted),
                  onPressed: () => o2.toggle(),
                ),
              ),
            )),
            const SizedBox(height: 16),
            Obx(() => TextField(
              onChanged: (v) => controller.confirmNewPassword.value = v,
              obscureText: o3.value,
              decoration: InputDecoration(
                labelText: 'Konfirmasi Password Baru',
                labelStyle: GoogleFonts.poppins(color: AppColors.textMuted),
                prefixIcon: const Icon(Icons.lock_outline, color: AppColors.primary),
                suffixIcon: IconButton(
                  icon: Icon(o3.value ? Icons.visibility_off_outlined : Icons.visibility_outlined, color: AppColors.textMuted),
                  onPressed: () => o3.toggle(),
                ),
              ),
            )),
            const SizedBox(height: 24),
            Obx(() => SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: controller.isChangingPass.value ? null : controller.changePassword,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  elevation: 0,
                ),
                child: controller.isChangingPass.value
                    ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5))
                    : Text('Ubah Password', style: GoogleFonts.poppins(fontWeight: FontWeight.w600, color: Colors.white)),
              ),
            )),
            const SizedBox(height: 12),
          ],
        ),
      ),
      isScrollControlled: true,
    );
  }
}

class _MenuCard extends StatelessWidget {
  final List<Widget> children;
  const _MenuCard({required this.children});

  @override
  Widget build(BuildContext context) => Container(
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      boxShadow: [BoxShadow(blurRadius: 10, color: Colors.black.withValues(alpha: 0.05))],
    ),
    child: Column(children: children),
  );
}

class _MenuItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final Color? iconColor;
  final Color? titleColor;
  final VoidCallback? onTap;
  final Widget? trailing;

  const _MenuItem({
    required this.icon,
    required this.title,
    this.subtitle,
    this.iconColor,
    this.titleColor,
    this.onTap,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) => ListTile(
    leading: Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: (iconColor ?? AppColors.primary).withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Icon(icon, color: iconColor ?? AppColors.primary, size: 20),
    ),
    title: Text(
      title,
      style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 14, color: titleColor ?? AppColors.textPrimary),
    ),
    subtitle: subtitle != null
        ? Text(subtitle!, style: GoogleFonts.poppins(fontSize: 12, color: AppColors.textMuted))
        : null,
    trailing: trailing ?? const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: AppColors.textMuted),
    onTap: onTap,
    contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
  );
}
