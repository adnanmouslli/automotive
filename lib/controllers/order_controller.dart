import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import '../models/new_address.dart';
import '../models/new_order.dart';
import '../routes/app_pages.dart';
import '../services/order_service.dart';
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
      if (currentUserId.isEmpty) {
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
    return _orders.where((o) => o.driverId == currentUserId).length;
  }

  int get pendingOrders {
    final currentUserId = _authController.currentUserId;
    return _orders.where((o) => o.driverId == currentUserId && o.status == 'pending').length;
  }

  int get inProgressOrders {
    final currentUserId = _authController.currentUserId;
    return _orders.where((o) => o.driverId == currentUserId && o.status == 'in_progress').length;
  }

  int get completedOrders {
    final currentUserId = _authController.currentUserId;
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

  // Create basic order - تم تحديثها لدعم بيانات صاحب الفاتورة
  // تحديث دالة createBasicOrder في NewOrderController

  Future<String?> createBasicOrder({
    required String client,
    required String clientPhone,
    required String clientEmail,
    NewAddress? clientAddress,
    required String description,
    required String vehicleOwner,
    required String licensePlateNumber,

    // بيانات السيارة الإضافية
    String? vin,
    String? brand,
    String? model,
    int? year,
    String? color,

    // الحقول الجديدة
    String? ukz,
    String? fin,
    String? bestellnummer,
    String? leasingvertragsnummer,
    String? kostenstelle,
    String? bemerkung,
    String? typ,

    required NewAddress pickupAddress,
    required NewAddress deliveryAddress,
    ServiceType serviceType = ServiceType.TRANSPORT,

    // بيانات صاحب الفاتورة
    bool isSameBilling = true,
    String? billingName,
    String? billingPhone,
    String? billingEmail,
    NewAddress? billingAddress,

    // الأغراض - تغيير النوع
    List<VehicleItem>? items,
    List<VehicleDamage>? damages,

  }) async {
    try {
      _isCreating.value = true;
      _errorMessage.value = '';

      // التحقق من صحة البيانات
      final validationError = _validateOrderData(
        client: client,
        vehicleOwner: vehicleOwner,
        licensePlateNumber: licensePlateNumber,
        pickupAddress: pickupAddress,
        deliveryAddress: deliveryAddress,
        clientAddress: clientAddress,
        isSameBilling: isSameBilling,
        billingName: billingName,
        billingPhone: billingPhone,
        billingEmail: billingEmail,
        billingAddress: billingAddress,
      );

      if (validationError != null) {
        throw Exception(validationError);
      }

      final currentUserId = _authController.currentUserId;
      if (currentUserId == null || currentUserId.isEmpty) {
        throw Exception('must_login_first'.tr);
      }

      print('📤 ${'creating_new_order'.tr}...');

      // تحويل الأغراض إلى List<String> قبل إنشاء الطلب
      final List<String> itemsAsStrings = (items ?? [])
          .map((item) => item.toString().split('.').last)
          .toList();

      print('🔍 الأغراض المحولة: $itemsAsStrings');

      final order = NewOrder(
        id: '',
        client: client.trim(),
        clientPhone: clientPhone.trim(),
        clientEmail: clientEmail.trim(),
        clientAddress: clientAddress,
        description: description.trim(),
        vehicleOwner: vehicleOwner.trim(),
        licensePlateNumber: licensePlateNumber.trim(),

        // بيانات السيارة الإضافية
        vin: vin?.trim() ?? '',
        brand: brand?.trim() ?? '',
        model: model?.trim() ?? '',
        year: year ?? 0,
        color: color?.trim() ?? '',

        // الحقول الجديدة
        ukz: ukz?.trim() ?? '',
        fin: fin?.trim() ?? '',
        bestellnummer: bestellnummer?.trim() ?? '',
        leasingvertragsnummer: leasingvertragsnummer?.trim() ?? '',
        kostenstelle: kostenstelle?.trim() ?? '',
        bemerkung: bemerkung?.trim() ?? '',
        typ: typ?.trim() ?? '',

        serviceType: serviceType,

        // بيانات صاحب الفاتورة
        isSameBilling: isSameBilling,
        billingName: isSameBilling ? null : billingName?.trim(),
        billingPhone: isSameBilling ? null : billingPhone?.trim(),
        billingEmail: isSameBilling ? null : billingEmail?.trim(),
        billingAddress: isSameBilling ? null : billingAddress,

        // استخدام الأغراض المحولة
        items: items ?? [], // سيتم التعامل معها في toJson

        pickupAddress: pickupAddress,
        deliveryAddress: deliveryAddress,
        driverId: currentUserId,

        damages: damages ?? [],

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
      print('❌ تفاصيل الخطأ: $e');
      return null;
    } finally {
      _isCreating.value = false;
    }
  }

  // Update order details with validation - تم تحديثها لدعم بيانات صاحب الفاتورة
  Future<bool> updateOrderDetails({
    required String orderId,
    required String client,
    required String clientPhone,
    required String clientEmail,
    String? clientAddress, // جديد
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
    // بيانات صاحب الفاتورة الجديدة
    bool? isSameBilling,
    String? billingName,
    String? billingPhone,
    String? billingEmail,
    String? billingAddress,
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
        'clientAddress': clientAddress?.trim(), // جديد
        'description': description.trim(),
        'vehicleOwner': vehicleOwner.trim(),
        'licensePlateNumber': licensePlateNumber.trim(),
        'comments': comments?.trim() ?? currentOrder.comments,
        // بيانات صاحب الفاتورة
        'isSameBilling': isSameBilling ?? currentOrder.isSameBilling,
        'billingName': billingName?.trim(),
        'billingPhone': billingPhone?.trim(),
        'billingEmail': billingEmail?.trim(),
        'billingAddress': billingAddress?.trim(),
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

  // Update full order with validation - تم تحديثها لدعم بيانات صاحب الفاتورة
  Future<bool> updateFullOrder({
    required String orderId,
    required Map<String, dynamic> orderData,
  }) async {
    try {
      _isCreating.value = true;
      _errorMessage.value = '';

      print('🔄 ${'starting_order_update'.tr}: $orderId');
      print('📊 ${'incoming_data'.tr}: ${orderData.keys.join(', ')}');

      // التحقق من وجود الأضرار في البيانات الواردة
      if (orderData.containsKey('damages')) {
        print('✅ الأضرار موجودة في البيانات الواردة');
        print('📊 عدد الأضرار: ${(orderData['damages'] as List).length}');
        for (int i = 0; i < (orderData['damages'] as List).length; i++) {
          print('📊 ضرر ${i + 1}: ${(orderData['damages'] as List)[i]}');
        }
      } else {
        print('⚠️ لا توجد أضرار في البيانات الواردة');
      }

      final currentOrder = getOrderById(orderId);
      if (currentOrder == null) {
        throw Exception('order_not_found_locally'.tr);
      }

      // تحضير البيانات للإرسال مع دعم جميع الحقول الجديدة
      final Map<String, dynamic> updateData = {
        // البيانات الأساسية
        'client': orderData['client']?.toString()?.trim() ?? '',
        'clientPhone': orderData['clientPhone']?.toString()?.trim() ?? '',
        'clientEmail': orderData['clientEmail']?.toString()?.trim() ?? '',
        'description': orderData['description']?.toString()?.trim() ?? '',
        'comments': orderData['comments']?.toString()?.trim() ?? '',
        'vehicleOwner': orderData['vehicleOwner']?.toString()?.trim() ?? '',
        'licensePlateNumber': orderData['licensePlateNumber']?.toString()?.trim() ?? '',
        'serviceType': orderData['serviceType']?.toString() ?? currentOrder.serviceType.toString().split('.').last.toUpperCase(),

        // ===== الحقول الجديدة - معالجة شاملة =====

        // بيانات صاحب الفاتورة
        'isSameBilling': orderData['isSameBilling'] ?? currentOrder.isSameBilling,
        'billingName': orderData['billingName']?.toString()?.trim(),
        'billingPhone': orderData['billingPhone']?.toString()?.trim(),
        'billingEmail': orderData['billingEmail']?.toString()?.trim(),

        // الحقول الإضافية للسيارة
        'ukz': orderData['ukz']?.toString()?.trim() ?? currentOrder.ukz,
        'fin': orderData['fin']?.toString()?.trim() ?? currentOrder.fin,
        'bestellnummer': orderData['bestellnummer']?.toString()?.trim() ?? currentOrder.bestellnummer,
        'leasingvertragsnummer': orderData['leasingvertragsnummer']?.toString()?.trim() ?? currentOrder.leasingvertragsnummer,
        'kostenstelle': orderData['kostenstelle']?.toString()?.trim() ?? currentOrder.kostenstelle,
        'bemerkung': orderData['bemerkung']?.toString()?.trim() ?? currentOrder.bemerkung,
        'typ': orderData['typ']?.toString()?.trim() ?? currentOrder.typ,

        // الأغراض
        'items': orderData['items'] ?? currentOrder.items.map((item) => item.toString().split('.').last).toList(),
      };

      // معالجة عنوان العميل
      if (orderData['clientAddress'] != null) {
        final clientAddressData = orderData['clientAddress'] as Map<String, dynamic>;
        updateData['clientAddress'] = {
          'street': clientAddressData['street']?.toString()?.trim() ?? '',
          'houseNumber': clientAddressData['houseNumber']?.toString()?.trim() ?? '',
          'zipCode': clientAddressData['zipCode']?.toString()?.trim() ?? '',
          'city': clientAddressData['city']?.toString()?.trim() ?? '',
          'country': clientAddressData['country']?.toString()?.trim() ?? 'Deutschland',
        };
      } else if (currentOrder.clientAddress != null) {
        updateData['clientAddress'] = currentOrder.clientAddress!.toJson();
      }

      // معالجة عنوان صاحب الفاتورة
      if (orderData['billingAddress'] != null) {
        final billingAddressData = orderData['billingAddress'] as Map<String, dynamic>;
        updateData['billingAddress'] = {
          'street': billingAddressData['street']?.toString()?.trim() ?? '',
          'houseNumber': billingAddressData['houseNumber']?.toString()?.trim() ?? '',
          'zipCode': billingAddressData['zipCode']?.toString()?.trim() ?? '',
          'city': billingAddressData['city']?.toString()?.trim() ?? '',
          'country': billingAddressData['country']?.toString()?.trim() ?? 'Deutschland',
        };
      } else if (currentOrder.billingAddress != null) {
        updateData['billingAddress'] = currentOrder.billingAddress!.toJson();
      }

      // معالجة عنوان الاستلام مع الحقول الجديدة
      if (orderData['pickupAddress'] != null) {
        final pickupData = orderData['pickupAddress'] as Map<String, dynamic>;
        updateData['pickupAddress'] = {
          'street': pickupData['street']?.toString()?.trim() ?? '',
          'houseNumber': pickupData['houseNumber']?.toString()?.trim() ?? '',
          'zipCode': pickupData['zipCode']?.toString()?.trim() ?? '',
          'city': pickupData['city']?.toString()?.trim() ?? '',
          'country': pickupData['country']?.toString()?.trim() ?? currentOrder.pickupAddress.country,

          // الحقول الجديدة للعنوان
          'date': pickupData['date']?.toString(),
          'companyName': pickupData['companyName']?.toString()?.trim(),
          'contactPersonName': pickupData['contactPersonName']?.toString()?.trim(),
          'contactPersonPhone': pickupData['contactPersonPhone']?.toString()?.trim(),
          'contactPersonEmail': pickupData['contactPersonEmail']?.toString()?.trim(),
          'fuelLevel': pickupData['fuelLevel'] is int ? pickupData['fuelLevel'] :
          (pickupData['fuelLevel'] != null ? int.tryParse(pickupData['fuelLevel'].toString()) : null),
          'fuelMeter': pickupData['fuelMeter'] is double ? pickupData['fuelMeter'] :
          (pickupData['fuelMeter'] != null ? double.tryParse(pickupData['fuelMeter'].toString()) : null),
        };
      } else {
        updateData['pickupAddress'] = currentOrder.pickupAddress.toJson();
      }

      // معالجة عنوان التسليم مع الحقول الجديدة
      if (orderData['deliveryAddress'] != null) {
        final deliveryData = orderData['deliveryAddress'] as Map<String, dynamic>;
        updateData['deliveryAddress'] = {
          'street': deliveryData['street']?.toString().trim() ?? '',
          'houseNumber': deliveryData['houseNumber']?.toString().trim() ?? '',
          'zipCode': deliveryData['zipCode']?.toString().trim() ?? '',
          'city': deliveryData['city']?.toString().trim() ?? '',
          'country': deliveryData['country']?.toString().trim() ?? currentOrder.deliveryAddress.country,

          // الحقول الجديدة للعنوان
          'date': deliveryData['date']?.toString(),
          'companyName': deliveryData['companyName']?.toString()?.trim(),
          'contactPersonName': deliveryData['contactPersonName']?.toString()?.trim(),
          'contactPersonPhone': deliveryData['contactPersonPhone']?.toString()?.trim(),
          'contactPersonEmail': deliveryData['contactPersonEmail']?.toString()?.trim(),
          'fuelLevel': deliveryData['fuelLevel'] is int ? deliveryData['fuelLevel'] :
          (deliveryData['fuelLevel'] != null ? int.tryParse(deliveryData['fuelLevel'].toString()) : null),
          'fuelMeter': deliveryData['fuelMeter'] is double ? deliveryData['fuelMeter'] :
          (deliveryData['fuelMeter'] != null ? double.tryParse(deliveryData['fuelMeter'].toString()) : null),
        };
      } else {
        updateData['deliveryAddress'] = currentOrder.deliveryAddress.toJson();
      }

      // ===== معالجة الأضرار - هذا هو الإصلاح الرئيسي! =====
      if (orderData['damages'] != null && orderData['damages'] is List) {
        final damagesData = orderData['damages'] as List;
        print('🔧 معالجة ${damagesData.length} ضرر...');

        updateData['damages'] = damagesData.map((damage) {
          if (damage is Map<String, dynamic>) {
            final processedDamage = {
              'side': damage['side']?.toString()?.toUpperCase() ?? 'FRONT',
              'type': damage['type']?.toString()?.toUpperCase() ?? 'DENT_BUMP',
              'description': damage['description']?.toString()?.trim(),
            };
            print('🔧 ضرر مُعالج: $processedDamage');
            return processedDamage;
          }
          return damage;
        }).toList();

        print('✅ تم معالجة ${(updateData['damages'] as List).length} ضرر');
      } else {
        // إذا لم تكن هناك أضرار في البيانات الجديدة، استخدم الموجودة
        updateData['damages'] = currentOrder.damages.map((damage) => {
          'side': _convertVehicleSideForBackend(damage.side),
          'type': _convertDamageTypeForBackend(damage.type),
          'description': damage.description,
        }).toList();
        print('📋 استخدام الأضرار الموجودة: ${(updateData['damages'] as List).length}');
      }

      print('📤 ${'sending_data_to_server'.tr}...');
      print('📋 ${'final_data'.tr}: ${updateData.keys.join(', ')}');

      // التحقق النهائي من وجود الأضرار قبل الإرسال
      if (updateData.containsKey('damages')) {
        print('✅ الأضرار موجودة في البيانات النهائية');
        print('📊 عدد الأضرار: ${(updateData['damages'] as List).length}');
      } else {
        print('❌ الأضرار مفقودة من البيانات النهائية!');
      }

      // إرسال التحديث للخادم
      final updatedOrder = await _orderService.updateOrderData(orderId, updateData);

      if (updatedOrder != null) {
        final index = _orders.indexWhere((o) => o.id == orderId);
        if (index != -1) {
          _orders[index] = updatedOrder;
          print('✅ ${'order_updated_locally'.tr}');
        }

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

  // Private helper methods - تم تحديثها لدعم بيانات صاحب الفاتورة
  String? _validateOrderData({
    required String client,
    required String vehicleOwner,
    required String licensePlateNumber,

    required NewAddress pickupAddress,
    required NewAddress deliveryAddress,

    NewAddress? clientAddress, // تم التغيير
    bool isSameBilling = true,
    String? billingName,
    String? billingPhone,
    String? billingEmail,
    NewAddress? billingAddress, // تم التغيير
  }) {
    if (client.trim().isEmpty) return 'client_name_required'.tr;
    if (vehicleOwner.trim().isEmpty) return 'vehicle_owner_name_required'.tr;
    if (licensePlateNumber.trim().isEmpty) return 'vehicle_plate_required'.tr;

    if (!_isValidAddress(pickupAddress)) return 'pickup_address_required'.tr;
    if (!_isValidAddress(deliveryAddress)) return 'delivery_address_required'.tr;

    // التحقق من بيانات صاحب الفاتورة إذا لم يكن نفس العميل
    if (!isSameBilling) {
      if (billingName == null || billingName.trim().isEmpty) return 'billing_name_required'.tr;
      if (billingPhone == null || billingPhone.trim().isEmpty) return 'billing_phone_required'.tr;
      if (billingEmail == null || billingEmail.trim().isEmpty) return 'billing_email_required'.tr;
      if (billingAddress == null || !_isValidAddress(billingAddress)) return 'billing_address_required'.tr;
    }

    return null;
  }

  // دالة مساعدة للحصول على نص الغرض
  String getVehicleItemText(VehicleItem item) {
    switch (item) {
      case VehicleItem.PARTITION_NET:
        return 'partition_net'.tr;
      case VehicleItem.WINTER_TIRES:
        return 'winter_tires'.tr;
      case VehicleItem.HUBCAPS:
        return 'hubcaps'.tr;
      case VehicleItem.REAR_PARCEL_SHELF:
        return 'rear_parcel_shelf'.tr;
      case VehicleItem.NAVIGATION_SYSTEM:
        return 'navigation_system'.tr;
      case VehicleItem.TRUNK_ROLL_COVER:
        return 'trunk_roll_cover'.tr;
      case VehicleItem.SAFETY_VEST:
        return 'safety_vest'.tr;
      case VehicleItem.VEHICLE_KEYS:
        return 'vehicle_keys'.tr;
      case VehicleItem.WARNING_TRIANGLE:
        return 'warning_triangle'.tr;
      case VehicleItem.RADIO:
        return 'radio'.tr;
      case VehicleItem.ALLOY_WHEELS:
        return 'alloy_wheels'.tr;
      case VehicleItem.SUMMER_TIRES:
        return 'summer_tires'.tr;
      case VehicleItem.OPERATING_MANUAL:
        return 'operating_manual'.tr;
      case VehicleItem.REGISTRATION_DOCUMENT:
        return 'registration_document'.tr;
      case VehicleItem.COMPRESSOR_REPAIR_KIT:
        return 'compressor_repair_kit'.tr;
      case VehicleItem.TOOLS_JACK:
        return 'tools_jack'.tr;
      case VehicleItem.SECOND_SET_OF_TIRES:
        return 'second_set_of_tires'.tr;
      case VehicleItem.EMERGENCY_WHEEL:
        return 'emergency_wheel'.tr;
      case VehicleItem.ANTENNA:
        return 'antenna'.tr;
      case VehicleItem.FUEL_CARD:
        return 'fuel_card'.tr;
      case VehicleItem.FIRST_AID_KIT:
        return 'first_aid_kit'.tr;
      case VehicleItem.SPARE_TIRE:
        return 'spare_tire'.tr;
      case VehicleItem.SERVICE_BOOK:
        return 'service_book'.tr;
      default:
        return item
            .toString()
            .split('.')
            .last;
    }
  }


  bool _isValidAddress(NewAddress address) {
    return address.street.trim().isNotEmpty &&
        address.city.trim().isNotEmpty;
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


  // طلب إدخال البريد الإلكتروني من المستخدم
  Future<String?> _requestEmailInput(NewOrder order) async {
    final TextEditingController emailController = TextEditingController();
    final RxString emailError = ''.obs;

    return await Get.dialog<String>(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.email_outlined, color: Colors.blue.shade600, size: 22),
            SizedBox(width: 8),
            Text('enter_email_address'.tr),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'no_email_found_for_client'.tr.replaceAll('client', order.client),
              style: TextStyle(fontSize: 14, height: 1.4),
            ),
            SizedBox(height: 16),
            Obx(() => TextField(
              controller: emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                labelText: 'email_address'.tr,
                hintText: 'example@company.com',
                prefixIcon: Icon(Icons.email_outlined),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                errorText: emailError.value.isEmpty ? null : emailError.value,
              ),
              onChanged: (value) => emailError.value = '',
            )),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text('cancel'.tr),
          ),
          Obx(() => ElevatedButton(
            onPressed: emailController.text.trim().isEmpty ? null : () {
              final email = emailController.text.trim();
              if (_isValidEmail(email)) {
                Get.back(result: email);
              } else {
                emailError.value = 'invalid_email_format'.tr;
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue.shade600,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: Text('continue'.tr, style: TextStyle(color: Colors.white)),
          )),
        ],
      ),
    );
  }


  // تنفيذ الإرسال الفعلي
  Future<void> _executeEmailSend(NewOrder order, String email) async {
    // عرض مؤشر تحميل
    Get.dialog(
      WillPopScope(
        onWillPop: () async => false,
        child: Center(
          child: Container(
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(color: Colors.blue.shade600),
                SizedBox(height: 16),
                Text('sending_report_email'.tr, style: TextStyle(fontSize: 14)),
                SizedBox(height: 8),
                Text(
                  email,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.blue.shade600,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      barrierDismissible: false,
    );

    try {
      // إرسال التقرير
      final result = await _orderService.sendOrderHtmlReportByEmail(order.id!, email);

      // إغلاق مؤشر التحميل
      if (Get.isDialogOpen == true) {
        Get.back();
      }

      // عرض النتيجة
      if (result.success) {
        await _showEmailSuccessDialog(result, order);
      } else {
        await _showEmailFailureDialog(result, order, email);
      }

    } catch (e) {
      // إغلاق مؤشر التحميل في حالة الخطأ
      if (Get.isDialogOpen == true) {
        Get.back();
      }

      await _showEmailErrorDialog(e.toString(), order, email);
    }
  }

  // عرض dialog نجاح الإرسال
  Future<void> _showEmailSuccessDialog(EmailReportResult result, NewOrder order) async {
    await Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green.shade600, size: 24),
            SizedBox(width: 8),
            Text('email_sent_successfully'.tr),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'report_send_successfully_message'.tr,
              style: TextStyle(fontSize: 14, height: 1.4),
            ),
            SizedBox(height: 16),
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
                  _buildInfoRow(Icons.email, 'sent_to'.tr, result.email, Colors.green.shade600),
                  SizedBox(height: 6),
                  _buildInfoRow(Icons.access_time, 'sent_at'.tr,
                      _formatDateTime(result.timestamp), Colors.green.shade600),
                  if (result.message.isNotEmpty) ...[
                    SizedBox(height: 6),
                    Text(
                      result.message,
                      style: TextStyle(
                        color: Colors.green.shade700,
                        fontSize: 12,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Get.back(),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green.shade600,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: Text('excellent'.tr, style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );


  }

  // عرض dialog فشل الإرسال
  Future<void> _showEmailFailureDialog(EmailReportResult result, NewOrder order, String email) async {
    await Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.error_outline, color: Colors.red.shade600, size: 24),
            SizedBox(width: 8),
            Text('email_send_failed'.tr),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'report_send_failed_message'.tr,
              style: TextStyle(fontSize: 14, height: 1.4),
            ),
            SizedBox(height: 16),
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.red.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'error_details'.tr,
                    style: TextStyle(
                      color: Colors.red.shade700,
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    result.message.isNotEmpty ? result.message : 'unknown_error'.tr,
                    style: TextStyle(color: Colors.red.shade700, fontSize: 12),
                  ),
                  if (result.error != null) ...[
                    SizedBox(height: 8),
                    ExpansionTile(
                      title: Text(
                        'technical_details'.tr,
                        style: TextStyle(fontSize: 12, color: Colors.red.shade600),
                      ),
                      children: [
                        Container(
                          width: double.infinity,
                          padding: EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.red.shade100,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            result.error!,
                            style: TextStyle(
                              fontSize: 11,
                              fontFamily: 'monospace',
                              color: Colors.red.shade700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text('ok'.tr),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              _executeEmailSend(order, email); // إعادة المحاولة
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue.shade600,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: Text('retry'.tr, style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  // عرض dialog خطأ في الاتصال
  Future<void> _showEmailErrorDialog(String error, NewOrder order, String email) async {
    await Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.wifi_off, color: Colors.orange.shade600, size: 24),
            SizedBox(width: 8),
            Text('connection_error'.tr),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'email_connection_error_occurred'.tr,
              style: TextStyle(fontSize: 14, height: 1.4),
            ),
            SizedBox(height: 16),
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.orange.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.orange.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'suggested_solutions'.tr,
                    style: TextStyle(
                      color: Colors.orange.shade700,
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                  SizedBox(height: 8),
                  _buildSolutionItem('check_internet_connection'.tr),
                  _buildSolutionItem('verify_email_address'.tr),
                  _buildSolutionItem('try_again_later'.tr),
                  _buildSolutionItem('contact_support_if_persists'.tr),
                ],
              ),
            ),
            SizedBox(height: 12),
            ExpansionTile(
              title: Text(
                'technical_error_details'.tr,
                style: TextStyle(fontSize: 13, color: Colors.grey.shade700),
              ),
              children: [
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    error,
                    style: TextStyle(
                      fontSize: 11,
                      fontFamily: 'monospace',
                      color: Colors.grey.shade700,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text('cancel'.tr),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              _executeEmailSend(order, email); // إعادة المحاولة
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue.shade600,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: Text('retry'.tr, style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  // دالة مساعدة لبناء عنصر الحل المقترح
  Widget _buildSolutionItem(String solution) {
    return Padding(
      padding: EdgeInsets.only(bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '• ',
            style: TextStyle(color: Colors.orange.shade700, fontSize: 12),
          ),
          Expanded(
            child: Text(
              solution,
              style: TextStyle(color: Colors.orange.shade700, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  // دالة مساعدة لبناء صف معلومات
  Widget _buildInfoRow(IconData icon, String label, String value, [Color? color]) {
    final iconColor = color ?? Colors.blue.shade600;
    final textColor = color ?? Colors.blue.shade700;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: iconColor, size: 16),
        SizedBox(width: 6),
        Text(
          '$label: ',
          style: TextStyle(
            color: textColor,
            fontWeight: FontWeight.w600,
            fontSize: 12,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              color: textColor,
              fontSize: 12,
            ),
          ),
        ),
      ],
    );
  }

  // دالة مساعدة للتحقق من صحة البريد الإلكتروني
  bool _isValidEmail(String email) {
    // final emailRegex = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+);
    //     return emailRegex.test(email.trim());
    return true;
  }

  // دالة مساعدة لتنسيق التاريخ والوقت
  String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 1) {
      return 'just_now'.tr;
    } else if (difference.inHours < 1) {
      return 'minutes_ago'.tr.replaceAll('count', difference.inMinutes.toString());
    } else if (difference.inDays < 1) {
      return 'hours_ago'.tr.replaceAll('count', difference.inHours.toString());
    } else {
      return '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
    }
  }

  // توليد تقرير PDF محسن
  Future<void> generatePdfReport(String orderId) async {
    try {
      _isCreating.value = true;


      // توليد التقرير
      final pdfBytes = await _orderService.generateOrderPdfReport(orderId);

      // إغلاق مؤشر التحميل
      if (Get.isDialogOpen == true) {
        Get.back();
      }

      // حفظ وعرض التقرير
      await _saveAndDisplayPdfReport(pdfBytes, orderId);

    } catch (e) {
      // إغلاق مؤشر التحميل في حالة الخطأ
      if (Get.isDialogOpen == true) {
        Get.back();
      }

      _showErrorSnackbar('pdf_report_generation_failed'.tr, e.toString());
      print('❌ خطأ في توليد PDF: $e');
    } finally {
      _isCreating.value = false;
    }
  }

  // حفظ وعرض تقرير PDF
  Future<void> _saveAndDisplayPdfReport(Uint8List pdfBytes, String orderId) async {
    try {
      // الحصول على مسار التخزين
      final directory = await getTemporaryDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final fileName = 'Fahrzeuguebergabe_$orderId\_$timestamp.pdf';
      final filePath = '${directory.path}/$fileName';

      // حفظ الملف
      final file = File(filePath);
      await file.writeAsBytes(pdfBytes);

      // فتح الملف
      final result = await OpenFilex.open(filePath);

      if (result.type == ResultType.done) {
        _showSuccessSnackbar(
          '📄 ${'pdf_report_generated'.tr}',
          'pdf_report_ready_to_view'.tr,
        );

        // إظهار خيارات إضافية بعد تأخير قصير
        Future.delayed(Duration(milliseconds: 1500), () {
          _showPdfActionsDialog(filePath, orderId);
        });
      } else {
        throw Exception('failed_to_open_pdf_file'.tr);
      }

    } catch (e) {
      throw Exception('failed_to_save_pdf_report'.tr.replaceAll('{error}', e.toString()));
    }
  }

// عرض خيارات إضافية للـ PDF
  void _showPdfActionsDialog(String filePath, String orderId) {
    final order = getOrderById(orderId);
    if (order == null) return;

    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.picture_as_pdf, color: Colors.red.shade600, size: 22),
            SizedBox(width: 8),
            Text('pdf_actions'.tr),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'pdf_saved_successfully_choose_action'.tr,
              style: TextStyle(fontSize: 14, height: 1.4),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 16),

            // زر إرسال بالبريد الإلكتروني
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  Get.back();
                  sendEmailReport(order);
                },
                icon: Icon(Icons.email, size: 18),
                label: Text('send_by_email'.tr),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue.shade600,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
            ),

            SizedBox(height: 8),


          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text('close'.tr),
          ),
        ],
      ),
    );
  }


// تعديل دالة إرسال التقرير لاستخدام PDF
  Future<void> sendEmailReport(NewOrder order) async {
    await _sendPdfReportWithDialog(order);
  }

// دالة محسنة لإرسال تقرير PDF عبر البريد الإلكتروني
  Future<void> _sendPdfReportWithDialog(NewOrder order) async {
    try {
      // التحقق من وجود بريد إلكتروني للعميل
      if (order.clientEmail.isEmpty) {
        final email = await _requestEmailInput(order);
        if (email == null || email.isEmpty) return;

        await _performPdfEmailSendWithConfirmation(order, email);
      } else {
        await _performPdfEmailSendWithConfirmation(order, order.clientEmail);
      }
    } catch (e) {
      print('❌ خطأ في إرسال تقرير PDF بالبريد: $e');
      _showErrorSnackbar('email_send_error'.tr, e.toString());
    }
  }

// تنفيذ إرسال PDF مع تأكيد المستخدم
  Future<void> _performPdfEmailSendWithConfirmation(NewOrder order, String email) async {
    // عرض dialog تأكيد
    final confirmed = await Get.dialog<bool>(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.send, color: Colors.blue.shade600, size: 22),
            SizedBox(width: 8),
            Text('confirm_send_report'.tr),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'confirm_send_pdf_report'.tr,
              style: TextStyle(fontSize: 14, height: 1.4),
            ),
            SizedBox(height: 16),
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildInfoRow(Icons.person, 'client'.tr, order.client),
                  SizedBox(height: 6),
                  _buildInfoRow(Icons.confirmation_number, 'order_number'.tr,
                      order.orderNumber ?? order.id),
                  SizedBox(height: 6),
                  _buildInfoRow(Icons.email, 'email_address'.tr, email),
                  SizedBox(height: 6),
                  _buildInfoRow(Icons.picture_as_pdf, 'report_type'.tr, 'PDF Report'),
                ],
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
              backgroundColor: Colors.blue.shade600,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.send, size: 16),
                SizedBox(width: 6),
                Text('send_pdf_report'.tr),
              ],
            ),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _executePdfEmailSend(order, email);
    }
  }

// تنفيذ إرسال PDF الفعلي
  Future<void> _executePdfEmailSend(NewOrder order, String email) async {
    // عرض مؤشر تحميل
    Get.dialog(
      WillPopScope(
        onWillPop: () async => false,
        child: Center(
          child: Container(
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(color: Colors.blue.shade600),
                SizedBox(height: 16),
                Text('sending_pdf_report_email'.tr, style: TextStyle(fontSize: 14)),
                SizedBox(height: 8),
                Text(
                  email,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.blue.shade600,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      barrierDismissible: false,
    );

    try {
      // إرسال تقرير PDF
      final result = await _orderService.sendOrderPdfReportByEmail(order.id!, email);

      // إغلاق مؤشر التحميل
      if (Get.isDialogOpen == true) {
        Get.back();
      }

      // عرض النتيجة
      if (result.success) {
        await _showEmailSuccessDialog(result, order);
      } else {
        await _showEmailFailureDialog(result, order, email);
      }

    } catch (e) {
      // إغلاق مؤشر التحميل في حالة الخطأ
      if (Get.isDialogOpen == true) {
        Get.back();
      }

      await _showEmailErrorDialog(e.toString(), order, email);
    }
  }

  // معاينة تقرير HTML
  Future<void> previewHtmlReport(String orderId) async {
    try {
      _isCreating.value = true;

      Get.dialog(
        Center(
          child: Container(
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(color: Colors.blue.shade600),
                SizedBox(height: 16),
                Text('loading_html_preview'.tr, style: TextStyle(fontSize: 14)),
              ],
            ),
          ),
        ),
        barrierDismissible: false,
      );

      // الحصول على معاينة التقرير
      final htmlContent = await _orderService.previewOrderHtmlReport(orderId);

      if (Get.isDialogOpen == true) {
        Get.back();
      }

      // عرض المعاينة في WebView أو متصفح خارجي
      await _displayHtmlPreview(htmlContent, orderId);

    } catch (e) {
      if (Get.isDialogOpen == true) {
        Get.back();
      }

      _showErrorSnackbar('html_preview_failed'.tr, e.toString());
    } finally {
      _isCreating.value = false;
    }
  }

  // عرض معاينة HTML
  Future<void> _displayHtmlPreview(String htmlContent, String orderId) async {
    try {
      // حفظ الملف للمعاينة
      final directory = await getTemporaryDirectory();
      final fileName = 'Preview_$orderId\_${DateTime.now().millisecondsSinceEpoch}.html';
      final filePath = '${directory.path}/$fileName';

      final file = File(filePath);
      await file.writeAsString(htmlContent, encoding: utf8);

      // فتح للمعاينة
      await OpenFilex.open(filePath);

      _showSuccessSnackbar(
        '👁️ ${'html_preview_opened'.tr}',
        'html_preview_ready'.tr,
      );

    } catch (e) {
      throw Exception('failed_to_display_preview'.tr.replaceAll('error', e.toString()));
    }
  }

  @override
  void onClose() {
    _orders.clear();
    super.onClose();
  }
}