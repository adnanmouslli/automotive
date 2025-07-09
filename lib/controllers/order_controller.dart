import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:io';
import 'dart:typed_data';
import '../models/new_address.dart';
import '../models/new_order.dart';
import '../routes/app_pages.dart';
import '../services/order_service.dart';
import '../views/EditOrderView.dart';
import 'auth_controller.dart';
import 'order_view_details.dart';

class NewOrderController extends GetxController {
  final NewOrderService _orderService = NewOrderService();
  final AuthController _authController = Get.find<AuthController>();

  // Observables
  final RxList<NewOrder> _orders = <NewOrder>[].obs;
  final RxBool _isLoading = false.obs;
  final RxBool _isCreating = false.obs;
  final RxString _searchQuery = ''.obs;
  final RxString _statusFilter = 'all'.obs;
  final RxString _errorMessage = ''.obs;

  // Public getters
  List<NewOrder> get orders => _orders;
  bool get isLoading => _isLoading.value;
  bool get isCreating => _isCreating.value;
  String get searchQuery => _searchQuery.value;
  String get statusFilter => _statusFilter.value;
  String get errorMessage => _errorMessage.value;

  // Filtered orders
  List<NewOrder> get filteredOrders {
    try {
      final currentUserId = _authController.currentUserId;
      if (currentUserId == null || currentUserId.isEmpty) {
        return [];
      }

      var filtered = _orders.where((order) => order.driverId == currentUserId).toList();

      // Filter by search query
      if (_searchQuery.value.isNotEmpty) {
        final query = _searchQuery.value.toLowerCase();
        filtered = filtered.where((order) =>
        order.client.toLowerCase().contains(query) ||
            order.licensePlateNumber.toLowerCase().contains(query) ||
            order.description.toLowerCase().contains(query) ||
            order.vehicleOwner.toLowerCase().contains(query) ||
            (order.orderNumber?.toLowerCase().contains(query) ?? false)
        ).toList();
      }

      // Filter by status
      if (_statusFilter.value != 'all') {
        filtered = filtered.where((order) => order.status == _statusFilter.value).toList();
      }

      return filtered;
    } catch (e) {
      print('filter_error'.tr.replaceAll('error', e.toString()));
      return [];
    }
  }

  // Statistics
  int get totalOrders {
    final currentUserId = _authController.currentUserId;
    if (currentUserId == null) return 0;
    return _orders.where((o) => o.driverId == currentUserId).length;
  }

  int get pendingOrders {
    final currentUserId = _authController.currentUserId;
    if (currentUserId == null) return 0;
    return _orders.where((o) => o.driverId == currentUserId && o.status == 'pending').length;
  }

  int get inProgressOrders {
    final currentUserId = _authController.currentUserId;
    if (currentUserId == null) return 0;
    return _orders.where((o) => o.driverId == currentUserId && o.status == 'in_progress').length;
  }

  int get completedOrders {
    final currentUserId = _authController.currentUserId;
    if (currentUserId == null) return 0;
    return _orders.where((o) => o.driverId == currentUserId && o.status == 'completed').length;
  }

  @override
  void onInit() {
    super.onInit();
    loadOrders();
  }

  // Load orders from backend
  Future<void> loadOrders() async {
    try {
      _isLoading.value = true;
      _errorMessage.value = '';

      final ordersList = await _orderService.getOrders();

      if (ordersList.isNotEmpty) {
        _orders.assignAll(ordersList);
      } else {
        _orders.clear();
      }
    } catch (e) {
      _errorMessage.value = e.toString();
      _showErrorSnackbar('failed_to_load_orders'.tr, e.toString());
    } finally {
      _isLoading.value = false;
    }
  }

  // Create basic order
  Future<String?> createBasicOrder({
    required String client,
    required String clientPhone,
    required String clientEmail,
    required String description,
    required String vehicleOwner,
    required String licensePlateNumber,
    required String pickupStreet,
    required String pickupHouseNumber,
    required String pickupZipCode,
    required String pickupCity,
    required String deliveryStreet,
    required String deliveryHouseNumber,
    required String deliveryZipCode,
    required String deliveryCity,
    ServiceType serviceType = ServiceType.TRANSPORT,
  }) async {
    try {
      _isCreating.value = true;
      _errorMessage.value = '';

      // التحقق من صحة البيانات
      final validationError = _validateOrderData(
        client: client,
        vehicleOwner: vehicleOwner,
        licensePlateNumber: licensePlateNumber,
        pickupStreet: pickupStreet,
        pickupCity: pickupCity,
        deliveryStreet: deliveryStreet,
        deliveryCity: deliveryCity,
      );

      if (validationError != null) {
        throw Exception(validationError);
      }

      // التحقق من معرف المستخدم
      final currentUserId = _authController.currentUserId;
      if (currentUserId == null || currentUserId.isEmpty) {
        throw Exception('must_login_first'.tr);
      }

      print('📤 ${'creating_new_order'.tr}...');

      final order = NewOrder(
        id: '',
        client: client.trim(),
        clientPhone: clientPhone.trim(),
        clientEmail: clientEmail.trim(),
        description: description.trim(),
        vehicleOwner: vehicleOwner.trim(),
        licensePlateNumber: licensePlateNumber.trim(),
        serviceType: serviceType,
        pickupAddress: NewAddress(
          street: pickupStreet.trim(),
          houseNumber: pickupHouseNumber.trim(),
          zipCode: pickupZipCode.trim(),
          city: pickupCity.trim(),
        ),
        deliveryAddress: NewAddress(
          street: deliveryStreet.trim(),
          houseNumber: deliveryHouseNumber.trim(),
          zipCode: deliveryZipCode.trim(),
          city: deliveryCity.trim(),
        ),
        driverId: currentUserId,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final createdOrder = await _orderService.createOrder(order);
      if (createdOrder != null) {
        _orders.add(createdOrder);
        _showSuccessSnackbar(
            'create_order_success'.tr,
            createdOrder.orderNumber != null
                ? 'order_number'.tr.replaceAll('number', createdOrder.orderNumber!)
                : '');
        print('✅ ${'order_created_successfully'.tr}: ${createdOrder.id}');
        return createdOrder.id;
      } else {
        throw Exception('order_data_not_returned'.tr);
      }
    } catch (e) {
      _errorMessage.value = e.toString();
      _showErrorSnackbar('failed_to_create_order'.tr, e.toString());
      return null;
    } finally {
      _isCreating.value = false;
    }
  }

// Update order details with validation (continued)
  Future<bool> updateOrderDetails({
    required String orderId,
    required String client,
    required String clientPhone,
    required String clientEmail,
    required String description,
    required String vehicleOwner,
    required String licensePlateNumber,
    String? comments,
    String? vin,
    String? brand,
    String? model,
    int? year,
    String? color,
    String? vehicleType,
    String? serviceDescription,
    NewAddress? pickupAddress,
    NewAddress? deliveryAddress,
  }) async {
    try {
      _isCreating.value = true;
      _errorMessage.value = '';

      if (orderId.isEmpty) {
        throw Exception('order_id_required'.tr);
      }

      final currentOrder = getOrderById(orderId);
      if (currentOrder == null) {
        throw Exception('order_not_found'.tr);
      }

      print('📝 ${'updating_order_details'.tr}: $orderId');

      // تحضير البيانات كـ Map بدلاً من استخدام copyWith
      final Map<String, dynamic> updateData = {
        'client': client.trim(),
        'clientPhone': clientPhone.trim(),
        'clientEmail': clientEmail.trim(),
        'description': description.trim(),
        'vehicleOwner': vehicleOwner.trim(),
        'licensePlateNumber': licensePlateNumber.trim(),
        'comments': comments?.trim() ?? currentOrder.comments,
        // إضافة الحقول الإضافية إذا كانت موجودة في النموذج
        if (vin != null) 'vin': vin.trim(),
        if (brand != null) 'brand': brand.trim(),
        if (model != null) 'model': model.trim(),
        if (year != null) 'year': year,
        if (color != null) 'color': color.trim(),
        if (vehicleType != null) 'vehicleType': vehicleType.trim(),
        if (serviceDescription != null) 'serviceDescription': serviceDescription.trim(),
      };

      // إضافة العناوين إذا تم تمريرها
      if (pickupAddress != null) {
        updateData['pickupAddress'] = {
          'street': pickupAddress.street,
          'houseNumber': pickupAddress.houseNumber,
          'zipCode': pickupAddress.zipCode,
          'city': pickupAddress.city,
          'country': pickupAddress.country,
        };
      }

      if (deliveryAddress != null) {
        updateData['deliveryAddress'] = {
          'street': deliveryAddress.street,
          'houseNumber': deliveryAddress.houseNumber,
          'zipCode': deliveryAddress.zipCode,
          'city': deliveryAddress.city,
          'country': deliveryAddress.country,
        };
      }

      // استخدام updateOrderData بدلاً من updateOrder
      final result = await _orderService.updateOrderData(orderId, updateData);

      if (result != null) {
        final index = _orders.indexWhere((o) => o.id == orderId);
        if (index != -1) {
          _orders[index] = result;
        }
        _showSuccessSnackbar('order_updated_success'.tr, '');
        print('✅ ${'order_updated_successfully'.tr}');
        return true;
      }
      return false;
    } catch (e) {
      final error = e.toString();
      _errorMessage.value = error;
      print('❌ ${'order_update_error'.tr}: $error');
      _showErrorSnackbar('failed_to_update_order'.tr, error);
      return false;
    } finally {
      _isCreating.value = false;
    }
  }

  // Update full order with validation
  Future<bool> updateFullOrder({
    required String orderId,
    required Map<String, dynamic> orderData,
  }) async {
    try {
      _isCreating.value = true;
      _errorMessage.value = '';

      print('🔄 ${'starting_order_update'.tr}: $orderId');
      print('📊 ${'incoming_data'.tr}: ${orderData.keys.join(', ')}');

      final currentOrder = getOrderById(orderId);
      if (currentOrder == null) {
        throw Exception('order_not_found_locally'.tr);
      }



      // تحضير البيانات للإرسال
      final Map<String, dynamic> updateData = {
        'client': orderData['client']?.toString()?.trim() ?? '',
        'clientPhone': orderData['clientPhone']?.toString()?.trim() ?? '',
        'clientEmail': orderData['clientEmail']?.toString()?.trim() ?? '',
        'description': orderData['description']?.toString()?.trim() ?? '',
        'comments': orderData['comments']?.toString()?.trim() ?? '',
        'vehicleOwner': orderData['vehicleOwner']?.toString()?.trim() ?? '',
        'licensePlateNumber': orderData['licensePlateNumber']?.toString()?.trim() ?? '',
        'serviceType': orderData['serviceType']?.toString() ?? currentOrder.serviceType.toString().split('.').last.toUpperCase(),
      };

      // معالجة عنوان الاستلام
      if (orderData['pickupAddress'] != null) {
        final pickupData = orderData['pickupAddress'] as Map<String, dynamic>;
        updateData['pickupAddress'] = <String, dynamic>{
          'street': pickupData['street']?.toString()?.trim() ?? '',
          'houseNumber': pickupData['houseNumber']?.toString()?.trim() ?? '',
          'zipCode': pickupData['zipCode']?.toString()?.trim() ?? '',
          'city': pickupData['city']?.toString()?.trim() ?? '',
          'country': pickupData['country']?.toString()?.trim() ?? currentOrder.pickupAddress.country,
        };
      } else {
        updateData['pickupAddress'] = <String, dynamic>{
          'street': currentOrder.pickupAddress.street,
          'houseNumber': currentOrder.pickupAddress.houseNumber,
          'zipCode': currentOrder.pickupAddress.zipCode,
          'city': currentOrder.pickupAddress.city,
          'country': currentOrder.pickupAddress.country,
        };
      }

      // معالجة عنوان التسليم
      if (orderData['deliveryAddress'] != null) {
        final deliveryData = orderData['deliveryAddress'] as Map<String, dynamic>;
        updateData['deliveryAddress'] = <String, dynamic>{
          'street': deliveryData['street']?.toString()?.trim() ?? '',
          'houseNumber': deliveryData['houseNumber']?.toString()?.trim() ?? '',
          'zipCode': deliveryData['zipCode']?.toString()?.trim() ?? '',
          'city': deliveryData['city']?.toString()?.trim() ?? '',
          'country': deliveryData['country']?.toString()?.trim() ?? currentOrder.deliveryAddress.country,
        };
      } else {
        updateData['deliveryAddress'] = <String, dynamic>{
          'street': currentOrder.deliveryAddress.street,
          'houseNumber': currentOrder.deliveryAddress.houseNumber,
          'zipCode': currentOrder.deliveryAddress.zipCode,
          'city': currentOrder.deliveryAddress.city,
          'country': currentOrder.deliveryAddress.country,
        };
      }

      print('📤 ${'sending_data_to_server'.tr}...');
      print('📋 ${'final_data'.tr}: ${updateData.keys.join(', ')}');

      // إرسال التحديث للخادم باستخدام Map بدلاً من NewOrder
      final updatedOrder = await _orderService.updateOrderData(orderId, updateData);

      if (updatedOrder != null) {
        // تحديث الطلبية في القائمة المحلية
        final index = _orders.indexWhere((o) => o.id == orderId);
        if (index != -1) {
          _orders[index] = updatedOrder;
          print('✅ ${'order_updated_locally'.tr}');
        }

        // إشعار جميع الكونترولرز المهتمة بالتحديث
        _notifyOrderUpdate(updatedOrder);

        _showSuccessSnackbar('order_updated_success'.tr, 'all_changes_saved'.tr);
        return true;
      } else {
        throw Exception('updated_data_not_returned'.tr);
      }
    } catch (e) {
      final errorMessage = e.toString();
      _errorMessage.value = errorMessage;
      print('❌ ${'order_update_error'.tr}: $errorMessage');

      _showErrorSnackbar('failed_to_update_order'.tr, errorMessage);
      return false;
    } finally {
      _isCreating.value = false;
    }
  }

  void _notifyOrderUpdate(NewOrder updatedOrder) {
    try {
      // تحديث الطلب في القائمة المحلية أولاً
      final index = _orders.indexWhere((o) => o.id == updatedOrder.id);
      if (index != -1) {
        _orders[index] = updatedOrder;
        print('✅ ${'order_updated_dashboard'.tr}');
      }

      // إشعار OrderDetailsController إذا كان موجوداً
      if (Get.isRegistered<OrderDetailsController>()) {
        final detailsController = Get.find<OrderDetailsController>();
        if (detailsController.order?.id == updatedOrder.id) {
          print('🔄 ${'updating_details_controller'.tr}');
          detailsController.updateOrderData(updatedOrder);
        }
      }
    } catch (e) {
      print('⚠️ ${'notifying_controllers_error'.tr.replaceAll('error', e.toString())}');
    }
  }

  // إضافة دالة جديدة للحصول على طلب محدث من الخادم
  Future<void> refreshOrderById(String orderId) async {
    try {
      print('🔄 ${'refreshing_order'.tr.replaceAll('orderId', orderId)}');

      // الحصول على الطلب المحدث من الخادم
      final updatedOrder = await _orderService.getOrderById(orderId);

      if (updatedOrder != null) {
        final index = _orders.indexWhere((o) => o.id == orderId);
        if (index != -1) {
          _orders[index] = updatedOrder;
          print('✅ ${'order_updated_dashboard'.tr}');

          // إشعار OrderDetailsController إذا كان موجوداً
          if (Get.isRegistered<OrderDetailsController>()) {
            final detailsController = Get.find<OrderDetailsController>();
            if (detailsController.order?.id == orderId) {
              detailsController.updateOrderData(updatedOrder);
            }
          }
        }
      }
    } catch (e) {
      print('❌ ${'refresh_order_error'.tr.replaceAll('error', e.toString())}');
    }
  }

  // Upload signature
  Future<bool> uploadSignature({
    required String orderId,
    required Uint8List signatureBytes,
    required String signerName,
    required bool isDriver,
  }) async {
    try {
      final signature = await _orderService.uploadSignature(
        orderId: orderId,
        signatureBytes: signatureBytes,
        signerName: signerName.trim(),
        isDriver: isDriver,
      );

      if (signature != null) {
        final orderIndex = _orders.indexWhere((o) => o.id == orderId);
        if (orderIndex != -1) {
          final currentOrder = _orders[orderIndex];
          final updatedSignatures = List<OrderSignature>.from(currentOrder.signatures)..add(signature);
          _orders[orderIndex] = currentOrder.copyWith(signatures: updatedSignatures);
        }
        _showSuccessSnackbar('signature_saved_success'.tr, '');
        return true;
      }
      return false;
    } catch (e) {
      _showErrorSnackbar('signature_save_failed'.tr, e.toString());
      return false;
    }
  }

  // Upload expenses
  Future<bool> uploadExpenses({
    required String orderId,
    required double fuel,
    required double tollFees,
    required double parking,
    required String notes,
  }) async {
    try {
      final expenses = await _orderService.uploadExpenses(
        orderId: orderId,
        fuel: fuel,
        tollFees: tollFees,
        parking: parking,
        notes: notes.trim(),
      );

      if (expenses != null) {
        final orderIndex = _orders.indexWhere((o) => o.id == orderId);
        if (orderIndex != -1) {
          final currentOrder = _orders[orderIndex];
          _orders[orderIndex] = currentOrder.copyWith(expenses: expenses);
        }
        _showSuccessSnackbar('expenses_added_success'.tr, '');
        return true;
      }
      return false;
    } catch (e) {
      _showErrorSnackbar('expenses_add_failed'.tr, e.toString());
      return false;
    }
  }

  // Get order by ID
  NewOrder? getOrderById(String id) {
    try {
      if (id.isEmpty) return null;
      return _orders.firstWhere((order) => order.id == id);
    } catch (e) {
      return null;
    }
  }

  // Update order status
  Future<bool> updateOrderStatus(String orderId, String newStatus) async {
    try {
      _isCreating.value = true;
      _errorMessage.value = '';

      if (orderId.isEmpty) {
        throw Exception('order_id_required'.tr);
      }

      if (newStatus.isEmpty) {
        throw Exception('new_status_required'.tr);
      }

      final order = getOrderById(orderId);
      if (order == null) {
        throw Exception('order_not_found_locally'.tr);
      }

      print('📝 ${'updating_order_from_to'.tr.replaceAll('from', order.status).replaceAll('to', newStatus)}');

      // التحقق من صحة تدفق الحالات
      if (!_orderService.canUpdateStatus(order.status, newStatus)) {
        throw Exception('cannot_update_status'.tr.replaceAll(
          'from', _orderService.getStatusDisplayText(order.status)
        ).replaceAll('to', _orderService.getStatusDisplayText(newStatus))

        );
      }

      // إرسال طلب التحديث للخادم
      final updatedOrder = await _orderService.updateOrderStatus(
        orderId: orderId,
        newStatus: newStatus,
      );

      if (updatedOrder != null) {
        // تحديث الطلبية في القائمة المحلية
        final index = _orders.indexWhere((o) => o.id == orderId);
        if (index != -1) {
          _orders[index] = updatedOrder;
          print('✅ ${'order_updated_locally'.tr}');
        }

        // إشعار OrderDetailsController بالتحديث - إضافة جديدة
        _notifyOrderUpdate(updatedOrder);

        // عرض رسالة نجاح
        final statusText = _orderService.getStatusDisplayText(newStatus);
        _showSuccessSnackbar(
            'status_updated_success'.tr,
            'status_changed_to'.tr.replaceAll('status', statusText)
        );

        return true;
      } else {
        throw Exception('updated_data_not_returned'.tr);
      }
    } catch (e) {
      final errorMessage = e.toString();
      _errorMessage.value = errorMessage;
      print('❌ ${'order_status_update_error'.tr}: $errorMessage');

      _showErrorSnackbar(
          'failed_to_update_order_status'.tr,
          errorMessage
      );
      return false;
    } finally {
      _isCreating.value = false;
    }
  }

  // Delete order
  Future<bool> deleteOrder(String orderId) async {
    try {
      final success = await _orderService.deleteOrder(orderId);
      if (success) {
        _orders.removeWhere((o) => o.id == orderId);
        _showSuccessSnackbar('order_deleted_success'.tr, '');
        return true;
      }
      return false;
    } catch (e) {
      _showErrorSnackbar('failed_to_delete_order'.tr, e.toString());
      return false;
    }
  }

  void editOrder(NewOrder order) {
    if (!canEditOrder(order.id)) {
      Get.snackbar(
        'warning'.tr,
        'cannot_edit_order_status'.tr,
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.orange,
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );
      return;
    }

    // تمرير NewOrder مباشرة
    Get.toNamed(Routes.EDIT_ORDER, arguments: order)?.then((result) {
      if (result == true) {
        refreshOrders();
        Get.snackbar(
          'edit_success'.tr,
          'order_updated_all_saved'.tr,
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.green,
          colorText: Colors.white,
          duration: const Duration(seconds: 3),
        );
      }
    });
  }

  //  Confirm delete order
  Future<void> confirmDeleteOrder(NewOrder order, [NewOrderController? controller]) async {
    final confirmed = await Get.dialog<bool>(
      AlertDialog(
        title: Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.red.shade600),
            SizedBox(width: 8),
            Text('confirm_delete'.tr),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'delete_order_confirmation'.tr.replaceAll('client', order.client),
              style: TextStyle(fontWeight: FontWeight.w500),
            ),
            SizedBox(height: 12),
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.red.shade200),
              ),
              child: Text(
                'order_deleted_permanently'.tr,
                style: TextStyle(color: Colors.red.shade600),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: Text('cancel'.tr),
          ),
          ElevatedButton(
            onPressed: () => Get.back(result: true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: Text('delete'.tr),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final success = await deleteOrder(order.id);
      if (success) {
        Get.snackbar(
          'order_deleted_success'.tr,
          'order_deleted_success_detailed'.tr.replaceAll('client', order.client),
          backgroundColor: Colors.green,
          colorText: Colors.white,
          snackPosition: SnackPosition.TOP,
          duration: Duration(seconds: 3),
        );
      }
    }
  }

  // دوال إضافية من الكونترولر القديم

  // دالة للحصول على إحصائيات مفصلة عن الصور
  Map<String, dynamic> getImageStatistics(String orderId) {
    try {
      final order = getOrderById(orderId);
      if (order == null) {
        return {
          'totalImages': 0,
          'categoriesCount': <String, int>{},
          'hasImages': false,
        };
      }

      final images = order.images;
      final categoriesCount = <String, int>{};

      for (final image in images) {
        final categoryText = getImageCategoryText(image.category);
        categoriesCount[categoryText] = (categoriesCount[categoryText] ?? 0) + 1;
      }

      return {
        'totalImages': images.length,
        'categoriesCount': categoriesCount,
        'hasImages': images.isNotEmpty,
        'categories': categoriesCount.keys.toList(),
      };
    } catch (e) {
      print('❌ ${'image_statistics_error'.tr.replaceAll('error', e.toString())}');
      return {
        'totalImages': 0,
        'categoriesCount': <String, int>{},
        'hasImages': false,
        'error': e.toString(),
      };
    }
  }

  // دالة للحصول على الصور حسب الفئة
  List<OrderImage> getImagesByCategory(String orderId, ImageCategory category) {
    try {
      final order = getOrderById(orderId);
      if (order == null) return [];
      return order.images.where((image) => image.category == category).toList();
    } catch (e) {
      print('❌ ${'images_by_category_error'.tr.replaceAll('error', e.toString())}');
      return [];
    }
  }

  // دالة للتحقق من اكتمال متطلبات الصور
  Map<String, dynamic> checkImageRequirements(String orderId) {
    try {
      final order = getOrderById(orderId);
      if (order == null) {
        return {
          'isComplete': false,
          'missingCategories': [],
          'availableCategories': [],
          'error': 'order_not_found'.tr,
        };
      }

      final images = order.images;
      final availableCategories = images.map((img) => img.category).toSet();

      final requiredCategories = <ImageCategory>{
        ImageCategory.PICKUP,
        ImageCategory.DELIVERY,
      };

      final missingCategories = requiredCategories
          .where((cat) => !availableCategories.contains(cat))
          .toList();

      return {
        'isComplete': missingCategories.isEmpty,
        'missingCategories': missingCategories.map((cat) => getImageCategoryText(cat)).toList(),
        'availableCategories': availableCategories.map((cat) => getImageCategoryText(cat)).toList(),
        'totalImages': images.length,
        'requiredCount': requiredCategories.length,
        'availableCount': availableCategories.length,
      };
    } catch (e) {
      print('❌ ${'image_requirements_error'.tr.replaceAll('error', e.toString())}');
      return {
        'isComplete': false,
        'missingCategories': [],
        'availableCategories': [],
        'error': e.toString(),
      };
    }
  }

  // دالة مساعدة للتحقق من أن الطلبية جاهزة للإكمال
  bool isOrderReadyForCompletion(String orderId) {
    try {
      final order = getOrderById(orderId);
      if (order == null) return false;

      final imageReqs = checkImageRequirements(orderId);
      if (!(imageReqs['isComplete'] ?? false)) {
        print('⚠️ ${'order_not_ready_missing_images'.tr}');
        return false;
      }

      if (!order.hasAllSignatures) {
        print('⚠️ ${'order_not_ready_missing_signatures'.tr}');
        return false;
      }

      return true;
    } catch (e) {
      print('❌ ${'order_readiness_error'.tr.replaceAll('error', e.toString())}');
      return false;
    }
  }

  // Get completion percentage
  double getOrderCompletionPercentage(String orderId) {
    final order = getOrderById(orderId);
    if (order == null) return 0.0;

    double progress = 0.0;
    progress += 0.4; // Basic info - 40%

    if (order.hasImages) progress += 0.2; // Images - 20%

    if (order.hasDriverSignature && order.hasCustomerSignature) {
      progress += 0.3; // Complete signatures - 30%
    } else if (order.hasDriverSignature || order.hasCustomerSignature) {
      progress += 0.15; // Partial signatures - 15%
    }

    if (order.hasExpenses) progress += 0.1; // Expenses - 10%

    return progress;
  }

  // Get missing requirements for order completion
  List<String> getMissingRequirements(String orderId) {
    final order = getOrderById(orderId);
    if (order == null) return ['order_not_found'.tr];

    List<String> missing = [];

    if (!order.hasImages) missing.add('add_vehicle_photos_req'.tr);
    if (!order.hasDriverSignature) missing.add('driver_signature_req'.tr);
    if (!order.hasCustomerSignature) missing.add('customer_signature_req'.tr);
    if (!order.hasExpenses) missing.add('add_expenses_req'.tr);

    return missing;
  }

  // Mark order as completed with validation
  Future<bool> completeOrder(String orderId) async {
    try {
      final order = getOrderById(orderId);
      if (order == null) {
        throw Exception('order_not_found'.tr);
      }

      print('🔍 ${'checking_completion_requirements'.tr}: $orderId');

      // فحص المتطلبات
      final missingRequirements = <String>[];

      if (!order.hasImages) {
        missingRequirements.add('add_vehicle_photos_req'.tr);
      }

      if (!order.hasDriverSignature) {
        missingRequirements.add('driver_signature_req'.tr);
      }

      if (!order.hasCustomerSignature) {
        missingRequirements.add('customer_signature_req'.tr);
      }

      // إذا كانت هناك متطلبات ناقصة
      if (missingRequirements.isNotEmpty) {
        final missingText = missingRequirements.join('، ');

        // عدم إظهار snackbar إذا تم الاستدعاء من OrderDetailsController
        final isFromDetailsController = Get.isRegistered<OrderDetailsController>() &&
            Get.find<OrderDetailsController>().order?.id == orderId;

        if (!isFromDetailsController) {
          _showErrorSnackbar(
              'missing_requirements'.tr,
              'requirements_for_completion'.tr.replaceAll('requirements', missingText)
          );
        }

        return false;
      }

      // تحديث الحالة
      print('✅ ${'all_requirements_completed'.tr}');
      final success = await updateOrderStatus(orderId, 'completed');

      if (success) {
        // عدم إظهار snackbar إذا تم الاستدعاء من OrderDetailsController
        final isFromDetailsController = Get.isRegistered<OrderDetailsController>() &&
            Get.find<OrderDetailsController>().order?.id == orderId;

        if (!isFromDetailsController) {
          Future.delayed(Duration(milliseconds: 500), () {
            _showSuccessSnackbar(
                '🎉 ${'order_completed_success'.tr}',
                'order_completed_success_detailed'.tr.replaceAll('client', order.client)
            );
          });
        }
      }

      return success;
    } catch (e) {
      final error = e.toString();
      print('❌ ${'order_completion_error'.tr}: $error');

      // عدم إظهار snackbar error إذا تم الاستدعاء من OrderDetailsController
      final isFromDetailsController = Get.isRegistered<OrderDetailsController>() &&
          Get.find<OrderDetailsController>().order?.id == orderId;

      if (!isFromDetailsController) {
        Future.delayed(Duration(milliseconds: 500), () {
          _showErrorSnackbar('failed_to_complete_order'.tr, error);
        });
      }

      return false;
    }
  }

  // Start order processing
  Future<bool> startOrder(String orderId) async {
    try {
      final order = getOrderById(orderId);
      if (order == null) {
        throw Exception('order_not_found'.tr);
      }

      if (order.status.toLowerCase() != 'pending') {
        throw Exception('can_only_start_pending'.tr);
      }

      return await updateOrderStatus(orderId, 'in_progress');
    } catch (e) {
      final error = e.toString();
      print('❌ ${'order_start_error'.tr}: $error');
      _showErrorSnackbar('failed_to_start_order'.tr, error);
      return false;
    }
  }

  // Cancel order
  Future<bool> cancelOrder(String orderId) async {
    try {
      final order = getOrderById(orderId);
      if (order == null) {
        throw Exception('order_not_found'.tr);
      }

      final currentStatus = order.status.toLowerCase();
      if (currentStatus == 'completed') {
        throw Exception('cannot_cancel_completed'.tr);
      }

      if (currentStatus == 'cancelled') {
        throw Exception('order_already_cancelled'.tr);
      }

      // عرض تأكيد الإلغاء
      final confirmed = await Get.dialog<bool>(
        AlertDialog(
          title: Row(
            children: [
              Icon(Icons.cancel_outlined, color: Colors.red.shade600),
              SizedBox(width: 8),
              Text('confirm_cancellation'.tr),
            ],
          ),
          content: Text(
            'cancel_order_confirmation'.tr.replaceAll('client', order.client),
            style: TextStyle(height: 1.4),
          ),
          actions: [
            TextButton(
              onPressed: () => Get.back(result: false),
              child: Text('no_continue'.tr),
            ),
            ElevatedButton(
              onPressed: () => Get.back(result: true),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red.shade600,
              ),
              child: Text('yes_cancel_order'.tr, style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      );

      if (confirmed == true) {
        return await updateOrderStatus(orderId, 'cancelled');
      }

      return false;
    } catch (e) {
      final error = e.toString();
      print('❌ ${'order_cancellation_error'.tr}: $error');
      _showErrorSnackbar('failed_to_cancel_order'.tr, error);
      return false;
    }
  }

  // دالة للتحقق من إمكانية تحديث الحالة
  bool canUpdateOrderStatus(String orderId, String newStatus) {
    final order = getOrderById(orderId);
    if (order == null) return false;

    return _orderService.canUpdateStatus(order.status, newStatus);
  }

// دالة للحصول على الحالات المسموح بالانتقال إليها
  List<String> getAllowedStatusTransitions(String orderId) {
    final order = getOrderById(orderId);
    if (order == null) return [];

    final currentStatus = order.status.toLowerCase();

    switch (currentStatus) {
      case 'pending':
        return ['in_progress', 'cancelled'];
      case 'in_progress':
        return ['completed', 'cancelled'];
      case 'completed':
      case 'cancelled':
      default:
        return [];
    }
  }

  // Get orders by status
  List<NewOrder> getOrdersByStatus(String status) {
    try {
      final currentUserId = _authController.currentUserId;
      if (currentUserId == null) return [];

      return _orders
          .where((order) =>
      order.driverId == currentUserId &&
          order.status.toLowerCase() == status.toLowerCase())
          .toList();
    } catch (e) {
      print('❌ ${'get_orders_by_status_error'.tr}: $e');
      return [];
    }
  }

  // Get recent orders (last 7 days)
  List<NewOrder> getRecentOrders() {
    try {
      final currentUserId = _authController.currentUserId;
      if (currentUserId == null) return [];

      final sevenDaysAgo = DateTime.now().subtract(const Duration(days: 7));

      return _orders
          .where((order) =>
      order.driverId == currentUserId &&
          order.createdAt.isAfter(sevenDaysAgo))
          .toList();
    } catch (e) {
      print('❌ ${'get_recent_orders_error'.tr}: $e');
      return [];
    }
  }

  // Check if user is authenticated
  bool get isAuthenticated {
    final currentUserId = _authController.currentUserId;
    return currentUserId != null && currentUserId.isNotEmpty;
  }

  // Get error message for display
  String get displayErrorMessage {
    if (_errorMessage.value.isEmpty) return '';

    final error = _errorMessage.value.toLowerCase();

    if (error.contains('network') || error.contains('connection')) {
      return 'connection_problem'.tr;
    } else if (error.contains('timeout')) {
      return 'connection_timeout'.tr;
    } else if (error.contains('unauthorized') || error.contains('authentication')) {
      return 'login_again'.tr;
    } else if (error.contains('not found')) {
      return 'data_not_found'.tr;
    } else {
      return _errorMessage.value;
    }
  }

  // Private helper methods
  String? _validateOrderData({
    required String client,
    required String vehicleOwner,
    required String licensePlateNumber,
    required String pickupStreet,
    required String pickupCity,
    required String deliveryStreet,
    required String deliveryCity,
  }) {
    if (client.trim().isEmpty) return 'client_name_required'.tr;
    if (vehicleOwner.trim().isEmpty) return 'vehicle_owner_name_required'.tr;
    if (licensePlateNumber.trim().isEmpty) return 'vehicle_plate_required'.tr;
    if (pickupStreet.trim().isEmpty || pickupCity.trim().isEmpty) return 'pickup_address_required'.tr;
    if (deliveryStreet.trim().isEmpty || deliveryCity.trim().isEmpty) return 'delivery_address_required'.tr;
    return null;
  }

  // Update search query
  void updateSearchQuery(String query) {
    _searchQuery.value = query.trim();
  }

  // Update status filter
  void updateStatusFilter(String status) {
    _statusFilter.value = status;
  }

  // Refresh orders
  Future<void> refreshOrders() async {
    await loadOrders();
    Get.snackbar(
      'orders_refreshed'.tr,
      'orders_list_updated'.tr,
      backgroundColor: Colors.blue,
      colorText: Colors.white,
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 2),
    );
  }

  // Clear filters
  void clearFilters() {
    _searchQuery.value = '';
    _statusFilter.value = 'all';
  }

  // Clear error
  void clearError() {
    _errorMessage.value = '';
  }

  // Helper methods
  String getServiceTypeText(ServiceType serviceType) {
    return _orderService.getServiceTypeText(serviceType);
  }

  String getImageCategoryText(ImageCategory category) {
    return _orderService.getImageCategoryText(category);
  }

  Color getStatusColor(String status) {
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

  String getStatusText(String status) {
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

  bool canEditOrder(String orderId) {
    final order = getOrderById(orderId);
    if (order == null) return false;
    final status = order.status.toLowerCase();
    return status != 'completed' && status != 'cancelled';
  }

  bool canCancelOrder(String orderId) {
    final order = getOrderById(orderId);
    if (order == null) return false;
    return order.status.toLowerCase() == 'pending';
  }

  // Snackbar helpers
  void _showSnackbar(String title, String message, Color color) {
    // إغلاق أي snackbar مفتوح
    if (Get.isSnackbarOpen) {
      Get.closeCurrentSnackbar();
    }

    // انتظار قصير ثم عرض الرسالة الجديدة
    Future.delayed(Duration(milliseconds: 200), () {
      if (!Get.isSnackbarOpen) { // التأكد من عدم وجود snackbar مفتوح
        Get.snackbar(
          title,
          message,
          backgroundColor: color,
          colorText: Colors.white,
          duration: Duration(seconds: color == Colors.red ? 6 : 4),
          margin: const EdgeInsets.all(10),
          borderRadius: 8,
          snackPosition: SnackPosition.TOP,
          maxWidth: Get.width * 0.95,
          icon: Icon(
            color == Colors.red ? Icons.error : Icons.check_circle,
            color: Colors.white,
          ),
          shouldIconPulse: false,
          mainButton: TextButton(
            onPressed: () => Get.closeCurrentSnackbar(),
            child: Text('close'.tr, style: TextStyle(color: Colors.white)),
          ),
        );
      }
    });
  }

  void _showSuccessSnackbar(String title, String message) {
    _showSnackbar(title, message, Colors.green);
  }

  void _showErrorSnackbar(String title, String message) {
    _showSnackbar(title, message, Colors.red);
  }

  Future<void> sendEmailReport(NewOrder order) async {
    try {
      // تفترض وجود دالة في الـ NewOrderService لإرسال البريد (حسب المثال السابق)
      bool success = await _orderService.sendOrderReportEmail(order.id, order.clientEmail);
      if (success) {
        // عرض رسالة نجاح، يمكنك استخدام Get.snackbar أو أي طريقة تفضلها
        Get.snackbar('success'.tr, 'email_report_success'.tr);
      } else {
        Get.snackbar('error'.tr, 'email_report_failed'.tr);
      }
    } catch (e) {
      Get.snackbar('error'.tr, 'email_send_error'.tr.replaceAll('error', e.toString()));
    }
  }

  @override
  void onClose() {
    _orders.clear();
    super.onClose();
  }
}
