import 'package:get/get_utils/src/get_utils/get_utils.dart';


class AppValidators {
  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'يرجى إدخال البريد الإلكتروني';
    }
    if (!GetUtils.isEmail(value)) {
      return 'يرجى إدخال بريد إلكتروني صحيح';
    }
    return null;
  }

  static String? validateRequired(String? value, String fieldName) {
    if (value == null || value.isEmpty) {
      return 'يرجى إدخال $fieldName';
    }
    return null;
  }

  static String? validatePhone(String? value) {
    if (value != null && value.isNotEmpty) {
      if (!GetUtils.isPhoneNumber(value)) {
        return 'يرجى إدخال رقم هاتف صحيح';
      }
    }
    return null;
  }

  static String? validateNumber(String? value, String fieldName) {
    if (value != null && value.isNotEmpty) {
      if (!GetUtils.isNum(value)) {
        return 'يرجى إدخال رقم صحيح في $fieldName';
      }
    }
    return null;
  }

  static String? validateLicensePlate(String? value) {
    if (value == null || value.isEmpty) {
      return 'يرجى إدخال رقم اللوحة';
    }
    // Add specific license plate validation if needed
    return null;
  }

  // static String? validateVIN(String? value) {
  //   if (value != null && value.isNotEmpty) {
  //     if (value.length != 17) {
  //       return 'رقم الهيكل يجب أن يكون 17 حرف';
  //     }
  //     if (!RegExp(r'^[A-HJ-NPR-Z0-9]{17}Put<AuthController>('))
  //       () => AuthController(),
  //     );
  //   }
  // }
}