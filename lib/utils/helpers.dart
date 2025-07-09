import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class AppHelpers {
  // Date formatting
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

  // Status helpers
  static Color getStatusColor(String status) {
    switch (status) {
      case 'pending':
        return Colors.orange;
      case 'in_progress':
        return Colors.blue;
      case 'completed':
        return Colors.green;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  static String getStatusText(String status) {
    switch (status) {
      case 'pending':
        return 'قيد الانتظار';
      case 'in_progress':
        return 'قيد التنفيذ';
      case 'completed':
        return 'مكتملة';
      case 'cancelled':
        return 'ملغية';
      default:
        return status;
    }
  }

  static IconData getStatusIcon(String status) {
    switch (status) {
      case 'pending':
        return Icons.schedule;
      case 'in_progress':
        return Icons.directions_car;
      case 'completed':
        return Icons.check_circle;
      case 'cancelled':
        return Icons.cancel;
      default:
        return Icons.help;
    }
  }

  // Confirmation dialogs
  static Future<bool> showConfirmationDialog({
    required String title,
    required String message,
    String confirmText = 'تأكيد',
    String cancelText = 'إلغاء',
    Color? confirmColor,
  }) async {
    final result = await Get.dialog<bool>(
      AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: Text(cancelText),
          ),
          ElevatedButton(
            onPressed: () => Get.back(result: true),
            style: ElevatedButton.styleFrom(
              backgroundColor: confirmColor ?? Colors.blue,
            ),
            child: Text(confirmText),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  // Generate order number
  static String generateOrderNumber() {
    final now = DateTime.now();
    return '${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}${now.hour.toString().padLeft(2, '0')}${now.minute.toString().padLeft(2, '0')}';
  }

  // Check network connectivity
  static Future<bool> isConnected() async {
    try {
      // Simple connectivity check
      // In real app, use connectivity_plus package
      return true;
    } catch (e) {
      return false;
    }
  }

  // Launch URL
  static Future<void> launchURL(String url) async {
    try {
      // In real app, use url_launcher package
      // await launch(url);
    } catch (e) {
      Get.snackbar('خطأ', 'لا يمكن فتح الرابط');
    }
  }

  // Share content
  static Future<void> shareContent(String content) async {
    try {
      // In real app, use share_plus package
      // await Share.share(content);
    } catch (e) {
      Get.snackbar('خطأ', 'لا يمكن مشاركة المحتوى');
    }
  }

  // Format currency
  static String formatCurrency(double amount, {String currency = 'ريال'}) {
    final formatter = NumberFormat('#,##0.00');
    return '${formatter.format(amount)} $currency';
  }

  // Capitalize first letter
  static String capitalize(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1).toLowerCase();
  }

  // Truncate text
  static String truncateText(String text, int maxLength) {
    if (text.length <= maxLength) return text;
    return '${text.substring(0, maxLength)}...';
  }
}