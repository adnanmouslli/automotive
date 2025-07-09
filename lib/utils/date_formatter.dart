import 'package:intl/intl.dart';

class DateFormatter {
  static String formatDate(DateTime date, {String locale = 'ar'}) {
    final formatter = DateFormat('dd/MM/yyyy', locale);
    return formatter.format(date);
  }

  static String formatDateTime(DateTime date, {String locale = 'ar'}) {
    final formatter = DateFormat('dd/MM/yyyy HH:mm', locale);
    return formatter.format(date);
  }

  static String formatTime(DateTime date, {String locale = 'ar'}) {
    final formatter = DateFormat('HH:mm', locale);
    return formatter.format(date);
  }

  static String formatDateTimeForEmail(DateTime date) {
    final formatter = DateFormat('EEEE، dd MMMM yyyy في HH:mm', 'ar');
    return formatter.format(date);
  }

  static String getRelativeTime(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 7) {
      return formatDate(date);
    } else if (difference.inDays > 0) {
      return 'منذ ${difference.inDays} ${difference.inDays == 1 ? 'يوم' : 'أيام'}';
    } else if (difference.inHours > 0) {
      return 'منذ ${difference.inHours} ${difference.inHours == 1 ? 'ساعة' : 'ساعات'}';
    } else if (difference.inMinutes > 0) {
      return 'منذ ${difference.inMinutes} ${difference.inMinutes == 1 ? 'دقيقة' : 'دقائق'}';
    } else {
      return 'الآن';
    }
  }
}
