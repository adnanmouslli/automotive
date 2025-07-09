import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../models/order.dart';

class PDFService {
  static Future<Uint8List> generateOrderPDF(Order order) async {
    final pdf = pw.Document();

    // Load font for Arabic text support
    final font = await PdfGoogleFonts.aBeeZeeItalic();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        textDirection: pw.TextDirection.rtl,
        theme: pw.ThemeData.withFont(
          base: font,
        ),
        build: (pw.Context context) {
          return [
            _buildHeader(),
            pw.SizedBox(height: 20),
            _buildOrderInfo(order),
            pw.SizedBox(height: 20),
            _buildClientInfo(order),
            pw.SizedBox(height: 20),
            _buildVehicleInfo(order),
            pw.SizedBox(height: 20),
            _buildServiceInfo(order),
            pw.SizedBox(height: 20),
            _buildSignatures(order),
            pw.SizedBox(height: 20),
            _buildFooter(),
          ];
        },
      ),
    );

    return pdf.save();
  }

  static pw.Widget _buildHeader() {
    return pw.Container(
      padding: const pw.EdgeInsets.all(20),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.blue, width: 2),
        borderRadius: pw.BorderRadius.circular(10),
      ),
      child: pw.Column(
        children: [
          pw.Text(
            'تقرير تسليم واستلام المركبة',
            style: pw.TextStyle(
              fontSize: 24,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.blue,
            ),
            textDirection: pw.TextDirection.rtl,
          ),
          pw.SizedBox(height: 10),
          pw.Text(
            'شركة التأمين الألمانية',
            style: pw.TextStyle(
              fontSize: 16,
              color: PdfColors.grey700,
            ),
            textDirection: pw.TextDirection.rtl,
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildOrderInfo(Order order) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(15),
      decoration: pw.BoxDecoration(
        color: PdfColors.grey100,
        borderRadius: pw.BorderRadius.circular(8),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'معلومات الطلب',
            style: pw.TextStyle(
              fontSize: 18,
              fontWeight: pw.FontWeight.bold,
            ),
            textDirection: pw.TextDirection.rtl,
          ),
          pw.SizedBox(height: 10),
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text('رقم الطلب: ${order.orderNumber}', textDirection: pw.TextDirection.rtl),
              pw.Text('التاريخ: ${_formatDate(order.createdAt)}', textDirection: pw.TextDirection.rtl),
            ],
          ),
          pw.SizedBox(height: 5),
          pw.Text('الحالة: ${_getStatusText(order.status)}', textDirection: pw.TextDirection.rtl),
        ],
      ),
    );
  }

  static pw.Widget _buildClientInfo(Order order) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(15),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey300),
        borderRadius: pw.BorderRadius.circular(8),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'بيانات العميل',
            style: pw.TextStyle(
              fontSize: 16,
              fontWeight: pw.FontWeight.bold,
            ),
            textDirection: pw.TextDirection.rtl,
          ),
          pw.SizedBox(height: 10),
          pw.Text('الاسم: ${order.client}', textDirection: pw.TextDirection.rtl),
          pw.Text('العنوان: ${order.clientAddress.toString()}', textDirection: pw.TextDirection.rtl),
          pw.Text('البريد الإلكتروني: ${order.pickup.email}', textDirection: pw.TextDirection.rtl),
          if (order.pickup.phone.isNotEmpty)
            pw.Text('الهاتف: ${order.pickup.phone}', textDirection: pw.TextDirection.rtl),
        ],
      ),
    );
  }

  static pw.Widget _buildVehicleInfo(Order order) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(15),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey300),
        borderRadius: pw.BorderRadius.circular(8),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'بيانات المركبة',
            style: pw.TextStyle(
              fontSize: 16,
              fontWeight: pw.FontWeight.bold,
            ),
            textDirection: pw.TextDirection.rtl,
          ),
          pw.SizedBox(height: 10),
          pw.Text('مالك المركبة: ${order.vehicleData.vehicleOwner}', textDirection: pw.TextDirection.rtl),
          pw.Text('رقم اللوحة: ${order.vehicleData.licensePlate}', textDirection: pw.TextDirection.rtl),
          if (order.vehicleData.vin.isNotEmpty)
            pw.Text('رقم الهيكل: ${order.vehicleData.vin}', textDirection: pw.TextDirection.rtl),
          if (order.vehicleData.ukz.isNotEmpty)
            pw.Text('UKZ: ${order.vehicleData.ukz}', textDirection: pw.TextDirection.rtl),
        ],
      ),
    );
  }

  static pw.Widget _buildServiceInfo(Order order) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(15),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey300),
        borderRadius: pw.BorderRadius.circular(8),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'بيانات الخدمة',
            style: pw.TextStyle(
              fontSize: 16,
              fontWeight: pw.FontWeight.bold,
            ),
            textDirection: pw.TextDirection.rtl,
          ),
          pw.SizedBox(height: 10),
          pw.Text('نوع المركبة: ${order.service.vehicleType}', textDirection: pw.TextDirection.rtl),
          pw.Text('نوع الخدمة: ${_getServiceTypeText(order.service.serviceType)}', textDirection: pw.TextDirection.rtl),
          if (order.comments.isNotEmpty)
            pw.Text('ملاحظات: ${order.comments}', textDirection: pw.TextDirection.rtl),
        ],
      ),
    );
  }

  static pw.Widget _buildSignatures(Order order) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Expanded(
          child: pw.Container(
            padding: const pw.EdgeInsets.all(15),
            decoration: pw.BoxDecoration(
              border: pw.Border.all(color: PdfColors.grey300),
              borderRadius: pw.BorderRadius.circular(8),
            ),
            child: pw.Column(
              children: [
                pw.Text(
                  'توقيع السائق',
                  style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                  textDirection: pw.TextDirection.rtl,
                ),
                pw.SizedBox(height: 40),
                if (order.driverSignature != null) ...[
                  pw.Text('الاسم: ${order.driverSignature!.name}', textDirection: pw.TextDirection.rtl),
                  pw.Text('التاريخ: ${_formatDate(order.driverSignature!.time)}', textDirection: pw.TextDirection.rtl),
                ],
              ],
            ),
          ),
        ),
        pw.SizedBox(width: 20),
        pw.Expanded(
          child: pw.Container(
            padding: const pw.EdgeInsets.all(15),
            decoration: pw.BoxDecoration(
              border: pw.Border.all(color: PdfColors.grey300),
              borderRadius: pw.BorderRadius.circular(8),
            ),
            child: pw.Column(
              children: [
                pw.Text(
                  'توقيع العميل',
                  style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                  textDirection: pw.TextDirection.rtl,
                ),
                pw.SizedBox(height: 40),
                if (order.customerSignature != null) ...[
                  pw.Text('الاسم: ${order.customerSignature!.name}', textDirection: pw.TextDirection.rtl),
                  pw.Text('التاريخ: ${_formatDate(order.customerSignature!.time)}', textDirection: pw.TextDirection.rtl),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }

  static pw.Widget _buildFooter() {
    return pw.Container(
      padding: const pw.EdgeInsets.all(15),
      decoration: pw.BoxDecoration(
        color: PdfColors.grey50,
        borderRadius: pw.BorderRadius.circular(8),
      ),
      child: pw.Column(
        children: [
          pw.Text(
            'شركة التأمين الألمانية',
            style: pw.TextStyle(
              fontSize: 14,
              fontWeight: pw.FontWeight.bold,
            ),
            textDirection: pw.TextDirection.rtl,
          ),
          pw.SizedBox(height: 5),
          pw.Text(
            'نظام إدارة تسليم واستلام المركبات',
            style: pw.TextStyle(fontSize: 12),
            textDirection: pw.TextDirection.rtl,
          ),
          pw.Text(
            'تم إنشاء هذا التقرير تلقائياً في ${_formatDate(DateTime.now())}',
            style: pw.TextStyle(fontSize: 10, color: PdfColors.grey600),
            textDirection: pw.TextDirection.rtl,
          ),
        ],
      ),
    );
  }

  static String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
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

  static String _getServiceTypeText(serviceType) {
    switch (serviceType.toString()) {
      case 'ServiceType.vehicleWash':
        return 'غسيل مركبة';
      case 'ServiceType.registration':
        return 'تسجيل';
      case 'ServiceType.other':
        return 'أخرى';
      default:
        return serviceType.toString();
    }
  }
}