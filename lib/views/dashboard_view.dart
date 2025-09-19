import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';
import '../controllers/auth_controller.dart';
import '../controllers/order_controller.dart';
import '../models/new_order.dart';
import '../services/order_service.dart';
import '../utils/AppColors.dart';
import '../widgets/LanguageSwitcher.dart';

class DashboardView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final NewOrderController orderController = Get.put(NewOrderController());
    final AuthController authController = Get.find<AuthController>();

    return Scaffold(
      backgroundColor: AppColors.lightGray, // استخدام اللون الرسمي للخلفية
      appBar: _buildAppBar(authController, orderController),
      body: CustomScrollView(
        slivers: [
          // Header Section with Stats
          SliverToBoxAdapter(
            child: _buildHeaderSection(orderController),
          ),

          // Search Section
          SliverToBoxAdapter(
            child: _buildSearchSection(orderController),
          ),

          // Orders List
          SliverToBoxAdapter(
            child: Obx(() {
              if (orderController.isLoading) {
                return _buildLoadingState();
              }

              final filteredOrders = orderController.filteredOrders;

              if (filteredOrders.isEmpty) {
                return _buildEmptyState();
              }

              return _buildOrdersList(filteredOrders, orderController);
            }),
          ),
        ],
      ),
      floatingActionButton: _buildFloatingActionButton(),
    );
  }

  PreferredSizeWidget _buildAppBar(AuthController authController, NewOrderController orderController) {
    return AppBar(
      elevation: 0,
      backgroundColor: AppColors.primaryBlue, // اللون الأزرق الصناعي الرسمي
      title: Obx(() => Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.whiteText.withOpacity(0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.dashboard_rounded,
              color: AppColors.whiteText,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${'welcome'.tr} ${authController.currentUserName}',
                style: AppColors.buttonTextStyle.copyWith(
                  color: AppColors.whiteText,
                  fontSize: 16,
                ),
              ),
              Text(
                'dashboard'.tr,
                style: AppColors.captionStyle.copyWith(
                  color: AppColors.whiteText.withOpacity(0.8),
                ),
              ),
            ],
          ),
        ],
      )),
      actions: [
        // زر تغيير اللغة
        LanguageSwitcher(),

        PopupMenuButton<String>(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.whiteText.withOpacity(0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.more_vert, color: AppColors.whiteText, size: 18),
          ),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          onSelected: (value) {
            if (value == 'logout') _showLogoutDialog(authController);
          },
          itemBuilder: (context) => [
            PopupMenuItem(
              value: 'logout',
              child: Row(
                children: [
                  Icon(Icons.logout_rounded, color: AppColors.errorRed, size: 18),
                  const SizedBox(width: 8),
                  Text('logout'.tr, style: AppColors.bodyStyle),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  Widget _buildHeaderSection(NewOrderController controller) {
    return Container(
      margin: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'quick_stats'.tr,
            style: AppColors.subHeadingStyle,
          ),
          const SizedBox(height: 12),
          _buildCompactStatsGrid(controller),
        ],
      ),
    );
  }

  Widget _buildCompactStatsGrid(NewOrderController controller) {
    return Obx(() {
      final stats = [
        {
          'title': 'total'.tr,
          'value': '${controller.totalOrders}',
          'icon': Icons.assignment_outlined,
          'color': AppColors.mediumGray,
          'bgColor': AppColors.lightGray,
        },
        {
          'title': 'pending'.tr,
          'value': '${controller.pendingOrders}',
          'icon': Icons.schedule_outlined,
          'color': AppColors.pendingOrange,
          'bgColor': AppColors.lightOrangeBg,
        },
        {
          'title': 'in_progress'.tr,
          'value': '${controller.inProgressOrders}',
          'icon': Icons.directions_car_outlined,
          'color': AppColors.progressBlue,
          'bgColor': AppColors.lightBlueBg,
        },
        {
          'title': 'completed'.tr,
          'value': '${controller.completedOrders}',
          'icon': Icons.check_circle_outline,
          'color': AppColors.successGreen,
          'bgColor': AppColors.lightGreenBg,
        },
      ];

      return GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 2.0,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
        ),
        itemCount: stats.length,
        itemBuilder: (context, index) {
          final stat = stats[index];
          return _buildCompactStatCard(
            stat['title'] as String,
            stat['value'] as String,
            stat['icon'] as IconData,
            stat['color'] as Color,
            stat['bgColor'] as Color,
          );
        },
      );
    });
  }

  Widget _buildCompactStatCard(String title, String value, IconData icon, Color color, Color bgColor) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: AppColors.cardDecoration,
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 20, color: color),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  value,
                  style: AppColors.subHeadingStyle.copyWith(
                    fontSize: 20,
                    color: color,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  title,
                  style: AppColors.captionStyle.copyWith(
                    fontWeight: FontWeight.w500,
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

  Widget _buildSearchSection(NewOrderController controller) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'search_and_filter'.tr,
            style: AppColors.subHeadingStyle,
          ),
          const SizedBox(height: 12),

          // Search Bar
          Container(
            decoration: AppColors.cardDecoration,
            child: TextField(
              onChanged: controller.updateSearchQuery,
              decoration: InputDecoration(
                hintText: 'search_orders'.tr,
                hintStyle: AppColors.captionStyle.copyWith(
                  color: AppColors.lightGrayText,
                ),
                prefixIcon: Icon(
                  Icons.search_rounded,
                  color: AppColors.lightGrayText,
                  size: 20,
                ),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
            ),
          ),

          const SizedBox(height: 12),

          // Filter Chips - Horizontal Scroll
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildFilterChip('all'.tr, 'all', controller),
                _buildFilterChip('pending'.tr, 'pending', controller),
                _buildFilterChip('in_progress'.tr, 'in_progress', controller),
                _buildFilterChip('completed'.tr, 'completed', controller),
              ],
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, String value, NewOrderController controller) {
    return Obx(() {
      final isSelected = controller.statusFilter == value;
      return Container(
        margin: const EdgeInsets.only(left: 8),
        child: FilterChip(
          label: Text(
            label,
            style: AppColors.captionStyle.copyWith(
              color: isSelected ? AppColors.whiteText : AppColors.mediumGray,
              fontWeight: FontWeight.w500,
              fontSize: 13,
            ),
          ),
          selected: isSelected,
          onSelected: (_) => controller.updateStatusFilter(value),
          backgroundColor: AppColors.pureWhite,
          selectedColor: AppColors.primaryBlue,
          checkmarkColor: AppColors.whiteText,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(
              color: isSelected ? AppColors.primaryBlue : AppColors.borderGray,
            ),
          ),
          elevation: isSelected ? 2 : 0,
          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
      );
    });
  }

  Widget _buildLoadingState() {
    return Container(
      height: 300,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryBlue),
            ),
            const SizedBox(height: 16),
            Text(
              'loading_orders'.tr,
              style: AppColors.bodyStyle,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(32),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.lightGray,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(
                Icons.assignment_outlined,
                size: 48,
                color: AppColors.lightGrayText,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'no_orders'.tr,
              style: AppColors.subHeadingStyle,
            ),
            const SizedBox(height: 8),
            Text(
              'create_first_order'.tr,
              style: AppColors.bodyStyle,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrdersList(List<NewOrder> orders, NewOrderController controller) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'order_list'.tr,
            style: AppColors.subHeadingStyle,
          ),
          const SizedBox(height: 12),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: orders.length,
            itemBuilder: (context, index) {
              final order = orders[index];
              return _buildSimpleOrderCard(order, controller);
            },
          ),
          const SizedBox(height: 100), // Space for FAB
        ],
      ),
    );
  }

  Widget _buildSimpleOrderCard(NewOrder order, NewOrderController controller) {
    final completionPercentage = controller.getOrderCompletionPercentage(order.id);
    final statusColor = AppColors.getStatusColor(order.status);
    final statusBgColor = AppColors.getStatusBackgroundColor(order.status);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: AppColors.cardDecoration,
      child: InkWell(
        onTap: () => _viewOrder(order),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Row
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: statusBgColor,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      _getServiceIcon(order.serviceType),
                      color: statusColor,
                      size: 18,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          order.client,
                          style: AppColors.bodyStyle.copyWith(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: AppColors.darkGray,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            // رقم اللوحة
                            Text(
                              order.licensePlateNumber,
                              style: AppColors.captionStyle,
                            ),
                            // فاصل
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 6),
                              child: Text(
                                '•',
                                style: AppColors.captionStyle.copyWith(
                                  color: AppColors.lightGrayText,
                                ),
                              ),
                            ),
                            // نوع الخدمة
                            Text(
                              _getServiceTypeName(order.serviceType),
                              style: AppColors.captionStyle.copyWith(
                                color: AppColors.primaryBlue,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: statusColor,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      controller.getStatusText(order.status),
                      style: AppColors.captionStyle.copyWith(
                        color: AppColors.whiteText,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // Progress Bar
              Row(
                children: [
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(3),
                      child: LinearProgressIndicator(
                        value: completionPercentage,
                        backgroundColor: AppColors.borderGray,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          completionPercentage == 1.0 ? AppColors.successGreen : AppColors.primaryBlue,
                        ),
                        minHeight: 4,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${(completionPercentage * 100).toInt()}%',
                    style: AppColors.captionStyle.copyWith(
                      fontWeight: FontWeight.w600,
                      color: completionPercentage == 1.0 ? AppColors.successGreen : AppColors.primaryBlue,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // Location Info
              Row(
                children: [
                  Icon(Icons.location_on_outlined, size: 14, color: AppColors.lightGrayText),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      '${order.pickupAddress.city} → ${order.deliveryAddress.city}',
                      style: AppColors.captionStyle,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(Icons.access_time_rounded, size: 14, color: AppColors.lightGrayText),
                  const SizedBox(width: 4),
                  Text(
                    _formatDate(order.createdAt),
                    style: AppColors.captionStyle,
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // استخدام الأزرار الذكية حسب حالة الطلب
              _buildSmartActionButtons(order, controller),
            ],
          ),
        ),
      ),
    );
  }

  String _getServiceTypeName(ServiceType serviceType) {
    switch (serviceType) {
      case ServiceType.WASH:
        return 'wash'.tr;
      case ServiceType.REGISTRATION:
        return 'registration'.tr;
      case ServiceType.TRANSPORT:
        return 'transport'.tr;
      case ServiceType.INSPECTION:
        return 'inspection'.tr;
      case ServiceType.MAINTENANCE:
        return 'maintenance'.tr;
      default:
        return 'other'.tr;
    }
  }

  // دالة جديدة للأزرار الذكية حسب حالة الطلب
  Widget _buildSmartActionButtons(NewOrder order, NewOrderController controller) {
    final status = order.status.toLowerCase();

    if (status == 'pending') {
      // للطلبيات المعلقة: عرض + بدء + حذف
      return Row(
        children: [
          // View Button
          Expanded(
            child: OutlinedButton(
              onPressed: () => _viewOrder(order),
              style: AppColors.secondaryButtonStyle.copyWith(
                padding: MaterialStateProperty.all(
                  const EdgeInsets.symmetric(vertical: 10),
                ),
              ),
              child: Text('view'.tr, style: AppColors.captionStyle),
            ),
          ),
          const SizedBox(width: 8),

          // Start Button
          Expanded(
            child: ElevatedButton(
              onPressed: () => _startOrder(order, controller),
              style: AppColors.primaryButtonStyle.copyWith(
                padding: MaterialStateProperty.all(
                  const EdgeInsets.symmetric(vertical: 10),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.play_arrow, size: 14, color: AppColors.whiteText),
                  const SizedBox(width: 4),
                  Text('start'.tr, style: AppColors.captionStyle.copyWith(
                    color: AppColors.whiteText,
                    fontWeight: FontWeight.w600,
                  )),
                ],
              ),
            ),
          ),
          const SizedBox(width: 8),

          // Delete Button
          Expanded(
            child: OutlinedButton(
              onPressed: () => controller.confirmDeleteOrder(order, controller),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 10),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                side: BorderSide(color: AppColors.errorRed.withOpacity(0.5)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.delete, size: 14, color: AppColors.errorRed),
                  const SizedBox(width: 4),
                  Text('delete'.tr, style: AppColors.captionStyle.copyWith(
                    color: AppColors.errorRed,
                    fontWeight: FontWeight.w600,
                  )),
                ],
              ),
            ),
          ),
        ],
      );
    }
    else if (status == 'in_progress') {
      // للطلبيات قيد التنفيذ
      if (!order.hasImages) {
        return Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () => _viewOrder(order),
                style: AppColors.secondaryButtonStyle.copyWith(
                  padding: MaterialStateProperty.all(
                    const EdgeInsets.symmetric(vertical: 10),
                  ),
                ),
                child: Text('view'.tr, style: AppColors.captionStyle),
              ),
            ),
          ],
        );
      }
      else {
        return Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () => _viewOrder(order),
                style: AppColors.secondaryButtonStyle.copyWith(
                  padding: MaterialStateProperty.all(
                    const EdgeInsets.symmetric(vertical: 10),
                  ),
                ),
                child: Text('view'.tr, style: AppColors.captionStyle),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              flex: 2,
              child: ElevatedButton(
                onPressed: () => _completeOrder(order, controller),
                style: AppColors.successButtonStyle.copyWith(
                  padding: MaterialStateProperty.all(
                    const EdgeInsets.symmetric(vertical: 10),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.check_circle, size: 14, color: AppColors.whiteText),
                    const SizedBox(width: 6),
                    Text('complete_order'.tr, style: AppColors.captionStyle.copyWith(
                      color: AppColors.whiteText,
                      fontWeight: FontWeight.w600,
                    )),
                  ],
                ),
              ),
            ),
          ],
        );
      }
    }
    else if (status == 'completed') {
      // للطلبيات المكتملة: عرض + تقرير HTML + إرسال بريد
      return Column(
        children: [
          // الصف الأول: عرض التفاصيل + تقرير HTML
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => _viewOrder(order),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    side: BorderSide(color: AppColors.successGreen.withOpacity(0.5)),
                  ),
                  child: Text('view'.tr, style: AppColors.captionStyle.copyWith(
                    color: AppColors.successGreen,
                    fontWeight: FontWeight.w600,
                  )),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                flex: 2,
                child: ElevatedButton(
                  onPressed: () => _generatePdfReport(order),
                  style: AppColors.successButtonStyle.copyWith(
                    padding: MaterialStateProperty.all(
                      const EdgeInsets.symmetric(vertical: 10),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.description, size: 14, color: AppColors.whiteText),
                      const SizedBox(width: 6),
                      Text('pdf_report'.tr, style: AppColors.captionStyle.copyWith(
                        color: AppColors.whiteText,
                        fontWeight: FontWeight.w600,
                      )),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          // الصف الثاني: إرسال بريد إلكتروني + معاينة
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => _sendEmailReport(order, controller),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    side: BorderSide(color: AppColors.progressBlue.withOpacity(0.5)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.email, size: 14, color: AppColors.progressBlue),
                      const SizedBox(width: 4),
                      Text('send_email'.tr, style: AppColors.captionStyle.copyWith(
                        color: AppColors.progressBlue,
                        fontWeight: FontWeight.w600,
                      )),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton(
                  onPressed: () => _previewHtmlReport(order),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    side: BorderSide(color: AppColors.mediumGray.withOpacity(0.5)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.preview, size: 14, color: AppColors.mediumGray),
                      const SizedBox(width: 4),
                      Text('preview'.tr, style: AppColors.captionStyle.copyWith(
                        color: AppColors.mediumGray,
                        fontWeight: FontWeight.w600,
                      )),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      );
    }
    else if (status == 'cancelled') {
      // للطلبيات الملغية
      return Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: () => _viewOrder(order),
              style: AppColors.secondaryButtonStyle.copyWith(
                padding: MaterialStateProperty.all(
                  const EdgeInsets.symmetric(vertical: 10),
                ),
              ),
              child: Text('view_details'.tr, style: AppColors.captionStyle),
            ),
          ),
        ],
      );
    }
    else {
      return const SizedBox.shrink();
    }
  }


// دالة توليد تقرير PDF محسنة ومُصححة
  Future<void> _generatePdfReport(NewOrder order) async {
    try {
      // عرض مؤشر تحميل مع تفاصيل أكثر
      Get.dialog(
        Center(
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.pureWhite,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.lightRedBg,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.picture_as_pdf,
                    color: AppColors.errorRed,
                    size: 40,
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'generating_pdf_report'.tr,
                  style: AppColors.bodyStyle.copyWith(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.darkGray,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'creating_professional_pdf'.tr,
                  style: AppColors.captionStyle,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: 200,
                  child: LinearProgressIndicator(
                    backgroundColor: AppColors.borderGray,
                    valueColor: const AlwaysStoppedAnimation<Color>(AppColors.errorRed),
                  ),
                ),
              ],
            ),
          ),
        ),
        barrierDismissible: false,
      );

      // إنشاء تقرير PDF باستخدام NewOrderController
      final controller = Get.find<NewOrderController>();
      await controller.generatePdfReport(order.id);

      // إغلاق مؤشر التحميل
      if (Get.isDialogOpen == true) {
        Get.back();
      }

    } catch (e) {
      // إغلاق مؤشر التحميل في حالة الخطأ
      if (Get.isDialogOpen == true) {
        Get.back();
      }

      // عرض رسالة خطأ محسنة
      Get.dialog(
        AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Row(
            children: [
              const Icon(Icons.error_outline, color: AppColors.errorRed, size: 24),
              const SizedBox(width: 8),
              Text('pdf_report_failed'.tr, style: AppColors.bodyStyle.copyWith(fontSize: 16)),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'pdf_report_error_message'.tr,
                style: AppColors.bodyStyle.copyWith(height: 1.4),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.lightRedBg,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.errorRed.withOpacity(0.3)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'error_details'.tr,
                      style: AppColors.captionStyle.copyWith(
                        color: AppColors.errorRed,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      e.toString(),
                      style: AppColors.captionStyle.copyWith(
                        color: AppColors.errorRed,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Get.back(),
              child: Text('ok'.tr, style: AppColors.bodyStyle.copyWith(color: AppColors.mediumGray)),
            ),
            ElevatedButton(
              onPressed: () {
                Get.back();
                _generatePdfReport(order);
              },
              style: AppColors.dangerButtonStyle,
              child: Text('retry'.tr, style: AppColors.buttonTextStyle.copyWith(color: AppColors.whiteText)),
            ),
          ],
        ),
      );
    }
  }

  Future<void> _saveAndDisplayPdfReport(Uint8List pdfBytes, String orderId) async {
    try {
      // الحصول على مسار التخزين المؤقت
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
        // عرض رسالة نجاح محسنة
        Get.snackbar(
          '📄 ${'pdf_report_generated'.tr}',
          'pdf_report_saved_successfully'.tr,
          backgroundColor: AppColors.errorRed,
          colorText: AppColors.whiteText,
          snackPosition: SnackPosition.TOP,
          duration: const Duration(seconds: 5),
          margin: const EdgeInsets.all(16),
          borderRadius: 12,
          icon: const Icon(Icons.picture_as_pdf, color: AppColors.whiteText),
          mainButton: TextButton(
            onPressed: () {
              Get.closeCurrentSnackbar();
              _showPdfOptionsDialog(filePath, orderId);
            },
            child: Text('options'.tr, style: AppColors.buttonTextStyle.copyWith(
              color: AppColors.whiteText,
              fontWeight: FontWeight.bold,
            )),
          ),
        );
      } else {
        throw Exception('failed_to_open_pdf_file'.tr);
      }

    } catch (e) {
      throw Exception('failed_to_save_pdf_file'.tr.replaceAll('{error}', e.toString()));
    }
  }

// عرض خيارات تقرير PDF
  Future<void> _showPdfOptionsDialog(String filePath, String orderId) async {
    // البحث عن الطلب بالـ ID
    final controller = Get.find<NewOrderController>();
    final order = controller.getOrderById(orderId);

    if (order == null) {
      Get.snackbar(
        'error'.tr,
        'order_not_found'.tr,
        backgroundColor: AppColors.errorRed,
        colorText: AppColors.whiteText,
      );
      return;
    }

    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            const Icon(Icons.picture_as_pdf, color: AppColors.errorRed, size: 24),
            const SizedBox(width: 8),
            Text('pdf_options'.tr, style: AppColors.bodyStyle.copyWith(fontSize: 16)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'pdf_generated_successfully_options'.tr,
              style: AppColors.bodyStyle.copyWith(height: 1.4),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),

            // خيار المشاركة
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.lightBlueBg,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.share, color: AppColors.progressBlue, size: 20),
              ),
              title: Text('share_pdf'.tr, style: AppColors.bodyStyle.copyWith(fontWeight: FontWeight.w500)),
              subtitle: Text('share_with_other_apps'.tr, style: AppColors.captionStyle),
              onTap: () {
                Get.back();
                _sharePdfReport(filePath);
              },
            ),

            const Divider(height: 1, color: AppColors.borderGray),

            // خيار إرسال بالبريد الإلكتروني
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.lightGreenBg,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.email, color: AppColors.successGreen, size: 20),
              ),
              title: Text('send_by_email'.tr, style: AppColors.bodyStyle.copyWith(fontWeight: FontWeight.w500)),
              subtitle: Text('send_pdf_to_client'.tr, style: AppColors.captionStyle),
              onTap: () {
                Get.back();
                _sendPdfEmailFromDialog(order);
              },
            ),

            const Divider(height: 1, color: AppColors.borderGray),

            // خيار نسخ المسار
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.lightGray,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.copy, color: AppColors.mediumGray, size: 20),
              ),
              title: Text('copy_file_path'.tr, style: AppColors.bodyStyle.copyWith(fontWeight: FontWeight.w500)),
              subtitle: Text('copy_path_to_clipboard'.tr, style: AppColors.captionStyle),
              onTap: () {
                Get.back();
                _copyFilePathToClipboard(filePath);
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text('close'.tr, style: AppColors.bodyStyle.copyWith(color: AppColors.mediumGray)),
          ),
        ],
      ),
    );
  }

// إرسال تقرير PDF بالبريد الإلكتروني من الـ dialog
  Future<void> _sendPdfEmailFromDialog(NewOrder order) async {
    final controller = Get.find<NewOrderController>();
    await controller.sendEmailReport(order);
  }

// مشاركة تقرير PDF
  Future<void> _sharePdfReport(String filePath) async {
    try {
      // يمكنك استخدام مكتبة share_plus لمشاركة الملف
      // await Share.shareXFiles([XFile(filePath)], text: 'Fahrzeugübergabe Bericht');

      // أو نسخ المسار إلى الحافظة كحل بديل
      await Clipboard.setData(ClipboardData(text: filePath));
      Get.snackbar(
        '📋 ${'file_path_copied'.tr}',
        'pdf_path_copied_successfully'.tr,
        backgroundColor: AppColors.progressBlue,
        colorText: AppColors.whiteText,
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 3),
        icon: const Icon(Icons.copy, color: AppColors.whiteText),
      );
    } catch (e) {
      print('❌ خطأ في مشاركة الملف: $e');
      Get.snackbar(
        'share_error'.tr,
        'failed_to_share_pdf'.tr,
        backgroundColor: AppColors.errorRed,
        colorText: AppColors.whiteText,
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 3),
      );
    }
  }

// نسخ مسار الملف إلى الحافظة
  Future<void> _copyFilePathToClipboard(String filePath) async {
    try {
      await Clipboard.setData(ClipboardData(text: filePath));
      Get.snackbar(
        '📋 ${'path_copied'.tr}',
        'file_path_copied_to_clipboard'.tr,
        backgroundColor: AppColors.mediumGray,
        colorText: AppColors.whiteText,
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 3),
        icon: const Icon(Icons.copy_all, color: AppColors.whiteText),
      );
    } catch (e) {
      print('❌ خطأ في نسخ المسار: $e');
    }
  }

// إرسال التقرير بالبريد الإلكتروني من الـ dialog
  Future<void> _sendEmailReport(NewOrder order, NewOrderController controller) async {
    await controller.sendEmailReport(order);
  }

// معاينة تقرير HTML
  Future<void> _previewHtmlReport(NewOrder order) async {
    try {
      // عرض مؤشر تحميل للمعاينة
      Get.dialog(
        Center(
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.pureWhite,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.lightGray,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.preview,
                    color: AppColors.mediumGray,
                    size: 40,
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'loading_preview'.tr,
                  style: AppColors.bodyStyle.copyWith(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.darkGray,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'preparing_report_preview'.tr,
                  style: AppColors.captionStyle,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: 200,
                  child: LinearProgressIndicator(
                    backgroundColor: AppColors.borderGray,
                    valueColor: const AlwaysStoppedAnimation<Color>(AppColors.mediumGray),
                  ),
                ),
              ],
            ),
          ),
        ),
        barrierDismissible: false,
      );

      // الحصول على معاينة التقرير
      final htmlContent = await NewOrderService().previewOrderHtmlReport(order.id!);

      // إغلاق مؤشر التحميل
      Get.back();

      // حفظ وعرض المعاينة
      await _displayHtmlPreview(htmlContent, order);

    } catch (e) {
      Get.back(); // إغلاق مؤشر التحميل في حالة الخطأ

      Get.snackbar(
        '❌ ${'preview_failed'.tr}',
        'failed_to_load_preview'.tr.replaceAll('error', e.toString()),
        backgroundColor: AppColors.errorRed,
        colorText: AppColors.whiteText,
        snackPosition: SnackPosition.TOP,
        duration: const Duration(seconds: 4),
        icon: const Icon(Icons.error_outline, color: AppColors.whiteText),
      );
    }
  }

// عرض معاينة HTML
  Future<void> _displayHtmlPreview(String htmlContent, NewOrder order) async {
    try {
      // حفظ الملف للمعاينة
      final directory = await getTemporaryDirectory();
      final fileName = 'Preview_${order.orderNumber ?? order.id}_${DateTime.now().millisecondsSinceEpoch}.html';
      final filePath = '${directory.path}/$fileName';

      final file = File(filePath);
      await file.writeAsString(htmlContent, encoding: utf8);

      // فتح للمعاينة
      final result = await OpenFilex.open(filePath);

      if (result.type == ResultType.done) {
        Get.snackbar(
          '👁️ ${'preview_opened'.tr}',
          'report_preview_ready'.tr,
          backgroundColor: AppColors.mediumGray,
          colorText: AppColors.whiteText,
          snackPosition: SnackPosition.TOP,
          duration: const Duration(seconds: 3),
          icon: const Icon(Icons.preview, color: AppColors.whiteText),
        );
      } else {
        throw Exception('failed_to_open_preview'.tr);
      }

    } catch (e) {
      throw Exception('failed_to_display_preview'.tr.replaceAll('error', e.toString()));
    }
  }



  // تنفيذ إرسال البريد الإلكتروني
  Future<void> _performEmailSend(NewOrder order, String email) async {
    // عرض مؤشر تحميل للإرسال
    Get.dialog(
      WillPopScope(
        onWillPop: () async => false,
        child: Center(
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.pureWhite,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const CircularProgressIndicator(color: AppColors.progressBlue),
                const SizedBox(height: 16),
                Text(
                  'sending_email_report'.tr,
                  style: AppColors.bodyStyle.copyWith(fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 8),
                Text(
                  'please_wait_sending'.tr,
                  style: AppColors.captionStyle,
                ),
                const SizedBox(height: 8),
                Text(
                  email,
                  style: AppColors.captionStyle.copyWith(
                    color: AppColors.progressBlue,
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
      // إرسال التقرير عبر البريد الإلكتروني
      final result = await NewOrderService().sendOrderHtmlReportByEmail(order.id!, email);

      // إغلاق مؤشر التحميل
      Get.back();

      // عرض نتيجة الإرسال
      await _showEmailSendResult(result, order, email);

    } catch (e) {
      // إغلاق مؤشر التحميل في حالة الخطأ
      Get.back();

      // عرض رسالة خطأ
      await _showEmailSendError(e.toString(), order, email);
    }
  }

  // عرض نتيجة إرسال البريد الإلكتروني
  Future<void> _showEmailSendResult(EmailReportResult result, NewOrder order, String email) async {
    if (result.success) {
      // نجح الإرسال
      Get.dialog(
        AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Row(
            children: [
              const Icon(Icons.check_circle, color: AppColors.successGreen, size: 24),
              const SizedBox(width: 8),
              Text('email_sent_successfully'.tr, style: AppColors.bodyStyle.copyWith(fontSize: 16)),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'email_sent_success_message'.tr,
                style: AppColors.bodyStyle.copyWith(height: 1.4),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.lightGreenBg,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.successGreen.withOpacity(0.3)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.email, color: AppColors.successGreen, size: 16),
                        const SizedBox(width: 6),
                        Text(
                          'sent_to'.tr,
                          style: AppColors.captionStyle.copyWith(
                            color: AppColors.successGreen,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      email,
                      style: AppColors.captionStyle.copyWith(
                        color: AppColors.successGreen,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.access_time, color: AppColors.successGreen, size: 16),
                        const SizedBox(width: 6),
                        Text(
                          'sent_at'.tr,
                          style: AppColors.captionStyle.copyWith(
                            color: AppColors.successGreen,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _formatDateTime(result.timestamp),
                      style: AppColors.captionStyle.copyWith(
                        color: AppColors.successGreen,
                      ),
                    ),
                    if (result.message.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Text(
                        result.message,
                        style: AppColors.captionStyle.copyWith(
                          color: AppColors.successGreen,
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
              style: AppColors.successButtonStyle,
              child: Text('great'.tr, style: AppColors.buttonTextStyle.copyWith(color: AppColors.whiteText)),
            ),
          ],
        ),
      );

      // عرض snackbar إضافي
      Future.delayed(const Duration(milliseconds: 500), () {
        Get.snackbar(
          '📧 ${'email_sent'.tr}',
          'report_sent_to_email'.tr.replaceAll('email', email),
          backgroundColor: AppColors.successGreen,
          colorText: AppColors.whiteText,
          snackPosition: SnackPosition.TOP,
          duration: const Duration(seconds: 4),
          margin: const EdgeInsets.all(16),
          borderRadius: 12,
          icon: const Icon(Icons.mark_email_read, color: AppColors.whiteText),
        );
      });

    } else {
      // فشل الإرسال
      Get.dialog(
        AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Row(
            children: [
              const Icon(Icons.error_outline, color: AppColors.errorRed, size: 24),
              const SizedBox(width: 8),
              Text('email_send_failed'.tr, style: AppColors.bodyStyle.copyWith(fontSize: 16)),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'email_send_failed_message'.tr,
                style: AppColors.bodyStyle.copyWith(height: 1.4),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.lightRedBg,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.errorRed.withOpacity(0.3)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'error_details'.tr,
                      style: AppColors.captionStyle.copyWith(
                        color: AppColors.errorRed,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      result.message.isNotEmpty ? result.message : 'unknown_error'.tr,
                      style: AppColors.captionStyle.copyWith(
                        color: AppColors.errorRed,
                      ),
                    ),
                    if (result.error != null) ...[
                      const SizedBox(height: 8),
                      Text(
                        'technical_error'.tr,
                        style: AppColors.captionStyle.copyWith(
                          color: AppColors.errorRed,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        result.error!,
                        style: AppColors.captionStyle.copyWith(
                          color: AppColors.errorRed,
                          fontSize: 11,
                          fontFamily: 'monospace',
                        ),
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
              child: Text('ok'.tr, style: AppColors.bodyStyle.copyWith(color: AppColors.mediumGray)),
            ),
            ElevatedButton(
              onPressed: () {
                Get.back();
                _performEmailSend(order, email); // إعادة المحاولة
              },
              style: AppColors.primaryButtonStyle,
              child: Text('retry'.tr, style: AppColors.buttonTextStyle.copyWith(color: AppColors.whiteText)),
            ),
          ],
        ),
      );
    }
  }

  // عرض خطأ في إرسال البريد الإلكتروني
  Future<void> _showEmailSendError(String error, NewOrder order, String email) async {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            const Icon(Icons.error_outline, color: AppColors.errorRed, size: 24),
            const SizedBox(width: 8),
            Text('connection_error'.tr, style: AppColors.bodyStyle.copyWith(fontSize: 16)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'email_connection_error_message'.tr,
              style: AppColors.bodyStyle.copyWith(height: 1.4),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.lightYellowBg,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.warningYellow.withOpacity(0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'troubleshooting_steps'.tr,
                    style: AppColors.captionStyle.copyWith(
                      color: AppColors.warningYellow,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '• ${'check_internet_connection'.tr}',
                    style: AppColors.captionStyle.copyWith(color: AppColors.warningYellow),
                  ),
                  Text(
                    '• ${'verify_email_address'.tr}',
                    style: AppColors.captionStyle.copyWith(color: AppColors.warningYellow),
                  ),
                  Text(
                    '• ${'try_again_later'.tr}',
                    style: AppColors.captionStyle.copyWith(color: AppColors.warningYellow),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            ExpansionTile(
              title: Text(
                'technical_details'.tr,
                style: AppColors.captionStyle.copyWith(color: AppColors.mediumGray),
              ),
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.lightGray,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    error,
                    style: AppColors.captionStyle.copyWith(
                      fontSize: 11,
                      fontFamily: 'monospace',
                      color: AppColors.mediumGray,
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
            child: Text('cancel'.tr, style: AppColors.bodyStyle.copyWith(color: AppColors.mediumGray)),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              _performEmailSend(order, email); // إعادة المحاولة
            },
            style: AppColors.primaryButtonStyle,
            child: Text('retry'.tr, style: AppColors.buttonTextStyle.copyWith(color: AppColors.whiteText)),
          ),
        ],
      ),
    );
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

  // دالة بدء تنفيذ الطلب
  Future<void> _startOrder(NewOrder order, NewOrderController controller) async {
    // التحقق من الحالة الحالية قبل المتابعة
    final currentOrder = controller.getOrderById(order.id);
    if (currentOrder?.status.toLowerCase() != 'pending') {
      Get.snackbar(
        'تنبيه',
        'لا يمكن بدء هذا الطلب - الحالة الحالية: ${controller.getStatusText(currentOrder?.status ?? '')}',
        backgroundColor: AppColors.warningYellow,
        colorText: AppColors.whiteText,
        snackPosition: SnackPosition.TOP,
        duration: const Duration(seconds: 3),
        icon: const Icon(Icons.warning, color: AppColors.whiteText),
      );
      return;
    }

    // عرض تأكيد البدء
    final confirmed = await Get.dialog<bool>(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            const Icon(Icons.play_arrow, color: AppColors.primaryBlue, size: 22),
            const SizedBox(width: 8),
            Text('start_order'.tr, style: AppColors.bodyStyle.copyWith(fontSize: 16)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'confirm_start_order'.tr.replaceAll('client', order.client),
              style: AppColors.bodyStyle.copyWith(
                height: 1.4,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.lightBlueBg,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.primaryBlue.withOpacity(0.3)),
              ),
              child: Text(
                'order_will_move_to_progress'.tr,
                style: AppColors.bodyStyle.copyWith(
                  color: AppColors.primaryBlue,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: Text('cancel'.tr, style: AppColors.bodyStyle.copyWith(color: AppColors.mediumGray)),
          ),
          ElevatedButton(
            onPressed: () => Get.back(result: true),
            style: AppColors.primaryButtonStyle,
            child: Text('start_order'.tr, style: AppColors.buttonTextStyle.copyWith(color: AppColors.whiteText)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      // إغلاق أي dialogs مفتوحة
      if (Get.isDialogOpen == true) {
        Get.back();
      }

      // عرض مؤشر التحميل
      Get.dialog(
        Center(
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.pureWhite,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const CircularProgressIndicator(color: AppColors.primaryBlue),
                const SizedBox(height: 16),
                Text('processing'.tr, style: AppColors.bodyStyle),
              ],
            ),
          ),
        ),
        barrierDismissible: false,
      );

      try {
        final success = await controller.startOrder(order.id);

        // إغلاق مؤشر التحميل
        if (Get.isDialogOpen == true) {
          Get.back();
        }

        if (success) {
          Get.snackbar(
            'order_started'.tr,
            'order_started_message'.tr.replaceAll('client', order.client),
            backgroundColor: AppColors.primaryBlue,
            colorText: AppColors.whiteText,
            snackPosition: SnackPosition.TOP,
            duration: const Duration(seconds: 3),
            icon: const Icon(Icons.play_arrow, color: AppColors.whiteText),
          );
        } else {
          Get.snackbar(
            'error'.tr,
            'operation_failed'.tr,
            backgroundColor: AppColors.errorRed,
            colorText: AppColors.whiteText,
            snackPosition: SnackPosition.TOP,
            duration: const Duration(seconds: 5),
          );
        }
      } catch (e) {
        // إغلاق مؤشر التحميل في حالة الخطأ
        if (Get.isDialogOpen == true) {
          Get.back();
        }

        Get.snackbar(
          'error'.tr,
          'order_start_failed'.tr.replaceAll('error', e.toString()),
          backgroundColor: AppColors.errorRed,
          colorText: AppColors.whiteText,
          snackPosition: SnackPosition.TOP,
          duration: const Duration(seconds: 5),
        );
      }
    }
  }

// دالة عرض الطلب المكتمل
  void _viewCompletedOrder(NewOrder order) {
    _viewOrder(order);
  }

  Widget _buildFloatingActionButton() {
    return FloatingActionButton.extended(
      heroTag: "dashboard_fab",
      onPressed: _createNewOrder,
      backgroundColor: AppColors.primaryBlue,
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      icon: const Icon(Icons.add_rounded, color: AppColors.whiteText, size: 22),
      label: Text(
        'new_order'.tr,
        style: AppColors.buttonTextStyle.copyWith(
          color: AppColors.whiteText,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  // Helper methods remain the same
  IconData _getServiceIcon(ServiceType serviceType) {
    switch (serviceType) {
      case ServiceType.TRANSPORT:
        return Icons.local_shipping_outlined;
      case ServiceType.WASH:
        return Icons.local_car_wash_outlined;
      case ServiceType.REGISTRATION:
        return Icons.description_outlined;
      case ServiceType.INSPECTION:
        return Icons.search_outlined;
      case ServiceType.MAINTENANCE:
        return Icons.build_outlined;
    }
  }

  Color _getStatusColor(String status) {
    return AppColors.getStatusColor(status);
  }

  String _formatDate(DateTime date) {
    final months = [
      'january'.tr, 'february'.tr, 'march'.tr, 'april'.tr, 'may'.tr, 'june'.tr,
      'july'.tr, 'august'.tr, 'september'.tr, 'october'.tr, 'november'.tr, 'december'.tr
    ];
    return '${date.day} ${months[date.month - 1]}';
  }

  void _createNewOrder() => Get.toNamed('/create-order');
  void _viewOrder(NewOrder order) => Get.toNamed('/order-details', arguments: order.id);
  void _addImages(NewOrder order) => Get.toNamed('/order-details', arguments: order.id);
  void _addSignatures(NewOrder order) => Get.toNamed('/order-details', arguments: order.id);

  Future<void> _completeOrder(NewOrder order, NewOrderController controller) async {
    try {
      // إغلاق أي snackbar مفتوح أولاً
      if (Get.isSnackbarOpen) {
        Get.closeCurrentSnackbar();
        await Future.delayed(const Duration(milliseconds: 300)); // انتظار قصير
      }

      // فحص المتطلبات أولاً
      final missingRequirements = <String>[];

      if (!order.hasImages) {
        missingRequirements.add('• ${'add_vehicle_photos'.tr}');
      }

      if (!order.hasDriverSignature) {
        missingRequirements.add('• ${'driver_signature'.tr}');
      }

      if (!order.hasCustomerSignature) {
        missingRequirements.add('• ${'customer_signature'.tr}');
      }

      // إذا كانت هناك متطلبات ناقصة، عرضها
      if (missingRequirements.isNotEmpty) {
        await Get.dialog(
          AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            title: Row(
              children: [
                const Icon(Icons.warning_amber_rounded, color: AppColors.warningYellow, size: 22),
                const SizedBox(width: 8),
                Text('missing_requirements'.tr, style: AppColors.bodyStyle.copyWith(fontSize: 16)),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('complete_order_missing_requirements'.tr, style: AppColors.bodyStyle.copyWith(height: 1.4)),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.lightYellowBg,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.warningYellow.withOpacity(0.3)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: missingRequirements.map((req) =>
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 2),
                          child: Text(req, style: AppColors.captionStyle.copyWith(color: AppColors.warningYellow)),
                        )
                    ).toList(),
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Get.back(),
                child: Text('ok'.tr, style: AppColors.bodyStyle.copyWith(color: AppColors.mediumGray)),
              ),
              ElevatedButton(
                onPressed: () {
                  Get.back();
                  // انتظار قصير قبل الانتقال
                  Future.delayed(const Duration(milliseconds: 200), () {
                    _viewOrder(order);
                  });
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.warningYellow,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: Text('add_requirements'.tr, style: AppColors.buttonTextStyle.copyWith(color: AppColors.whiteText)),
              ),
            ],
          ),
          barrierDismissible: true,
        );
        return;
      }

      // إذا كانت جميع المتطلبات مكتملة، عرض تأكيد الإتمام
      final confirmed = await Get.dialog<bool>(
        AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Row(
            children: [
              const Icon(Icons.check_circle_outline, color: AppColors.successGreen, size: 22),
              const SizedBox(width: 8),
              Text('complete_order'.tr, style: AppColors.bodyStyle.copyWith(fontSize: 16)),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'confirm_completion'.tr.replaceAll('client',  order.client),
                style: AppColors.bodyStyle.copyWith(
                  height: 1.4,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.lightGreenBg,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.successGreen.withOpacity(0.3)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'all_requirements_met'.tr,
                      style: AppColors.bodyStyle.copyWith(
                        color: AppColors.successGreen,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text('photos_added'.tr, style: AppColors.captionStyle.copyWith(color: AppColors.successGreen)),
                    Text('driver_sign_added'.tr, style: AppColors.captionStyle.copyWith(color: AppColors.successGreen)),
                    Text('customer_sign_added'.tr, style: AppColors.captionStyle.copyWith(color: AppColors.successGreen)),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Get.back(result: false),
              child: Text('cancel'.tr, style: AppColors.bodyStyle.copyWith(color: AppColors.mediumGray)),
            ),
            ElevatedButton(
              onPressed: () => Get.back(result: true),
              style: AppColors.successButtonStyle,
              child: Text('complete_order'.tr, style: AppColors.buttonTextStyle.copyWith(color: AppColors.whiteText)),
            ),
          ],
        ),
        barrierDismissible: true,
      );

      // إذا لم يتم التأكيد، الخروج
      if (confirmed != true) return;

      // انتظار قصير قبل عرض مؤشر التحميل
      await Future.delayed(const Duration(milliseconds: 200));

      // متغير لتتبع حالة مؤشر التحميل
      bool isLoadingDialogOpen = false;

      try {
        // عرض مؤشر التحميل
        Get.dialog(
          WillPopScope(
            onWillPop: () async => false, // منع الإغلاق بالضغط على الخلف
            child: Center(
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.pureWhite,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const CircularProgressIndicator(color: AppColors.successGreen),
                    const SizedBox(height: 16),
                    Text('completing_order'.tr, style: AppColors.bodyStyle),
                  ],
                ),
              ),
            ),
          ),
          barrierDismissible: false,
        );
        isLoadingDialogOpen = true;

        // تنفيذ عملية الإتمام
        final success = await controller.completeOrder(order.id);

        // إغلاق مؤشر التحميل
        if (isLoadingDialogOpen && Get.isDialogOpen == true) {
          Get.back();
          isLoadingDialogOpen = false;
        }

        // انتظار قصير قبل عرض النتيجة
        await Future.delayed(const Duration(milliseconds: 300));

        if (success) {
          // عرض رسالة نجاح بدون تداخل
          Get.snackbar(
            '🎉 ${'order_completed'.tr}',
            'order_completed_success'.tr.replaceAll('client', order.client),
            backgroundColor: AppColors.successGreen,
            colorText: AppColors.whiteText,
            snackPosition: SnackPosition.TOP,
            duration: const Duration(seconds: 4),
            margin: const EdgeInsets.all(16),
            borderRadius: 12,
            icon: const Icon(Icons.check_circle, color: AppColors.whiteText),
          );
        } else {
          Get.snackbar(
            'error'.tr,
            'operation_failed'.tr,
            backgroundColor: AppColors.errorRed,
            colorText: AppColors.whiteText,
            snackPosition: SnackPosition.TOP,
            duration: const Duration(seconds: 5),
          );
        }
      } catch (e) {
        // إغلاق مؤشر التحميل في حالة الخطأ
        if (isLoadingDialogOpen && Get.isDialogOpen == true) {
          try {
            Get.back();
          } catch (closeError) {
            print('❌ خطأ في إغلاق dialog: $closeError');
          }
          isLoadingDialogOpen = false;
        }

        // انتظار قصير قبل عرض رسالة الخطأ
        await Future.delayed(const Duration(milliseconds: 300));

        Get.snackbar(
          'error'.tr,
          'order_completion_failed'.tr.replaceAll('error', e.toString()),
          backgroundColor: AppColors.errorRed,
          colorText: AppColors.whiteText,
          snackPosition: SnackPosition.TOP,
          duration: const Duration(seconds: 5),
        );
      }
    } catch (e) {
      print('❌ خطأ عام في _completeOrder: $e');

      // إغلاق أي dialogs مفتوحة
      try {
        if (Get.isDialogOpen == true) {
          Get.back();
        }
      } catch (closeError) {
        print('❌ خطأ في إغلاق dialog في catch العام: $closeError');
      }

      // انتظار قبل عرض رسالة الخطأ
      await Future.delayed(const Duration(milliseconds: 300));

      Get.snackbar(
        'خطأ',
        'حدث خطأ غير متوقع: $e',
        backgroundColor: AppColors.errorRed,
        colorText: AppColors.whiteText,
        snackPosition: SnackPosition.TOP,
      );
    }
  }

  void _showLogoutDialog(AuthController authController) {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            const Icon(Icons.logout_rounded, color: AppColors.errorRed, size: 22),
            const SizedBox(width: 8),
            Text('logout'.tr, style: AppColors.bodyStyle.copyWith(fontSize: 16)),
          ],
        ),
        content: Text(
          'logout_confirmation'.tr,
          style: AppColors.bodyStyle.copyWith(height: 1.4),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text('cancel'.tr, style: AppColors.bodyStyle.copyWith(color: AppColors.mediumGray)),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              authController.logout();
            },
            style: AppColors.dangerButtonStyle,
            child: Text('logout'.tr, style: AppColors.buttonTextStyle.copyWith(color: AppColors.whiteText)),
          ),
        ],
      ),
    );
  }
}