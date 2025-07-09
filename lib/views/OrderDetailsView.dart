import 'package:automotive/config/app_config.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/order_controller.dart';
import '../controllers/order_view_details.dart';
import '../models/new_address.dart';
import '../models/new_order.dart';

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
            backgroundColor: Colors.grey.shade50,
            appBar: _buildSafeAppBar(controller),
            body: Obx(() {
              if (controller.isLoading) {
                return _buildLoadingOverlay();
              }

              return RefreshIndicator(
                onRefresh: () => controller.loadOrderDetails(orderId!),
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
              child: Text('start_execution'.tr),
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
              child: Text('complete_order'.tr),
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
            title: Text('alert'.tr),
            content: Text('operation_in_progress'.tr),
            actions: [
              TextButton(
                onPressed: () => Get.back(result: false),
                child: Text('stay'.tr),
              ),
              ElevatedButton(
                onPressed: () => Get.back(result: true),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                child: Text('exit'.tr),
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
      backgroundColor: Colors.blue.shade600,
      foregroundColor: Colors.white,
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
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          if (controller.order?.licensePlateNumber.isNotEmpty == true)
            Text(
              controller.order!.licensePlateNumber,
              style: const TextStyle(
                fontSize: 12,
                color: Colors.white70,
              ),
            ),
        ],
      ),
      actions: [
        if (controller.order != null)
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert),
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
                        color: Colors.blue.shade600, size: 20),
                    const SizedBox(width: 12),
                    Text('edit_details'.tr),
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
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.blue.shade600,
            Colors.indigo.shade600,
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.shade200.withOpacity(0.5),
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
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.assignment_outlined,
              color: Colors.white,
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
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  order.licensePlateNumber,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.white70,
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    _getServiceTypeText(order.serviceType),
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.white,
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
      color: Colors.grey.shade50,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(
                    strokeWidth: 3,
                    valueColor:
                    AlwaysStoppedAnimation<Color>(Colors.blue.shade600),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'processing'.tr,
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 16,
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
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.blue.shade800,
              Colors.blue.shade600,
              Colors.indigo.shade600,
            ],
          ),
        ),
        child: FlexibleSpaceBar(
          title: Obx(() {
            final order = controller.order;
            if (order == null) {
              return Text(
                'order_details'.tr,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              );
            }

            return Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  order.client.isNotEmpty ? order.client : 'order_details'.tr,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (order.licensePlateNumber.isNotEmpty)
                  Text(
                    order.licensePlateNumber,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
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
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.more_vert,
                  color: Colors.white,
                  size: 20,
                ),
              ),
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
                          color: Colors.blue.shade600, size: 20),
                      const SizedBox(width: 12),
                      Text('edit_details'.tr),
                    ],
                  ),
                ),
                if (controller.canCompleteOrder)
                  PopupMenuItem(
                    value: 'complete',
                    child: Row(
                      children: [
                        Icon(Icons.check_circle_outline,
                            color: Colors.green.shade600, size: 20),
                        const SizedBox(width: 12),
                        Text('complete_order'.tr),
                      ],
                    ),
                  ),
                PopupMenuItem(
                  value: 'delete',
                  child: Row(
                    children: [
                      Icon(Icons.delete_outline,
                          color: Colors.red.shade600, size: 20),
                      const SizedBox(width: 12),
                      Text('delete_order'.tr),
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
              valueColor: AlwaysStoppedAnimation<Color>(Colors.blue.shade600),
            ),
            const SizedBox(height: 16),
            Text(
              'loading_order_details'.tr,
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 16,
              ),
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
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.blue.shade600,
            Colors.indigo.shade600,
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.shade200.withOpacity(0.5),
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
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.timeline_rounded,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Text(
                  'order_progress'.tr,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
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
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${(completionPercentage * 100).toInt()}%',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
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
                    backgroundColor: Colors.white.withOpacity(0.2),
                    valueColor:
                    const AlwaysStoppedAnimation<Color>(Colors.white),
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
                Icon(Icons.checklist_rounded,
                    color: Colors.blue.shade600, size: 24),
                const SizedBox(width: 12),
                Text(
                  'order_requirements'.tr,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue.shade800,
                  ),
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
                    Colors.green.shade600,
                    Icons.check_circle_rounded,
                  )),

                // Missing requirements
                if (missing.isNotEmpty)
                  ...missing.map((item) => _buildRequirementItem(
                    item,
                    false,
                    Colors.orange.shade600,
                    Icons.radio_button_unchecked_rounded,
                  )),

                if (missing.isEmpty)
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.green.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.green.shade200),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.check_circle_rounded,
                            color: Colors.green.shade600),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'all_requirements_met_ready'.tr,
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: Colors.green.shade700,
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
              style: TextStyle(
                color: Colors.grey.shade700,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBasicInfoCard(NewOrder order) {
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
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(Icons.info_outline,
                      color: Colors.blue.shade600, size: 24),
                ),
                const SizedBox(width: 12),
                Text(
                  'basic_information'.tr,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue.shade800,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            _buildModernInfoGrid(order),
          ],
        ),
      ),
    );
  }

  Widget _buildModernInfoGrid(NewOrder order) {
    final infoItems = [
      {'label': 'client'.tr, 'value': order.client, 'icon': Icons.person_outline},
      {
        'label': 'phone'.tr,
        'value': order.clientPhone,
        'icon': Icons.phone_outlined
      },
      {
        'label': 'email'.tr,
        'value': order.clientEmail,
        'icon': Icons.email_outlined
      },
      {
        'label': 'vehicle_owner'.tr,
        'value': order.vehicleOwner,
        'icon': Icons.account_circle_outlined
      },
      {
        'label': 'license_plate'.tr,
        'value': order.licensePlateNumber,
        'icon': Icons.confirmation_number_outlined
      },
      {
        'label': 'service_type'.tr,
        'value': _getServiceTypeText(order.serviceType),
        'icon': Icons.build_outlined
      },
    ];

    return Column(
      children: [
        ...infoItems.map((item) => _buildModernInfoRow(
          item['label'] as String,
          item['value'] as String,
          item['icon'] as IconData,
        )),
        if (order.description.isNotEmpty) ...[
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.description_outlined,
                        color: Colors.grey.shade600, size: 18),
                    const SizedBox(width: 8),
                    Text(
                      'description'.tr,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: Colors.grey.shade700,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  order.description,
                  style: TextStyle(
                    color: Colors.grey.shade800,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
        if (order.comments.isNotEmpty) ...[
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.blue.shade200),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.comment_outlined,
                        color: Colors.blue.shade600, size: 18),
                    const SizedBox(width: 8),
                    Text(
                      'comments'.tr,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: Colors.blue.shade700,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  order.comments,
                  style: TextStyle(
                    color: Colors.blue.shade800,
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
                Text(
                  'addresses'.tr,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue.shade800,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            _buildAddressSection(
              'pickup_address'.tr,
              order.pickupAddress,
              Icons.upload_rounded,
              Colors.blue,
            ),
            const SizedBox(height: 16),
            _buildAddressSection(
              'delivery_address'.tr,
              order.deliveryAddress,
              Icons.download_rounded,
              Colors.green,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAddressSection(
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
          const SizedBox(height: 12),
          Text(
            '${address.street} ${address.houseNumber}',
            style: TextStyle(
              color: Colors.grey.shade800,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '${address.zipCode} ${address.city}',
            style: TextStyle(color: Colors.grey.shade700),
          ),
          if (address.country.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              address.country,
              style: TextStyle(color: Colors.grey.shade700),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildImagesSection(OrderDetailsController controller) {
    final order = controller.order;

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
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.purple.shade50,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(Icons.photo_library_outlined,
                          color: Colors.purple.shade600, size: 24),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      "images".tr,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                Material(
                  color: Colors.green.shade600,
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
                        color: Colors.white,
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
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(16),
        border:
        Border.all(color: Colors.grey.shade200, style: BorderStyle.solid),
      ),
      child: Center(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(
                Icons.photo_library_outlined,
                size: 48,
                color: Colors.grey.shade400,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'no_images_added'.tr,
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'click_to_upload'.tr,
              style: TextStyle(
                color: Colors.grey.shade500,
                fontSize: 14,
              ),
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
            color: Colors.black.withOpacity(0.08),
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
                    color: Colors.grey.shade200,
                    child: Center(
                      child: CircularProgressIndicator(
                        value: loadingProgress.expectedTotalBytes != null
                            ? loadingProgress.cumulativeBytesLoaded /
                            loadingProgress.expectedTotalBytes!
                            : null,
                        strokeWidth: 2,
                        valueColor:
                        AlwaysStoppedAnimation<Color>(Colors.blue.shade400),
                      ),
                    ),
                  );
                },
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: Colors.grey.shade200,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.broken_image_outlined,
                            color: Colors.grey.shade400, size: 32),
                        const SizedBox(height: 8),
                        Text(
                          'failed_to_load_image'.tr,
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 12,
                          ),
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
                      Colors.black.withOpacity(0.7),
                    ],
                  ),
                ),
              ),
            ),
            // Delete button (new)
            Positioned(
              top: 8,
              left: 8,
              child: GetBuilder<OrderDetailsController>(
                builder: (controller) => Material(
                  color: Colors.red.withOpacity(0.9),
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
                        color: Colors.white,
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
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Text(
                  _getImageCategoryText(image.category),
                  style: const TextStyle(
                    color: Colors.white,
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
                      color: Colors.white,
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
                    color: Colors.orange.shade50,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(Icons.draw_outlined,
                      color: Colors.orange.shade600, size: 24),
                ),
                const SizedBox(width: 12),
                Text(
                  'signatures'.tr,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue.shade800,
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
                    Colors.blue,
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
                    Colors.green,
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
      MaterialColor color,
      ) {
    final bool isSigned = signature != null;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isSigned ? color.shade50 : Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isSigned ? color.shade200 : Colors.grey.shade200,
          width: 1.5,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isSigned ? color.shade600 : Colors.grey.shade400,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              isSigned ? Icons.check_circle_outline : icon,
              color: Colors.white,
              size: 20,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                    color: isSigned ? color.shade700 : Colors.grey.shade700,
                  ),
                ),
                const SizedBox(height: 4),
                if (signature != null) ...[
                  Text(
                    signature.signerName,
                    style: TextStyle(
                      color: color.shade800,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'signed_at'.tr.replaceAll('{date}', _formatDateTime(signature.signedAt)),
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ] else ...[
                  Text(
                    'not_signed_yet'.tr,
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ],
            ),
          ),
          // Action buttons
          if (isSigned) ...[
            // Delete signature button (new)
            GetBuilder<OrderDetailsController>(
              builder: (controller) => Material(
                color: Colors.red.shade600,
                borderRadius: BorderRadius.circular(8),
                child: InkWell(
                  borderRadius: BorderRadius.circular(8),
                  onTap: controller.isLoading
                      ? null
                      : () => controller.deleteSignature(
                      signature!.id, signature.isDriver),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    child: const Icon(
                      Icons.delete_outline,
                      color: Colors.white,
                      size: 16,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
          ],
          if (!isSigned)
            Material(
              color: color.shade600,
              borderRadius: BorderRadius.circular(10),
              elevation: 2,
              child: InkWell(
                borderRadius: BorderRadius.circular(10),
                onTap: onAdd,
                child: Container(
                  padding: const EdgeInsets.all(12),
                  child: const Icon(Icons.add_rounded, color: Colors.white),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildExpensesSection(OrderDetailsController controller) {
    final order = controller.order;

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
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.green.shade50,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(Icons.receipt_long_outlined,
                          color: Colors.green.shade600, size: 24),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'expenses'.tr,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                if (controller.hasExpenses)
                  Material(
                    color: Colors.blue.shade600,
                    borderRadius: BorderRadius.circular(12),
                    elevation: 2,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: controller.isLoading
                          ? null
                          : () => controller.editExpenses(),
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        child: const Icon(Icons.edit, color: Colors.white),
                      ),
                    ),
                  ),
                if (!controller.hasExpenses)
                  Material(
                    color: Colors.green.shade600,
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
                        child: const Icon(Icons.add_rounded, color: Colors.white),
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
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(16),
        border:
        Border.all(color: Colors.grey.shade200, style: BorderStyle.solid),
      ),
      child: Center(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(
                Icons.receipt_outlined,
                size: 40,
                color: Colors.grey.shade400,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'no_expenses_added'.tr,
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'click_to_add_expenses'.tr,
              style: TextStyle(
                color: Colors.grey.shade500,
                fontSize: 14,
              ),
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
                Colors.grey.shade300,
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
                Colors.green.shade50,
                Colors.green.shade100,
              ],
            ),
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
                child: const Icon(Icons.account_balance_wallet_outlined,
                    color: Colors.white, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'total'.tr,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Container(
                padding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.green.shade600,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '€${expenses.total.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
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
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.blue.shade200),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.note_outlined,
                    color: Colors.blue.shade600, size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'notes'.tr,
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: Colors.blue.shade700,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        expenses.notes,
                        style: TextStyle(
                          color: Colors.blue.shade800,
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
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.grey.shade600, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey.shade700,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              '€${amount.toStringAsFixed(2)}',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade800,
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
                          ? Colors.blue.shade300
                          : Colors.grey.shade300
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildFloatingActionMenu(OrderDetailsController controller) {
    return Obx(() {
      final order = controller.order;
      if (order == null || order.isCompleted) return const SizedBox.shrink();

      return OptimizedSpeedDial(
        controller: controller,
        order: order,
      );
    });
  }

  // Helper methods
  Color _getCategoryColor(ImageCategory category) {
    switch (category) {
      case ImageCategory.PICKUP:
        return Colors.blue.shade600;
      case ImageCategory.DELIVERY:
        return Colors.green.shade600;
      case ImageCategory.DAMAGE:
        return Colors.red.shade600;
      case ImageCategory.ADDITIONAL:
        return Colors.purple.shade600;
      case ImageCategory.INTERIOR:
        return Colors.orange.shade600;
      case ImageCategory.EXTERIOR:
        return Colors.teal.shade600;
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
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
}

// Enhanced version of SpeedDial
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

    actionItems.add(SpeedDialChildData(
      child: const Icon(Icons.add_a_photo_rounded),
      backgroundColor: Colors.purple.shade600,
      label: 'add_image'.tr,
      onTap: widget.controller.addImage,
      heroTag: "add_image_fab",
    ));

    if (!widget.controller.hasExpenses) {
      actionItems.add(SpeedDialChildData(
        child: const Icon(Icons.receipt_long_outlined),
        backgroundColor: Colors.green.shade600,
        label: 'add_expenses'.tr,
        onTap: widget.controller.addExpenses,
        heroTag: "add_expenses_fab",
      ));
    }

    if (widget.order.driverSignature == null) {
      actionItems.add(SpeedDialChildData(
        child: const Icon(Icons.local_shipping_outlined),
        backgroundColor: Colors.blue.shade600,
        label: 'driver_signature'.tr,
        onTap: widget.controller.addDriverSignature,
        heroTag: "driver_signature_fab",
      ));
    }

    if (widget.order.customerSignature == null) {
      actionItems.add(SpeedDialChildData(
        child: const Icon(Icons.person_outline),
        backgroundColor: Colors.orange.shade600,
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
          backgroundColor: Colors.blue.shade600,
          foregroundColor: Colors.white,
          elevation: 8,
          shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
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
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Text(
            data.label,
            style: TextStyle(
              color: Colors.grey.shade800,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        const SizedBox(width: 16),
        FloatingActionButton(
          mini: true,
          heroTag: data.heroTag,
          onPressed: data.onTap,
          backgroundColor: data.backgroundColor,
          foregroundColor: Colors.white,
          child: data.child,
        ),
      ],
    );
  }
}