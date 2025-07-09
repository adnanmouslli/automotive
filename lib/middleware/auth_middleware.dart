import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/auth_controller.dart';
import '../routes/app_pages.dart';

class AuthMiddleware extends GetMiddleware {
  @override
  int? get priority => 1;

  @override
  RouteSettings? redirect(String? route) {
    final authController = Get.find<AuthController>();

    if (!authController.isAuthenticated.value && route != Routes.LOGIN) {
      return const RouteSettings(name: Routes.LOGIN);
    }

    if (authController.isAuthenticated.value && route == Routes.LOGIN) {
      return const RouteSettings(name: Routes.DASHBOARD);
    }

    return null;
  }
}