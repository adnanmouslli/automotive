import 'package:automotive/services/auth_service.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'dart:convert';
import 'dart:typed_data';
import '../config/app_config.dart';
import '../models/new_order.dart';

class OrderDetailsService {
  final AuthService _authService = AuthService();

  // Get authorization headers
  Map<String, String> get _headers {
    final token = _authService.getAuthToken();
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  Map<String, String> get _multipartHeaders {
    final token = _authService.getAuthToken();
    return {
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  // Get order details
  Future<NewOrder?> getOrderDetails(String orderId) async {
    try {
      print('📥 جلب تفاصيل الطلبية: $orderId');

      final response = await http.get(
        Uri.parse('${AppConfig.baseUrl}/orders/$orderId'),
        headers: _headers,
      );

      print('📥 استجابة الخادم: ${response.statusCode}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        return NewOrder.fromJson(data);
      } else {
        throw Exception('فشل في جلب تفاصيل الطلبية: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ خطأ في جلب تفاصيل الطلبية: $e');
      throw Exception('خطأ في الاتصال بالخادم: $e');
    }
  }

  // Upload multiple images
  Future<List<String>> uploadMultipleImages({
    required String orderId,
    required List<XFile> images,
    required ImageCategory category,
    required String description,
  }) async {
    try {
      print('📤 رفع ${images.length} صورة للطلبية: $orderId');

      final request = http.MultipartRequest(
        'POST',
        Uri.parse('${AppConfig.baseUrl}/uploads/images/multiple'),
      );

      // Add headers
      request.headers.addAll(_multipartHeaders);

      // Add form fields
      request.fields['orderId'] = orderId;
      request.fields['category'] = category.name;
      if (description.isNotEmpty) {
        request.fields['description'] = description;
      }

      // Add files
      for (int i = 0; i < images.length; i++) {
        final image = images[i];
        final bytes = await image.readAsBytes();

        request.files.add(
          http.MultipartFile.fromBytes(
            'files', // Backend expects 'files' for multiple upload
            bytes,
            filename: 'image_$i.jpg',
          ),
        );

        print('📷 إضافة صورة ${i + 1}: ${image.name}');
      }

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      print('📤 استجابة رفع الصور: ${response.statusCode}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = json.decode(response.body);
        print(
            '✅ تم رفع الصور بنجاح: ${data['successCount']} من ${data['totalFiles']}');

        // Return list of uploaded image IDs
        final results = data['results'] as List?;
        return results?.map((r) => r['id'] as String).toList() ?? [];
      } else {
        final errorData = json.decode(response.body);
        throw Exception(errorData['message'] ?? 'فشل في رفع الصور');
      }
    } catch (e) {
      print('❌ خطأ في رفع الصور: $e');
      throw Exception('فشل في رفع الصور: $e');
    }
  }

  // تحديث المصاريف
  Future<OrderExpenses?> updateExpenses({
    required String orderId,
    required Map<String, dynamic> expensesData,
  }) async {
    try {
      print('🔄 تحديث مصاريف الطلبية: $orderId');
      print('📊 البيانات المرسلة: $expensesData');

      // إضافة orderId إلى البيانات المرسلة
      final requestData = {
        'orderId': orderId, // إضافة orderId هنا أيضاً
        ...expensesData,
      };

      final response = await http.put(
        Uri.parse('${AppConfig.baseUrl}/orders/$orderId/expenses'),
        headers: _headers,
        body: json.encode(requestData),
      );

      print('📤 استجابة تحديث المصاريف: ${response.statusCode}');
      print('📄 محتوى الاستجابة: ${response.body}');

      if (response.statusCode == 200) {
        if (response.body.isNotEmpty) {
          final data = json.decode(response.body);
          print('✅ تم تحديث المصاريف بنجاح');
          return OrderExpenses.fromJson(data);
        }
      }

      final errorData = response.body.isNotEmpty
          ? json.decode(response.body)
          : {'message': 'خطأ غير معروف'};
      throw Exception(errorData['message'] ?? 'فشل في تحديث المصاريف');
    } catch (e) {
      print('❌ خطأ في تحديث المصاريف: $e');
      throw Exception('فشل في تحديث المصاريف: $e');
    }
  }
  // Upload single image (fallback method)
  Future<String?> uploadSingleImage({
    required String orderId,
    required XFile image,
    required ImageCategory category,
    required String description,
  }) async {
    try {
      print('📤 رفع صورة واحدة للطلبية: $orderId');

      final request = http.MultipartRequest(
        'POST',
        Uri.parse('${AppConfig.baseUrl}/uploads/image'),
      );

      // Add headers
      request.headers.addAll(_multipartHeaders);

      // Add form fields
      request.fields['orderId'] = orderId;
      request.fields['category'] = category.name;
      if (description.isNotEmpty) {
        request.fields['description'] = description;
      }

      // Add file
      final bytes = await image.readAsBytes();
      request.files.add(
        http.MultipartFile.fromBytes(
          'file', // Backend expects 'file' for single upload
          bytes,
          filename: 'image.jpg',
        ),
      );

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      print('📤 استجابة رفع الصورة: ${response.statusCode}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = json.decode(response.body);
        print('✅ تم رفع الصورة بنجاح: ${data['id']}');
        return data['id'] as String?;
      } else {
        final errorData = json.decode(response.body);
        throw Exception(errorData['message'] ?? 'فشل في رفع الصورة');
      }
    } catch (e) {
      print('❌ خطأ في رفع الصورة: $e');
      throw Exception('فشل في رفع الصورة: $e');
    }
  }

  // Upload signature
  Future<OrderSignature?> uploadSignature({
    required String orderId,
    required Uint8List signatureBytes,
    required String signerName,
    required bool isDriver,
  }) async {
    try {
      print('📤 رفع توقيع للطلبية: $orderId');

      final request = http.MultipartRequest(
        'POST',
        Uri.parse('${AppConfig.baseUrl}/uploads/signature'),
      );

      // Add headers
      request.headers.addAll(_multipartHeaders);

      // Add form fields
      request.fields['orderId'] = orderId;
      request.fields['signerName'] = signerName;
      request.fields['isDriver'] = isDriver.toString();

      // Add signature file
      request.files.add(
        http.MultipartFile.fromBytes(
          'file',
          signatureBytes,
          filename: 'signature.png',
        ),
      );

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      print('📤 استجابة رفع التوقيع: ${response.statusCode}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = json.decode(response.body);
        print('✅ تم رفع التوقيع بنجاح: ${data['id']}');
        return OrderSignature.fromJson(data);
      } else {
        final errorData = json.decode(response.body);
        throw Exception(errorData['message'] ?? 'فشل في رفع التوقيع');
      }
    } catch (e) {
      print('❌ خطأ في رفع التوقيع: $e');
      throw Exception('فشل في رفع التوقيع: $e');
    }
  }

  // Upload expenses
  Future<OrderExpenses?> uploadExpenses({
    required String orderId,
    required Map<String, dynamic> expensesData,
  }) async {
    try {
      print('📤 رفع مصاريف للطلبية: $orderId');
      print('📊 البيانات المرسلة: $expensesData');

      // إضافة orderId إلى البيانات المرسلة
      final requestData = {
        'orderId': orderId, // هذا هو الإصلاح المطلوب
        ...expensesData,
      };

      print('📊 البيانات النهائية المرسلة: $requestData');

      final response = await http.post(
        Uri.parse('${AppConfig.baseUrl}/uploads/expenses'),
        headers: _headers,
        body: json.encode(requestData), // إرسال البيانات مع orderId
      );

      print('📤 استجابة رفع المصاريف: ${response.statusCode}');
      print('📄 محتوى الاستجابة: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        if (response.body.isNotEmpty) {
          final data = json.decode(response.body);
          print('✅ تم رفع المصاريف بنجاح');
          return OrderExpenses.fromJson(data);
        }
      }

      final errorData = response.body.isNotEmpty
          ? json.decode(response.body)
          : {'message': 'خطأ غير معروف'};
      throw Exception(errorData['message'] ?? 'فشل في رفع المصاريف');
    } catch (e) {
      print('❌ خطأ في رفع المصروفات: $e');
      throw Exception('فشل في رفع المصاريف: $e');
    }
  }

  // Complete order
  Future<bool> completeOrder(String orderId) async {
    try {
      print('📤 إتمام الطلبية: $orderId');

      final response = await http.patch(
        Uri.parse('${AppConfig.baseUrl}/orders/$orderId'),
        headers: _headers,
        body: json.encode({
          'status': 'completed',
        }),
      );

      print('📤 استجابة إتمام الطلبية: ${response.statusCode}');

      if (response.statusCode == 200) {
        print('✅ تم إتمام الطلبية بنجاح');
        return true;
      } else {
        final errorData = json.decode(response.body);
        throw Exception(errorData['message'] ?? 'فشل في إتمام الطلبية');
      }
    } catch (e) {
      print('❌ خطأ في إتمام الطلبية: $e');
      throw Exception('فشل في إتمام الطلبية: $e');
    }
  }

  // Update order details
  Future<bool> updateOrderDetails(
      String orderId, Map<String, dynamic> updates) async {
    try {
      print('📤 تحديث تفاصيل الطلبية: $orderId');
      print('📊 البيانات المرسلة: $updates');

      // استخدام PATCH بدلاً من PUT
      final response = await http.patch(
        Uri.parse('${AppConfig.baseUrl}/orders/$orderId'),
        headers: _headers,
        body: json.encode(updates),
      );

      print('📤 استجابة تحديث الطلبية: ${response.statusCode}');
      print('📄 محتوى الاستجابة: ${response.body}');

      if (response.statusCode == 200) {
        print('✅ تم تحديث الطلبية بنجاح');
        return true;
      } else {
        String errorMessage = 'فشل في تحديث الطلبية';
        try {
          if (response.body.isNotEmpty) {
            final errorData = json.decode(response.body);
            errorMessage =
                errorData['message'] ?? errorData['error'] ?? errorMessage;
          }
        } catch (e) {
          errorMessage =
              'خطأ في الخادم (${response.statusCode}): ${response.body}';
        }
        throw Exception(errorMessage);
      }
    } catch (e) {
      print('❌ خطأ في تحديث الطلبية: $e');
      throw Exception('فشل في تحديث الطلبية: $e');
    }
  }

  // Delete order
  Future<bool> deleteOrder(String orderId) async {
    try {
      print('📤 حذف الطلبية: $orderId');

      final response = await http.delete(
        Uri.parse('${AppConfig.baseUrl}/orders/$orderId'),
        headers: _headers,
      );

      print('📤 استجابة حذف الطلبية: ${response.statusCode}');

      if (response.statusCode == 200 || response.statusCode == 204) {
        print('✅ تم حذف الطلبية بنجاح');
        return true;
      } else {
        final errorData = json.decode(response.body);
        throw Exception(errorData['message'] ?? 'فشل في حذف الطلبية');
      }
    } catch (e) {
      print('❌ خطأ في حذف الطلبية: $e');
      throw Exception('فشل في حذف الطلبية: $e');
    }
  }

  // 1. حذف صورة
  Future<bool> deleteImage({
    required String orderId,
    required String imageId,
  }) async {
    try {
      print('🗑️ حذف صورة: $imageId من الطلبية: $orderId');

      final response = await http.delete(
        Uri.parse('${AppConfig.baseUrl}/orders/$orderId/images/$imageId'),
        headers: _headers,
      );

      print('📤 استجابة حذف الصورة: ${response.statusCode}');

      if (response.statusCode == 200 || response.statusCode == 204) {
        print('✅ تم حذف الصورة بنجاح');
        return true;
      } else {
        final errorData = response.body.isNotEmpty
            ? json.decode(response.body)
            : {'message': 'خطأ غير معروف'};
        throw Exception(errorData['message'] ?? 'فشل في حذف الصورة');
      }
    } catch (e) {
      print('❌ خطأ في حذف الصورة: $e');
      throw Exception('فشل في حذف الصورة: $e');
    }
  }

// 2. حذف توقيع
  Future<bool> deleteSignature({
    required String orderId,
    required String signatureId,
  }) async {
    try {
      print('🗑️ حذف توقيع: $signatureId من الطلبية: $orderId');

      final response = await http.delete(
        Uri.parse(
            '${AppConfig.baseUrl}/orders/$orderId/signatures/$signatureId'),
        headers: _headers,
      );

      print('📤 استجابة حذف التوقيع: ${response.statusCode}');

      if (response.statusCode == 200 || response.statusCode == 204) {
        print('✅ تم حذف التوقيع بنجاح');
        return true;
      } else {
        final errorData = response.body.isNotEmpty
            ? json.decode(response.body)
            : {'message': 'خطأ غير معروف'};
        throw Exception(errorData['message'] ?? 'فشل في حذف التوقيع');
      }
    } catch (e) {
      print('❌ خطأ في حذف التوقيع: $e');
      throw Exception('فشل في حذف التوقيع: $e');
    }
  }

// 3. تحديث حالة الطلبية
  Future<bool> updateOrderStatus({
    required String orderId,
    required String status,
  }) async {
    try {
      print('📋 تحديث حالة الطلبية: $orderId إلى: $status');

      // استخدام PATCH بدلاً من PUT مع المسار الصحيح
      final response = await http.patch(
        Uri.parse(
            '${AppConfig.baseUrl}/orders/$orderId/status'), // المسار الصحيح
        headers: _headers,
        body: json.encode({'status': status}),
      );

      print('📤 استجابة تحديث الحالة: ${response.statusCode}');
      print('📄 محتوى الاستجابة: ${response.body}');

      if (response.statusCode == 200) {
        print('✅ تم تحديث حالة الطلبية بنجاح');
        return true;
      } else {
        String errorMessage = 'فشل في تحديث حالة الطلبية';
        try {
          if (response.body.isNotEmpty) {
            final errorData = json.decode(response.body);
            errorMessage =
                errorData['message'] ?? errorData['error'] ?? errorMessage;
          }
        } catch (e) {
          errorMessage =
              'خطأ في الخادم (${response.statusCode}): ${response.body}';
        }
        throw Exception(errorMessage);
      }
    } catch (e) {
      print('❌ خطأ في تحديث حالة الطلبية: $e');
      throw Exception('فشل في تحديث حالة الطلبية: $e');
    }
  }
}
