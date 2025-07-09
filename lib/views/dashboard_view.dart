import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import '../controllers/auth_controller.dart';
import '../controllers/order_controller.dart';
import '../models/new_order.dart';
import '../routes/app_pages.dart';
import '../services/order_service.dart';
import '../widgets/LanguageSwitcher.dart';

class DashboardView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final NewOrderController orderController = Get.put(NewOrderController());
    final AuthController authController = Get.find<AuthController>();

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
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
      backgroundColor: Colors.blue.shade700,
      title: Obx(() => Row(
        children: [
          Container(
            padding: EdgeInsets.all(2),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Icons.dashboard_rounded,
              color: Colors.white,
              size: 20,
            ),
          ),
          SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${'welcome'.tr} ${authController.currentUserName}',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                'dashboard'.tr,
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ],
      )),
      actions: [
        // زر تغيير اللغة
        LanguageSwitcher(),

        // IconButton(
        //   icon: Container(
        //     padding: EdgeInsets.all(6),
        //     decoration: BoxDecoration(
        //       color: Colors.white.withOpacity(0.15),
        //       borderRadius: BorderRadius.circular(8),
        //     ),
        //     child: Icon(Icons.refresh, color: Colors.white, size: 18),
        //   ),
        //   onPressed: () => orderController.refreshOrders(),
        // ),
        PopupMenuButton<String>(
          icon: Container(
            padding: EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(Icons.more_vert, color: Colors.white, size: 18),
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
                  Icon(Icons.logout_rounded, color: Colors.red.shade600, size: 18),
                  SizedBox(width: 8),
                  Text('logout'.tr, style: TextStyle(fontSize: 14)),
                ],
              ),
            ),
          ],
        ),
        SizedBox(width: 8),
      ],
    );
  }

  Widget _buildHeaderSection(NewOrderController controller) {
    return Container(
      margin: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'quick_stats'.tr,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade800,
            ),
          ),
          SizedBox(height: 12),
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
          'color': Colors.blue.shade600,
          'bgColor': Colors.blue.shade50,
        },
        {
          'title': 'pending'.tr,
          'value': '${controller.pendingOrders}',
          'icon': Icons.schedule_outlined,
          'color': Colors.orange.shade600,
          'bgColor': Colors.orange.shade50,
        },
        {
          'title': 'in_progress'.tr,
          'value': '${controller.inProgressOrders}',
          'icon': Icons.directions_car_outlined,
          'color': Colors.purple.shade600,
          'bgColor': Colors.purple.shade50,
        },
        {
          'title': 'completed'.tr,
          'value': '${controller.completedOrders}',
          'icon': Icons.check_circle_outline,
          'color': Colors.green.shade600,
          'bgColor': Colors.green.shade50,
        },
      ];

      return GridView.builder(
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
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
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 20, color: color),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
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
      padding: EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'search_and_filter'.tr,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade800,
            ),
          ),
          SizedBox(height: 12),

          // Search Bar
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade200),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 8,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: TextField(
              onChanged: controller.updateSearchQuery,
              decoration: InputDecoration(
                hintText: 'search_orders'.tr,
                hintStyle: TextStyle(color: Colors.grey.shade500, fontSize: 14),
                prefixIcon: Icon(Icons.search_rounded, color: Colors.grey.shade500, size: 20),
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
            ),
          ),

          SizedBox(height: 12),

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
          SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, String value, NewOrderController controller) {
    return Obx(() {
      final isSelected = controller.statusFilter == value;
      return Container(
        margin: EdgeInsets.only(left: 8),
        child: FilterChip(
          label: Text(
            label,
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.grey.shade700,
              fontWeight: FontWeight.w500,
              fontSize: 13,
            ),
          ),
          selected: isSelected,
          onSelected: (_) => controller.updateStatusFilter(value),
          backgroundColor: Colors.white,
          selectedColor: Colors.blue.shade600,
          checkmarkColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(
              color: isSelected ? Colors.blue.shade600 : Colors.grey.shade300,
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
              valueColor: AlwaysStoppedAnimation<Color>(Colors.blue.shade600),
            ),
            SizedBox(height: 16),
            Text(
              'loading_orders'.tr,
              style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: EdgeInsets.all(32),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(
                Icons.assignment_outlined,
                size: 48,
                color: Colors.grey.shade400,
              ),
            ),
            SizedBox(height: 20),
            Text(
              'no_orders'.tr,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade700,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'create_first_order'.tr,
              style: TextStyle(
                color: Colors.grey.shade500,
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrdersList(List<NewOrder> orders, NewOrderController controller) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'order_list'.tr,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade800,
            ),
          ),
          SizedBox(height: 12),
          ListView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemCount: orders.length,
            itemBuilder: (context, index) {
              final order = orders[index];
              return _buildSimpleOrderCard(order, controller);
            },
          ),
          SizedBox(height: 100), // Space for FAB
        ],
      ),
    );
  }

  Widget _buildSimpleOrderCard(NewOrder order, NewOrderController controller) {
    final completionPercentage = controller.getOrderCompletionPercentage(order.id);

    return Container(
      margin: EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: InkWell(
        onTap: () => _viewOrder(order),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Row
              // Header Row
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: _getStatusColor(order.status).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      _getServiceIcon(order.serviceType),
                      color: _getStatusColor(order.status),
                      size: 18,
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          order.client,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Colors.black87,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: 2),
                        Row(
                          children: [
                            // رقم اللوحة
                            Text(
                              order.licensePlateNumber,
                              style: TextStyle(
                                color: Colors.grey.shade600,
                                fontSize: 13,
                              ),
                            ),
                            // فاصل
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 6),
                              child: Text(
                                '•',
                                style: TextStyle(
                                  color: Colors.grey.shade400,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                            // نوع الخدمة
                            Text(
                              _getServiceTypeName(order.serviceType),
                              style: TextStyle(
                                color: Colors.blue.shade600,
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: _getStatusColor(order.status),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      controller.getStatusText(order.status),
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),

              SizedBox(height: 12),

              // Progress Bar
              Row(
                children: [
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(3),
                      child: LinearProgressIndicator(
                        value: completionPercentage,
                        backgroundColor: Colors.grey.shade200,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          completionPercentage == 1.0 ? Colors.green : Colors.blue.shade600,
                        ),
                        minHeight: 4,
                      ),
                    ),
                  ),
                  SizedBox(width: 8),
                  Text(
                    '${(completionPercentage * 100).toInt()}%',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: completionPercentage == 1.0 ? Colors.green : Colors.blue.shade600,
                    ),
                  ),
                ],
              ),

              SizedBox(height: 12),

              // Location Info
              Row(
                children: [
                  Icon(Icons.location_on_outlined, size: 14, color: Colors.grey.shade500),
                  SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      '${order.pickupAddress.city} → ${order.deliveryAddress.city}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  SizedBox(width: 8),
                  Icon(Icons.access_time_rounded, size: 14, color: Colors.grey.shade500),
                  SizedBox(width: 4),
                  Text(
                    _formatDate(order.createdAt),
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade500,
                    ),
                  ),
                ],
              ),

              SizedBox(height: 12),

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
      // للطلبيات المعلقة: عرض + بدء + حذف + ارسال بريد
      return Row(
        children: [
          // View Button
          Expanded(
            child: OutlinedButton(
              onPressed: () => _viewOrder(order),
              style: OutlinedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 10),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                side: BorderSide(color: Colors.grey.shade300),
              ),
              child: Text('view'.tr, style: TextStyle(fontSize: 12)),
            ),
          ),
          SizedBox(width: 8),

          // Start Button
          Expanded(
            child: ElevatedButton(
              onPressed: () => _startOrder(order, controller),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue.shade600,
                padding: EdgeInsets.symmetric(vertical: 10),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.play_arrow, size: 14, color: Colors.white),
                  SizedBox(width: 4),
                  Text('start'.tr, style: TextStyle(fontSize: 12, color: Colors.white)),
                ],
              ),
            ),
          ),
          SizedBox(width: 8),

          // Delete Button
          Expanded(
            child: OutlinedButton(
              onPressed: () => controller.confirmDeleteOrder(order, controller),
              style: OutlinedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 10),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                side: BorderSide(color: Colors.red.shade300),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.delete, size: 14, color: Colors.red.shade600),
                  SizedBox(width: 4),
                  Text('delete'.tr, style: TextStyle(fontSize: 12, color: Colors.red.shade600)),
                ],
              ),
            ),
          ),
        ],
      );
    }
    else if (status == 'in_progress') {
      // للطلبيات قيد التنفيذ: أزرار مع إرسال بريد
      if (!order.hasImages) {
        return Row(
          children: [

            Expanded(
              child: OutlinedButton(
                onPressed: () => _viewOrder(order),
                style: OutlinedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 10),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                  side: BorderSide(color: Colors.grey.shade300),
                ),
                child: Text('view'.tr, style: TextStyle(fontSize: 12)),
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
                style: OutlinedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 10),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  side: BorderSide(color: Colors.grey.shade300),
                ),
                child: Text('view'.tr, style: TextStyle(fontSize: 12)),
              ),
            ),
            SizedBox(width: 8),
            Expanded(
              flex: 2,
              child: ElevatedButton(
                onPressed: () => _completeOrder(order, controller),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green.shade600,
                  padding: EdgeInsets.symmetric(vertical: 10),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.check_circle, size: 14, color: Colors.white),
                    SizedBox(width: 6),
                    Text('complete_order'.tr, style: TextStyle(fontSize: 12, color: Colors.white)),
                  ],
                ),
              ),
            ),

          ],
        );
      }
    }
    else if (status == 'completed') {
      // للطلبيات المكتملة: عرض التفاصيل + تقرير + ارسال بريد
      return Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: () => _viewOrder(order),
              style: OutlinedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 10),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                side: BorderSide(color: Colors.green.shade300),
              ),
              child: Text('view'.tr, style: TextStyle(fontSize: 12, color: Colors.green.shade600)),

            ),
          ),
          SizedBox(width: 8),
          Expanded(
            child: ElevatedButton(
              onPressed: () => _generateReport(order),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green.shade600,
                padding: EdgeInsets.symmetric(vertical: 10),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.receipt_long, size: 14, color: Colors.white),
                  SizedBox(width: 6),
                  Text('report'.tr, style: TextStyle(fontSize: 12, color: Colors.white)),
                ],
              ),
            ),
          ),
          SizedBox(width: 8),

          // Send Email Button
          Expanded(
            child: OutlinedButton(
              onPressed: () => controller.sendEmailReport(order),
              style: OutlinedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 10),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                side: BorderSide(color: Colors.teal.shade300),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.email, size: 14, color: Colors.teal.shade600),
                  SizedBox(width: 4),
                  Text('email'.tr, style: TextStyle(fontSize: 12, color: Colors.teal.shade600)),
                ],
              ),
            ),
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
              style: OutlinedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 10),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                side: BorderSide(color: Colors.grey.shade300),
              ),
              child: Text('عرض التفاصيل', style: TextStyle(fontSize: 12)),
            ),
          ),
        ],
      );
    }
    else {
      return SizedBox.shrink();
    }
  }

// دالة محسنة لإنتاج التقرير
  Future<void> _generateReport(NewOrder order) async {
    try {
      // عرض مؤشر تحميل
      Get.dialog(
        Center(
          child: CircularProgressIndicator(),
        ),
        barrierDismissible: false,
      );

      // إنشاء التقرير
      final pdfBytes = await NewOrderService().generateOrderPdf(order.id!);

      // إغلاق مؤشر التحميل
      Get.back();

      // حفظ وعرض الملف
      await _saveAndOpenPdf(pdfBytes, order);

    } catch (e) {
      Get.back(); // إغلاق مؤشر التحميل في حالة الخطأ
      Get.snackbar(
        'خطأ في إنشاء التقرير',
        e.toString(),
        backgroundColor: Colors.red.shade600,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
        duration: Duration(seconds: 5),
        icon: Icon(Icons.error, color: Colors.white),
      );
    }
  }

// دالة مساعدة لحفظ وفتح ملف PDF
  Future<void> _saveAndOpenPdf(Uint8List pdfBytes, NewOrder order) async {
    try {
      // الحصول على مسار التخزين المؤقت
      final directory = await getTemporaryDirectory();
      final filePath = '${directory.path}/Handover_Report_${order.orderNumber}.pdf';

      // حفظ الملف
      final file = File(filePath);
      await file.writeAsBytes(pdfBytes);

      // فتح الملف
      await OpenFile.open(filePath);

      // عرض رسالة نجاح
      Get.snackbar(
        'تم إنشاء التقرير',
        'تم حفظ التقرير بنجاح وجاهز للمشاركة',
        backgroundColor: Colors.green.shade600,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
        duration: Duration(seconds: 3),
        icon: Icon(Icons.check_circle, color: Colors.white),
      );

    } catch (e) {
      throw Exception('فشل في حفظ أو فتح الملف: $e');
    }
  }

  Widget _buildQuickActions(NewOrder order, NewOrderController controller) {
    final actions = <Widget>[];

    // دائماً عرض زر العرض
    actions.add(
      Expanded(
        child: OutlinedButton(
          onPressed: () => _viewOrder(order),
          style: OutlinedButton.styleFrom(
            padding: EdgeInsets.symmetric(vertical: 8),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            side: BorderSide(color: Colors.grey.shade300),
          ),
          child: Text('عرض', style: TextStyle(fontSize: 12)),
        ),
      ),
    );

    // الأزرار حسب حالة الطلب
    final status = order.status.toLowerCase();

    if (status == 'pending') {
      // زر بدء التنفيذ
      actions.add(SizedBox(width: 8));
      actions.add(
        Expanded(
          child: ElevatedButton(
            onPressed: () => _startOrder(order, controller),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue.shade600,
              padding: EdgeInsets.symmetric(vertical: 8),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.play_arrow, size: 14, color: Colors.white),
                SizedBox(width: 4),
                Text('بدء', style: TextStyle(fontSize: 12, color: Colors.white)),
              ],
            ),
          ),
        ),
      );
    } else if (status == 'in_progress') {
      // فحص المتطلبات وعرض الزر المناسب
      if (!order.hasImages) {
        actions.add(SizedBox(width: 8));
        actions.add(
          Expanded(
            child: ElevatedButton(
              onPressed: () => _addImages(order),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange.shade600,
                padding: EdgeInsets.symmetric(vertical: 8),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.camera_alt, size: 14, color: Colors.white),
                  SizedBox(width: 4),
                  Text('صور', style: TextStyle(fontSize: 12, color: Colors.white)),
                ],
              ),
            ),
          ),
        );
      } else if (!order.hasAllSignatures) {
        actions.add(SizedBox(width: 8));
        actions.add(
          Expanded(
            child: ElevatedButton(
              onPressed: () => _addSignatures(order),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.purple.shade600,
                padding: EdgeInsets.symmetric(vertical: 8),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.edit, size: 14, color: Colors.white),
                  SizedBox(width: 4),
                  Text('توقيع', style: TextStyle(fontSize: 12, color: Colors.white)),
                ],
              ),
            ),
          ),
        );
      } else {
        // جميع المتطلبات مكتملة - زر الإتمام
        actions.add(SizedBox(width: 8));
        actions.add(
          Expanded(
            child: ElevatedButton(
              onPressed: () => _completeOrder(order, controller),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green.shade600,
                padding: EdgeInsets.symmetric(vertical: 8),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.check_circle, size: 14, color: Colors.white),
                  SizedBox(width: 4),
                  Text('إتمام', style: TextStyle(fontSize: 12, color: Colors.white)),
                ],
              ),
            ),
          ),
        );
      }
    } else if (status == 'completed') {
      // زر عرض التقرير أو المشاركة
      actions.add(SizedBox(width: 8));
      actions.add(
        Expanded(
          child: ElevatedButton(
            onPressed: () => _viewCompletedOrder(order),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green.shade600,
              padding: EdgeInsets.symmetric(vertical: 8),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.receipt, size: 14, color: Colors.white),
                SizedBox(width: 4),
                Text('تقرير', style: TextStyle(fontSize: 12, color: Colors.white)),
              ],
            ),
          ),
        ),
      );
    }

    return Row(children: actions);
  }


  // دالة بدء تنفيذ الطلب
  Future<void> _startOrder(NewOrder order, NewOrderController controller) async {
    // التحقق من الحالة الحالية قبل المتابعة
    final currentOrder = controller.getOrderById(order.id);
    if (currentOrder?.status.toLowerCase() != 'pending') {
      Get.snackbar(
        'تنبيه',
        'لا يمكن بدء هذا الطلب - الحالة الحالية: ${controller.getStatusText(currentOrder?.status ?? '')}',
        backgroundColor: Colors.orange.shade600,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
        duration: Duration(seconds: 3),
        icon: Icon(Icons.warning, color: Colors.white),
      );
      return;
    }

    // عرض تأكيد البدء
    final confirmed = await Get.dialog<bool>(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.play_arrow, color: Colors.blue.shade600, size: 22),
            SizedBox(width: 8),
            Text('start_order'.tr, style: TextStyle(fontSize: 16)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'confirm_start_order'.tr.replaceAll('client', order.client),
              style: TextStyle(fontSize: 14, height: 1.4, fontWeight: FontWeight.w500),
            ),
            SizedBox(height: 12),
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue.shade200),
              ),
              child: Text(
                'order_will_move_to_progress'.tr,
                style: TextStyle(
                  color: Colors.blue.shade700,
                  fontWeight: FontWeight.w500,
                ),
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
              backgroundColor: Colors.blue.shade600,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: Text('start_order'.tr, style: TextStyle(color: Colors.white)),
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
                Text('processing'.tr, style: TextStyle(fontSize: 14)),
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
            backgroundColor: Colors.blue.shade600,
            colorText: Colors.white,
            snackPosition: SnackPosition.TOP,
            duration: Duration(seconds: 3),
            icon: Icon(Icons.play_arrow, color: Colors.white),
          );
        } else {
          Get.snackbar(
            'error'.tr,
            'operation_failed'.tr,
            backgroundColor: Colors.red.shade600,
            colorText: Colors.white,
            snackPosition: SnackPosition.TOP,
            duration: Duration(seconds: 5),
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
          backgroundColor: Colors.red.shade600,
          colorText: Colors.white,
          snackPosition: SnackPosition.TOP,
          duration: Duration(seconds: 5),
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
      backgroundColor: Colors.blue.shade600,
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      icon: Icon(Icons.add_rounded, color: Colors.white, size: 22),
      label: Text(
        'new_order'.tr,
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 14,
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
    switch (status) {
      case 'pending':
        return Colors.orange.shade600;
      case 'in_progress':
        return Colors.purple.shade600;
      case 'completed':
        return Colors.green.shade600;
      case 'cancelled':
        return Colors.red.shade600;
      default:
        return Colors.grey.shade600;
    }
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
        await Future.delayed(Duration(milliseconds: 300)); // انتظار قصير
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
                Icon(Icons.warning_amber_rounded, color: Colors.orange.shade600, size: 22),
                SizedBox(width: 8),
                Text('missing_requirements'.tr, style: TextStyle(fontSize: 16)),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('complete_order_missing_requirements'.tr, style: TextStyle(fontSize: 14, height: 1.4)),
                SizedBox(height: 12),
                Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.orange.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.orange.shade200),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: missingRequirements.map((req) =>
                        Padding(
                          padding: EdgeInsets.symmetric(vertical: 2),
                          child: Text(req, style: TextStyle(color: Colors.orange.shade700)),
                        )
                    ).toList(),
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Get.back(),
                child: Text('ok'.tr, style: TextStyle(color: Colors.grey.shade600)),
              ),
              ElevatedButton(
                onPressed: () {
                  Get.back();
                  // انتظار قصير قبل الانتقال
                  Future.delayed(Duration(milliseconds: 200), () {
                    _viewOrder(order);
                  });
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange.shade600,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: Text('add_requirements'.tr, style: TextStyle(color: Colors.white)),
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
                'confirm_completion'.tr.replaceAll('client',  order.client),
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

      // إذا لم يتم التأكيد، الخروج
      if (confirmed != true) return;

      // انتظار قصير قبل عرض مؤشر التحميل
      await Future.delayed(Duration(milliseconds: 200));

      // متغير لتتبع حالة مؤشر التحميل
      bool isLoadingDialogOpen = false;

      try {
        // عرض مؤشر التحميل
        Get.dialog(
          WillPopScope(
            onWillPop: () async => false, // منع الإغلاق بالضغط على الخلف
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
                    CircularProgressIndicator(color: Colors.green.shade600),
                    SizedBox(height: 16),
                    Text('completing_order'.tr, style: TextStyle(fontSize: 14)),
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
        await Future.delayed(Duration(milliseconds: 300));

        if (success) {
          // عرض رسالة نجاح بدون تداخل
          Get.snackbar(
            '🎉 ${'order_completed'.tr}',
            'order_completed_success'.tr.replaceAll('client', order.client),
            backgroundColor: Colors.green.shade600,
            colorText: Colors.white,
            snackPosition: SnackPosition.TOP,
            duration: Duration(seconds: 4),
            margin: EdgeInsets.all(16),
            borderRadius: 12,
            icon: Icon(Icons.check_circle, color: Colors.white),
          );
        } else {
          Get.snackbar(
            'error'.tr,
            'operation_failed'.tr,
            backgroundColor: Colors.red.shade600,
            colorText: Colors.white,
            snackPosition: SnackPosition.TOP,
            duration: Duration(seconds: 5),
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
        await Future.delayed(Duration(milliseconds: 300));

        Get.snackbar(
          'error'.tr,
          'order_completion_failed'.tr.replaceAll('error', e.toString()),
          backgroundColor: Colors.red.shade600,
          colorText: Colors.white,
          snackPosition: SnackPosition.TOP,
          duration: Duration(seconds: 5),
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
      await Future.delayed(Duration(milliseconds: 300));

      Get.snackbar(
        'خطأ',
        'حدث خطأ غير متوقع: $e',
        backgroundColor: Colors.red.shade600,
        colorText: Colors.white,
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
            Icon(Icons.logout_rounded, color: Colors.red.shade600, size: 22),
            SizedBox(width: 8),
            Text('logout'.tr, style: TextStyle(fontSize: 16)),
          ],
        ),
        content: Text(
          'logout_confirmation'.tr,
          style: TextStyle(fontSize: 14, height: 1.4),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text('cancel'.tr, style: TextStyle(color: Colors.grey.shade600)),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              authController.logout();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade600,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: Text('logout'.tr, style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}