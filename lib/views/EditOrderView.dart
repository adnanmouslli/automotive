import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/order_controller.dart';
import '../models/new_order.dart';
import '../routes/app_pages.dart';

class EditOrderView extends StatefulWidget {
  final NewOrder order;

  const EditOrderView({Key? key, required this.order}) : super(key: key);

  @override
  State<EditOrderView> createState() => _EditOrderViewState();
}

class _EditOrderViewState extends State<EditOrderView>
    with TickerProviderStateMixin {
  final NewOrderController _controller = Get.find<NewOrderController>();
  final _formKey = GlobalKey<FormState>();
  late TabController _tabController;

  // Controllers for form fields
  late final TextEditingController _clientController;
  late final TextEditingController _clientPhoneController;
  late final TextEditingController _clientEmailController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _commentsController;
  late final TextEditingController _vehicleOwnerController;
  late final TextEditingController _licensePlateController;

  // Address controllers
  late final TextEditingController _pickupStreetController;
  late final TextEditingController _pickupHouseController;
  late final TextEditingController _pickupZipController;
  late final TextEditingController _pickupCityController;
  late final TextEditingController _deliveryStreetController;
  late final TextEditingController _deliveryHouseController;
  late final TextEditingController _deliveryZipController;
  late final TextEditingController _deliveryCityController;

  bool _isModified = false;
  late ServiceType _selectedServiceType;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _initializeControllers();
    _setupChangeListeners();
  }

  void _initializeControllers() {
    final order = widget.order;

    // Basic info controllers
    _clientController = TextEditingController(text: order.client);
    _clientPhoneController = TextEditingController(text: order.clientPhone);
    _clientEmailController = TextEditingController(text: order.clientEmail);
    _descriptionController = TextEditingController(text: order.description);
    _commentsController = TextEditingController(text: order.comments);

    // Vehicle controllers
    _vehicleOwnerController = TextEditingController(text: order.vehicleOwner);
    _licensePlateController = TextEditingController(text: order.licensePlateNumber);

    // Address controllers
    _pickupStreetController = TextEditingController(text: order.pickupAddress.street);
    _pickupHouseController = TextEditingController(text: order.pickupAddress.houseNumber);
    _pickupZipController = TextEditingController(text: order.pickupAddress.zipCode);
    _pickupCityController = TextEditingController(text: order.pickupAddress.city);
    _deliveryStreetController = TextEditingController(text: order.deliveryAddress.street);
    _deliveryHouseController = TextEditingController(text: order.deliveryAddress.houseNumber);
    _deliveryZipController = TextEditingController(text: order.deliveryAddress.zipCode);
    _deliveryCityController = TextEditingController(text: order.deliveryAddress.city);

    _selectedServiceType = order.serviceType;
  }

  void _setupChangeListeners() {
    final controllers = [
      _clientController, _clientPhoneController, _clientEmailController,
      _descriptionController, _commentsController, _vehicleOwnerController,
      _licensePlateController, _pickupStreetController,
      _pickupHouseController, _pickupZipController, _pickupCityController,
      _deliveryStreetController, _deliveryHouseController,
      _deliveryZipController, _deliveryCityController,
    ];

    for (final controller in controllers) {
      controller.addListener(() {
        if (!_isModified) {
          setState(() => _isModified = true);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: _buildAppBar(),
      body: Form(
        key: _formKey,
        child: Column(
          children: [
            _buildProgressIndicator(),
            _buildTabBar(),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildBasicInfoTab(),
                  _buildVehicleInfoTab(),
                  _buildAddressesTab(),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomActions(),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      elevation: 0,
      backgroundColor: Colors.white,
      foregroundColor: Colors.black87,
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'edit_order'.tr,
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          Text(
            '${widget.order.client}',
            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
          ),
        ],
      ),
      actions: [
        if (_isModified)
          Container(
            margin: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            child: Chip(
              label: Text(
                'modified'.tr,
                style: TextStyle(color: Colors.white, fontSize: 12),
              ),
              backgroundColor: Colors.orange,
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
          ),
        Obx(() =>
        _controller.isCreating
            ? Container(
          margin: EdgeInsets.all(12),
          width: 20,
          height: 20,
          child: CircularProgressIndicator(strokeWidth: 2),
        )
            : IconButton(
          icon: Icon(Icons.save_rounded),
          onPressed: _isModified ? _submitForm : null,
          tooltip: 'save_changes_tooltip'.tr,
        )),
      ],
    );
  }

  Widget _buildProgressIndicator() {
    return Container(
      height: 4,
      child: Obx(() =>
          LinearProgressIndicator(
            value: _controller.isCreating ? null : 1.0,
            backgroundColor: Colors.grey[200],
            valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
          )),
    );
  }

  Widget _buildTabBar() {
    return Container(
      color: Colors.white,
      child: TabBar(
        controller: _tabController,
        labelColor: Colors.blue[700],
        unselectedLabelColor: Colors.grey[600],
        indicatorColor: Colors.blue[700],
        indicatorWeight: 3,
        tabs: [
          Tab(
            icon: Icon(Icons.person_outline),
            text: 'client_data'.tr,
          ),
          Tab(
            icon: Icon(Icons.directions_car_outlined),
            text: 'vehicle_data'.tr,
          ),
          Tab(
            icon: Icon(Icons.location_on_outlined),
            text: 'addresses'.tr,
          ),
        ],
      ),
    );
  }

  Widget _buildBasicInfoTab() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        children: [
          _buildSectionCard(
            title: 'client_info'.tr,
            icon: Icons.person,
            children: [
              _buildTextField(
                controller: _clientController,
                label: 'client_name'.tr,
                icon: Icons.person_outline,
                // إزالة validator - الحقل أصبح اختياري
              ),
              _buildTextField(
                controller: _clientPhoneController,
                label: 'phone_number'.tr,
                icon: Icons.phone_outlined,
                keyboardType: TextInputType.phone,
              ),
              _buildTextField(
                controller: _clientEmailController,
                label: 'email_address'.tr,
                icon: Icons.email_outlined,
                keyboardType: TextInputType.emailAddress,
              ),
            ],
          ),
          SizedBox(height: 16),
          _buildSectionCard(
            title: 'order_details'.tr,
            icon: Icons.description,
            children: [
              _buildTextField(
                controller: _descriptionController,
                label: 'order_description'.tr,
                icon: Icons.description_outlined,
                maxLines: 3,
                // إزالة validator - الحقل أصبح اختياري
              ),
              _buildTextField(
                controller: _commentsController,
                label: 'additional_notes'.tr,
                icon: Icons.note_outlined,
                maxLines: 2,
              ),
              _buildServiceTypeDropdown(),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildVehicleInfoTab() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        children: [
          _buildSectionCard(
            title: 'owner_vehicle_info'.tr,
            icon: Icons.directions_car,
            children: [
              _buildTextField(
                controller: _vehicleOwnerController,
                label: 'vehicle_owner'.tr,
                icon: Icons.person_pin_outlined,
                // إزالة validator - الحقل أصبح اختياري
              ),
              _buildTextField(
                controller: _licensePlateController,
                label: 'license_plate'.tr,
                icon: Icons.confirmation_number_outlined,
                // إزالة validator - الحقل أصبح اختياري
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAddressesTab() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        children: [
          _buildAddressCard(
            title: 'pickup_address'.tr,
            icon: Icons.where_to_vote,
            color: Colors.green,
            streetController: _pickupStreetController,
            houseController: _pickupHouseController,
            zipController: _pickupZipController,
            cityController: _pickupCityController,
          ),
          SizedBox(height: 16),
          _buildAddressCard(
            title: 'delivery_address'.tr,
            icon: Icons.location_on,
            color: Colors.blue,
            streetController: _deliveryStreetController,
            houseController: _deliveryHouseController,
            zipController: _deliveryZipController,
            cityController: _deliveryCityController,
          ),
        ],
      ),
    );
  }

  Widget _buildServiceTypeDropdown() {
    return Padding(
      padding: EdgeInsets.only(bottom: 16),
      child: DropdownButtonFormField<ServiceType>(
        value: _selectedServiceType,
        decoration: InputDecoration(
          labelText: 'service_type'.tr,
          prefixIcon: Icon(Icons.build_outlined, color: Colors.grey[600]),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey[300]!),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.blue, width: 2),
          ),
          filled: true,
          fillColor: Colors.grey[50],
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
        items: ServiceType.values.map((ServiceType type) {
          return DropdownMenuItem<ServiceType>(
            value: type,
            child: Text(_getServiceTypeText(type), style: TextStyle(fontSize: 16)),
          );
        }).toList(),
        onChanged: (ServiceType? newValue) {
          if (newValue != null) {
            setState(() {
              _selectedServiceType = newValue;
              _isModified = true;
            });
          }
        },
      ),
    );
  }

  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: Colors.blue[700], size: 24),
                SizedBox(width: 8),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800],
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildAddressCard({
    required String title,
    required IconData icon,
    required Color color,
    required TextEditingController streetController,
    required TextEditingController houseController,
    required TextEditingController zipController,
    required TextEditingController cityController,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 24),
                SizedBox(width: 8),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800],
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            _buildTextField(
              controller: streetController,
              label: 'street'.tr,
              icon: Icons.edit_road,
              // إزالة validator - الحقل أصبح اختياري
            ),
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: _buildTextField(
                    controller: houseController,
                    label: 'house_number'.tr,
                    icon: Icons.home_outlined,
                    // إزالة validator - الحقل أصبح اختياري
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  flex: 3,
                  child: _buildTextField(
                    controller: zipController,
                    label: 'postal_code'.tr,
                    icon: Icons.markunread_mailbox_outlined,
                    keyboardType: TextInputType.number,
                    // إزالة validator - الحقل أصبح اختياري
                  ),
                ),
              ],
            ),
            _buildTextField(
              controller: cityController,
              label: 'city'.tr,
              icon: Icons.location_city_outlined,
              // إزالة validator - الحقل أصبح اختياري
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    int maxLines = 1,
    TextInputType? keyboardType,
    String? Function(String?)? validator, // إبقاء المعامل لكن لن نستخدمه
  }) {
    return Padding(
      padding: EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: Colors.grey[600]),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey[300]!),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.blue, width: 2),
          ),
          filled: true,
          fillColor: Colors.grey[50],
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
        maxLines: maxLines,
        keyboardType: keyboardType,
        // إزالة validator تماماً - جميع الحقول أصبحت اختيارية
        // validator: validator,
        style: TextStyle(fontSize: 16),
      ),
    );
  }

  Widget _buildBottomActions() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 1,
            blurRadius: 8,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              flex: 1,
              child: Obx(() =>
                  ElevatedButton.icon(
                    onPressed: _isModified && !_controller.isCreating
                        ? _submitForm
                        : null,
                    icon: _controller.isCreating
                        ? SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                        : Icon(Icons.save),
                    label: Text(_controller.isCreating
                        ? 'saving'.tr
                        : 'save_changes'.tr),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue[700],
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  )),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _submitForm() async {
    // إزالة التحقق من صحة النموذج - لأن جميع الحقول أصبحت اختيارية
    // if (!_formKey.currentState!.validate()) {
    //   _tabController.animateTo(0);
    //   return;
    // }

    print('starting_save_process'.tr);

    final orderData = {
      'client': _clientController.text.trim(),
      'clientPhone': _clientPhoneController.text.trim(),
      'clientEmail': _clientEmailController.text.trim(),
      'description': _descriptionController.text.trim(),
      'comments': _commentsController.text.trim(),
      'vehicleOwner': _vehicleOwnerController.text.trim(),
      'licensePlateNumber': _licensePlateController.text.trim(),
      'serviceType': _selectedServiceType.toString().split('.').last.toUpperCase(),
      'pickupAddress': {
        'street': _pickupStreetController.text.trim(),
        'houseNumber': _pickupHouseController.text.trim(),
        'zipCode': _pickupZipController.text.trim(),
        'city': _pickupCityController.text.trim(),
        'country': widget.order.pickupAddress.country,
      },
      'deliveryAddress': {
        'street': _deliveryStreetController.text.trim(),
        'houseNumber': _deliveryHouseController.text.trim(),
        'zipCode': _deliveryZipController.text.trim(),
        'city': _deliveryCityController.text.trim(),
        'country': widget.order.deliveryAddress.country,
      },
    };

    // محاولة الحفظ مع معالجة جميع الأخطاء المحتملة
    bool shouldReturn = true;
    String message = 'changes_saved'.tr;
    Color messageColor = Colors.green;

    try {
      final success = await _controller.updateFullOrder(
        orderId: widget.order.id,
        orderData: orderData,
      ).timeout(
        Duration(seconds: 10), // مهلة زمنية للطلب
        onTimeout: () {
          print('request_timeout'.tr);
          return false;
        },
      );

      if (!success) {
        message = 'failed_to_save_changes'.tr;
        messageColor = Colors.orange;
      }
    } catch (e) {
      print('save_error'.tr.replaceAll('error', e.toString()));
      message = 'error_occurred_while_saving'.tr;
      messageColor = Colors.orange;
    }

    // عرض رسالة النتيجة
    Get.snackbar(
      message.contains('تم') || message.contains('saved') || message.contains('gespeichert') ?
      'success_saved'.tr : 'error_occurred'.tr,
      message,
      backgroundColor: messageColor,
      colorText: Colors.white,
      snackPosition: SnackPosition.TOP,
      duration: const Duration(seconds: 3),
    );

    // العودة إذا نجح الحفظ
    if (messageColor == Colors.green) {
      Get.back();
    }
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

  @override
  void dispose() {
    _tabController.dispose();
    _clientController.dispose();
    _clientPhoneController.dispose();
    _clientEmailController.dispose();
    _descriptionController.dispose();
    _commentsController.dispose();
    _vehicleOwnerController.dispose();
    _licensePlateController.dispose();
    _pickupStreetController.dispose();
    _pickupHouseController.dispose();
    _pickupZipController.dispose();
    _pickupCityController.dispose();
    _deliveryStreetController.dispose();
    _deliveryHouseController.dispose();
    _deliveryZipController.dispose();
    _deliveryCityController.dispose();
    super.dispose();
  }
}