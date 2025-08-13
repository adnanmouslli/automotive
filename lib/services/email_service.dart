import 'dart:io';
import 'dart:typed_data';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';
import '../models/order.dart';

class EmailServiceEmailService {
  // Email configuration - في التطبيق الحقيقي، هذه البيانات تأتي من متغيرات البيئة
  static const String _smtpHost = 'smtp.gmail.com';
  static const int _smtpPort = 587;
  static const String _username = 'adnan@gmail.com';
  static const String _password = 'adnan@123456789';
  static const String _fromEmail = 'test@gmail.com';
  static const String _fromName = 'شركة التأمين الألمانية';

  static Future<bool> sendOrderPDF({
    required Order order,
    required String recipientEmail,
    required Uint8List pdfBytes,
  }) async {
    try {
      final smtpServer = gmail(_username, _password);

      final message = Message()
        ..from = Address(_fromEmail, _fromName)
        ..recipients.add(recipientEmail)
        ..subject = 'تقرير تسليم واستلام المركبة - رقم الطلب ${order.orderNumber}'
        ..html = _buildEmailBody(order)
        ..attachments = [
          FileAttachment(
            pdfBytes as File,
            fileName: 'order_${order.orderNumber}_report.pdf',
            contentType: 'application/pdf',
          )
        ];

      final sendReport = await send(message, smtpServer);
      print('تم إرسال الإيميل: ${sendReport.toString()}');
      return true;
    } catch (e) {
      print('خطأ في إرسال الإيميل: $e');
      return false;
    }
  }

  static String _buildEmailBody(Order order) {
    return '''
    <!DOCTYPE html>
    <html dir="rtl" lang="ar">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>تقرير تسليم واستلام المركبة</title>
        <style>
            body {
                font-family: Arial, sans-serif;
                line-height: 1.6;
                color: #333;
                direction: rtl;
                text-align: right;
            }
            .container {
                max-width: 600px;
                margin: 0 auto;
                padding: 20px;
            }
            .header {
                background-color: #2196F3;
                color: white;
                padding: 20px;
                text-align: center;
                border-radius: 8px 8px 0 0;
            }
            .content {
                background-color: #f9f9f9;
                padding: 20px;
                border: 1px solid #ddd;
            }
            .info-box {
                background-color: white;
                padding: 15px;
                margin: 10px 0;
                border-radius: 5px;
                border-right: 4px solid #2196F3;
            }
            .footer {
                background-color: #333;
                color: white;
                padding: 15px;
                text-align: center;
                border-radius: 0 0 8px 8px;
                font-size: 12px;
            }
            .highlight {
                color: #2196F3;
                font-weight: bold;
            }
        </style>
    </head>
    <body>
        <div class="container">
            <div class="header">
                <h1>شركة التأمين الألمانية</h1>
                <p>تقرير تسليم واستلام المركبة</p>
            </div>
            
            <div class="content">
                <p>عزيزي/عزيزتي <span class="highlight">${order.client}</span>،</p>
                
                <p>نتشرف بإرسال تقرير تسليم واستلام المركبة المرفق بهذا الإيميل.</p>
                
                <div class="info-box">
                    <h3>تفاصيل الطلب:</h3>
                    <p><strong>رقم الطلب:</strong> ${order.orderNumber}</p>
                    <p><strong>رقم اللوحة:</strong> ${order.vehicleData.licensePlate}</p>
                    <p><strong>نوع المركبة:</strong> ${order.service.vehicleType}</p>
                    <p><strong>حالة الطلب:</strong> ${_getStatusText(order.status)}</p>
                </div>
                
                <div class="info-box">
                    <h3>معلومات الاتصال:</h3>
                    <p><strong>الهاتف:</strong> ${order.pickup.phone}</p>
                    <p><strong>البريد الإلكتروني:</strong> ${order.pickup.email}</p>
                </div>
                
                <p>يرجى مراجعة التقرير المرفق والتأكد من صحة جميع البيانات. في حال وجود أي استفسارات أو ملاحظات، يرجى التواصل معنا.</p>
                
                <p>شكراً لثقتكم بخدماتنا.</p>
            </div>
            
            <div class="footer">
                <p>شركة التأمين الألمانية</p>
                <p>نظام إدارة تسليم واستلام المركبات</p>
                <p>تم إنشاء هذا الإيميل تلقائياً - يرجى عدم الرد على هذا الإيميل</p>
            </div>
        </div>
    </body>
    </html>
    ''';
  }

  static String _getStatusText(String status) {
    switch (status) {
      case 'pending':
        return 'قيد الانتظار';
      case 'in_progress':
        return 'قيد التنفيذ';
      case 'completed':
        return 'مكتملة';
      default:
        return status;
    }
  }

  // دالة لاختبار إعدادات الإيميل
  static Future<bool> testEmailConfiguration() async {
    try {
      final smtpServer = gmail(_username, _password);

      final message = Message()
        ..from = Address(_fromEmail, _fromName)
        ..recipients.add(_fromEmail) // إرسال لنفس الإيميل للاختبار
        ..subject = 'اختبار إعدادات الإيميل'
        ..text = 'هذا إيميل اختبار للتأكد من صحة إعدادات الإيميل.';

      await send(message, smtpServer);
      return true;
    } catch (e) {
      print('خطأ في اختبار الإيميل: $e');
      return false;
    }
  }
}