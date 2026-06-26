import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../theme/app_colors.dart';
import '../controllers/register_controller.dart';

class RegisterView extends GetView<RegisterController> {
  const RegisterView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Back button
              Row(
                children: [
                  GestureDetector(
                    onTap: () => Get.back(),
                    child: Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [BoxShadow(blurRadius: 6, color: Colors.black.withValues(alpha: 0.07))],
                      ),
                      child: const Icon(Icons.arrow_back_ios_new_rounded, size: 16, color: AppColors.textPrimary),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              Text(
                'Create Account',
                style: GoogleFonts.poppins(
                  fontSize: 26,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Sign up to start using TailorLink',
                style: GoogleFonts.poppins(fontSize: 13, color: AppColors.textMuted),
              ),
              const SizedBox(height: 28),

              // Form card
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(blurRadius: 24, color: Colors.black.withValues(alpha: 0.07), offset: const Offset(0, 8)),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildLabel('Full Name'),
                    const SizedBox(height: 6),
                    _buildField(
                      hint: 'Enter your full name',
                      icon: Icons.person_outline_rounded,
                      onChanged: (v) => controller.name.value = v,
                    ),
                    const SizedBox(height: 14),

                    _buildLabel('Email'),
                    const SizedBox(height: 6),
                    _buildField(
                      hint: 'Enter your email',
                      icon: Icons.email_outlined,
                      onChanged: (v) => controller.email.value = v,
                      keyboardType: TextInputType.emailAddress,
                    ),
                    const SizedBox(height: 14),

                    _buildLabel('Username'),
                    const SizedBox(height: 6),
                    _buildField(
                      hint: 'Choose a username',
                      icon: Icons.alternate_email_rounded,
                      onChanged: (v) => controller.username.value = v,
                    ),
                    const SizedBox(height: 14),

                    _buildLabel('Password'),
                    const SizedBox(height: 6),
                    Obx(() => _buildField(
                      hint: 'Create a password',
                      icon: Icons.lock_outline_rounded,
                      onChanged: (v) => controller.password.value = v,
                      obscureText: controller.obscurePass.value,
                      suffixIcon: IconButton(
                        icon: Icon(
                          controller.obscurePass.value ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                          color: AppColors.textMuted,
                          size: 20,
                        ),
                        onPressed: () => controller.obscurePass.toggle(),
                      ),
                    )),
                    const SizedBox(height: 14),

                    _buildLabel('Confirm Password'),
                    const SizedBox(height: 6),
                    Obx(() => _buildField(
                      hint: 'Repeat your password',
                      icon: Icons.lock_outline_rounded,
                      onChanged: (v) => controller.confirmPassword.value = v,
                      obscureText: controller.obscureConfirm.value,
                      suffixIcon: IconButton(
                        icon: Icon(
                          controller.obscureConfirm.value ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                          color: AppColors.textMuted,
                          size: 20,
                        ),
                        onPressed: () => controller.obscureConfirm.toggle(),
                      ),
                    )),
                    const SizedBox(height: 28),

                    Obx(() => SizedBox(
                      height: 52,
                      child: ElevatedButton(
                        onPressed: controller.isLoading.value ? null : controller.register,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        ),
                        child: controller.isLoading.value
                            ? const SizedBox(
                                height: 22,
                                width: 22,
                                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
                              )
                            : Text(
                                'Create Account',
                                style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white),
                              ),
                      ),
                    )),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Already have an account? ',
                    style: GoogleFonts.poppins(fontSize: 13, color: AppColors.textMuted),
                  ),
                  GestureDetector(
                    onTap: () => Get.back(),
                    child: Text(
                      'Sign In',
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
    );
  }

  Widget _buildField({
    required String hint,
    required IconData icon,
    required void Function(String) onChanged,
    TextInputType? keyboardType,
    bool obscureText = false,
    Widget? suffixIcon,
  }) {
    return TextField(
      onChanged: onChanged,
      obscureText: obscureText,
      keyboardType: keyboardType,
      style: GoogleFonts.poppins(fontSize: 14, color: AppColors.textPrimary),
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: Icon(icon, color: AppColors.primary, size: 20),
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: AppColors.surface,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
      ),
    );
  }
}
