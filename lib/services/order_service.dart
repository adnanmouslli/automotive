import 'package:automotive/config/app_config.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import '../models/new_order.dart';
import '../services/auth_service.dart';
import 'package:http_parser/http_parser.dart';

class NewOrderService {
  static const String baseUrl = AppConfig.baseUrl;
  final AuthService _authService = AuthService();

  // Get headers with auth token
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
      'Accept': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  // Create new order with backend-compatible data
  Future<NewOrder?> createOrder(NewOrder order) async {
    try {
      print('📤 إرسال طلبية جديدة إلى الباك إند...');

      final orderJson = _prepareOrderDataForBackend(order);
      print('📄 بيانات الطلبية: ${json.encode(orderJson)}');

      final response = await http.post(
        Uri.parse('$baseUrl/orders'),
        headers: _headers,
        body: json.encode(orderJson),
      );

      print('📨 استجابة الباك إند: ${response.statusCode}');
      print('📄 محتوى الاستجابة: ${response.body}');

      if (response.statusCode == 201 || response.statusCode == 200) {
        final responseData = json.decode(response.body);

        if (responseData != null && responseData is Map<String, dynamic>) {
          return NewOrder.fromJson(responseData);
        } else {
          throw Exception('تنسيق استجابة غير صحيح من الخادم');
        }
      } else {
        String errorMessage = 'فشل في إنشاء الطلب';
        try {
          final errorData = json.decode(response.body);
          errorMessage = errorData['message'] ??
              errorData['error'] ??
              'خطأ غير معروف (${response.statusCode})';
        } catch (e) {
          errorMessage =
              'خطأ في الخادم (${response.statusCode}): ${response.body}';
        }
        throw Exception(errorMessage);
      }
    } on SocketException {
      throw Exception('فشل في الاتصال بالخادم. تحقق من الاتصال بالإنترنت');
    } on FormatException catch (e) {
      throw Exception('خطأ في تنسيق البيانات: ${e.message}');
    } catch (e) {
      print('❌ خطأ في إنشاء الطلبية: $e');
      throw Exception('فشل في إنشاء الطلب: ${e.toString()}');
    }
  }

  // تحضير بيانات الطلبية لتتوافق مع الباك إند
  Map<String, dynamic> _prepareOrderDataForBackend(NewOrder order) {
    return {
      // البيانات الأساسية
      'client': order.client,
      'clientPhone': order.clientPhone,
      'clientEmail': order.clientEmail,
      'description': order.description,
      'comments': order.comments,
      'vehicleOwner': order.vehicleOwner,
      'licensePlateNumber': order.licensePlateNumber,
      'vin': order.vin,
      'brand': order.brand,
      'model': order.model,
      'year': order.year,
      'color': order.color,
      'vehicleType': order.vehicleType,
      'serviceType': _convertServiceTypeForBackend(order.serviceType),
      'serviceDescription': order.serviceDescription,

      // ===== إضافة الحقول الجديدة =====

      // بيانات صاحب الفاتورة
      'isSameBilling': order.isSameBilling,
      'billingName': order.billingName,
      'billingPhone': order.billingPhone,
      'billingEmail': order.billingEmail,
      'billingAddress': order.billingAddress?.toJson(),
      'clientAddress': order.clientAddress?.toJson(),

      // الحقول الإضافية للسيارة
      'ukz': order.ukz,
      'fin': order.fin,
      'bestellnummer': order.bestellnummer,
      'leasingvertragsnummer': order.leasingvertragsnummer,
      'kostenstelle': order.kostenstelle,
      'bemerkung': order.bemerkung,
      'typ': order.typ,

      // الأغراض - تحويل صحيح
      'items': order.items.map((item) => item.toString().split('.').last).toList(),

      // العناوين مع الحقول الجديدة
      'pickupAddress': order.pickupAddress.toJson(),
      'deliveryAddress': order.deliveryAddress.toJson(),

      'damages': order.damages.map((damage) {
        return {
          'side': _convertVehicleSideForBackend(damage.side),
          'type': _convertDamageTypeForBackend(damage.type),
          'description': damage.description,
        };
      }).toList(),
    };
  }

  String _convertVehicleSideForBackend(VehicleSide side) {
    switch (side) {
      case VehicleSide.FRONT:
        return 'FRONT';
      case VehicleSide.REAR:
        return 'REAR';
      case VehicleSide.LEFT:
        return 'LEFT';
      case VehicleSide.RIGHT:
        return 'RIGHT';
      case VehicleSide.TOP:
        return 'TOP';
    }
  }

  String _convertDamageTypeForBackend(DamageType type) {
    switch (type) {
      case DamageType.DENT_BUMP:
        return 'DENT_BUMP';
      case DamageType.STONE_CHIP:
        return 'STONE_CHIP';
      case DamageType.SCRATCH_GRAZE:
        return 'SCRATCH_GRAZE';
      case DamageType.PAINT_DAMAGE:
        return 'PAINT_DAMAGE';
      case DamageType.CRACK_BREAK:
        return 'CRACK_BREAK';
      case DamageType.MISSING:
        return 'MISSING';
    }
  }

  String _convertServiceTypeForBackend(ServiceType serviceType) {
    switch (serviceType) {
      case ServiceType.TRANSPORT:
        return 'TRANSPORT';
      case ServiceType.WASH:
        return 'WASH';
      case ServiceType.REGISTRATION:
        return 'REGISTRATION';
      case ServiceType.INSPECTION:
        return 'INSPECTION';
      case ServiceType.MAINTENANCE:
        return 'MAINTENANCE';
    }
  }

  // Get all orders with improved error handling
  Future<List<NewOrder>> getOrders() async {
    try {
      print('📥 جلب الطلبيات من الباك إند...');

      final response = await http.get(
        Uri.parse('$baseUrl/orders'),
        headers: _headers,
      );

      print('📨 استجابة جلب الطلبيات: ${response.statusCode}');
      print('📄 محتوى الاستجابة: ${response.body}');

      if (response.statusCode == 200) {
        final responseBody = response.body;
        if (responseBody.isEmpty) {
          print('⚠️ استجابة فارغة من الخادم');
          return [];
        }

        final dynamic responseData = json.decode(responseBody);
        print('🔍 نوع البيانات المُستلمة: ${responseData.runtimeType}');

        List<dynamic> ordersData;

        // التعامل مع التنسيقات المختلفة للاستجابة
        if (responseData is List) {
          // إذا كانت الاستجابة مصفوفة مباشرة
          ordersData = responseData;
          print('📋 البيانات عبارة عن مصفوفة مباشرة');
        } else if (responseData is Map<String, dynamic>) {
          // إذا كانت الاستجابة object
          if (responseData.containsKey('data') && responseData['data'] is List) {
            // تنسيق: { "data": [...], "success": true }
            ordersData = responseData['data'];
            print('📋 البيانات موجودة في حقل data');
          } else if (responseData.containsKey('orders') && responseData['orders'] is List) {
            // تنسيق: { "orders": [...] }
            ordersData = responseData['orders'];
            print('📋 البيانات موجودة في حقل orders');
          } else if (responseData.containsKey('results') && responseData['results'] is List) {
            // تنسيق: { "results": [...] }
            ordersData = responseData['results'];
            print('📋 البيانات موجودة في حقل results');
          } else {
            // إذا كان object واحد، حوله إلى مصفوفة
            ordersData = [responseData];
            print('📋 البيانات عبارة عن object واحد');
          }
        } else {
          throw Exception('تنسيق غير متوقع للبيانات: ${responseData.runtimeType}');
        }

        print('🔢 عدد العناصر المُستلمة: ${ordersData.length}');

        final orders = <NewOrder>[];
        for (int i = 0; i < ordersData.length; i++) {
          try {
            final orderJson = ordersData[i];
            if (orderJson != null && orderJson is Map<String, dynamic>) {
              final order = NewOrder.fromJson(orderJson);
              orders.add(order);
              print('✅ تم تحليل الطلبية ${i + 1}: ${order.client}');
            } else {
              print('⚠️ تجاهل عنصر غير صحيح في الفهرس $i: $orderJson');
            }
          } catch (e) {
            print('❌ خطأ في تحليل الطلبية ${i + 1}: $e');
            print('📄 البيانات المشكوك فيها: ${ordersData[i]}');
            // نواصل مع باقي الطلبيات
          }
        }

        print('✅ تم جلب ${orders.length} طلبية صحيحة من أصل ${ordersData.length}');
        return orders;

      } else {
        String errorMessage = 'فشل في تحميل الطلبيات';
        try {
          final errorData = json.decode(response.body);
          errorMessage = errorData['message'] ?? errorMessage;
        } catch (e) {
          errorMessage = 'خطأ في الخادم (${response.statusCode})';
        }
        throw Exception(errorMessage);
      }
    } on SocketException {
      throw Exception('فشل في الاتصال بالخادم. تحقق من الاتصال بالإنترنت');
    } on FormatException catch (e) {
      print('❌ خطأ في تحليل JSON: $e');
      throw Exception('خطأ في تنسيق البيانات المستلمة');
    } catch (e) {
      print('❌ خطأ عام في جلب الطلبيات: $e');
      throw Exception('فشل في تحميل الطلبيات: ${e.toString()}');
    }
  }

  // Get order by ID with better null handling
  Future<NewOrder?> getOrderById(String orderId) async {
    try {
      if (orderId.isEmpty) {
        throw Exception('معرف الطلبية مطلوب');
      }

      print('🔍 جلب الطلبية: $orderId');

      final response = await http.get(
        Uri.parse('$baseUrl/orders/$orderId'),
        headers: _headers,
      );

      print('📨 استجابة جلب الطلبية: ${response.statusCode}');

      if (response.statusCode == 200) {
        final responseBody = response.body;
        if (responseBody.isEmpty) {
          return null;
        }

        final orderData = json.decode(responseBody);
        if (orderData != null && orderData is Map<String, dynamic>) {
          return NewOrder.fromJson(orderData);
        }
        return null;
      } else if (response.statusCode == 404) {
        return null;
      } else {
        throw Exception('فشل في جلب الطلبية (${response.statusCode})');
      }
    } on SocketException {
      throw Exception('فشل في الاتصال بالخادم');
    } catch (e) {
      print('❌ خطأ في جلب الطلبية: $e');
      throw Exception('فشل في تحميل الطلب: ${e.toString()}');
    }
  }

  // Update order with improved validation
  // Update order with comprehensive validation and error handling
  Future<NewOrder?> updateOrder(String orderId, NewOrder orderData) async {
    try {
      print('📤 تحديث الطلبية: $orderId');

      final response = await http.put(
        Uri.parse('${AppConfig.baseUrl}/orders/$orderId'),
        headers: _headers,
        body: json.encode(orderData),
      );

      print('📤 استجابة تحديث الطلبية: ${response.statusCode}');
      print('📄 محتوى الاستجابة: ${response.body}');

      if (response.statusCode == 200) {
        if (response.body.isNotEmpty) {
          final data = json.decode(response.body);
          print('✅ تم تحديث الطلبية بنجاح');
          return NewOrder.fromJson(data);
        } else {
          print('⚠️ استجابة فارغة من الخادم');
          return null;
        }
      } else {
        String errorMessage = 'فشل في تحديث الطلبية';
        try {
          if (response.body.isNotEmpty) {
            final errorData = json.decode(response.body);
            errorMessage = errorData['message'] ?? errorData['error'] ?? errorMessage;
          }
        } catch (e) {
          errorMessage = 'خطأ في الخادم (${response.statusCode}): ${response.body}';
        }
        throw Exception(errorMessage);
      }
    } catch (e) {
      print('❌ خطأ في تحديث الطلبية: $e');
      throw Exception('فشل في تحديث الطلبية: $e');
    }
  }


  Future<NewOrder?> updateOrderData(String orderId, Map<String, dynamic> orderData) async {
    try {
      print('📤 تحديث الطلبية باستخدام Map: $orderId');
      print('📊 الحقول المرسلة: ${orderData.keys.join(', ')}');

      // طباعة تفصيلية لبعض الحقول الجديدة للتأكد
      if (orderData.containsKey('ukz')) print('🔧 UKZ: ${orderData['ukz']}');
      if (orderData.containsKey('fin')) print('🔧 FIN: ${orderData['fin']}');
      if (orderData.containsKey('isSameBilling')) print('💳 isSameBilling: ${orderData['isSameBilling']}');
      if (orderData.containsKey('items')) print('📦 Items: ${orderData['items']}');

      // ===== إضافة طباعة تفصيلية للأضرار =====
      if (orderData.containsKey('damages')) {
        final damages = orderData['damages'] as List;
        print('⚠️ Damages Count: ${damages.length}');
        for (int i = 0; i < damages.length; i++) {
          print('⚠️ Damage ${i + 1}: ${damages[i]}');
        }
      } else {
        print('❌ لا توجد أضرار في البيانات المرسلة!');
      }

      // التحقق من سلامة بيانات الأضرار قبل الإرسال
      if (orderData.containsKey('damages') && orderData['damages'] is List) {
        final damages = orderData['damages'] as List;
        final validDamages = <Map<String, dynamic>>[];

        for (int i = 0; i < damages.length; i++) {
          final damage = damages[i];
          if (damage is Map<String, dynamic>) {
            // التأكد من وجود الحقول المطلوبة
            final validDamage = {
              'side': damage['side']?.toString()?.toUpperCase() ?? 'FRONT',
              'type': damage['type']?.toString()?.toUpperCase() ?? 'DENT_BUMP',
              'description': damage['description']?.toString()?.trim(),
            };

            // إزالة الوصف إذا كان فارغاً
            if (validDamage['description']?.isEmpty == true) {
              validDamage.remove('description');
            }

            validDamages.add(validDamage);
            print('✅ ضرر صحيح ${i + 1}: $validDamage');
          } else {
            print('⚠️ تجاهل ضرر غير صحيح ${i + 1}: $damage');
          }
        }

        // استبدال البيانات بالبيانات المنظفة
        orderData['damages'] = validDamages;
        print('🔧 تم تنظيف الأضرار: ${validDamages.length} ضرر صحيح');
      }

      final response = await http.put(
        Uri.parse('${AppConfig.baseUrl}/orders/$orderId'),
        headers: _headers,
        body: json.encode(orderData),
      );

      print('📤 استجابة تحديث الطلبية: ${response.statusCode}');
      print('📄 محتوى الاستجابة: ${response.body}');

      if (response.statusCode == 200) {
        if (response.body.isNotEmpty) {
          final data = json.decode(response.body);
          print('✅ تم تحديث الطلبية بنجاح');

          // التحقق من الأضرار في الاستجابة
          if (data is Map<String, dynamic> && data.containsKey('damages')) {
            print('✅ الأضرار موجودة في الاستجابة: ${data['damages']}');
          }

          return NewOrder.fromJson(data);
        } else {
          print('⚠️ استجابة فارغة من الخادم');
          return null;
        }
      } else {
        String errorMessage = 'فشل في تحديث الطلبية';
        try {
          if (response.body.isNotEmpty) {
            final errorData = json.decode(response.body);
            errorMessage = errorData['message'] ?? errorData['error'] ?? errorMessage;
          }
        } catch (e) {
          errorMessage = 'خطأ في الخادم (${response.statusCode}): ${response.body}';
        }
        throw Exception(errorMessage);
      }
    } catch (e) {
      print('❌ خطأ في تحديث الطلبية: $e');
      throw Exception('فشل في تحديث الطلبية: $e');
    }
  }

// تحضير البيانات بتنسيق متوافق مع الباك إند
  Map<String, dynamic> _prepareUpdateDataForBackend(NewOrder order) {
    final updateData = <String, dynamic>{};

    // البيانات الأساسية
    if (order.client.isNotEmpty) updateData['client'] = order.client.trim();
    if (order.clientPhone.isNotEmpty) updateData['clientPhone'] = order.clientPhone.trim();
    if (order.clientEmail.isNotEmpty) updateData['clientEmail'] = order.clientEmail.trim();
    if (order.description.isNotEmpty) updateData['description'] = order.description.trim();
    if (order.comments?.isNotEmpty == true) updateData['comments'] = order.comments!.trim();

    // ===== إضافة الحقول الجديدة =====

    // بيانات صاحب الفاتورة
    updateData['isSameBilling'] = order.isSameBilling;
    if (order.billingName != null) updateData['billingName'] = order.billingName;
    if (order.billingPhone != null) updateData['billingPhone'] = order.billingPhone;
    if (order.billingEmail != null) updateData['billingEmail'] = order.billingEmail;
    if (order.billingAddress != null) updateData['billingAddress'] = order.billingAddress!.toJson();
    if (order.clientAddress != null) updateData['clientAddress'] = order.clientAddress!.toJson();

    // الحقول الإضافية للسيارة
    if (order.ukz.isNotEmpty) updateData['ukz'] = order.ukz.trim();
    if (order.fin.isNotEmpty) updateData['fin'] = order.fin.trim();
    if (order.bestellnummer.isNotEmpty) updateData['bestellnummer'] = order.bestellnummer.trim();
    if (order.leasingvertragsnummer.isNotEmpty) updateData['leasingvertragsnummer'] = order.leasingvertragsnummer.trim();
    if (order.kostenstelle.isNotEmpty) updateData['kostenstelle'] = order.kostenstelle.trim();
    if (order.bemerkung.isNotEmpty) updateData['bemerkung'] = order.bemerkung.trim();
    if (order.typ.isNotEmpty) updateData['typ'] = order.typ.trim();

    // بيانات المركبة
    if (order.vehicleOwner.isNotEmpty) updateData['vehicleOwner'] = order.vehicleOwner.trim();
    if (order.licensePlateNumber.isNotEmpty) updateData['licensePlateNumber'] = order.licensePlateNumber.trim();
    if (order.vin.isNotEmpty) updateData['vin'] = order.vin.trim();
    if (order.brand.isNotEmpty) updateData['brand'] = order.brand.trim();
    if (order.model.isNotEmpty) updateData['model'] = order.model.trim();
    if (order.year > 0) updateData['year'] = order.year;
    if (order.color.isNotEmpty) updateData['color'] = order.color.trim();
    if (order.vehicleType.isNotEmpty) updateData['vehicleType'] = order.vehicleType.trim();

    // الأغراض
    if (order.items.isNotEmpty) {
      updateData['items'] = order.items.map((item) => item.toString().split('.').last).toList();
    }

    // بيانات الخدمة
    updateData['serviceType'] = _convertServiceTypeForBackend(order.serviceType);
    if (order.serviceDescription.isNotEmpty) {
      updateData['serviceDescription'] = order.serviceDescription.trim();
    }

    // العناوين مع الحقول الجديدة
    updateData['pickupAddress'] = order.pickupAddress.toJson();
    updateData['deliveryAddress'] = order.deliveryAddress.toJson();

    // إضافة الأضرار - هذا كان مفقود!
    updateData['damages'] = order.damages.map((damage) => {
      'side': _convertVehicleSideForBackend(damage.side),
      'type': _convertDamageTypeForBackend(damage.type),
      'description': damage.description,
    }).toList();

    return updateData;
  }


  // Upload single image (الطريقة الأصلية)
  Future<OrderImage?> uploadImage({
    required String orderId,
    required File imageFile,
    required ImageCategory category,
    required String description,
  }) async {
    try {
      if (orderId.isEmpty) {
        throw Exception('معرف الطلبية مطلوب');
      }

      if (!await imageFile.exists()) {
        throw Exception('الملف غير موجود');
      }

      print('📤 رفع صورة واحدة للطلبية: $orderId');
      print('📁 مسار الملف: ${imageFile.path}');
      print('📊 حجم الملف: ${await imageFile.length()} بايت');

      var request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/uploads/image'),
      );

      // Add headers
      final token = _authService.getAuthToken();
      if (token != null) {
        request.headers['Authorization'] = 'Bearer $token';
      }
      request.headers['Accept'] = 'application/json';

      // Add fields
      request.fields['orderId'] = orderId;
      request.fields['category'] = _convertImageCategoryForBackend(category);
      request.fields['description'] = description;

      // Add file
      String? mimeType = _getMimeType(imageFile.path);
      if (mimeType != null) {
        request.files.add(await http.MultipartFile.fromPath(
          'file',
          imageFile.path,
          contentType: MediaType.parse(mimeType),
        ));
      } else {
        request.files.add(await http.MultipartFile.fromPath(
          'file',
          imageFile.path,
          contentType: MediaType('application', 'octet-stream'),
        ));
      }

      final response = await request.send();
      final responseBody = await response.stream.bytesToString();

      print('📨 استجابة رفع الصورة: ${response.statusCode}');
      print('📄 محتوى استجابة الصورة: $responseBody');

      if (response.statusCode == 200 || response.statusCode == 201) {
        if (responseBody.isEmpty) {
          throw Exception('استجابة فارغة من الخادم');
        }

        final responseData = json.decode(responseBody);
        if (responseData != null && responseData is Map<String, dynamic>) {
          return OrderImage.fromJson(responseData);
        }
        throw Exception('تنسيق استجابة غير صحيح');
      } else {
        String errorMessage = 'فشل في رفع الصورة';
        try {
          if (responseBody.isNotEmpty) {
            final errorData = json.decode(responseBody);
            errorMessage =
                errorData['message'] ?? errorData['error'] ?? 'خطأ غير معروف';
          }
        } catch (e) {
          errorMessage =
              'خطأ في الخادم (${response.statusCode}): $responseBody';
        }
        throw Exception(errorMessage);
      }
    } on SocketException {
      throw Exception('فشل في الاتصال بالخادم');
    } catch (e) {
      print('❌ خطأ في رفع الصورة: $e');
      throw Exception('فشل في رفع الصورة: ${e.toString()}');
    }
  }

  // جديد: رفع صور متعددة
  Future<MultipleImageUploadResult> uploadMultipleImages({
    required String orderId,
    required List<File> imageFiles,
    required ImageCategory category,
    required String description,
  }) async {
    try {
      if (orderId.isEmpty) {
        throw Exception('معرف الطلبية مطلوب');
      }

      if (imageFiles.isEmpty) {
        throw Exception('لا توجد ملفات للرفع');
      }

      print('📤 بدء رفع ${imageFiles.length} صورة للطلبية: $orderId');

      // التحقق من وجود جميع الملفات
      for (int i = 0; i < imageFiles.length; i++) {
        if (!await imageFiles[i].exists()) {
          throw Exception('الملف ${i + 1} غير موجود: ${imageFiles[i].path}');
        }
      }

      var request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/uploads/images/multiple'),
      );

      // Add headers
      final token = _authService.getAuthToken();
      if (token != null) {
        request.headers['Authorization'] = 'Bearer $token';
      }
      request.headers['Accept'] = 'application/json';

      // Add fields
      request.fields['orderId'] = orderId;
      request.fields['category'] = _convertImageCategoryForBackend(category);
      request.fields['description'] = description;

      // Add files
      for (int i = 0; i < imageFiles.length; i++) {
        final file = imageFiles[i];
        String? mimeType = _getMimeType(file.path);

        if (mimeType != null) {
          request.files.add(await http.MultipartFile.fromPath(
            'files', // الباك إند يتوقع 'files' للصور المتعددة
            file.path,
            contentType: MediaType.parse(mimeType),
          ));
        } else {
          request.files.add(await http.MultipartFile.fromPath(
            'files',
            file.path,
            contentType: MediaType('application', 'octet-stream'),
          ));
        }

        print(
            '📁 تم إضافة الملف ${i + 1}: ${file.path} (${await file.length()} بايت)');
      }

      print('📦 إرسال ${request.files.length} ملف إلى الخادم...');

      final response = await request.send();
      final responseBody = await response.stream.bytesToString();

      print('📨 استجابة رفع الصور المتعددة: ${response.statusCode}');
      print('📄 محتوى الاستجابة: $responseBody');

      if (response.statusCode == 200 || response.statusCode == 201) {
        if (responseBody.isEmpty) {
          throw Exception('استجابة فارغة من الخادم');
        }

        final responseData = json.decode(responseBody);
        if (responseData != null && responseData is Map<String, dynamic>) {
          return MultipleImageUploadResult.fromJson(responseData);
        }
        throw Exception('تنسيق استجابة غير صحيح');
      } else {
        String errorMessage = 'فشل في رفع الصور';
        try {
          if (responseBody.isNotEmpty) {
            final errorData = json.decode(responseBody);
            errorMessage =
                errorData['message'] ?? errorData['error'] ?? 'خطأ غير معروف';
          }
        } catch (e) {
          errorMessage =
              'خطأ في الخادم (${response.statusCode}): $responseBody';
        }
        throw Exception(errorMessage);
      }
    } on SocketException {
      throw Exception('فشل في الاتصال بالخادم');
    } catch (e) {
      print('❌ خطأ في رفع الصور المتعددة: $e');
      throw Exception('فشل في رفع الصور: ${e.toString()}');
    }
  }

  // تحويل ImageCategory ليتوافق مع الباك إند
  String _convertImageCategoryForBackend(ImageCategory category) {
    switch (category) {
      case ImageCategory.PICKUP:
        return 'PICKUP';
      case ImageCategory.DELIVERY:
        return 'DELIVERY';
      case ImageCategory.ADDITIONAL:
        return 'ADDITIONAL';
      case ImageCategory.DAMAGE:
        return 'DAMAGE';
      case ImageCategory.INTERIOR:
        return 'INTERIOR';
      case ImageCategory.EXTERIOR:
        return 'EXTERIOR';
    }
  }

  // Upload signature with proper PNG format
  Future<OrderSignature?> uploadSignature({
    required String orderId,
    required Uint8List signatureBytes,
    required String signerName,
    required bool isDriver,
  }) async {
    try {
      if (orderId.isEmpty) {
        throw Exception('معرف الطلبية مطلوب');
      }

      if (signerName.isEmpty) {
        throw Exception('اسم الموقع مطلوب');
      }

      if (signatureBytes.isEmpty) {
        throw Exception('بيانات التوقيع مطلوبة');
      }

      print('📤 رفع توقيع للطلبية: $orderId');
      print('📝 اسم الموقع: $signerName');
      print('🎯 نوع التوقيع: ${isDriver ? 'سائق' : 'عميل'}');

      var request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/uploads/signature'),
      );

      // Add headers
      request.headers.addAll(_multipartHeaders);

      // Add fields
      request.fields['orderId'] = orderId;
      request.fields['signerName'] = signerName;
      request.fields['isDriver'] = isDriver.toString();

      // Add signature file
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      request.files.add(http.MultipartFile.fromBytes(
        'file',
        signatureBytes,
        filename: 'signature_$timestamp.png',
        contentType: MediaType('image', 'png'),
      ));

      final response = await request.send();
      final responseBody = await response.stream.bytesToString();

      print('📨 استجابة رفع التوقيع: ${response.statusCode}');
      print('📄 محتوى استجابة التوقيع: $responseBody');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = json.decode(responseBody);
        if (responseData != null && responseData is Map<String, dynamic>) {
          return OrderSignature.fromJson(responseData);
        }
        throw Exception('تنسيق استجابة غير صحيح');
      } else {
        String errorMessage = 'فشل في رفع التوقيع';
        try {
          final errorData = json.decode(responseBody);
          errorMessage = errorData['message'] ?? errorMessage;
        } catch (e) {
          errorMessage =
              'خطأ في الخادم (${response.statusCode}): $responseBody';
        }
        throw Exception(errorMessage);
      }
    } on SocketException {
      throw Exception('فشل في الاتصال بالخادم');
    } catch (e) {
      print('❌ خطأ في رفع التوقيع: $e');
      throw Exception('فشل في رفع التوقيع: ${e.toString()}');
    }
  }

  // Upload expenses with validation
  Future<OrderExpenses?> uploadExpenses({
    required String orderId,
    required double fuel,
    required double tollFees,
    required double parking,
    required String notes,
    double? wash,
    double? adBlue,
    double? other,
  }) async {
    try {
      if (orderId.isEmpty) {
        throw Exception('معرف الطلبية مطلوب');
      }

      if (fuel < 0 || tollFees < 0 || parking < 0) {
        throw Exception('قيم المصاريف يجب أن تكون موجبة');
      }

      print('📤 رفع مصاريف للطلبية: $orderId');

      final expensesData = {
        'orderId': orderId,
        'fuel': fuel,
        'tollFees': tollFees,
        'parking': parking,
        'notes': notes,
        if (wash != null && wash > 0) 'wash': wash,
        if (adBlue != null && adBlue > 0) 'adBlue': adBlue,
        if (other != null && other > 0) 'other': other,
      };

      print('📄 بيانات المصاريف: ${json.encode(expensesData)}');

      final response = await http.post(
        Uri.parse('$baseUrl/uploads/expenses'),
        headers: _headers,
        body: json.encode(expensesData),
      );

      print('📨 استجابة رفع المصاريف: ${response.statusCode}');
      print('📄 محتوى استجابة المصاريف: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = json.decode(response.body);
        if (responseData != null && responseData is Map<String, dynamic>) {
          return OrderExpenses.fromJson(responseData);
        }
        throw Exception('تنسيق استجابة غير صحيح');
      } else {
        String errorMessage = 'فشل في إضافة المصاريف';
        try {
          final errorData = json.decode(response.body);
          errorMessage = errorData['message'] ?? errorMessage;
        } catch (e) {
          errorMessage =
              'خطأ في الخادم (${response.statusCode}): ${response.body}';
        }
        throw Exception(errorMessage);
      }
    } on SocketException {
      throw Exception('فشل في الاتصال بالخادم');
    } catch (e) {
      print('❌ خطأ في رفع المصاريف: $e');
      throw Exception('فشل في إضافة المصاريف: ${e.toString()}');
    }
  }

  // Delete order with validation
  Future<bool> deleteOrder(String orderId) async {
    try {
      print('🗑️ حذف الطلبية: $orderId');

      final response = await http.delete(
        Uri.parse('${AppConfig.baseUrl}/orders/$orderId'),
        headers: _headers,
      );

      print('📤 استجابة حذف الطلبية: ${response.statusCode}');
      print('📄 محتوى الاستجابة: ${response.body}');

      if (response.statusCode == 200) {
        // معالجة الاستجابة الناجحة
        if (response.body.isNotEmpty) {
          final data = json.decode(response.body);
          print('✅ تم حذف الطلبية بنجاح: ${data['message']}');
        }
        return true;
      } else if (response.statusCode == 204) {
        // في حالة NO_CONTENT (لا يوجد محتوى)
        print('✅ تم حذف الطلبية بنجاح (204)');
        return true;
      } else if (response.statusCode == 404) {
        throw Exception('الطلبية غير موجودة');
      } else {
        final errorData = response.body.isNotEmpty
            ? json.decode(response.body)
            : {'message': 'خطأ غير معروف'};
        throw Exception(errorData['message'] ?? 'فشل في حذف الطلبية');
      }
    } catch (e) {
      print('❌ خطأ في حذف الطلبية: $e');
      throw Exception('فشل في حذف الطلبية: $e');
    }
  }

  // Get service type text in Arabic
  String getServiceTypeText(ServiceType serviceType) {
    switch (serviceType) {
      case ServiceType.TRANSPORT:
        return 'نقل';
      case ServiceType.WASH:
        return 'غسيل';
      case ServiceType.REGISTRATION:
        return 'تسجيل';
      case ServiceType.INSPECTION:
        return 'فحص';
      case ServiceType.MAINTENANCE:
        return 'صيانة';
    }
  }

  // Get image category text in Arabic
  String getImageCategoryText(ImageCategory category) {
    switch (category) {
      case ImageCategory.PICKUP:
        return 'صور الاستلام';
      case ImageCategory.DELIVERY:
        return 'صور التسليم';
      case ImageCategory.ADDITIONAL:
        return 'صور إضافية';
      case ImageCategory.DAMAGE:
        return 'صور الأضرار';
      case ImageCategory.INTERIOR:
        return 'صور داخلية';
      case ImageCategory.EXTERIOR:
        return 'صور خارجية';
    }
  }

  // دالة مساعدة لتحديد نوع المحتوى
  String? _getMimeType(String filePath) {
    final extension = filePath.toLowerCase().split('.').last;

    switch (extension) {
      case 'jpg':
      case 'jpeg':
        return 'image/jpeg';
      case 'png':
        return 'image/png';
      case 'gif':
        return 'image/gif';
      case 'webp':
        return 'image/webp';
      case 'bmp':
        return 'image/bmp';
      case 'tiff':
      case 'tif':
        return 'image/tiff';
      default:
        return null;
    }
  }

// استبدل دالة updateOrderStatus في NewOrderService بهذه النسخة المُبسطة

  Future<NewOrder?> updateOrderStatus({
    required String orderId,
    required String newStatus,
  }) async {
    try {
      if (orderId.isEmpty) {
        throw Exception('معرف الطلبية مطلوب');
      }

      if (newStatus.isEmpty) {
        throw Exception('الحالة الجديدة مطلوبة');
      }

      print('📋 تحديث حالة الطلبية: $orderId إلى $newStatus');

      final response = await http.patch(
        Uri.parse('$baseUrl/orders/$orderId/status'),
        headers: _headers,
        body: json.encode({'status': newStatus.toLowerCase()}),
      );

      print('📨 استجابة تحديث الحالة: ${response.statusCode}');
      print('📄 محتوى الاستجابة: ${response.body}');

      if (response.statusCode == 200) {
        if (response.body.isEmpty) {
          throw Exception('استجابة فارغة من الخادم');
        }

        final dynamic responseData = json.decode(response.body);
        print('🔍 نوع بيانات الاستجابة: ${responseData.runtimeType}');

        Map<String, dynamic>? orderData;

        // التعامل مع التنسيقات المختلفة
        if (responseData is Map<String, dynamic>) {
          if (responseData.containsKey('data') && responseData['data'] != null) {
            // تنسيق: { "success": true, "data": {...} }
            orderData = responseData['data'] as Map<String, dynamic>;
            print('📋 البيانات موجودة في حقل data');
          } else if (responseData.containsKey('order') && responseData['order'] != null) {
            // تنسيق: { "order": {...} }
            orderData = responseData['order'] as Map<String, dynamic>;
            print('📋 البيانات موجودة في حقل order');
          } else if (responseData.containsKey('success')) {
            // تنسيق الاستجابة يحتوي على success لكن بدون data
            // نحاول استخدام البيانات مباشرة
            if (responseData.containsKey('id') || responseData.containsKey('orderNumber')) {
              orderData = responseData;
              print('📋 البيانات موجودة في الجذر');
            }
          } else {
            // البيانات في الجذر مباشرة
            orderData = responseData;
            print('📋 البيانات في الجذر مباشرة');
          }
        } else {
          throw Exception('تنسيق استجابة غير متوقع: ${responseData.runtimeType}');
        }

        if (orderData != null) {
          try {
            final updatedOrder = NewOrder.fromJson(orderData);
            print('✅ تم تحديث حالة الطلبية بنجاح إلى: ${updatedOrder.status}');
            return updatedOrder;
          } catch (e) {
            print('❌ خطأ في تحليل بيانات الطلبية المُحدثة: $e');
            print('📄 البيانات: $orderData');
            throw Exception('خطأ في تحليل البيانات المُحدثة');
          }
        } else {
          throw Exception('لم يتم العثور على بيانات الطلبية في الاستجابة');
        }

      } else if (response.statusCode == 404) {
        throw Exception('الطلبية غير موجودة');
      } else if (response.statusCode == 403) {
        throw Exception('ليس لديك صلاحية لتحديث هذه الطلبية');
      } else if (response.statusCode == 400) {
        String errorMessage = 'حالة غير صحيحة';
        try {
          if (response.body.isNotEmpty) {
            final errorData = json.decode(response.body);
            errorMessage = errorData['message'] ?? errorMessage;
          }
        } catch (e) {
          // ignore parsing error
        }
        throw Exception(errorMessage);
      } else {
        String errorMessage = 'فشل في تحديث حالة الطلب';
        try {
          if (response.body.isNotEmpty) {
            final errorData = json.decode(response.body);
            errorMessage = errorData['message'] ?? errorMessage;
          }
        } catch (e) {
          errorMessage = 'خطأ في الخادم (${response.statusCode})';
        }
        throw Exception(errorMessage);
      }
    } on SocketException {
      throw Exception('فشل في الاتصال بالخادم. تحقق من الاتصال بالإنترنت');
    } on FormatException catch (e) {
      print('❌ خطأ في تحليل JSON: $e');
      throw Exception('خطأ في تنسيق البيانات المُستلمة');
    } catch (e) {
      print('❌ خطأ عام في تحديث حالة الطلبية: $e');
      throw Exception('فشل في تحديث حالة الطلب: ${e.toString()}');
    }
  }

  // التحقق من حالة الطلبية
  Future<String?> getOrderStatus(String orderId) async {
    try {
      if (orderId.isEmpty) {
        throw Exception('معرف الطلبية مطلوب');
      }

      print('🔍 جلب حالة الطلبية: $orderId');

      final response = await http.get(
        Uri.parse('$baseUrl/orders/$orderId/status'),
        headers: _headers,
      );

      print('📨 استجابة جلب الحالة: ${response.statusCode}');

      if (response.statusCode == 200) {
        if (response.body.isEmpty) {
          return null;
        }

        final responseData = json.decode(response.body);
        if (responseData['success'] == true && responseData['data'] != null) {
          return responseData['data']['status'];
        }
        return null;
      } else if (response.statusCode == 404) {
        return null;
      } else {
        throw Exception('فشل في جلب حالة الطلبية (${response.statusCode})');
      }
    } on SocketException {
      throw Exception('فشل في الاتصال بالخادم');
    } catch (e) {
      print('❌ خطأ في جلب حالة الطلبية: $e');
      throw Exception('فشل في جلب حالة الطلب: ${e.toString()}');
    }
  }

// التحقق من إمكانية تحديث الحالة
  bool canUpdateStatus(String currentStatus, String newStatus) {
    final statusFlow = {
      'pending': ['in_progress', 'cancelled'],
      'in_progress': ['completed', 'cancelled'],
      'completed': [], // لا يمكن تغيير الحالة من مكتمل
      'cancelled': [], // لا يمكن تغيير الحالة من ملغي
    };

    final allowedStatuses = statusFlow[currentStatus.toLowerCase()] ?? [];
    return allowedStatuses.contains(newStatus.toLowerCase());
  }

// دالة مساعدة لترجمة الحالات
  String getStatusDisplayText(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return 'قيد الانتظار';
      case 'in_progress':
        return 'قيد التنفيذ';
      case 'completed':
        return 'مكتمل';
      case 'cancelled':
        return 'ملغي';
      default:
        return status;
    }
  }

  // في ملف new_order_service.dart

  Future<Uint8List> generateOrderPdf(String orderId) async {
    try {
      // محاولة الحصول على تقرير HTML أولاً
      final htmlContent = await generateOrderHtmlReport(orderId);

      // تحويل HTML إلى bytes (مؤقت)
      return Uint8List.fromList(utf8.encode(htmlContent));
    } catch (e) {
      print('❌ تحذير: generateOrderPdf مُستبعدة، استخدم generateOrderHtmlReport');
      throw Exception('هذه الدالة مُستبعدة، استخدم generateOrderHtmlReport بدلاً من ذلك');
    }
  }

  // دالة لإرسال بريد التقرير للطلبية
  Future<bool> sendOrderReportEmail(String orderId, String email) async {
    try {
      final result = await sendOrderHtmlReportByEmail(orderId, email);
      return result.success;
    } catch (e) {
      print('❌ تحذير: sendOrderReportEmail مُستبعدة، استخدم sendOrderHtmlReportByEmail');
      return false;
    }
  }

  // توليد تقرير HTML وتحميله
  Future<String> generateOrderHtmlReport(String orderId) async {
    try {
      if (orderId.isEmpty) {
        throw Exception('معرف الطلبية مطلوب');
      }

      print('📄 طلب إنشاء تقرير HTML للطلبية: $orderId');

      final response = await http.get(
        Uri.parse('$baseUrl/reports/order/$orderId/download'),
        headers: _headers,
      );

      print('📨 استجابة إنشاء تقرير HTML: ${response.statusCode}');

      if (response.statusCode == 200) {
        print('✅ تم إنشاء تقرير HTML بنجاح');
        return response.body;
      } else {
        String errorMessage = 'فشل في إنشاء التقرير';
        try {
          if (response.body.isNotEmpty) {
            final errorData = json.decode(response.body);
            errorMessage = errorData['message'] ?? errorMessage;
          }
        } catch (e) {
          errorMessage = 'خطأ في الخادم (${response.statusCode})';
        }
        throw Exception(errorMessage);
      }
    } on SocketException {
      throw Exception('فشل في الاتصال بالخادم. تحقق من الاتصال بالإنترنت');
    } catch (e) {
      print('❌ خطأ في إنشاء تقرير HTML: $e');
      throw Exception('فشل في إنشاء التقرير: ${e.toString()}');
    }
  }

  // معاينة تقرير HTML
  Future<String> previewOrderHtmlReport(String orderId) async {
    try {
      if (orderId.isEmpty) {
        throw Exception('معرف الطلبية مطلوب');
      }

      print('👁️ طلب معاينة تقرير HTML للطلبية: $orderId');

      final response = await http.get(
        Uri.parse('$baseUrl/reports/order/$orderId/preview'),
        headers: _headers,
      );

      print('📨 استجابة معاينة تقرير HTML: ${response.statusCode}');

      if (response.statusCode == 200) {
        print('✅ تم الحصول على معاينة تقرير HTML بنجاح');
        return response.body;
      } else {
        String errorMessage = 'فشل في معاينة التقرير';
        try {
          if (response.body.isNotEmpty) {
            final errorData = json.decode(response.body);
            errorMessage = errorData['message'] ?? errorMessage;
          }
        } catch (e) {
          errorMessage = 'خطأ في الخادم (${response.statusCode})';
        }
        throw Exception(errorMessage);
      }
    } on SocketException {
      throw Exception('فشل في الاتصال بالخادم');
    } catch (e) {
      print('❌ خطأ في معاينة تقرير HTML: $e');
      throw Exception('فشل في معاينة التقرير: ${e.toString()}');
    }
  }

  // إرسال تقرير HTML عبر البريد الإلكتروني
  Future<EmailReportResult> sendOrderHtmlReportByEmail(String orderId, String email) async {
    try {
      if (orderId.isEmpty) {
        throw Exception('معرف الطلبية مطلوب');
      }

      if (email.isEmpty || !_isValidEmail(email)) {
        throw Exception('البريد الإلكتروني غير صالح');
      }

      print('📧 طلب إرسال تقرير HTML بالبريد الإلكتروني للطلبية: $orderId إلى $email');

      final requestBody = {
        'email': email.trim(),
      };

      final response = await http.post(
        Uri.parse('$baseUrl/reports/order/$orderId/send-email'),
        headers: _headers,
        body: json.encode(requestBody),
      );

      print('📨 استجابة إرسال تقرير HTML بالبريد: ${response.statusCode}');
      print('📄 محتوى الاستجابة: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        if (response.body.isNotEmpty) {
          final responseData = json.decode(response.body);
          return EmailReportResult.fromJson(responseData);
        } else {
          // إذا كانت الاستجابة فارغة لكن الحالة ناجحة
          return EmailReportResult(
            success: true,
            message: 'تم إرسال التقرير بنجاح',
            email: email,
            orderId: orderId,
            reportType: 'HTML',
            timestamp: DateTime.now(),
          );
        }
      } else {
        String errorMessage = 'فشل في إرسال التقرير بالبريد الإلكتروني';
        try {
          if (response.body.isNotEmpty) {
            final errorData = json.decode(response.body);
            errorMessage = errorData['message'] ?? errorMessage;
          }
        } catch (e) {
          errorMessage = 'خطأ في الخادم (${response.statusCode})';
        }

        return EmailReportResult(
          success: false,
          message: errorMessage,
          email: email,
          orderId: orderId,
          reportType: 'HTML',
          timestamp: DateTime.now(),
          error: errorMessage,
        );
      }
    } on SocketException {
      return EmailReportResult(
        success: false,
        message: 'فشل في الاتصال بالخادم. تحقق من الاتصال بالإنترنت',
        email: email,
        orderId: orderId,
        reportType: 'HTML',
        timestamp: DateTime.now(),
        error: 'SocketException',
      );
    } catch (e) {
      print('❌ خطأ في إرسال تقرير HTML بالبريد: $e');
      return EmailReportResult(
        success: false,
        message: 'فشل في إرسال التقرير: ${e.toString()}',
        email: email,
        orderId: orderId,
        reportType: 'HTML',
        timestamp: DateTime.now(),
        error: e.toString(),
      );
    }
  }

  // الحصول على تقرير HTML محسّن للطباعة
  Future<String> getPrintReadyHtmlReport(String orderId) async {
    try {
      if (orderId.isEmpty) {
        throw Exception('معرف الطلبية مطلوب');
      }

      print('🖨️ طلب تقرير HTML جاهز للطباعة للطلبية: $orderId');

      final response = await http.get(
        Uri.parse('$baseUrl/reports/order/$orderId/print-ready'),
        headers: _headers,
      );

      print('📨 استجابة تقرير HTML للطباعة: ${response.statusCode}');

      if (response.statusCode == 200) {
        print('✅ تم الحصول على تقرير HTML جاهز للطباعة بنجاح');
        return response.body;
      } else {
        String errorMessage = 'فشل في الحصول على التقرير الجاهز للطباعة';
        try {
          if (response.body.isNotEmpty) {
            final errorData = json.decode(response.body);
            errorMessage = errorData['message'] ?? errorMessage;
          }
        } catch (e) {
          errorMessage = 'خطأ في الخادم (${response.statusCode})';
        }
        throw Exception(errorMessage);
      }
    } on SocketException {
      throw Exception('فشل في الاتصال بالخادم');
    } catch (e) {
      print('❌ خطأ في الحصول على تقرير HTML للطباعة: $e');
      throw Exception('فشل في الحصول على التقرير: ${e.toString()}');
    }
  }

  // الحصول على تقرير HTML محسّن للموبايل
  Future<String> getMobileFriendlyHtmlReport(String orderId) async {
    try {
      if (orderId.isEmpty) {
        throw Exception('معرف الطلبية مطلوب');
      }

      print('📱 طلب تقرير HTML متوافق مع الموبايل للطلبية: $orderId');

      final response = await http.get(
        Uri.parse('$baseUrl/reports/order/$orderId/mobile-friendly'),
        headers: _headers,
      );

      print('📨 استجابة تقرير HTML للموبايل: ${response.statusCode}');

      if (response.statusCode == 200) {
        print('✅ تم الحصول على تقرير HTML متوافق مع الموبايل بنجاح');
        return response.body;
      } else {
        String errorMessage = 'فشل في الحصول على التقرير المتوافق مع الموبايل';
        try {
          if (response.body.isNotEmpty) {
            final errorData = json.decode(response.body);
            errorMessage = errorData['message'] ?? errorMessage;
          }
        } catch (e) {
          errorMessage = 'خطأ في الخادم (${response.statusCode})';
        }
        throw Exception(errorMessage);
      }
    } on SocketException {
      throw Exception('فشل في الاتصال بالخادم');
    } catch (e) {
      print('❌ خطأ في الحصول على تقرير HTML للموبايل: $e');
      throw Exception('فشل في الحصول على التقرير: ${e.toString()}');
    }
  }

  // دالة مساعدة للتحقق من صحة البريد الإلكتروني
  bool _isValidEmail(String email) {
    // final emailRegex = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');
    // return emailRegex.test(email.trim());
    return true ;
  }

}


class EmailReportResult {
  final bool success;
  final String message;
  final String email;
  final String orderId;
  final String reportType;
  final DateTime timestamp;
  final String? error;

  EmailReportResult({
    required this.success,
    required this.message,
    required this.email,
    required this.orderId,
    required this.reportType,
    required this.timestamp,
    this.error,
  });

  factory EmailReportResult.fromJson(Map<String, dynamic> json) {
    return EmailReportResult(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      email: json['email'] ?? '',
      orderId: json['orderId'] ?? '',
      reportType: json['reportType'] ?? 'HTML',
      timestamp: json['timestamp'] != null
          ? DateTime.parse(json['timestamp'])
          : DateTime.now(),
      error: json['error'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'message': message,
      'email': email,
      'orderId': orderId,
      'reportType': reportType,
      'timestamp': timestamp.toIso8601String(),
      if (error != null) 'error': error,
    };
  }

  @override
  String toString() {
    return 'EmailReportResult(success: $success, message: $message, email: $email)';
  }
}


// نموذج لنتائج رفع الصور المتعددة
class MultipleImageUploadResult {
  final bool success;
  final int totalFiles;
  final int successCount;
  final int errorCount;
  final List<OrderImage> results;
  final List<Map<String, dynamic>>? errors;
  final String message;

  MultipleImageUploadResult({
    required this.success,
    required this.totalFiles,
    required this.successCount,
    required this.errorCount,
    required this.results,
    this.errors,
    required this.message,
  });

  factory MultipleImageUploadResult.fromJson(Map<String, dynamic> json) {
    return MultipleImageUploadResult(
      success: json['success'] ?? false,
      totalFiles: json['totalFiles'] ?? 0,
      successCount: json['successCount'] ?? 0,
      errorCount: json['errorCount'] ?? 0,
      results: (json['results'] as List<dynamic>?)
              ?.map((item) => OrderImage.fromJson(item))
              .toList() ??
          [],
      errors: (json['errors'] as List<dynamic>?)
          ?.map((item) => Map<String, dynamic>.from(item))
          .toList(),
      message: json['message'] ?? '',
    );
  }

  bool get hasErrors => errorCount > 0;
  bool get hasPartialSuccess => successCount > 0 && errorCount > 0;
  bool get hasCompleteSuccess => successCount == totalFiles && errorCount == 0;
  bool get hasCompleteFailure => successCount == 0 && errorCount == totalFiles;

  String getDetailedErrorMessage() {
    if (!hasErrors || errors == null) return '';

    final errorMessages = errors!
        .map((error) {
          final filename = error['filename'] ?? 'ملف غير معروف';
          final errorMsg = error['error'] ?? 'خطأ غير معروف';
          final index = error['index'] ?? '';
          return 'الصورة $index ($filename): $errorMsg';
        })
        .take(3)
        .join('\n');

    if (errors!.length > 3) {
      return '$errorMessages\n... و ${errors!.length - 3} أخطاء أخرى';
    }

    return errorMessages;
  }

}
