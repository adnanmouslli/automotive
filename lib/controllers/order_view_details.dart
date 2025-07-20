import 'dart:convert';

import 'package:automotive/controllers/order_controller.dart';
import 'package:automotive/services/OrderDetailsService.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'dart:typed_data';
import '../models/new_order.dart';
import '../routes/app_pages.dart';
import '../utils/AppColors.dart';
import 'auth_controller.dart';

class OrderDetailsController extends GetxController {
  final OrderDetailsService _service = OrderDetailsService();
  final AuthController _authController = Get.find<AuthController>();
  final ImagePicker _picker = ImagePicker();

  // Observables
  final Rx<NewOrder?> _order = Rx<NewOrder?>(null);
  final RxBool _isLoading = false.obs;
  final RxString _errorMessage = ''.obs;

  // إضافة متغير للتحقق من التهيئة
  final RxBool _isInitialized = false.obs;

  // Public getters
  NewOrder? get order => _order.value;
  bool get isLoading => _isLoading.value;
  String get errorMessage => _errorMessage.value;
  bool get isInitialized => _isInitialized.value;

  // Computed properties
  bool get hasExpenses => order?.expenses != null;
  bool get canCompleteOrder =>
      order != null && order!.hasAllSignatures && order!.hasImages && order!.isCompleted ;

  double get completionPercentage {
    if (order == null) return 0.0;

    double progress = 0.4; // Basic info always exists

    if (order!.hasImages) progress += 0.2;
    if (order!.hasDriverSignature) progress += 0.15;
    if (order!.hasCustomerSignature) progress += 0.15;
    if (order!.hasExpenses) progress += 0.1;

    return progress;
  }

  List<String> get missingRequirements {
    if (order == null) return [];

    List<String> missing = [];

    if (!order!.hasImages) missing.add('add_vehicle_photos_req'.tr);
    if (!order!.hasDriverSignature) missing.add('driver_signature_req'.tr);
    if (!order!.hasCustomerSignature) missing.add('customer_signature_req'.tr);
    if (!order!.hasExpenses) missing.add('add_expenses_req'.tr);

    return missing;
  }

  bool _isDisposed = false;

  @override
  void onInit() {
    super.onInit();
    ever(_order, (_) {
      if (!_isDisposed) {
        update(); // تحديث الواجهة عند تغيير الطلب فقط إذا لم يتم التخلص من الكونترولر
      }
    });
  }

  // Initialize with order ID
  void initializeOrder(String orderId) {
    if (_isDisposed) return; // منع التنفيذ إذا تم التخلص من الكونترولر

    print('🔄 ${'starting_order_initialization'.tr.replaceAll('orderId', orderId)}');
    if (_isInitialized.value && order?.id == orderId) {
      print('✅ ${'order_already_loaded'.tr}');
      return;
    }
    loadOrderDetails(orderId);
  }

  // Load order details
  Future<void> loadOrderDetails(String orderId, {bool forceReload = false}) async {
    if (_isDisposed) return; // منع التنفيذ إذا تم التخلص من الكونترولر

    try {
      _isLoading.value = true;
      if (!_isDisposed) update();

      final orderData = await _service.getOrderDetails(orderId);
      if (orderData != null && !_isDisposed) {
        _order.value = orderData;
        print("=========================");
        print(jsonEncode(_order.value));
        _isInitialized.value = true;
        if (!_isDisposed) update();
      }
    } catch (e) {
      print('❌ ${'error_loading_order_details'.tr.replaceAll('error', e.toString())}');
      if (!_isDisposed) {
        _showErrorSnackbar('loading_failed'.tr, e.toString());
      }
    } finally {
      if (!_isDisposed) {
        _isLoading.value = false;
        update();
      }
    }
  }

  // Add single image
  Future<void> addImage() async {
    try {
      if (order == null) return;

      final List<XFile> images = await _picker.pickMultiImage(
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (images.isNotEmpty) {
        await _uploadMultipleImages(images);
      }
    } catch (e) {
      print('❌ ${'select_images_error'.tr.replaceAll('error', e.toString())}');
      _showErrorSnackbar('select_images_error'.tr, e.toString());
    }
  }

  // Upload multiple images
  Future<void> _uploadMultipleImages(List<XFile> images) async {
    try {
      _isLoading.value = true;

      // Show category selection dialog
      final category = await _showCategorySelectionDialog();
      if (category == null) return;

      // Show description input dialog
      final description = await _showDescriptionInputDialog();

      print('📤 ${'uploading_images'.tr.replaceAll('count', images.length.toString())
      .replaceAll('orderId', order!.id)
      }');

      final results = await _service.uploadMultipleImages(
        orderId: order!.id,
        images: images,
        category: category,
        description: description ?? '',
      );

      if (results.isNotEmpty) {
        // Reload order to get updated images
        await loadOrderDetails(order!.id);

        _showSuccessSnackbar('images_uploaded_success'.tr.replaceAll(
          'uploaded', results.length.toString()
        ).replaceAll('total', images.length.toString())
            , '');
      } else {
        throw Exception('failed_upload_images'.tr);
      }
    } catch (e) {
      print('❌ ${'image_upload_error'.tr.replaceAll('error', e.toString())}');
      _showErrorSnackbar('failed_upload_images'.tr, e.toString());
    } finally {
      _isLoading.value = false;
    }
  }

  // Add driver signature
  Future<void> addDriverSignature() async {
    if (order == null) return;

    final signatureData = await Get.toNamed('/signature', arguments: {
      'title': 'driver_signature'.tr,
      'signerName': _authController.currentUserName,
    });

    if (signatureData != null && signatureData is Map) {
      await _uploadSignature(
        signatureBytes: signatureData['signature'],
        signerName: signatureData['signerName'],
        isDriver: true,
      );
    }
  }

  // Add customer signature
  Future<void> addCustomerSignature() async {
    if (order == null) return;

    final signatureData = await Get.toNamed('/signature', arguments: {
      'title': 'customer_signature'.tr,
      'signerName': order!.client,
    });

    if (signatureData != null && signatureData is Map) {
      await _uploadSignature(
        signatureBytes: signatureData['signature'],
        signerName: signatureData['signerName'],
        isDriver: false,
      );
    }
  }

  // Upload signature
  Future<void> _uploadSignature({
    required Uint8List signatureBytes,
    required String signerName,
    required bool isDriver,
  }) async {
    try {
      if (order == null) return;

      _isLoading.value = true;

      print('📤 ${'uploading_signature'.tr.replaceAll('orderId', order!.id)}');

      final signature = await _service.uploadSignature(
        orderId: order!.id,
        signatureBytes: signatureBytes,
        signerName: signerName,
        isDriver: isDriver,
      );

      if (signature != null) {
        // Reload order to get updated signatures
        await loadOrderDetails(order!.id);

        _showSuccessSnackbar(
            'signature_saved_success'.tr,
            'signature_type_saved'.tr.replaceAll('type', isDriver ? 'driver'.tr : 'customer'.tr));
      } else {
        throw Exception('signature_save_failed'.tr);
      }
    } catch (e) {
      print('❌ ${'signature_upload_error'.tr.replaceAll('error', e.toString())}');
      _showErrorSnackbar('signature_save_failed'.tr, e.toString());
    } finally {
      _isLoading.value = false;
    }
  }

  // Add expenses
  Future<void> addExpenses() async {
    if (order == null) return;

    final expensesData = await Get.toNamed('/expenses', arguments: {
      'orderId': order!.id,
    });

    if (expensesData != null && expensesData is Map) {
      await _uploadExpenses(expensesData);
    }
  }

  // تعديل المصاريف
  Future<void> editExpenses() async {
    try {
      if (order == null || order!.expenses == null) return;

      final expensesData = await Get.toNamed('/expenses', arguments: {
        'orderId': order!.id,
        'expenses': order!.expenses!.toJson(), // إرسال المصاريف الحالية للتعديل
        'isEditMode': true, // وضع التعديل
      });

      if (expensesData != null && expensesData is Map) {
        await _updateExpenses(expensesData);
      }
    } catch (e) {
      print('❌ ${'expenses_update_error'.tr.replaceAll('error', e.toString())}');
      _showErrorSnackbar('failed_to_save_expenses'.tr, e.toString());
    }
  }

  // تحديث المصاريف في الخادم
  Future<void> _updateExpenses(Map<dynamic, dynamic> expensesData) async {
    try {
      if (order == null) return;

      _isLoading.value = true;

      print('🔄 ${'updating_expenses_for_order'.tr.replaceAll('orderId', order!.id)}');
      print('📊 ${'incoming_expenses_data'.tr.replaceAll('data', expensesData.toString())}');

      final expenses = await _service.updateExpenses(
        orderId: order!.id,
        expensesData: Map<String, dynamic>.from(expensesData),
      );

      if (expenses != null) {
        await loadOrderDetails(order!.id);
        _showSuccessSnackbar('expenses_updated_successfully'.tr,
            'expenses_total_amount'.tr.replaceAll('amount', expenses.total.toStringAsFixed(2)));
      }
    } catch (e) {
      print('❌ ${'expenses_update_error'.tr.replaceAll('error', e.toString())}');
      _showErrorSnackbar('failed_to_save_expenses'.tr, e.toString());
    } finally {
      _isLoading.value = false;
    }
  }

  Future<void> _uploadExpenses(Map<dynamic, dynamic> expensesData) async {
    try {
      if (order == null) return;

      _isLoading.value = true;

      print('📤 ${'uploading_expenses_for_order'.tr.replaceAll('orderId', order!.id)}');
      print('📊 ${'incoming_expenses_data'.tr.replaceAll('data', expensesData.toString())}');

      final expenses = await _service.uploadExpenses(
        orderId: order!.id,
        expensesData: Map<String, dynamic>.from(expensesData),
      );

      if (expenses != null) {
        await loadOrderDetails(order!.id);
        _showSuccessSnackbar('expenses_added_success'.tr,
            'expenses_total_amount'.tr.replaceAll('amount', expenses.total.toStringAsFixed(2)));
      }
    } catch (e) {
      print('❌ ${'expenses_upload_error'.tr.replaceAll('error', e.toString())}');
      _showErrorSnackbar('expenses_add_failed'.tr, e.toString());
    } finally {
      _isLoading.value = false;
    }
  }

  // Complete order
  Future<void> completeOrder() async {
    if (_isDisposed) return;

    try {
      if (order == null) return;

      // إغلاق أي snackbar مفتوح
      if (Get.isSnackbarOpen) {
        Get.closeCurrentSnackbar();
        await Future.delayed(Duration(milliseconds: 300));
      }

      if (!canCompleteOrder) {
        print('❌ ${'cannot_complete_missing_requirements'.tr}');
        print('📋 ${'missing_requirements_list'.tr.replaceAll('requirements', missingRequirements.join(", "))}');

        _showErrorSnackbar('cannot_complete_missing_requirements'.tr,
            'missing_requirements_list'.tr.replaceAll('requirements', missingRequirements.join(", ")));
        return;
      }

      // إضافة تأكيد الإتمام
      final confirmed = await Get.dialog<bool>(
        AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Row(
            children: [
              Icon(Icons.check_circle_outline, color: Colors.green.shade600, size: 22),
              SizedBox(width: 8),
              Text('complete_order'.tr, style: TextStyle(fontSize: 16)),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'confirm_completion'.tr.replaceAll('client', order!.client),
                style: TextStyle(fontSize: 14, height: 1.4, fontWeight: FontWeight.w500),
              ),
              SizedBox(height: 12),
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.green.shade200),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'all_requirements_met'.tr,
                      style: TextStyle(
                        color: Colors.green.shade700,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 6),
                    Text('photos_added'.tr, style: TextStyle(color: Colors.green.shade600)),
                    Text('driver_sign_added'.tr, style: TextStyle(color: Colors.green.shade600)),
                    Text('customer_sign_added'.tr, style: TextStyle(color: Colors.green.shade600)),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Get.back(result: false),
              child: Text('cancel'.tr, style: TextStyle(color: Colors.grey.shade600)),
            ),
            ElevatedButton(
              onPressed: () => Get.back(result: true),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green.shade600,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: Text('complete_order'.tr, style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
        barrierDismissible: true,
      );


      print('🔄 ${'starting_order_completion'.tr}');

      // انتظار قصير قبل بدء التحميل
      await Future.delayed(Duration(milliseconds: 200));

      if (_isDisposed) return;

      // تشغيل مؤشر التحميل
      _isLoading.value = true;
      if (!_isDisposed) update();

      try {
        // استخدام updateOrderStatus مع معالجة أفضل للأخطاء
        await updateOrderStatus('completed');

        if (_isDisposed) return;

        // إيقاف التحميل
        _isLoading.value = false;
        if (!_isDisposed) update();

        // انتظار قصير قبل عرض الرسالة
        await Future.delayed(Duration(milliseconds: 300));

        if (_isDisposed) return;

        // إظهار رسالة نجاح
        _showSuccessSnackbar(
          '🎉 ${'order_completed'.tr}',
          'order_completed_success_detailed'.tr.replaceAll('client', order!.client),
        );

        // العودة للصفحة السابقة بعد تأخير
        await Future.delayed(const Duration(seconds: 1));
        if (!_isDisposed) {
          Get.back();
        }
      } catch (e) {
        if (_isDisposed) return;

        _isLoading.value = false;
        if (!_isDisposed) update();

        print('❌ ${'order_completion_process_error'.tr.replaceAll('error', e.toString())}');

        // انتظار قصير قبل عرض رسالة الخطأ
        await Future.delayed(Duration(milliseconds: 300));

        if (!_isDisposed) {
          _showErrorSnackbar('failed_to_complete_order'.tr, e.toString());
        }
      }
    } catch (e) {
      if (_isDisposed) return;

      _isLoading.value = false;
      if (!_isDisposed) update();

      print('❌ ${'general_completion_error'.tr.replaceAll('error', e.toString())}');

      // انتظار قصير قبل عرض رسالة الخطأ
      await Future.delayed(Duration(milliseconds: 300));

      if (!_isDisposed) {
        _showErrorSnackbar('failed_to_complete_order'.tr, e.toString());
      }
    }
  }

  // تحديث دالة editDetails لتشمل التحقق من الصحة
  Future<void> editDetails() async {
    try {
      // التحقق من وجود الطلب أولاً
      if (order == null) {
        print('❌ ${'cannot_edit_no_data'.tr}');
        _showErrorSnackbar('edit_error_title'.tr, 'order_data_unavailable'.tr);
        return;
      }

      print('🔄 ${'opening_edit_page'.tr.replaceAll('orderId', order!.id)}');

      // التحقق من وجود دالة toJson في NewOrder model
      Map<String, dynamic> orderData;
      try {
        orderData = order!.toJson();
      } catch (e) {
        print('❌ ${'error_converting_order_json'.tr.replaceAll('error', e.toString())}');
        // إنشاء البيانات يدوياً كبديل
        orderData = {
          'id': order!.id,
          'client': order!.client,
          'clientPhone': order!.clientPhone,
          'clientEmail': order!.clientEmail,
          'vehicleOwner': order!.vehicleOwner,
          'licensePlateNumber': order!.licensePlateNumber,
          'serviceType': order!.serviceType.toString(),
          'description': order!.description,
          'comments': order!.comments,
          'pickupAddress': order!.pickupAddress.toJson(),
          'deliveryAddress': order!.deliveryAddress.toJson(),
          'status': order!.status,
          // يمكن إضافة المزيد من الحقول حسب الحاجة
        };
      }

      print('📋 ${'order_data_for_editing'.tr.replaceAll('fields', orderData.keys.toList().toString())}');

      final result = await Get.toNamed('/edit-order', arguments: {
        'order': orderData,
        'orderId': order!.id, // إضافة معرف الطلب كاحتياط
      });

      // التحقق من نجاح التعديل
      if (result == true) {
        print('✅ ${'edit_completed_successfully'.tr}');
        await loadOrderDetails(order!.id);
        _showSuccessSnackbar('order_updated_success'.tr, 'changes_saved'.tr);
      } else if (result != null) {
        print('ℹ️ ${'edit_result'.tr.replaceAll('result', result.toString())}');
      }
    } catch (e) {
      print('❌ ${'error_opening_edit_page'.tr.replaceAll('error', e.toString())}');
      _showErrorSnackbar(
          'edit_error_title'.tr,
          'could_not_open_edit_page'.tr.replaceAll('error', e.toString()));
    }
  }

  // دالة لإنشاء بيانات الطلب يدوياً في حالة عدم وجود toJson
  Map<String, dynamic> _createOrderDataManually() {
    return {
      'id': order!.id,
      'client': order!.client,
      'clientPhone': order!.clientPhone ?? '',
      'clientEmail': order!.clientEmail ?? '',
      'vehicleOwner': order!.vehicleOwner ?? '',
      'licensePlateNumber': order!.licensePlateNumber,
      'serviceType': order!.serviceType.toString().split('.').last,
      'description': order!.description ?? '',
      'comments': order!.comments ?? '',
      'pickupAddress': {
        'street': order!.pickupAddress.street,
        'houseNumber': order!.pickupAddress.houseNumber,
        'city': order!.pickupAddress.city,
        'zipCode': order!.pickupAddress.zipCode,
        'country': order!.pickupAddress.country,
      },
      'deliveryAddress': {
        'street': order!.deliveryAddress.street,
        'houseNumber': order!.deliveryAddress.houseNumber,
        'city': order!.deliveryAddress.city,
        'zipCode': order!.deliveryAddress.zipCode,
        'country': order!.deliveryAddress.country,
      },
      'status': order!.status ?? 'pending',
      'createdAt': order!.createdAt?.toIso8601String(),
      'updatedAt': order!.updatedAt?.toIso8601String(),
    };
  }

  // دالة للتعامل مع نتيجة التحرير
  void _handleEditResult(dynamic result) {
    if (result == true) {
      print('✅ ${'edit_completed_successfully'.tr}');
      loadOrderDetails(order!.id);
      _showSuccessSnackbar('order_updated_success'.tr, 'changes_saved'.tr);
    } else if (result == false) {
      print('ℹ️ ${'edit_cancelled'.tr}');
    } else if (result != null) {
      print('ℹ️ ${'edit_result'.tr.replaceAll('result', result.toString())}');
    }
  }

  // Handle menu actions
  void handleMenuAction(String action) {
    switch (action) {
      case 'edit_details':
        editOrder(); // استخدام دالة editOrder المحدثة
        break;
      case 'complete':
        completeOrder();
        break;
      case 'mark_in_progress':
        updateOrderStatus('in_progress');
        break;
    }
  }

  Future<void> updateOrderStatus(String status) async {
    if (_isDisposed) return;

    try {
      if (order == null) return;

      // لا نحتاج إلى تشغيل _isLoading.value = true هنا إذا كانت تعمل من completeOrder
      // لأن completeOrder تدير التحميل بنفسها

      final success = await _service.updateOrderStatus(
        orderId: order!.id,
        status: status.toLowerCase(),
      );

      if (success && !_isDisposed) {
        // إعادة تحميل بيانات الطلب
        await loadOrderDetails(order!.id);

        // إشعار NewOrderController بالتحديث
        _notifyDashboardUpdate();

        if (!_isDisposed) {
          update();
          // عدم إظهار snackbar هنا لأن completeOrder تدير ذلك
          // _showSuccessSnackbar('تم التحديث', 'حالة الطلب: ${_getStatusText(status)}');
        }
      } else if (!success && !_isDisposed) {
        throw Exception('updating_order_status_server'.tr);
      }
    } catch (e) {
      if (!_isDisposed) {
        print('❌ خطأ في updateOrderStatus: $e');
        throw e; // إعادة throw للخطأ ليتم التعامل معه في completeOrder
      }
    }
  }

  void _notifyDashboardUpdate() {
    try {
      // التحقق من وجود NewOrderController وإعادة تحميل البيانات
      if (Get.isRegistered<NewOrderController>()) {
        final dashboardController = Get.find<NewOrderController>();
        print('🔄 ${'notifying_dashboard_update'.tr}');
        dashboardController.loadOrders();
      }
    } catch (e) {
      print('⚠️ ${'error_notifying_dashboard'.tr.replaceAll('error', e.toString())}');
    }
  }

  String _getStatusText(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return 'pending'.tr;
      case 'in_progress':
        return 'in_progress'.tr;
      case 'completed':
        return 'completed'.tr;
      case 'cancelled':
        return 'status_cancelled'.tr;
      default:
        return status;
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
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

  // Show category selection dialog
  Future<ImageCategory?> _showCategorySelectionDialog() async {
    return await Get.dialog<ImageCategory>(
      AlertDialog(
        title: Text('select_image_category'.tr),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: ImageCategory.values.map((category) {
            return ListTile(
              title: Text(_getCategoryText(category)),
              onTap: () => Get.back(result: category),
            );
          }).toList(),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text('cancel'.tr),
          ),
        ],
      ),
    );
  }

  // Show description input dialog
  Future<String?> _showDescriptionInputDialog() async {
    final controller = TextEditingController();

    return await Get.dialog<String>(
      AlertDialog(
        title: Text('image_description_optional'.tr),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(
            hintText: 'enter_image_description'.tr,
            border: const OutlineInputBorder(),
          ),
          maxLines: 3,
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text('skip'.tr),
          ),
          ElevatedButton(
            onPressed: () => Get.back(result: controller.text.trim()),
            child: Text('ok'.tr),
          ),
        ],
      ),
    );
  }

  // Helper methods
  String _getCategoryText(ImageCategory category) {
    switch (category) {
      case ImageCategory.PICKUP:
        return 'pickup_photos'.tr;
      case ImageCategory.DELIVERY:
        return 'delivery_photos'.tr;
      case ImageCategory.DAMAGE:
        return 'damage_photos'.tr;
      case ImageCategory.ADDITIONAL:
        return 'additional_photos'.tr;
      case ImageCategory.INTERIOR:
        return 'interior_photos'.tr;
      case ImageCategory.EXTERIOR:
        return 'exterior_photos'.tr;
    }
  }

  void _showSuccessSnackbar(String title, String message) {
    if (_isDisposed) return;

    // إغلاق أي snackbar مفتوح أولاً
    if (Get.isSnackbarOpen) {
      Get.closeCurrentSnackbar();
    }

    // انتظار قصير ثم عرض الرسالة الجديدة
    Future.delayed(Duration(milliseconds: 200), () {
      if (!_isDisposed) {
        Get.snackbar(
          title,
          message,
          backgroundColor: Colors.green,
          colorText: Colors.white,
          snackPosition: SnackPosition.TOP,
          duration: const Duration(seconds: 3),
          margin: EdgeInsets.all(16),
          borderRadius: 12,
          icon: Icon(Icons.check_circle, color: Colors.white),
        );
      }
    });
  }

  void _showErrorSnackbar(String title, String message) {
    if (_isDisposed) return;

    // إغلاق أي snackbar مفتوح أولاً
    if (Get.isSnackbarOpen) {
      Get.closeCurrentSnackbar();
    }

    // انتظار قصير ثم عرض الرسالة الجديدة
    Future.delayed(Duration(milliseconds: 200), () {
      if (!_isDisposed) {
        Get.snackbar(
          title,
          message,
          backgroundColor: Colors.red,
          colorText: Colors.white,
          snackPosition: SnackPosition.TOP,
          duration: const Duration(seconds: 4),
          margin: EdgeInsets.all(16),
          borderRadius: 12,
          icon: Icon(Icons.error, color: Colors.white),
        );
      }
    });
  }

  // 1. حذف صورة
  Future<void> deleteImage(String imageId) async {
    try {
      if (order == null) return;

      final confirmed = await Get.dialog<bool>(
        AlertDialog(
          title: Text('confirm_delete_image'.tr),
          content: Text('confirm_delete_image_message'.tr),
          actions: [
            TextButton(
              onPressed: () => Get.back(result: false),
              child: Text('cancel'.tr),
            ),
            ElevatedButton(
              onPressed: () => Get.back(result: true),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: Text('delete'.tr),
            ),
          ],
        ),
      );

      if (confirmed == true) {
        _isLoading.value = true;

        final success = await _service.deleteImage(
          orderId: order!.id,
          imageId: imageId,
        );

        if (success) {
          // إعادة تحميل تفاصيل الطلبية لتحديث قائمة الصور
          await loadOrderDetails(order!.id);
          _showSuccessSnackbar('image_deleted_success'.tr, '');
        }
      }
    } catch (e) {
      print('❌ ${'failed_delete_image'.tr}: $e');
      _showErrorSnackbar('failed_delete_image'.tr, e.toString());
    } finally {
      _isLoading.value = false;
    }
  }

// 2. حذف توقيع
  Future<void> deleteSignature(String signatureId, bool isDriver) async {
    try {
      if (order == null) return;

      final confirmed = await Get.dialog<bool>(
        AlertDialog(
          backgroundColor: AppColors.pureWhite,
          title: Text(
            'confirm_delete_signature'.tr,
            style: AppColors.subHeadingStyle,
          ),
          content: Text(
            'confirm_delete_signature_message'.tr.replaceAll(
                'signerType',
                isDriver ? 'driver'.tr : 'customer'.tr
            ),
            style: AppColors.bodyStyle,
          ),
          actions: [
            TextButton(
              onPressed: () => Get.back(result: false),
              style: AppColors.secondaryButtonStyle,
              child: Text(
                'cancel'.tr,
                style: AppColors.buttonTextStyle.copyWith(
                  color: AppColors.primaryBlue,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () => Get.back(result: true),
              style: AppColors.dangerButtonStyle,
              child: Text(
                'delete'.tr,
                style: AppColors.buttonTextStyle.copyWith(
                  color: AppColors.whiteText,
                ),
              ),
            ),
          ],
        ),
      );

      if (confirmed == true) {
        _isLoading.value = true;

        final success = await _service.deleteSignature(
          orderId: order!.id,
          signatureId: signatureId,
        );

        if (success) {
          // إعادة تحميل تفاصيل الطلبية لتحديث التوقيعات
          await loadOrderDetails(order!.id);

          _showSuccessSnackbar(
              'signature_deleted_success'.tr,
              'signature_type_saved'.tr.replaceAll(
                  'type',
                  isDriver ? 'driver'.tr : 'customer'.tr
              )
          );
        }
      }
    } catch (e) {
      print('❌ ${'failed_delete_signature'.tr}: $e');
      _showErrorSnackbar(
          'failed_delete_signature'.tr,
          e.toString()
      );
    } finally {
      _isLoading.value = false;
    }
  }

  Future<void> editOrder() async {
    try {
      // التحقق من وجود الطلب أولاً
      if (order == null) {
        print('❌ ${'cannot_edit_no_data'.tr}');
        _showErrorSnackbar('edit_error_title'.tr, 'order_data_unavailable'.tr);
        return;
      }

      // التحقق من إمكانية التعديل
      // if (!canEditOrder(order!.id)) {
      //   _showErrorSnackbar('warning'.tr, 'cannot_edit_current_status'.tr);
      //   return;
      // }
      //
      // print('🔄 ${'opening_edit_page'.tr.replaceAll({'orderId': order!.id})}');

      // فتح صفحة التحرير مع تمرير الطلب مباشرة
      final result = await Get.toNamed(Routes.EDIT_ORDER, arguments: order);

      // التعامل مع نتيجة التحرير
      if (result == true) {
        print('✅ ${'edit_completed_successfully'.tr}');

        // إعادة تحميل بيانات الطلب لتحديث الواجهة
        await loadOrderDetails(order!.id);

        _showSuccessSnackbar('order_updated_success'.tr, 'order_updated_all_saved'.tr);
      } else if (result != null) {
        print('ℹ️ ${'edit_result'.tr.replaceAll('result', result.toString())}');
      }
    } catch (e) {
      print('❌ ${'error_opening_edit_page'.tr.replaceAll('error', e.toString())}');
      _showErrorSnackbar('edit_error_title'.tr, 'could_not_open_edit_page'.tr.replaceAll('error', e.toString()));
    }
  }

  bool canEditOrder(String orderId) {
    if (order == null) return false;
    final status = order!.status.toLowerCase();
    return status != 'completed' && status != 'cancelled';
  }

  void updateOrderData(NewOrder updatedOrder) {
    try {
      if (updatedOrder.id == order?.id) {
        print('🔄 ${'reloading_order_data'.tr}: ${updatedOrder.id}');
        _order.value = updatedOrder;
        print('✅ ${'order_updated_locally'.tr}');
      }
    } catch (e) {
      print('❌ خطأ في تحديث البيانات محلياً: $e');
    }
  }

  @override
  void onClose() {
    _isDisposed = true; // تحديد أن الكونترولر تم التخلص منه
    _order.value = null;
    _isInitialized.value = false;
    print('🗑️ ${'controller_disposed'.tr}');
    super.onClose();
  }

}