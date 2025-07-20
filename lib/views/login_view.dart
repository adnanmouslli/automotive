import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/auth_controller.dart';
import '../utils/AppColors.dart';

class LoginView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final AuthController authController = Get.find<AuthController>();
    final formKey = GlobalKey<FormState>();
    final emailController = TextEditingController(text: 'admin@gmail.com');
    final passwordController = TextEditingController(text: '123');

    final obscurePassword = true.obs;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.primaryBlue,
              AppColors.primaryBlue.withOpacity(0.8),
              AppColors.lightGray,
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
              child: Container(
                constraints: const BoxConstraints(maxWidth: 420),
                child: Card(
                  elevation: 8,
                  shadowColor: AppColors.mediumShadow,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(28),
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(28),
                      color: AppColors.pureWhite,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(40.0),
                      child: Form(
                        key: formKey,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Enhanced Logo/Header with Animation
                            TweenAnimationBuilder(
                              duration: const Duration(milliseconds: 800),
                              tween: Tween<double>(begin: 0, end: 1),
                              builder: (context, double value, child) {
                                return Transform.scale(
                                  scale: value,
                                  child: Container(
                                    width: 120,
                                    height: 120,
                                    decoration: BoxDecoration(
                                      color: AppColors.pureWhite,
                                      borderRadius: BorderRadius.circular(60),
                                      boxShadow: [
                                        BoxShadow(
                                          color: AppColors.mediumShadow,
                                          blurRadius: 25,
                                          offset: const Offset(0, 10),
                                        ),
                                      ],
                                    ),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(60),
                                      child: Image.asset(
                                        'assets/logo.jpg', // ضع مسار اللوغو هنا
                                        width: 120,
                                        height: 120,
                                        fit: BoxFit.cover,
                                        errorBuilder: (context, error, stackTrace) {
                                          return Container(
                                            width: 120,
                                            height: 120,
                                            decoration: BoxDecoration(
                                              gradient: LinearGradient(
                                                begin: Alignment.topLeft,
                                                end: Alignment.bottomRight,
                                                colors: [
                                                  AppColors.primaryBlue,
                                                  AppColors.primaryBlue.withOpacity(0.8),
                                                ],
                                              ),
                                              borderRadius: BorderRadius.circular(60),
                                            ),
                                            child: Icon(
                                              Icons.business,
                                              size: 60,
                                              color: AppColors.whiteText,
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                            const SizedBox(height: 32),

                            // Enhanced Title
                            Text(
                              'app_title'.tr,
                              style: AppColors.headingStyle.copyWith(
                                color: AppColors.darkGray,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                              decoration: BoxDecoration(
                                color: AppColors.lightBlueBg,
                                borderRadius: BorderRadius.circular(25),
                                border: Border.all(color: AppColors.borderGray, width: 1.5),
                              ),
                              child: Text(
                                'login'.tr + ' - ${'drivers'.tr}',
                                style: TextStyle(
                                  color: AppColors.primaryBlue,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                            const SizedBox(height: 40),

                            // Enhanced Email Field
                            Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(18),
                                boxShadow: [AppColors.cardDecoration.boxShadow!.first],
                              ),
                              child: TextFormField(
                                controller: emailController,
                                keyboardType: TextInputType.emailAddress,
                                textDirection: TextDirection.ltr,
                                style: TextStyle(fontSize: 16, color: AppColors.darkGray),
                                decoration: InputDecoration(
                                  labelText: 'email'.tr,
                                  hintText: 'email_hint'.tr,
                                  prefixIcon: Container(
                                    margin: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: AppColors.lightBlueBg,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Icon(
                                      Icons.email_outlined,
                                      color: AppColors.primaryBlue,
                                      size: 22,
                                    ),
                                  ),
                                  filled: true,
                                  fillColor: AppColors.lightGray,
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(18),
                                    borderSide: BorderSide.none,
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(18),
                                    borderSide: BorderSide(color: AppColors.borderGray, width: 1),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(18),
                                    borderSide: BorderSide(color: AppColors.primaryBlue, width: 2),
                                  ),
                                  errorBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(18),
                                    borderSide: BorderSide(color: AppColors.errorRed, width: 2),
                                  ),
                                  labelStyle: TextStyle(color: AppColors.mediumGray),
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'email_required'.tr;
                                  }
                                  if (!GetUtils.isEmail(value)) {
                                    return 'email_invalid'.tr;
                                  }
                                  return null;
                                },
                              ),
                            ),
                            const SizedBox(height: 24),

                            // Enhanced Password Field
                            Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(18),
                                boxShadow: [AppColors.cardDecoration.boxShadow!.first],
                              ),
                              child: Obx(() => TextFormField(
                                controller: passwordController,
                                obscureText: obscurePassword.value,
                                style: TextStyle(fontSize: 16, color: AppColors.darkGray),
                                decoration: InputDecoration(
                                  labelText: 'password'.tr,
                                  prefixIcon: Container(
                                    margin: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: AppColors.lightBlueBg,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Icon(
                                      Icons.lock_outlined,
                                      color: AppColors.primaryBlue,
                                      size: 22,
                                    ),
                                  ),
                                  suffixIcon: IconButton(
                                    icon: Icon(
                                      obscurePassword.value
                                          ? Icons.visibility_outlined
                                          : Icons.visibility_off_outlined,
                                      color: AppColors.mediumGray,
                                    ),
                                    onPressed: () {
                                      obscurePassword.toggle();
                                    },
                                  ),
                                  filled: true,
                                  fillColor: AppColors.lightGray,
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(18),
                                    borderSide: BorderSide.none,
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(18),
                                    borderSide: BorderSide(color: AppColors.borderGray, width: 1),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(18),
                                    borderSide: BorderSide(color: AppColors.primaryBlue, width: 2),
                                  ),
                                  errorBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(18),
                                    borderSide: BorderSide(color: AppColors.errorRed, width: 2),
                                  ),
                                  labelStyle: TextStyle(color: AppColors.mediumGray),
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'password_required'.tr;
                                  }
                                  return null;
                                },
                              )),
                            ),
                            const SizedBox(height: 36),

                            // Enhanced Login Button
                            Obx(() => AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              width: double.infinity,
                              height: 60,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(18),
                                gradient: authController.isLoading.value
                                    ? LinearGradient(
                                  colors: [AppColors.borderGray, AppColors.mediumGray],
                                )
                                    : LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    AppColors.primaryBlue,
                                    AppColors.primaryBlue.withOpacity(0.8),
                                  ],
                                ),
                                boxShadow: authController.isLoading.value
                                    ? []
                                    : [
                                  BoxShadow(
                                    color: AppColors.primaryBlue.withOpacity(0.4),
                                    blurRadius: 20,
                                    offset: const Offset(0, 8),
                                  ),
                                ],
                              ),
                              child: Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(18),
                                  onTap: authController.isLoading.value ? null : () async {
                                    if (formKey.currentState!.validate()) {
                                      final success = await authController.login(
                                        emailController.text.trim(),
                                        passwordController.text,
                                      );
                                      if (success) {
                                        Get.offAllNamed('/dashboard');
                                      }
                                    }
                                  },
                                  child: Container(
                                    alignment: Alignment.center,
                                    child: authController.isLoading.value
                                        ? Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        const SizedBox(
                                          width: 24,
                                          height: 24,
                                          child: CircularProgressIndicator(
                                            color: AppColors.whiteText,
                                            strokeWidth: 3,
                                          ),
                                        ),
                                        const SizedBox(width: 16),
                                        Text(
                                          'loading'.tr,
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                            color: AppColors.whiteText,
                                          ),
                                        ),
                                      ],
                                    )
                                        : Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.all(8),
                                          decoration: BoxDecoration(
                                            color: AppColors.whiteText.withOpacity(0.2),
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          child: Icon(
                                            Icons.login_rounded,
                                            color: AppColors.whiteText,
                                            size: 20,
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Text(
                                          'login'.tr,
                                          style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                            color: AppColors.whiteText,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            )),
                            const SizedBox(height: 28),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}