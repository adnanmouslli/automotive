import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../services/auth_service.dart';
import '../models/user.dart';

class AuthController extends GetxController {
  final AuthService _authService = AuthService();

  // Observables
  RxBool isLoading = false.obs;
  RxBool isAuthenticated = false.obs;
  Rx<User?> currentUser = Rx<User?>(null);

  @override
  void onInit() {
    super.onInit();
    _checkAuthStatus();
  }

  // Check if user is already logged in
  void _checkAuthStatus() async {
    try {
      final user = _authService.getCurrentUser();
      if (user != null) {
        // التحقق من صلاحية التوكن
        final isValidToken = await _authService.verifyToken();
        if (isValidToken && user.role == UserRole.driver) {
          currentUser.value = user;
          isAuthenticated.value = true;
        } else {
          // إذا كان التوكن غير صالح أو المستخدم ليس سائق، امسح البيانات
          await _authService.clearUserData();
        }
      }
    } catch (e) {
      print('Error checking auth status: $e');
      await _authService.clearUserData();
    }
  }

  // Login method
  Future<bool> login(String email, String password) async {
    try {
      isLoading.value = true;

      final user = await _authService.login(email, password);

      print("==========");
      print(user);

      if (user != null) {
        // التحقق الإضافي من أن المستخدم سائق
        if (user.role != UserRole.driver) {
          Get.snackbar(
            'auth_error'.tr,
            'access_denied'.tr,
            snackPosition: SnackPosition.TOP,
            backgroundColor: Colors.red,
            colorText: Colors.white,
          );
          return false;
        }

        currentUser.value = user;
        isAuthenticated.value = true;

        // Save user data locally
        await _authService.saveUser(user);

        Get.snackbar(
          'login_success'.tr,
          'welcome_user'.tr.replaceAll('name', user.name),
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );

        return true;
      } else {
        Get.snackbar(
          'auth_error'.tr,
          'invalid_credentials'.tr,
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return false;
      }
    } catch (e) {
      String errorMessage = 'login_error'.tr;

      if (e.toString().contains('غير مسموح')) {
        errorMessage = 'access_denied'.tr;
      } else if (e.toString().contains('البريد الإلكتروني أو كلمة المرور')) {
        errorMessage = 'invalid_credentials'.tr;
      } else if (e.toString().contains('فشل في الاتصال')) {
        errorMessage = 'connection_failed'.tr;
      }

      Get.snackbar(
        'auth_error'.tr,
        errorMessage,
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  // Logout method
  Future<void> logout() async {
    try {
      await _authService.logout();
      currentUser.value = null;
      isAuthenticated.value = false;

      Get.offAllNamed('/login');
      Get.snackbar(
        'logout_success'.tr,
        'logout_completed'.tr,
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.blue,
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        'auth_error'.tr,
        'logout_error'.tr,
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  // User role checks
  bool get isDriver => currentUser.value?.role == UserRole.driver;

  // Getters for user data
  String get currentUserId => currentUser.value?.id ?? '';
  String get currentUserName => currentUser.value?.name ?? '';
  String get currentUserEmail => currentUser.value?.email ?? '';
  String get currentUserRole => currentUser.value?.role.toString().split('.').last ?? '';

  // Get auth token
  String? get authToken => _authService.getAuthToken();
}