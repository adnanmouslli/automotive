import 'package:flutter/material.dart';

/// ثوابت الألوان الرسمية لتطبيق شركة السيارات
class AppColors {
  // منع إنشاء كائن من هذا الكلاس
  AppColors._();

  // =============== الألوان الأساسية ===============

  /// الأزرق الصناعي - اللون الرئيسي للتطبيق
  static const Color primaryBlue = Color(0xFF003B73);

  /// الأبيض النقي - للخلفيات والبطاقات
  static const Color pureWhite = Color(0xFFFFFFFF);

  /// الرمادي الفاتح - للخلفية الرئيسية
  static const Color lightGray = Color(0xFFF5F7FA);

  /// الرمادي الداكن - للنصوص الأساسية
  static const Color darkGray = Color(0xFF2D3748);

  /// الرمادي المتوسط - للنصوص الثانوية
  static const Color mediumGray = Color(0xFF4A5568);

  /// الرمادي الفاتح جداً - للحدود والفواصل
  static const Color borderGray = Color(0xFFE2E8F0);

  // =============== ألوان الحالات ===============

  /// الأخضر - للحالات المكتملة والنجاح
  static const Color successGreen = Color(0xFF38A169);

  /// البرتقالي - للحالات المعلقة والانتظار
  static const Color pendingOrange = Color(0xFFED8936);

  /// الأزرق المتوسط - للحالات قيد المعالجة
  static const Color progressBlue = Color(0xFF3182CE);

  /// الأحمر - للأخطاء والحذف
  static const Color errorRed = Color(0xFFC53030);

  /// الأصفر - للتنبيهات
  static const Color warningYellow = Color(0xFFECC94B);

  // =============== ألوان الخلفيات الثانوية ===============

  /// خلفية خضراء فاتحة
  static const Color lightGreenBg = Color(0xFFF0FFF4);

  /// خلفية برتقالية فاتحة
  static const Color lightOrangeBg = Color(0xFFFEF5E7);

  /// خلفية زرقاء فاتحة
  static const Color lightBlueBg = Color(0xFFEBF8FF);

  /// خلفية حمراء فاتحة
  static const Color lightRedBg = Color(0xFFFED7D7);

  /// خلفية صفراء فاتحة
  static const Color lightYellowBg = Color(0xFFFEFCBF);

  // =============== ألوان النصوص ===============

  /// نص أبيض للأزرار الداكنة
  static const Color whiteText = Color(0xFFFFFFFF);

  /// نص رمادي فاتح للعناصر غير النشطة
  static const Color lightGrayText = Color(0xFFA0AEC0);

  /// نص رمادي للمعلومات الثانوية
  static const Color secondaryText = Color(0xFF718096);

  // =============== ألوان الظلال ===============

  /// ظل خفيف للبطاقات
  static const Color lightShadow = Color(0x0A000000);

  /// ظل متوسط للعناصر المرفوعة
  static const Color mediumShadow = Color(0x1A000000);

  // =============== دوال مساعدة للحصول على الألوان حسب الحالة ===============

  /// الحصول على لون الحالة
  static Color getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
      case 'ausstehend':
        return pendingOrange;
      case 'in_progress':
      case 'in bearbeitung':
        return progressBlue;
      case 'completed':
      case 'abgeschlossen':
        return successGreen;
      case 'cancelled':
      case 'storniert':
        return errorRed;
      default:
        return mediumGray;
    }
  }

  /// الحصول على لون خلفية الحالة
  static Color getStatusBackgroundColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
      case 'ausstehend':
        return lightOrangeBg;
      case 'in_progress':
      case 'in bearbeitung':
        return lightBlueBg;
      case 'completed':
      case 'abgeschlossen':
        return lightGreenBg;
      case 'cancelled':
      case 'storniert':
        return lightRedBg;
      default:
        return lightGray;
    }
  }

  /// الحصول على لون الأيقونة حسب نوع الخدمة
  static Color getServiceIconColor(String serviceType) {
    switch (serviceType.toLowerCase()) {
      case 'transport':
        return progressBlue;
      case 'wash':
        return successGreen;
      case 'registration':
        return pendingOrange;
      case 'inspection':
        return primaryBlue;
      case 'maintenance':
        return errorRed;
      default:
        return mediumGray;
    }
  }

  // =============== ثيمات الألوان للمكونات ===============

  /// ثيم الأزرار الأساسية
  static ButtonStyle get primaryButtonStyle => ElevatedButton.styleFrom(
    backgroundColor: primaryBlue,
    foregroundColor: whiteText,
    elevation: 2,
    shadowColor: mediumShadow,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(8),
    ),
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
  );

  /// ثيم الأزرار الثانوية
  static ButtonStyle get secondaryButtonStyle => OutlinedButton.styleFrom(
    foregroundColor: primaryBlue,
    side: const BorderSide(color: borderGray),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(8),
    ),
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
  );

  /// ثيم أزرار النجاح
  static ButtonStyle get successButtonStyle => ElevatedButton.styleFrom(
    backgroundColor: successGreen,
    foregroundColor: whiteText,
    elevation: 2,
    shadowColor: mediumShadow,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(8),
    ),
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
  );

  /// ثيم أزرار الخطر
  static ButtonStyle get dangerButtonStyle => ElevatedButton.styleFrom(
    backgroundColor: errorRed,
    foregroundColor: whiteText,
    elevation: 2,
    shadowColor: mediumShadow,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(8),
    ),
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
  );

  // =============== ديكوريشن للبطاقات ===============

  /// ديكوريشن البطاقة الأساسية
  static BoxDecoration get cardDecoration => BoxDecoration(
    color: pureWhite,
    borderRadius: BorderRadius.circular(12),
    border: Border.all(color: borderGray),
    boxShadow: const [
      BoxShadow(
        color: lightShadow,
        blurRadius: 8,
        offset: Offset(0, 2),
      ),
    ],
  );

  /// ديكوريشن البطاقة المرفوعة
  static BoxDecoration get elevatedCardDecoration => BoxDecoration(
    color: pureWhite,
    borderRadius: BorderRadius.circular(12),
    border: Border.all(color: borderGray),
    boxShadow: const [
      BoxShadow(
        color: mediumShadow,
        blurRadius: 12,
        offset: Offset(0, 4),
      ),
    ],
  );

  // =============== أنماط النصوص ===============

  /// نمط العنوان الرئيسي
  static const TextStyle headingStyle = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: darkGray,
    height: 1.2,
  );

  /// نمط العنوان الفرعي
  static const TextStyle subHeadingStyle = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: darkGray,
    height: 1.3,
  );

  /// نمط النص العادي
  static const TextStyle bodyStyle = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.normal,
    color: mediumGray,
    height: 1.4,
  );

  /// نمط النص الصغير
  static const TextStyle captionStyle = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.normal,
    color: secondaryText,
    height: 1.3,
  );

  /// نمط نص الأزرار
  static const TextStyle buttonTextStyle = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    height: 1.2,
  );
}