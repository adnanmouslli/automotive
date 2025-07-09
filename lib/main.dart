import 'package:automotive/routes/app_pages.dart';
import 'package:automotive/translations/app_translations.dart';
import 'package:automotive/translations/languages.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

// Controllers
import 'bindings/initial_binding.dart';
import 'controllers/auth_controller.dart';

// Views
import 'views/login_view.dart';
import 'views/dashboard_view.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize GetStorage
  await GetStorage.init();

  runApp(CarHandoverApp());
}

class CarHandoverApp extends StatelessWidget {

  final locale = GetStorage(); // لتخزين لغة التطبيق المفضلة

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(

        title: 'app_title'.tr, // استخدام الترجمة
      debugShowCheckedModeBanner: false,
        translations: AppTranslations(), // إضافة الترجمات
        locale: _getLocale(), // اللغة الحالية
        fallbackLocale: Locale(Languages.german), // اللغة الافتراضية

        // Theme
      theme: ThemeData(
        primarySwatch: Colors.blue,
        fontFamily: 'Arial',
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.blue.shade600,
          foregroundColor: Colors.white,
          elevation: 0,
          centerTitle: true,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
      ),

      // Initialize Controllers immediately
      initialBinding: InitialBindings(),

      // Routes
      initialRoute: Routes.LOGIN,
      getPages: AppPages.routes
    );
  }

  Locale _getLocale() {
    String? langCode = locale.read('language');
    if (langCode != null) {
      return Locale(langCode);
    } else {
      return Get.deviceLocale ?? Locale(Languages.german);
    }
  }


}


class AuthWrapper extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GetBuilder<AuthController>(
      builder: (authController) {
        return Obx(() {
          if (authController.isAuthenticated.value) {
            return DashboardView();
          } else {
            return LoginView();
          }
        });
      },
    );
  }
}