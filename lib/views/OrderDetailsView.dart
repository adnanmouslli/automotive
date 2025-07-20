import 'package:automotive/config/app_config.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/order_controller.dart';
import '../controllers/order_view_details.dart';
import '../models/new_address.dart';
import '../models/new_order.dart';
import '../utils/AppColors.dart';

class OrderDetailsView extends StatefulWidget {
  @override
  _OrderDetailsViewState createState() => _OrderDetailsViewState();
}

class _OrderDetailsViewState extends State<OrderDetailsView> {
  late OrderDetailsController controller;
  String? orderId;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    orderId = Get.arguments as String?;
    controller = Get.put(OrderDetailsController());

    // Single initialization
    if (orderId != null && !_isInitialized) {
      _isInitialized = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          controller.initializeOrder(orderId!);
        }
      });
    }
  }

  @override
  void dispose() {
    // Clean up controller when exiting
    controller.onClose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        return await _handleBackNavigation();
      },
      child: GetBuilder<OrderDetailsController>(
        builder: (controller) {
          return Scaffold(
            backgroundColor: AppColors.lightGray,
            appBar: _buildSafeAppBar(controller),
            body: Obx(() {
              if (controller.isLoading) {
                return _buildLoadingOverlay();
              }

              return RefreshIndicator(
                onRefresh: () => controller.loadOrderDetails(orderId!),
                color: AppColors.primaryBlue,
                child: CustomScrollView(
                  physics: const BouncingScrollPhysics(),
                  cacheExtent: 200.0,
                  slivers: [
                    SliverToBoxAdapter(
                      child: controller.order == null
                          ? _buildLoadingState()
                          : Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildHeaderCard(controller.order!),
                            const SizedBox(height: 20),
                            _buildProgressCard(controller),
                            const SizedBox(height: 20),
                            _buildStatusOverview(controller),
                            const SizedBox(height: 20),
                            _buildBasicInfoCard(controller.order!),
                            const SizedBox(height: 20),
                            _buildVehicleDamageSection(controller.order!),
                            const SizedBox(height: 20),
                            _buildAddressesCard(controller.order!),
                            const SizedBox(height: 20),
                            _buildImagesSection(controller),
                            const SizedBox(height: 20),
                            _buildSignaturesSection(controller),
                            const SizedBox(height: 20),
                            _buildExpensesSection(controller),
                            const SizedBox(height: 20),
                            _buildActionButtons(controller),
                            const SizedBox(height: 100),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }),
          );
        },
      ),
    );
  }

  // Function to check for updates
  void _checkForUpdates(OrderDetailsController controller, String orderId) {
    // Check if data needs to be reloaded
    final lastUpdate = controller.order?.updatedAt;
    final now = DateTime.now();

    // Reload data if certain time has passed or as needed
    if (lastUpdate == null || now.difference(lastUpdate).inMinutes > 1) {
      print('🔄 Reloading data to check for updates');
      controller.loadOrderDetails(orderId);
    }
  }

  Widget _buildStatusActionButtons(OrderDetailsController controller) {
    final order = controller.order;
    if (order == null || order.isCompleted) return const SizedBox();

    final status = order.status.toLowerCase();

    if (status == 'pending') {
      return Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: () => controller.updateOrderStatus('in_progress'),
              style: AppColors.secondaryButtonStyle,
              child: Text('start_execution'.tr, style: AppColors.buttonTextStyle),
            ),
          ),
        ],
      );
    } else if (status == 'in_progress') {
      return Row(
        children: [
          Expanded(
            child: ElevatedButton(
              onPressed: controller.completeOrder,
              style: AppColors.successButtonStyle,
              child: Text('complete_order'.tr, style: AppColors.buttonTextStyle.copyWith(color: AppColors.whiteText)),
            ),
          ),
        ],
      );
    }

    return const SizedBox();
  }

  Future<bool> _handleBackNavigation() async {
    try {
      final controller = Get.find<OrderDetailsController>();
      if (controller.isLoading) {
        final shouldExit = await Get.dialog<bool>(
          AlertDialog(
            backgroundColor: AppColors.pureWhite,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            title: Text('alert'.tr, style: AppColors.subHeadingStyle),
            content: Text('operation_in_progress'.tr, style: AppColors.bodyStyle),
            actions: [
              TextButton(
                onPressed: () => Get.back(result: false),
                child: Text('stay'.tr, style: AppColors.buttonTextStyle.copyWith(color: AppColors.mediumGray)),
              ),
              ElevatedButton(
                onPressed: () => Get.back(result: true),
                style: AppColors.dangerButtonStyle,
                child: Text('exit'.tr, style: AppColors.buttonTextStyle.copyWith(color: AppColors.whiteText)),
              ),
            ],
          ),
        );
        return shouldExit ?? false;
      }

      // Update dashboard before exiting - new addition
      _updateDashboardBeforeExit(controller);

      return true;
    } catch (e) {
      print('error_handling_exit'.tr.replaceAll('error' , e.toString()));
      return true;
    }
  }

  // New function to update dashboard before exiting
  void _updateDashboardBeforeExit(OrderDetailsController controller) {
    try {
      if (controller.order != null) {
        // Check for NewOrderController and update data
        if (Get.isRegistered<NewOrderController>()) {
          final dashboardController = Get.find<NewOrderController>();
          print('🔄 Updating dashboard data before exiting details');

          // Reload data to ensure updates
          dashboardController.loadOrders();
        }
      }
    } catch (e) {
      print('⚠️ ${'error_updating_dashboard'.tr.replaceAll('error', e.toString())}');
    }
  }

  // Safe AppBar with better exit handling
  PreferredSizeWidget _buildSafeAppBar(OrderDetailsController controller) {
    return AppBar(
      elevation: 0,
      backgroundColor: AppColors.primaryBlue,
      foregroundColor: AppColors.whiteText,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () async {
          final canPop = await _handleBackNavigation();
          if (canPop) {
            Get.back();
          }
        },
      ),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            controller.order?.client.isNotEmpty == true
                ? controller.order!.client
                : 'order_details'.tr,
            style: AppColors.buttonTextStyle.copyWith(
              color: AppColors.whiteText,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          if (controller.order?.licensePlateNumber.isNotEmpty == true)
            Text(
              controller.order!.licensePlateNumber,
              style: AppColors.captionStyle.copyWith(
                color: AppColors.lightGrayText,
              ),
            ),
        ],
      ),
      actions: [
        if (controller.order != null)
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert),
            color: AppColors.pureWhite,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            onSelected: (value) => _handleMenuAction(value, controller),
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'edit_details',
                child: Row(
                  children: [
                    Icon(Icons.edit_outlined,
                        color: AppColors.primaryBlue, size: 20),
                    const SizedBox(width: 12),
                    Text('edit_details'.tr, style: AppColors.bodyStyle),
                  ],
                ),
              ),
            ],
          ),
      ],
    );
  }

  void _handleMenuAction(String action, OrderDetailsController controller) {
    switch (action) {
      case 'edit_details':
        controller.editOrder(); // Using updated function from controller
        break;
    }
  }

  // Enhanced header card
  Widget _buildHeaderCard(NewOrder order) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.primaryBlue,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.mediumShadow,
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.whiteText.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.assignment_outlined,
              color: AppColors.whiteText,
              size: 32,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  order.client,
                  style: AppColors.subHeadingStyle.copyWith(
                    color: AppColors.whiteText,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  order.licensePlateNumber,
                  style: AppColors.bodyStyle.copyWith(
                    color: AppColors.lightGrayText,
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.whiteText.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    _getServiceTypeText(order.serviceType),
                    style: AppColors.captionStyle.copyWith(
                      color: AppColors.whiteText,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Separate loading overlay
  Widget _buildLoadingOverlay() {
    return Container(
      color: AppColors.lightGray,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: AppColors.elevatedCardDecoration,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(
                    strokeWidth: 3,
                    valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryBlue),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'processing'.tr,
                    style: AppColors.bodyStyle.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSliverAppBar(OrderDetailsController controller) {
    return SliverAppBar(
      expandedHeight: 200,
      floating: false,
      pinned: true,
      backgroundColor: Colors.transparent,
      flexibleSpace: Container(
        decoration: const BoxDecoration(
          color: AppColors.primaryBlue,
        ),
        child: FlexibleSpaceBar(
          title: Obx(() {
            final order = controller.order;
            if (order == null) {
              return Text(
                'order_details'.tr,
                style: AppColors.buttonTextStyle.copyWith(
                  color: AppColors.whiteText,
                ),
              );
            }

            return Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  order.client.isNotEmpty ? order.client : 'order_details'.tr,
                  style: AppColors.buttonTextStyle.copyWith(
                    color: AppColors.whiteText,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (order.licensePlateNumber.isNotEmpty)
                  Text(
                    order.licensePlateNumber,
                    style: AppColors.captionStyle.copyWith(
                      color: AppColors.lightGrayText,
                    ),
                  ),
              ],
            );
          }),
        ),
      ),
      actions: [
        Container(
          margin: const EdgeInsets.only(left: 16),
          child: Obx(() {
            final order = controller.order;
            if (order == null) return const SizedBox.shrink();

            return PopupMenuButton<String>(
              icon: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.whiteText.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.more_vert,
                  color: AppColors.whiteText,
                  size: 20,
                ),
              ),
              color: AppColors.pureWhite,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              onSelected: (value) => controller.handleMenuAction(value),
              itemBuilder: (context) => [
                PopupMenuItem(
                  value: 'edit_details',
                  child: Row(
                    children: [
                      Icon(Icons.edit_outlined,
                          color: AppColors.primaryBlue, size: 20),
                      const SizedBox(width: 12),
                      Text('edit_details'.tr, style: AppColors.bodyStyle),
                    ],
                  ),
                ),
                if (controller.canCompleteOrder)
                  PopupMenuItem(
                    value: 'complete',
                    child: Row(
                      children: [
                        Icon(Icons.check_circle_outline,
                            color: AppColors.successGreen, size: 20),
                        const SizedBox(width: 12),
                        Text('complete_order'.tr, style: AppColors.bodyStyle),
                      ],
                    ),
                  ),
                PopupMenuItem(
                  value: 'delete',
                  child: Row(
                    children: [
                      Icon(Icons.delete_outline,
                          color: AppColors.errorRed, size: 20),
                      const SizedBox(width: 12),
                      Text('delete_order'.tr, style: AppColors.bodyStyle),
                    ],
                  ),
                ),
              ],
            );
          }),
        ),
      ],
    );
  }

  Widget _buildLoadingState() {
    return Container(
      height: 400,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              strokeWidth: 3,
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryBlue),
            ),
            const SizedBox(height: 16),
            Text(
              'loading_order_details'.tr,
              style: AppColors.bodyStyle,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressCard(OrderDetailsController controller) {
    final completionPercentage = controller.completionPercentage;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.primaryBlue,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.mediumShadow,
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.whiteText.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.timeline_rounded,
                    color: AppColors.whiteText,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Text(
                  'order_progress'.tr,
                  style: AppColors.subHeadingStyle.copyWith(
                    color: AppColors.whiteText,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'completion_percentage'.tr,
                      style: AppColors.bodyStyle.copyWith(
                        color: AppColors.lightGrayText,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.whiteText.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${(completionPercentage * 100).toInt()}%',
                        style: AppColors.buttonTextStyle.copyWith(
                          color: AppColors.whiteText,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: completionPercentage,
                    backgroundColor: AppColors.whiteText.withOpacity(0.2),
                    valueColor: const AlwaysStoppedAnimation<Color>(AppColors.whiteText),
                    minHeight: 8,
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _buildStatusOverview(OrderDetailsController controller) {
    final missing = controller.missingRequirements;
    final completed = _getCompletedRequirements(controller);

    return Container(
      decoration: AppColors.cardDecoration,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.checklist_rounded,
                    color: AppColors.primaryBlue, size: 24),
                const SizedBox(width: 12),
                Text(
                  'order_requirements'.tr,
                  style: AppColors.subHeadingStyle,
                ),
              ],
            ),
            const SizedBox(height: 16),
            Column(
              children: [
                // Completed requirements
                if (completed.isNotEmpty)
                  ...completed.map((item) => _buildRequirementItem(
                    item,
                    true,
                    AppColors.successGreen,
                    Icons.check_circle_rounded,
                  )),

                // Missing requirements
                if (missing.isNotEmpty)
                  ...missing.map((item) => _buildRequirementItem(
                    item,
                    false,
                    AppColors.pendingOrange,
                    Icons.radio_button_unchecked_rounded,
                  )),

                if (missing.isEmpty)
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.lightGreenBg,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.successGreen.withOpacity(0.3)),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.check_circle_rounded,
                            color: AppColors.successGreen),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'all_requirements_met_ready'.tr,
                            style: AppColors.bodyStyle.copyWith(
                              fontWeight: FontWeight.w600,
                              color: AppColors.successGreen,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRequirementItem(
      String text, bool isCompleted, Color color, IconData icon) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(icon, size: 20, color: color),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: AppColors.bodyStyle.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBasicInfoCard(NewOrder order) {
    return Column(
      children: [
        // قسم معلومات مقدم الطلب
        Container(
          decoration: AppColors.cardDecoration,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppColors.lightBlueBg,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(Icons.person_outline,
                          color: AppColors.primaryBlue, size: 24),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'client_information'.tr, // معلومات مقدم الطلب
                      style: AppColors.subHeadingStyle,
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                _buildClientInfoGrid(order),
              ],
            ),
          ),
        ),

        const SizedBox(height: 16),

        // قسم معلومات صاحب الفاتورة
        Container(
          decoration: AppColors.cardDecoration,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppColors.lightGreenBg,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(Icons.receipt_long_outlined,
                          color: AppColors.successGreen, size: 24),
                    ),
                    const SizedBox(width: 12),
                    Expanded( // إضافة Expanded حول النص
                      child: Text(
                        'billing_information'.tr, // معلومات صاحب الفاتورة
                        style: AppColors.subHeadingStyle,
                        overflow: TextOverflow.ellipsis, // إضافة overflow
                        maxLines: 2, // السماح بسطرين
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                _buildBillingInfoSection(order),
              ],
            ),
          ),
        ),

        const SizedBox(height: 16),

        // قسم معلومات السيارة والخدمة
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.lightBlueBg,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(Icons.directions_car_outlined,
                  color: AppColors.progressBlue, size: 24),
            ),
            const SizedBox(width: 12),
            Expanded( // أو Flexible
              child: Text(
                'vehicle_service_info'.tr,
                style: AppColors.subHeadingStyle,
                overflow: TextOverflow.ellipsis, // اختياري
                maxLines: 2, // اختياري
              ),
            ),
          ],
        ),

      ],
    );
  }

  Widget _buildClientInfoGrid(NewOrder order) {
    final clientInfoItems = [
      {'label': 'client_name'.tr, 'value': order.client, 'icon': Icons.person_outline},
      {
        'label': 'phone'.tr,
        'value': order.clientPhone ?? '',
        'icon': Icons.phone_outlined
      },
      {
        'label': 'email'.tr,
        'value': order.clientEmail ?? '',
        'icon': Icons.email_outlined
      },
    ];

    return Column(
      children: [
        ...clientInfoItems.map((item) => _buildModernInfoRow(
          item['label'] as String,
          item['value'] as String,
          item['icon'] as IconData,
        )),

        // عرض عنوان العميل إذا كان موجود
        if (order.clientAddress != null) ...[
          const SizedBox(height: 8),
          _buildAddressInfoCard(
            'client_address'.tr,
            order.clientAddress!,
            Icons.location_on_outlined,
            AppColors.progressBlue,
          ),
        ],

        // إضافة الوصف والتعليقات
        if (order.description.isNotEmpty) ...[
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.lightGray,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.borderGray),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.description_outlined,
                        color: AppColors.successGreen, size: 18),
                    const SizedBox(width: 8),
                    Text(
                      'service_description'.tr,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: AppColors.darkGray,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  order.serviceDescription,
                  style: TextStyle(
                    color: AppColors.mediumGray,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildAddressInfoCard(
      String title,
      NewAddress address,
      IconData icon,
      Color color
      ) {
    final Color bgColor = color == AppColors.progressBlue
        ? AppColors.lightBlueBg
        : color == AppColors.successGreen
        ? AppColors.lightGreenBg
        : color == AppColors.pendingOrange
        ? AppColors.lightOrangeBg
        : AppColors.lightGray;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 18),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: AppColors.darkGray,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            _formatAddressText(address),
            style: TextStyle(
              color: AppColors.mediumGray,
              height: 1.3,
            ),
          ),
        ],
      ),
    );
  }

  String _formatAddressText(NewAddress address) {
    List<String> addressParts = [];

    if (address.street.isNotEmpty && address.houseNumber.isNotEmpty) {
      addressParts.add('${address.street} ${address.houseNumber}');
    } else if (address.street.isNotEmpty) {
      addressParts.add(address.street);
    }

    if (address.zipCode.isNotEmpty && address.city.isNotEmpty) {
      addressParts.add('${address.zipCode} ${address.city}');
    } else if (address.city.isNotEmpty) {
      addressParts.add(address.city);
    }

    if (address.country.isNotEmpty && address.country != 'Deutschland') {
      addressParts.add(address.country);
    }

    return addressParts.join('\n');
  }

  Widget _buildBillingInfoSection(NewOrder order) {
    if (order.isSameBilling) {
      // نفس العميل
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.green.shade50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.green.shade200),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.green.shade600,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.check_circle_outline,
                color: Colors.white,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'same_as_client'.tr,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Colors.green.shade700,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'billing_same_client_desc'.tr,
                    style: TextStyle(
                      color: Colors.green.shade600,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    } else {
      // صاحب فاتورة مختلف
      final billingInfoItems = [
        {
          'label': 'billing_name'.tr,
          'value': order.billingName ?? '',
          'icon': Icons.business_outlined
        },
        {
          'label': 'billing_phone'.tr,
          'value': order.billingPhone ?? '',
          'icon': Icons.phone_outlined
        },
        {
          'label': 'billing_email'.tr,
          'value': order.billingEmail ?? '',
          'icon': Icons.email_outlined
        },
      ];

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.orange.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.orange.shade200),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline, color: Colors.orange.shade600, size: 18),
                const SizedBox(width: 8),
                Expanded( // إضافة Expanded
                  child: Text(
                    'different_billing_info'.tr, // معلومات فوترة مختلفة
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Colors.orange.shade700,
                      fontSize: 14,
                    ),
                    overflow: TextOverflow.ellipsis, // إضافة overflow
                    maxLines: 2, // السماح بسطرين كحد أقصى
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          ...billingInfoItems.map((item) => _buildModernInfoRow(
            item['label'] as String,
            item['value'] as String,
            item['icon'] as IconData,
          )),

          // عرض عنوان صاحب الفاتورة إذا كان موجود (تم التحديث)
          if (order.billingAddress != null) ...[
            const SizedBox(height: 8),
            _buildAddressInfoCard(
              'billing_address'.tr,
              order.billingAddress!,
              Icons.location_on_outlined,
              Colors.orange,
            ),
          ],
        ],
      );
    }
  }



  bool _hasAdditionalVehicleInfo(NewOrder order) {
    return order.ukz.isNotEmpty ||
        order.fin.isNotEmpty ||
        order.bestellnummer.isNotEmpty ||
        order.leasingvertragsnummer.isNotEmpty ||
        order.kostenstelle.isNotEmpty ||
        order.bemerkung.isNotEmpty ||
        order.typ.isNotEmpty;
  }

  Widget _buildModernInfoRow(String label, String value, IconData icon) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.grey.shade600, size: 20),
          const SizedBox(width: 12),
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey.shade600,
                fontSize: 13,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value.isEmpty ? 'not_specified'.tr : value,
              style: TextStyle(
                color: value.isEmpty ? Colors.grey.shade400 : Colors.black87,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddressesCard(NewOrder order) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(Icons.location_on_outlined,
                      color: Colors.green.shade600, size: 24),
                ),
                const SizedBox(width: 12),
                Expanded( // إضافة Expanded هنا
                  child: Text(
                    'addresses'.tr,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue.shade800,
                    ),
                    overflow: TextOverflow.ellipsis, // إضافة النقاط
                    maxLines: 1, // السماح بسطر واحد فقط
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            _buildExtendedAddressSection(
              'pickup_address'.tr,
              order.pickupAddress,
              Icons.upload_rounded,
              Colors.blue,
            ),
            const SizedBox(height: 20),
            _buildExtendedAddressSection(
              'destination_address'.tr,
              order.deliveryAddress,
              Icons.location_on_rounded,
              Colors.green,
            ),
          ],
        ),
      ),
    );
  }

  // دالة جديدة لعرض العناوين المحدثة مع الحقول الإضافية
  Widget _buildExtendedAddressSection(
      String title, NewAddress address, IconData icon, MaterialColor color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // العنوان الرئيسي
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.shade600,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, size: 16, color: Colors.white),
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: color.shade700,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // العنوان الأساسي
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: color.shade100),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.location_on_outlined,
                        color: color.shade600, size: 16),
                    const SizedBox(width: 8),
                    Text(
                      'address'.tr,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: color.shade700,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  '${address.street} ${address.houseNumber}',
                  style: TextStyle(
                    color: Colors.grey.shade800,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  '${address.zipCode} ${address.city}',
                  style: TextStyle(color: Colors.grey.shade700),
                ),
                if (address.country.isNotEmpty && address.country != 'Deutschland')
                  Text(
                    address.country,
                    style: TextStyle(color: Colors.grey.shade700),
                  ),
              ],
            ),
          ),

          // المعلومات الإضافية
          if (_hasExtendedAddressInfo(address)) ...[
            const SizedBox(height: 12),

            // التاريخ والشركة
            if (address.date != null || address.companyName != null) ...[
              Row(
                children: [
                  if (address.date != null)
                    Expanded(
                      child: _buildAddressInfoItem(
                        'date'.tr,
                        _formatDate(address.date!),
                        Icons.date_range_outlined,
                        color,
                      ),
                    ),
                  if (address.date != null && address.companyName != null)
                    const SizedBox(width: 12),
                  if (address.companyName != null)
                    Expanded(
                      child: _buildAddressInfoItem(
                        'company_name'.tr,
                        address.companyName!,
                        Icons.business_outlined,
                        color,
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 8),
            ],

            // بيانات الموظف
            if (address.contactPersonName != null ||
                address.contactPersonPhone != null ||
                address.contactPersonEmail != null) ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: color.shade100),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.person_outline,
                            color: color.shade600, size: 16),
                        const SizedBox(width: 8),
                        Text(
                          'contact_person'.tr,
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: color.shade700,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    if (address.contactPersonName != null)
                      _buildContactDetail(
                          Icons.person,
                          address.contactPersonName!,
                          color
                      ),
                    if (address.contactPersonPhone != null)
                      _buildContactDetail(
                          Icons.phone,
                          address.contactPersonPhone!,
                          color
                      ),
                    if (address.contactPersonEmail != null)
                      _buildContactDetail(
                          Icons.email,
                          address.contactPersonEmail!,
                          color
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
            ],

            // معلومات الوقود
            if (address.fuelLevel != null || address.fuelMeter != null) ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: color.shade100),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.local_gas_station_outlined,
                            color: color.shade600, size: 16),
                        const SizedBox(width: 8),
                        Expanded( // إضافة Expanded للنص الرئيسي
                          child: Text(
                            'fuel_information'.tr,
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: color.shade700,
                              fontSize: 14,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        if (address.fuelLevel != null) ...[
                          Expanded(
                            child: Row(
                              mainAxisSize: MainAxisSize.min, // إضافة هذا
                              children: [
                                Icon(Icons.speed, color: color.shade600, size: 14),
                                const SizedBox(width: 4),
                                Flexible( // تغيير من Text إلى Flexible
                                  child: Text(
                                    'fuel_level'.tr + ': ',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey.shade600,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: color.shade600,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    '${address.fuelLevel}/8',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                        if (address.fuelMeter != null) ...[
                          if (address.fuelLevel != null) const SizedBox(width: 12),
                          Expanded(
                            child: Row(
                              mainAxisSize: MainAxisSize.min, // إضافة هذا
                              children: [
                                Icon(Icons.straighten, color: color.shade600, size: 14),
                                const SizedBox(width: 4),
                                Flexible( // تغيير من Text إلى Flexible
                                  child: Text(
                                    'fuel_meter'.tr + ': ',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey.shade600,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                Text(
                                  '${address.fuelMeter!.toStringAsFixed(1)} L',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.grey.shade800,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ],
        ],
      ),
    );
  }

  // دالة مساعدة لبناء عنصر معلومات العنوان
  Widget _buildAddressInfoItem(
      String label, String value, IconData icon, MaterialColor color) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.shade100),
      ),
      child: Row(
        children: [
          Icon(icon, color: color.shade600, size: 14),
          const SizedBox(width: 6),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade800,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // دالة مساعدة لبناء تفاصيل الاتصال
  Widget _buildContactDetail(IconData icon, String value, MaterialColor color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Icon(icon, color: color.shade600, size: 14),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade800,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // دالة للتحقق من وجود معلومات إضافية في العنوان
  bool _hasExtendedAddressInfo(NewAddress address) {
    return address.date != null ||
        address.companyName != null ||
        address.contactPersonName != null ||
        address.contactPersonPhone != null ||
        address.contactPersonEmail != null ||
        address.fuelLevel != null ||
        address.fuelMeter != null;
  }

  // دالة لتنسيق التاريخ
  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}.${date.month.toString().padLeft(2, '0')}.${date.year}';
  }

  // إضافة قسم عرض الأغراض في _buildVehicleAndServiceInfo
  Widget _buildVehicleAndServiceInfo(NewOrder order) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // قسم البيانات الأساسية للسيارة
        Text(
          'basic_vehicle_data'.tr,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.blue.shade700,
          ),
        ),
        const SizedBox(height: 12),

        // البيانات الأساسية
        _buildModernInfoRow(
          'vehicle_owner'.tr,
          order.vehicleOwner,
          Icons.account_circle_outlined,
        ),
        _buildModernInfoRow(
          'license_plate'.tr,
          order.licensePlateNumber,
          Icons.confirmation_number_outlined,
        ),

        // قسم المعلومات الإضافية للسيارة (الحقول الجديدة)
        if (_hasAdditionalVehicleInfo(order)) ...[
          const SizedBox(height: 20),
          Divider(color: Colors.grey.shade300, thickness: 1),
          const SizedBox(height: 16),

          Text(
            'additional_vehicle_info'.tr,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.purple.shade700,
            ),
          ),
          const SizedBox(height: 12),

          if (order.ukz.isNotEmpty)
            _buildModernInfoRow('ÜKZ', order.ukz, Icons.confirmation_number_outlined),
          if (order.fin.isNotEmpty)
            _buildModernInfoRow('FIN', order.fin, Icons.fingerprint),
          if (order.bestellnummer.isNotEmpty)
            _buildModernInfoRow('bestellnummer'.tr, order.bestellnummer, Icons.receipt_long),
          if (order.leasingvertragsnummer.isNotEmpty)
            _buildModernInfoRow('leasingvertragsnummer'.tr, order.leasingvertragsnummer, Icons.assignment),
          if (order.kostenstelle.isNotEmpty)
            _buildModernInfoRow('kostenstelle'.tr, order.kostenstelle, Icons.account_balance),
          if (order.typ.isNotEmpty)
            _buildModernInfoRow('typ'.tr, order.typ, Icons.category),

          // Bemerkung في مربع منفصل إذا كان موجود
          if (order.bemerkung.isNotEmpty) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.purple.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.purple.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.note_outlined,
                          color: Colors.purple.shade600, size: 18),
                      const SizedBox(width: 8),
                      Text(
                        'bemerkung'.tr,
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: Colors.purple.shade700,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    order.bemerkung,
                    style: TextStyle(
                      color: Colors.purple.shade800,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],


        // قسم الأغراض المتاحة مع السيارة (جديد)
        if (order.items.isNotEmpty) ...[
          const SizedBox(height: 20),
          Divider(color: Colors.grey.shade300, thickness: 1),
          const SizedBox(height: 16),

          Text(
            'vehicle_items'.tr,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.indigo.shade700,
            ),
          ),
          const SizedBox(height: 12),

          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.indigo.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.indigo.shade200),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.checklist_outlined,
                        color: Colors.indigo.shade600, size: 18),
                    const SizedBox(width: 8),
                    Text(
                      'available_items'.tr,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: Colors.indigo.shade700,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: order.items.map((item) {
                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.indigo.shade600,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        _getVehicleItemText(item),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
        ],


        // قسم معلومات الخدمة
        const SizedBox(height: 20),
        Divider(color: Colors.grey.shade300, thickness: 1),
        const SizedBox(height: 16),

        Text(
          'service_information'.tr,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.green.shade700,
          ),
        ),
        const SizedBox(height: 12),

        _buildModernInfoRow(
          'service_type'.tr,
          _getServiceTypeText(order.serviceType),
          Icons.build_outlined,
        ),

        if (order.vehicleType.isNotEmpty)
          _buildModernInfoRow(
            'vehicle_type'.tr,
            order.vehicleType,
            Icons.directions_car,
          ),

        if (order.serviceDescription.isNotEmpty) ...[
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.green.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.green.shade200),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.description_outlined,
                        color: Colors.green.shade600, size: 18),
                    const SizedBox(width: 8),
                    Text(
                      'service_description'.tr,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: Colors.green.shade700,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  order.serviceDescription,
                  style: TextStyle(
                    color: Colors.green.shade800,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  // دالة مساعدة للحصول على نص الغرض
  String _getVehicleItemText(VehicleItem item) {
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
        return item.toString().split('.').last;
    }
  }



  Widget _buildImagesSection(OrderDetailsController controller) {
    final order = controller.order;

    return Container(
      decoration: AppColors.elevatedCardDecoration,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppColors.lightBlueBg,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(Icons.photo_library_outlined,
                          color: AppColors.progressBlue, size: 24),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      "images".tr,
                      style: AppColors.subHeadingStyle,
                    ),
                  ],
                ),
                Material(
                  color: AppColors.successGreen,
                  borderRadius: BorderRadius.circular(12),
                  elevation: 2,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: () {
                      if (!controller.isLoading) {
                        controller.addImage();
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      child: const Icon(
                        Icons.add_a_photo_rounded,
                        color: AppColors.whiteText,
                        size: 20,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            (order == null || order.images.isEmpty)
                ? _buildEmptyImagesState(controller)
                : _buildImagesGrid(order.images),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyImagesState(OrderDetailsController controller) {
    return Container(
      padding: const EdgeInsets.all(40),
      decoration: BoxDecoration(
        color: AppColors.lightGray,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderGray),
      ),
      child: Center(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.pureWhite,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(
                Icons.photo_library_outlined,
                size: 48,
                color: AppColors.lightGrayText,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'no_images_added'.tr,
              style: AppColors.bodyStyle.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.mediumGray,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'click_to_upload'.tr,
              style: AppColors.captionStyle,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImagesGrid(List<OrderImage> images) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.85,
      ),
      itemCount: images.length,
      itemBuilder: (context, index) {
        final image = images[index];
        return _buildEnhancedImageTile(image);
      },
    );
  }

  Widget _buildEnhancedImageTile(OrderImage image) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.mediumShadow,
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          children: [
            // Original image
            Positioned.fill(
              child: Image.network(
                "${AppConfig.baseUrl}${image.imageUrl}",
                fit: BoxFit.cover,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Container(
                    color: AppColors.lightGray,
                    child: Center(
                      child: CircularProgressIndicator(
                        value: loadingProgress.expectedTotalBytes != null
                            ? loadingProgress.cumulativeBytesLoaded /
                            loadingProgress.expectedTotalBytes!
                            : null,
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(AppColors.progressBlue),
                      ),
                    ),
                  );
                },
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: AppColors.lightGray,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.broken_image_outlined,
                            color: AppColors.lightGrayText, size: 32),
                        const SizedBox(height: 8),
                        Text(
                          'failed_to_load_image'.tr,
                          style: AppColors.captionStyle,
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            // Gradient overlay
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      AppColors.darkGray.withOpacity(0.7),
                    ],
                  ),
                ),
              ),
            ),
            // Delete button
            Positioned(
              top: 8,
              left: 8,
              child: GetBuilder<OrderDetailsController>(
                builder: (controller) => Material(
                  color: AppColors.errorRed.withOpacity(0.9),
                  borderRadius: BorderRadius.circular(20),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(20),
                    onTap: controller.isLoading
                        ? null
                        : () => controller.deleteImage(image.id),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      child: const Icon(
                        Icons.delete_outline,
                        color: AppColors.whiteText,
                        size: 16,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            // Category badge
            Positioned(
              top: 8,
              right: 8,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _getCategoryColor(image.category),
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.mediumShadow,
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Text(
                  _getImageCategoryText(image.category),
                  style: const TextStyle(
                    color: AppColors.whiteText,
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            // Description at bottom
            if (image.description.isNotEmpty)
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.all(12),
                  child: Text(
                    image.description,
                    style: const TextStyle(
                      color: AppColors.whiteText,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSignaturesSection(OrderDetailsController controller) {
    final order = controller.order;

    return Container(
      decoration: AppColors.elevatedCardDecoration,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.lightOrangeBg,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(Icons.draw_outlined,
                      color: AppColors.pendingOrange, size: 24),
                ),
                const SizedBox(width: 12),
                Expanded( // إضافة Expanded لحل مشكلة النص الطويل
                  child: Text(
                    'signatures'.tr,
                    style: AppColors.subHeadingStyle.copyWith(
                      color: AppColors.primaryBlue,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            if (order != null)
              Column(
                children: [
                  _buildEnhancedSignatureCard(
                    'driver_signature'.tr,
                    order.driverSignature,
                        () {
                      if (!controller.isLoading) {
                        controller.addDriverSignature();
                      }
                    },
                    Icons.local_shipping_outlined,
                    AppColors.progressBlue,
                  ),
                  const SizedBox(height: 16),
                  _buildEnhancedSignatureCard(
                    'customer_signature'.tr,
                    order.customerSignature,
                        () {
                      if (!controller.isLoading) {
                        controller.addCustomerSignature();
                      }
                    },
                    Icons.person_outline,
                    AppColors.successGreen,
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }


  Widget _buildEnhancedSignatureCard(
      String title,
      OrderSignature? signature,
      VoidCallback onAdd,
      IconData icon,
      Color color,
      ) {
    final bool isSigned = signature != null;
    final Color bgColor = isSigned
        ? (color == AppColors.progressBlue ? AppColors.lightBlueBg : AppColors.lightGreenBg)
        : AppColors.lightGray;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isSigned ? color.withOpacity(0.3) : AppColors.borderGray,
          width: 1.5,
        ),
      ),
      child: Column( // تغيير من Row إلى Column
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header row مع الأيقونة والعنوان
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isSigned ? color : AppColors.lightGrayText,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  isSigned ? Icons.check_circle_outline : icon,
                  color: AppColors.whiteText,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                    color: isSigned ? AppColors.darkGray : AppColors.mediumGray,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              // Action button في نفس الصف
              if (!isSigned)
                Material(
                  color: color,
                  borderRadius: BorderRadius.circular(10),
                  elevation: 2,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(10),
                    onTap: onAdd,
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      child: const Icon(Icons.add_rounded, color: AppColors.whiteText),
                    ),
                  ),
                ),
            ],
          ),

          // معلومات التوقيع في صف منفصل
          if (signature != null) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.7),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // اسم صاحب التوقيع
                  if (signature.name.isNotEmpty) ...[
                    Row(
                      children: [
                        Icon(
                          Icons.person_outline,
                          size: 16,
                          color: color,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'signer_name'.tr + ':', // "اسم الموقع:"
                          style: TextStyle(
                            color: AppColors.mediumGray,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Padding(
                      padding: const EdgeInsets.only(left: 22),
                      child: Text(
                        signature.name,
                        style: TextStyle(
                          color: AppColors.darkGray,
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                  ],

                  // تاريخ التوقيع
                  Row(
                    children: [
                      Icon(
                        Icons.access_time,
                        size: 16,
                        color: color,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'signed_at'.tr + ':', // "وقت التوقيع:"
                        style: TextStyle(
                          color: AppColors.mediumGray,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Padding(
                    padding: const EdgeInsets.only(left: 22),
                    child: Text(
                      _formatDateTime(signature.signedAt),
                      style: TextStyle(
                        color: AppColors.darkGray,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // أزرار الحذف في صف منفصل
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                GetBuilder<OrderDetailsController>(
                  builder: (controller) => Material(
                    color: AppColors.errorRed,
                    borderRadius: BorderRadius.circular(8),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(8),
                      onTap: controller.isLoading
                          ? null
                          : () => controller.deleteSignature(
                          signature.id, signature.isDriver),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.delete_outline,
                              color: AppColors.whiteText,
                              size: 16,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'delete'.tr,
                              style: const TextStyle(
                                color: AppColors.whiteText,
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ] else ...[
            // إذا لم يكن هناك توقيع
            const SizedBox(height: 8),
            Center(
              child: Text(
                'not_signed_yet'.tr,
                style: AppColors.captionStyle.copyWith(
                  fontStyle: FontStyle.italic,
                  color: AppColors.mediumGray,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildExpensesSection(OrderDetailsController controller) {
    final order = controller.order;

    return Container(
      decoration: AppColors.elevatedCardDecoration,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppColors.lightGreenBg,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(Icons.receipt_long_outlined,
                          color: AppColors.successGreen, size: 24),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'expenses'.tr,
                      style: AppColors.subHeadingStyle,
                    ),
                  ],
                ),
                if (controller.hasExpenses)
                  Material(
                    color: AppColors.progressBlue,
                    borderRadius: BorderRadius.circular(12),
                    elevation: 2,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: controller.isLoading
                          ? null
                          : () => controller.editExpenses(),
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        child: const Icon(Icons.edit, color: AppColors.whiteText),
                      ),
                    ),
                  ),
                if (!controller.hasExpenses)
                  Material(
                    color: AppColors.successGreen,
                    borderRadius: BorderRadius.circular(12),
                    elevation: 2,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: () {
                        if (!controller.isLoading) {
                          controller.addExpenses();
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        child: const Icon(Icons.add_rounded, color: AppColors.whiteText),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 20),
            order?.expenses == null
                ? _buildEmptyExpensesState(controller)
                : _buildExpensesDetails(order!.expenses!),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyExpensesState(OrderDetailsController controller) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: AppColors.lightGray,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderGray),
      ),
      child: Center(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.pureWhite,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(
                Icons.receipt_outlined,
                size: 40,
                color: AppColors.lightGrayText,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'no_expenses_added'.tr,
              style: AppColors.bodyStyle.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.mediumGray,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'click_to_add_expenses'.tr,
              style: AppColors.captionStyle,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExpensesDetails(OrderExpenses expenses) {
    return Column(
      children: [
        _buildExpenseItem('fuel'.tr, expenses.fuel, Icons.local_gas_station),
        _buildExpenseItem(
            'vehicle_wash'.tr, expenses.wash, Icons.car_crash_outlined),
        _buildExpenseItem('AdBlue', expenses.adBlue, Icons.opacity),
        _buildExpenseItem('other_expenses'.tr, expenses.other, Icons.receipt_long),
        Container(
          margin: const EdgeInsets.symmetric(vertical: 16),
          height: 1,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.transparent,
                AppColors.borderGray,
                Colors.transparent,
              ],
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppColors.lightGreenBg,
                AppColors.successGreen.withOpacity(0.1),
              ],
            ),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.successGreen.withOpacity(0.3)),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.successGreen,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.account_balance_wallet_outlined,
                    color: AppColors.whiteText, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'total'.tr,
                  style: AppColors.subHeadingStyle,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.successGreen,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '€${expenses.total.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.whiteText,
                  ),
                ),
              ),
            ],
          ),
        ),
        if (expenses.notes.isNotEmpty) ...[
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.lightBlueBg,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.progressBlue.withOpacity(0.3)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.note_outlined,
                    color: AppColors.progressBlue, size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'notes'.tr,
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: AppColors.primaryBlue,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        expenses.notes,
                        style: TextStyle(
                          color: AppColors.mediumGray,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildExpenseItem(String label, double amount, IconData icon) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.lightGray,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.borderGray),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.mediumGray, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: AppColors.bodyStyle.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.pureWhite,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: AppColors.borderGray),
            ),
            child: Text(
              '€${amount.toStringAsFixed(2)}',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: AppColors.darkGray,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(OrderDetailsController controller) {
    final order = controller.order;
    if (order == null) return const SizedBox();

    return Column(
      children: [
        _buildStatusActionButtons(controller),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => controller.editOrder(),
                icon: Icon(Icons.edit_outlined, size: 18),
                label: Text('edit'.tr),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  side: BorderSide(
                      color: controller.canEditOrder(order.id)
                          ? AppColors.progressBlue
                          : AppColors.borderGray
                  ),
                  foregroundColor: controller.canEditOrder(order.id)
                      ? AppColors.progressBlue
                      : AppColors.lightGrayText,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // Helper methods
  Color _getCategoryColor(ImageCategory category) {
    switch (category) {
      case ImageCategory.DAMAGE:
        return AppColors.errorRed;
      case ImageCategory.INTERIOR:
        return AppColors.progressBlue;
      case ImageCategory.EXTERIOR:
        return AppColors.successGreen;
      case ImageCategory.INTERIOR:
        return AppColors.pendingOrange;
      default:
        return AppColors.mediumGray;
    }
  }

  List<String> _getCompletedRequirements(OrderDetailsController controller) {
    final List<String> completed = [];
    final order = controller.order;

    if (order != null) {
      if (order.images.isNotEmpty) completed.add('add_image'.tr);
      if (order.driverSignature != null) completed.add('driver_signature'.tr);
      if (order.customerSignature != null) completed.add('customer_signature'.tr);
      if (order.expenses != null) completed.add('add_expenses'.tr);
    }

    return completed;
  }

  String _getServiceTypeText(ServiceType serviceType) {
    switch (serviceType) {
      case ServiceType.TRANSPORT:
        return 'transport'.tr;
      case ServiceType.WASH:
        return 'wash'.tr;
      case ServiceType.REGISTRATION:
        return 'registration'.tr;
      case ServiceType.INSPECTION:
        return 'inspection'.tr;
      case ServiceType.MAINTENANCE:
        return 'maintenance'.tr;
    }
  }

  String _getImageCategoryText(ImageCategory category) {
    switch (category) {
      case ImageCategory.PICKUP:
        return 'pickup'.tr;
      case ImageCategory.DELIVERY:
        return 'delivery'.tr;
      case ImageCategory.ADDITIONAL:
        return 'additional'.tr;
      case ImageCategory.DAMAGE:
        return 'damage'.tr;
      case ImageCategory.INTERIOR:
        return 'interior'.tr;
      case ImageCategory.EXTERIOR:
        return 'exterior'.tr;
    }
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day.toString().padLeft(2, '0')}.${dateTime.month.toString().padLeft(2, '0')}.${dateTime.year} ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  Widget _buildVehicleDamageSection(NewOrder order) {
    if (order.damages.isEmpty) {
      return Container(
        decoration: AppColors.elevatedCardDecoration,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.lightGreenBg,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(Icons.car_repair_outlined,
                        color: AppColors.successGreen, size: 24),
                  ),
                  const SizedBox(width: 12),
                  Expanded( // إضافة Expanded حول النص
                    child: Text(
                      'vehicle_damages'.tr,
                      style: AppColors.subHeadingStyle.copyWith(
                        color: AppColors.primaryBlue,
                      ),
                      overflow: TextOverflow.ellipsis, // إضافة overflow
                      maxLines: 2, // السماح بسطرين
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppColors.lightGreenBg,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.successGreen.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.successGreen,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.check_circle_outline,
                        color: AppColors.whiteText,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'no_damages_reported'.tr,
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: AppColors.darkGray,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'vehicle_in_good_condition'.tr,
                            style: TextStyle(
                              color: AppColors.mediumGray,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    }

    // تجميع الأضرار حسب الجانب
    final Map<VehicleSide, List<VehicleDamage>> damagesBySide = {};
    for (final damage in order.damages) {
      if (!damagesBySide.containsKey(damage.side)) {
        damagesBySide[damage.side] = [];
      }
      damagesBySide[damage.side]!.add(damage);
    }

    return Container(
      decoration: AppColors.elevatedCardDecoration,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.lightRedBg,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(Icons.car_repair_outlined,
                      color: AppColors.errorRed, size: 24),
                ),
                const SizedBox(width: 12),
                Expanded( // إضافة Expanded حول النص
                  child: Text(
                    'vehicle_damages'.tr,
                    style: AppColors.subHeadingStyle.copyWith(
                      color: AppColors.primaryBlue,
                    ),
                    overflow: TextOverflow.ellipsis, // إضافة overflow
                    maxLines: 2, // السماح بسطرين
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.errorRed,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    '${order.damages.length} ${'damages'.tr}',
                    style: const TextStyle(
                      color: AppColors.whiteText,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // عرض مخطط السيارة مع الأضرار
            _buildVehicleDiagramWithDamages(damagesBySide),

            const SizedBox(height: 24),

            // تفاصيل الأضرار لكل جانب
            ...damagesBySide.entries.map((entry) {
              return _buildSideDamageCard(entry.key, entry.value);
            }).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildVehicleDiagramWithDamages(Map<VehicleSide, List<VehicleDamage>> damagesBySide) {
    return Container(
      height: 220,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.lightGray,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderGray),
      ),
      child: Stack(
        children: [
          // خلفية السيارة
          Center(
            child: Container(
              width: 140,
              height: 200,
              decoration: BoxDecoration(
                color: AppColors.pureWhite,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.mediumGray, width: 2),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.lightShadow,
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.directions_car,
                    size: 60,
                    color: AppColors.mediumGray,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'vehicle'.tr,
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.secondaryText,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // نقاط الأضرار للجوانب
          ...damagesBySide.entries.map((entry) {
            return _buildDamageIndicator(entry.key, entry.value.length);
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildDamageIndicator(VehicleSide side, int damageCount) {
    Widget indicator = Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: AppColors.errorRed,
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.whiteText, width: 3),
        boxShadow: [
          BoxShadow(
            color: AppColors.errorRed.withOpacity(0.5),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Center(
        child: Text(
          '$damageCount',
          style: const TextStyle(
            color: AppColors.whiteText,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );

    // تحديد موقع المؤشر حسب الجانب
    switch (side) {
      case VehicleSide.FRONT:
        return Positioned(
          top: 20,
          left: 0,
          right: 0,
          child: Center(child: indicator),
        );
      case VehicleSide.REAR:
        return Positioned(
          bottom: 20,
          left: 0,
          right: 0,
          child: Center(child: indicator),
        );
      case VehicleSide.LEFT:
        return Positioned(
          top: 0,
          bottom: 0,
          left: 20,
          child: Center(child: indicator),
        );
      case VehicleSide.RIGHT:
        return Positioned(
          top: 0,
          bottom: 0,
          right: 20,
          child: Center(child: indicator),
        );
      case VehicleSide.TOP:
        return Positioned(
          top: 70,
          left: 0,
          right: 0,
          child: Center(child: indicator),
        );
    }
  }

  Widget _buildSideDamageCard(VehicleSide side, List<VehicleDamage> damages) {
    final sideColor = _getSideColor(side);
    final sideColorBg = _getSideColorBackground(side);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: sideColorBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: sideColor.withOpacity(0.3)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: sideColor,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    _getSideIcon(side),
                    color: AppColors.whiteText,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    _getVehicleSideText(side),
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.darkGray,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: sideColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${damages.length} ${'damages'.tr}',
                    style: const TextStyle(
                      color: AppColors.whiteText,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // عرض الأضرار
            ...damages.map((damage) => _buildDamageItem(damage, sideColor)).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildDamageItem(VehicleDamage damage, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: AppColors.cardDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  _getDamageTypeText(damage.type),
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.darkGray,
                  ),
                ),
              ),
            ],
          ),
          if (damage.description?.isNotEmpty == true) ...[
            const SizedBox(height: 8),
            Text(
              damage.description!,
              style: AppColors.bodyStyle.copyWith(
                height: 1.3,
              ),
            ),
          ],
        ],
      ),
    );
  }

  // دوال مساعدة محدثة
  Color _getSideColor(VehicleSide side) {
    switch (side) {
      case VehicleSide.FRONT:
        return AppColors.progressBlue;
      case VehicleSide.REAR:
        return AppColors.successGreen;
      case VehicleSide.LEFT:
        return AppColors.pendingOrange;
      case VehicleSide.RIGHT:
        return AppColors.primaryBlue;
      case VehicleSide.TOP:
        return AppColors.warningYellow;
    }
  }

  Color _getSideColorBackground(VehicleSide side) {
    switch (side) {
      case VehicleSide.FRONT:
        return AppColors.lightBlueBg;
      case VehicleSide.REAR:
        return AppColors.lightGreenBg;
      case VehicleSide.LEFT:
        return AppColors.lightOrangeBg;
      case VehicleSide.RIGHT:
        return AppColors.lightBlueBg;
      case VehicleSide.TOP:
        return AppColors.lightYellowBg;
    }
  }

  IconData _getSideIcon(VehicleSide side) {
    switch (side) {
      case VehicleSide.FRONT:
        return Icons.keyboard_arrow_up;
      case VehicleSide.REAR:
        return Icons.keyboard_arrow_down;
      case VehicleSide.LEFT:
        return Icons.keyboard_arrow_left;
      case VehicleSide.RIGHT:
        return Icons.keyboard_arrow_right;
      case VehicleSide.TOP:
        return Icons.keyboard_double_arrow_up;
    }
  }

  String _getVehicleSideText(VehicleSide side) {
    switch (side) {
      case VehicleSide.FRONT:
        return 'vehicle_front'.tr;
      case VehicleSide.REAR:
        return 'vehicle_rear'.tr;
      case VehicleSide.LEFT:
        return 'vehicle_left'.tr;
      case VehicleSide.RIGHT:
        return 'vehicle_right'.tr;
      case VehicleSide.TOP:
        return 'vehicle_top'.tr;
    }
  }

  String _getDamageTypeText(DamageType damageType) {
    switch (damageType) {
      case DamageType.DENT_BUMP:
        return 'dent_bump'.tr;
      case DamageType.STONE_CHIP:
        return 'stone_chip'.tr;
      case DamageType.SCRATCH_GRAZE:
        return 'scratch_graze'.tr;
      case DamageType.PAINT_DAMAGE:
        return 'paint_damage'.tr;
      case DamageType.CRACK_BREAK:
        return 'crack_break'.tr;
      case DamageType.MISSING:
        return 'missing'.tr;
    }
  }
}

// Enhanced version of SpeedDial with AppColors
class OptimizedSpeedDial extends StatefulWidget {
  final OrderDetailsController controller;
  final NewOrder order;

  const OptimizedSpeedDial({
    Key? key,
    required this.controller,
    required this.order,
  }) : super(key: key);

  @override
  _OptimizedSpeedDialState createState() => _OptimizedSpeedDialState();
}

class _OptimizedSpeedDialState extends State<OptimizedSpeedDial>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  bool _isOpen = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggle() {
    if (widget.controller.isLoading) return;

    if (_isOpen) {
      _controller.reverse();
    } else {
      _controller.forward();
    }
    setState(() {
      _isOpen = !_isOpen;
    });
  }

  @override
  Widget build(BuildContext context) {
    final actionItems = <SpeedDialChildData>[];

    // إضافة صورة
    actionItems.add(SpeedDialChildData(
      child: const Icon(Icons.add_a_photo_rounded),
      backgroundColor: AppColors.progressBlue,
      label: 'add_image'.tr,
      onTap: widget.controller.addImage,
      heroTag: "add_image_fab",
    ));

    // إضافة مصاريف
    if (!widget.controller.hasExpenses) {
      actionItems.add(SpeedDialChildData(
        child: const Icon(Icons.receipt_long_outlined),
        backgroundColor: AppColors.successGreen,
        label: 'add_expenses'.tr,
        onTap: widget.controller.addExpenses,
        heroTag: "add_expenses_fab",
      ));
    }

    // توقيع السائق
    if (widget.order.driverSignature == null) {
      actionItems.add(SpeedDialChildData(
        child: const Icon(Icons.local_shipping_outlined),
        backgroundColor: AppColors.primaryBlue,
        label: 'driver_signature'.tr,
        onTap: widget.controller.addDriverSignature,
        heroTag: "driver_signature_fab",
      ));
    }

    // توقيع العميل
    if (widget.order.customerSignature == null) {
      actionItems.add(SpeedDialChildData(
        child: const Icon(Icons.person_outline),
        backgroundColor: AppColors.pendingOrange,
        label: 'customer_signature'.tr,
        onTap: widget.controller.addCustomerSignature,
        heroTag: "customer_signature_fab",
      ));
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ...actionItems.reversed.map((item) {
          return AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return FadeTransition(
                opacity: _controller,
                child: SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0, 1),
                    end: Offset.zero,
                  ).animate(CurvedAnimation(
                    parent: _controller,
                    curve: Curves.easeOut,
                  )),
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    child: OptimizedSpeedDialChild(data: item),
                  ),
                ),
              );
            },
          );
        }),
        FloatingActionButton(
          heroTag: "order_details_main_fab",
          onPressed: _toggle,
          backgroundColor: AppColors.primaryBlue,
          foregroundColor: AppColors.whiteText,
          elevation: 8,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16)
          ),
          child: AnimatedIcon(
            icon: AnimatedIcons.menu_close,
            progress: _controller,
          ),
        ),
      ],
    );
  }
}

class SpeedDialChildData {
  final Widget child;
  final Color backgroundColor;
  final String label;
  final VoidCallback onTap;
  final String heroTag;

  SpeedDialChildData({
    required this.child,
    required this.backgroundColor,
    required this.label,
    required this.onTap,
    required this.heroTag,
  });
}

class OptimizedSpeedDialChild extends StatelessWidget {
  final SpeedDialChildData data;

  const OptimizedSpeedDialChild({
    Key? key,
    required this.data,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // نص التسمية
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: AppColors.pureWhite,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.borderGray),
            boxShadow: [
              BoxShadow(
                color: AppColors.lightShadow,
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Text(
            data.label,
            style: AppColors.bodyStyle.copyWith(
              fontWeight: FontWeight.w600,
              color: AppColors.darkGray,
            ),
          ),
        ),
        const SizedBox(width: 16),
        // زر الإجراء
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(28),
            boxShadow: [
              BoxShadow(
                color: AppColors.mediumShadow,
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: FloatingActionButton(
            mini: true,
            heroTag: data.heroTag,
            onPressed: data.onTap,
            backgroundColor: data.backgroundColor,
            foregroundColor: AppColors.whiteText,
            elevation: 0, // نستخدم الظل المخصص بدلاً من elevation
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(28),
            ),
            child: data.child,
          ),
        ),
      ],
    );
  }
}