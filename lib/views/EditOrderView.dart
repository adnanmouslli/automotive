import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/order_controller.dart';
import '../models/new_order.dart';
import '../models/new_address.dart';
import '../routes/app_pages.dart';
import '../utils/AppColors.dart';

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

  // Client Address controllers
  late final TextEditingController _clientAddressStreetController;
  late final TextEditingController _clientAddressHouseController;
  late final TextEditingController _clientAddressZipController;
  late final TextEditingController _clientAddressCityController;

  // Billing controllers
  late final TextEditingController _billingNameController;
  late final TextEditingController _billingPhoneController;
  late final TextEditingController _billingEmailController;
  late final TextEditingController _billingAddressStreetController;
  late final TextEditingController _billingAddressHouseController;
  late final TextEditingController _billingAddressZipController;
  late final TextEditingController _billingAddressCityController;

  // Additional vehicle fields controllers
  late final TextEditingController _ukzController;
  late final TextEditingController _finController;
  late final TextEditingController _bestellnummerController;
  late final TextEditingController _leasingvertragsnummerController;
  late final TextEditingController _kostenstelleController;
  late final TextEditingController _bemerkungController;
  late final TextEditingController _typController;

  // Pickup address controllers with extended fields
  late final TextEditingController _pickupStreetController;
  late final TextEditingController _pickupHouseController;
  late final TextEditingController _pickupZipController;
  late final TextEditingController _pickupCityController;
  late final TextEditingController _pickupDateController;
  late final TextEditingController _pickupCompanyController;
  late final TextEditingController _pickupContactNameController;
  late final TextEditingController _pickupContactPhoneController;
  late final TextEditingController _pickupContactEmailController;
  late final TextEditingController _pickupFuelMeterController;

  // Delivery address controllers with extended fields
  late final TextEditingController _deliveryStreetController;
  late final TextEditingController _deliveryHouseController;
  late final TextEditingController _deliveryZipController;
  late final TextEditingController _deliveryCityController;
  late final TextEditingController _deliveryDateController;
  late final TextEditingController _deliveryCompanyController;
  late final TextEditingController _deliveryContactNameController;
  late final TextEditingController _deliveryContactPhoneController;
  late final TextEditingController _deliveryContactEmailController;
  late final TextEditingController _deliveryFuelMeterController;

  // Observable variables
  bool _isModified = false;
  late ServiceType _selectedServiceType;
  bool _isSameBilling = true;
  RxList<VehicleItem> _selectedItems = <VehicleItem>[].obs;
  RxInt _pickupFuelLevel = 0.obs;
  RxInt _deliveryFuelLevel = 0.obs;

  RxList<VehicleSide> _selectedSides = <VehicleSide>[].obs;
  RxList<VehicleDamage> _selectedDamages = <VehicleDamage>[].obs;

  // خريطة لحفظ أوصاف الأضرار لكل جانب
  final Map<VehicleSide, TextEditingController> _damageDescriptionControllers = {};


  void _initializeDamageControllers() {
    print('🔧 تهيئة controllers الأضرار...');

    // نسخ الأضرار الموجودة
    _selectedDamages.assignAll(widget.order.damages);
    print('📊 تم تحميل ${widget.order.damages.length} ضرر من الطلبية');

    // استخراج الجوانب المحددة من الأضرار الموجودة
    final Set<VehicleSide> sides = {};
    for (final damage in widget.order.damages) {
      sides.add(damage.side);
      print('🔧 جانب محدد: ${damage.side} - نوع: ${damage.type}');
    }
    _selectedSides.assignAll(sides.toList());

    // إنشاء controllers للأوصاف مع دمج الأوصاف للجانب الواحد
    for (final side in VehicleSide.values) {
      final sideDescriptions = widget.order.damages
          .where((d) => d.side == side)
          .map((d) => d.description ?? '')
          .where((desc) => desc.isNotEmpty)
          .toSet() // إزالة التكرارات
          .join('\n');

      _damageDescriptionControllers[side] = TextEditingController(text: sideDescriptions);

      if (sideDescriptions.isNotEmpty) {
        print('📝 تم تحميل وصف للجانب $side: $sideDescriptions');
      }
    }

    print('✅ تم الانتهاء من تهيئة controllers الأضرار');
  }

  void _setupDamageChangeListeners() {
    for (final controller in _damageDescriptionControllers.values) {
      controller.addListener(() {
        if (!_isModified) {
          setState(() => _isModified = true);
        }
      });
    }
  }

  // دوال التحكم في الأضرار
  void _toggleVehicleSide(VehicleSide side) {
    if (_selectedSides.contains(side)) {
      _selectedSides.remove(side);
      // إزالة جميع الأضرار المرتبطة بهذا الجانب
      _selectedDamages.removeWhere((damage) => damage.side == side);
    } else {
      _selectedSides.add(side);
    }

    if (!_isModified) {
      setState(() => _isModified = true);
    }
  }

  void _toggleDamage(VehicleSide side, DamageType damageType) {
    final damage = VehicleDamage(side: side, type: damageType);

    if (_isDamageSelected(side, damageType)) {
      _selectedDamages.removeWhere((d) => d.side == side && d.type == damageType);
    } else {
      _selectedDamages.add(damage);
      // التأكد من أن الجانب محدد
      if (!_selectedSides.contains(side)) {
        _selectedSides.add(side);
      }
    }

    if (!_isModified) {
      setState(() => _isModified = true);
    }
  }

  bool _isDamageSelected(VehicleSide side, DamageType damageType) {
    return _selectedDamages.any((damage) => damage.side == side && damage.type == damageType);
  }

  List<VehicleDamage> _getDamagesForSide(VehicleSide side) {
    return _selectedDamages.where((damage) => damage.side == side).toList();
  }

  void _clearAllDamages() {
    _selectedDamages.clear();
    _selectedSides.clear();
    // مسح جميع أوصاف الأضرار
    for (final controller in _damageDescriptionControllers.values) {
      controller.clear();
    }

    if (!_isModified) {
      setState(() => _isModified = true);
    }
  }

  TextEditingController _getDamageDescriptionController(VehicleSide side) {
    if (!_damageDescriptionControllers.containsKey(side)) {
      _damageDescriptionControllers[side] = TextEditingController();
    }
    return _damageDescriptionControllers[side]!;
  }

// دوال مساعدة
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

// إعداد الأضرار النهائية مع الأوصاف للحفظ
  List<VehicleDamage> _getFinalDamagesList() {
    print('🔧 بدء إعداد قائمة الأضرار النهائية...');
    print('🔧 عدد الأضرار المُحددة: ${_selectedDamages.length}');
    print('🔧 الجوانب المُحددة: ${_selectedSides.map((s) => s.toString().split('.').last).join(', ')}');

    final List<VehicleDamage> finalDamages = [];

    for (int i = 0; i < _selectedDamages.length; i++) {
      final damage = _selectedDamages[i];
      final controller = _damageDescriptionControllers[damage.side];
      final description = controller?.text.trim();

      print('🔧 معالجة ضرر ${i + 1}:');
      print('   الجانب: ${damage.side}');
      print('   النوع: ${damage.type}');
      print('   الوصف: ${description ?? "فارغ"}');

      finalDamages.add(VehicleDamage(
        side: damage.side,
        type: damage.type,
        description: description?.isNotEmpty == true ? description : null,
      ));
    }

    print('📋 تم إعداد ${finalDamages.length} ضرر للإرسال');
    return finalDamages;
  }

  void _disposeDamageControllers() {
    for (final controller in _damageDescriptionControllers.values) {
      controller.dispose();
    }
    _damageDescriptionControllers.clear();
  }

  @override
  void initState() {
    super.initState();
    _tabController =
        TabController(length: 4, vsync: this); // زيادة عدد التبويبات
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

    // Client address controllers
    _clientAddressStreetController = TextEditingController(
        text: order.clientAddress?.street ?? '');
    _clientAddressHouseController = TextEditingController(
        text: order.clientAddress?.houseNumber ?? '');
    _clientAddressZipController = TextEditingController(
        text: order.clientAddress?.zipCode ?? '');
    _clientAddressCityController = TextEditingController(
        text: order.clientAddress?.city ?? '');

    // Billing initialization
    _isSameBilling = order.isSameBilling;
    _billingNameController =
        TextEditingController(text: order.billingName ?? '');
    _billingPhoneController =
        TextEditingController(text: order.billingPhone ?? '');
    _billingEmailController =
        TextEditingController(text: order.billingEmail ?? '');
    _billingAddressStreetController = TextEditingController(
        text: order.billingAddress?.street ?? '');
    _billingAddressHouseController = TextEditingController(
        text: order.billingAddress?.houseNumber ?? '');
    _billingAddressZipController = TextEditingController(
        text: order.billingAddress?.zipCode ?? '');
    _billingAddressCityController = TextEditingController(
        text: order.billingAddress?.city ?? '');

    // Vehicle controllers
    _vehicleOwnerController = TextEditingController(text: order.vehicleOwner);
    _licensePlateController =
        TextEditingController(text: order.licensePlateNumber);

    // Additional vehicle fields
    _ukzController = TextEditingController(text: order.ukz);
    _finController = TextEditingController(text: order.fin);
    _bestellnummerController = TextEditingController(text: order.bestellnummer);
    _leasingvertragsnummerController =
        TextEditingController(text: order.leasingvertragsnummer);
    _kostenstelleController = TextEditingController(text: order.kostenstelle);
    _bemerkungController = TextEditingController(text: order.bemerkung);
    _typController = TextEditingController(text: order.typ);

    // Pickup address controllers
    _pickupStreetController =
        TextEditingController(text: order.pickupAddress.street);
    _pickupHouseController =
        TextEditingController(text: order.pickupAddress.houseNumber);
    _pickupZipController =
        TextEditingController(text: order.pickupAddress.zipCode);
    _pickupCityController =
        TextEditingController(text: order.pickupAddress.city);
    _pickupDateController = TextEditingController(
        text: order.pickupAddress.date?.toIso8601String().split('T')[0] ?? '');
    _pickupCompanyController =
        TextEditingController(text: order.pickupAddress.companyName ?? '');
    _pickupContactNameController = TextEditingController(
        text: order.pickupAddress.contactPersonName ?? '');
    _pickupContactPhoneController = TextEditingController(
        text: order.pickupAddress.contactPersonPhone ?? '');
    _pickupContactEmailController = TextEditingController(
        text: order.pickupAddress.contactPersonEmail ?? '');
    _pickupFuelMeterController = TextEditingController(
        text: order.pickupAddress.fuelMeter?.toString() ?? '');
    _pickupFuelLevel.value = order.pickupAddress.fuelLevel ?? 0;

    // Delivery address controllers
    _deliveryStreetController =
        TextEditingController(text: order.deliveryAddress.street);
    _deliveryHouseController =
        TextEditingController(text: order.deliveryAddress.houseNumber);
    _deliveryZipController =
        TextEditingController(text: order.deliveryAddress.zipCode);
    _deliveryCityController =
        TextEditingController(text: order.deliveryAddress.city);
    _deliveryDateController = TextEditingController(
        text: order.deliveryAddress.date?.toIso8601String().split('T')[0] ??
            '');
    _deliveryCompanyController =
        TextEditingController(text: order.deliveryAddress.companyName ?? '');
    _deliveryContactNameController = TextEditingController(
        text: order.deliveryAddress.contactPersonName ?? '');
    _deliveryContactPhoneController = TextEditingController(
        text: order.deliveryAddress.contactPersonPhone ?? '');
    _deliveryContactEmailController = TextEditingController(
        text: order.deliveryAddress.contactPersonEmail ?? '');
    _deliveryFuelMeterController = TextEditingController(
        text: order.deliveryAddress.fuelMeter?.toString() ?? '');
    _deliveryFuelLevel.value = order.deliveryAddress.fuelLevel ?? 0;

    _selectedServiceType = order.serviceType;
    _selectedItems.assignAll(order.items);

    _initializeDamageControllers();

  }

  void _setupChangeListeners() {
    final controllers = [
      _clientController,
      _clientPhoneController,
      _clientEmailController,
      _descriptionController,
      _commentsController,
      _vehicleOwnerController,
      _licensePlateController,
      _clientAddressStreetController,
      _clientAddressHouseController,
      _clientAddressZipController,
      _clientAddressCityController,
      _billingNameController,
      _billingPhoneController,
      _billingEmailController,
      _billingAddressStreetController,
      _billingAddressHouseController,
      _billingAddressZipController,
      _billingAddressCityController,
      _ukzController,
      _finController,
      _bestellnummerController,
      _leasingvertragsnummerController,
      _kostenstelleController,
      _bemerkungController,
      _typController,
      _pickupStreetController,
      _pickupHouseController,
      _pickupZipController,
      _pickupCityController,
      _pickupDateController,
      _pickupCompanyController,
      _pickupContactNameController,
      _pickupContactPhoneController,
      _pickupContactEmailController,
      _pickupFuelMeterController,
      _deliveryStreetController,
      _deliveryHouseController,
      _deliveryZipController,
      _deliveryCityController,
      _deliveryDateController,
      _deliveryCompanyController,
      _deliveryContactNameController,
      _deliveryContactPhoneController,
      _deliveryContactEmailController,
      _deliveryFuelMeterController,
    ];

    for (final controller in controllers) {
      controller.addListener(() {
        if (!_isModified) {
          setState(() => _isModified = true);
        }
      });
    }
    _setupDamageChangeListeners();

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightGray,
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
                  _buildClientInfoTab(),
                  _buildVehicleInfoTab(),
                  _buildPickupAddressTab(),
                  _buildDeliveryAddressTab(),
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
      backgroundColor: AppColors.pureWhite,
      foregroundColor: AppColors.darkGray,
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'edit_order'.tr,
            style: AppColors.subHeadingStyle.copyWith(fontWeight: FontWeight.bold),
          ),
          Text(
            '${widget.order.client}',
            style: TextStyle(fontSize: 14, color: AppColors.secondaryText),
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
                style: TextStyle(color: AppColors.whiteText, fontSize: 12),
              ),
              backgroundColor: AppColors.pendingOrange,
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
          ),
        Obx(() =>
        _controller.isCreating
            ? Container(
          margin: EdgeInsets.all(12),
          width: 20,
          height: 20,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: AppColors.primaryBlue,
          ),
        )
            : IconButton(
          icon: Icon(Icons.save_rounded, color: AppColors.primaryBlue),
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
            backgroundColor: AppColors.borderGray,
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryBlue),
          )),
    );
  }

  Widget _buildTabBar() {
    return Container(
      color: AppColors.pureWhite,
      child: TabBar(
        controller: _tabController,
        labelColor: AppColors.primaryBlue,
        unselectedLabelColor: AppColors.mediumGray,
        indicatorColor: AppColors.primaryBlue,
        indicatorWeight: 3,
        isScrollable: true,
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
            icon: Icon(Icons.where_to_vote),
            text: 'pickup_address'.tr,
          ),
          Tab(
            icon: Icon(Icons.location_on),
            text: 'delivery_address'.tr,
          ),
        ],
      ),
    );
  }

  Widget _buildClientInfoTab() {
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
            title: 'client_address'.tr,
            icon: Icons.location_on,
            children: [
              Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: _buildTextField(
                      controller: _clientAddressStreetController,
                      label: 'street'.tr,
                      icon: Icons.edit_road,
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: _buildTextField(
                      controller: _clientAddressHouseController,
                      label: 'house_number'.tr,
                      icon: Icons.home_outlined,
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  Expanded(
                    child: _buildTextField(
                      controller: _clientAddressZipController,
                      label: 'postal_code'.tr,
                      icon: Icons.markunread_mailbox_outlined,
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: _buildTextField(
                      controller: _clientAddressCityController,
                      label: 'city'.tr,
                      icon: Icons.location_city_outlined,
                    ),
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: 16),
          _buildBillingSection(),
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

  Widget _buildBillingSection() {
    return _buildSectionCard(
      title: 'billing_info'.tr,
      icon: Icons.receipt,
      children: [
        CheckboxListTile(
          value: _isSameBilling,
          onChanged: (value) {
            setState(() {
              _isSameBilling = value ?? true;
              _isModified = true;
            });
          },
          title: Text('same_as_client'.tr, style: TextStyle(color: AppColors.darkGray)),
          subtitle: Text('billing_same_client_desc'.tr, style: TextStyle(color: AppColors.secondaryText)),
          controlAffinity: ListTileControlAffinity.leading,
          activeColor: AppColors.primaryBlue,
        ),
        if (!_isSameBilling) ...[
          SizedBox(height: 16),
          _buildTextField(
            controller: _billingNameController,
            label: 'billing_name'.tr,
            icon: Icons.person_outline,
          ),
          _buildTextField(
            controller: _billingPhoneController,
            label: 'billing_phone'.tr,
            icon: Icons.phone_outlined,
            keyboardType: TextInputType.phone,
          ),
          _buildTextField(
            controller: _billingEmailController,
            label: 'billing_email'.tr,
            icon: Icons.email_outlined,
            keyboardType: TextInputType.emailAddress,
          ),
          Text(
            'billing_address'.tr,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: AppColors.primaryBlue,
            ),
          ),
          SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                flex: 3,
                child: _buildTextField(
                  controller: _billingAddressStreetController,
                  label: 'street'.tr,
                  icon: Icons.location_on_outlined,
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: _buildTextField(
                  controller: _billingAddressHouseController,
                  label: 'house_number'.tr,
                  icon: Icons.home_outlined,
                ),
              ),
            ],
          ),
          Row(
            children: [
              Expanded(
                child: _buildTextField(
                  controller: _billingAddressZipController,
                  label: 'postal_code'.tr,
                  icon: Icons.mail_outline,
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: _buildTextField(
                  controller: _billingAddressCityController,
                  label: 'city'.tr,
                  icon: Icons.location_city_outlined,
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildVehicleInfoTab() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        children: [
          _buildSectionCard(
            title: 'basic_vehicle_info'.tr,
            icon: Icons.directions_car,
            children: [
              _buildTextField(
                controller: _vehicleOwnerController,
                label: 'vehicle_owner'.tr,
                icon: Icons.person_pin_outlined,
              ),
              _buildTextField(
                controller: _licensePlateController,
                label: 'license_plate'.tr,
                icon: Icons.confirmation_number_outlined,
              ),
            ],
          ),
          SizedBox(height: 16),
          _buildSectionCard(
            title: 'additional_vehicle_info'.tr,
            icon: Icons.info_outline,
            children: [
              Row(
                children: [
                  Expanded(
                    child: _buildTextField(
                      controller: _ukzController,
                      label: 'ÜKZ',
                      icon: Icons.confirmation_number_outlined,
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: _buildTextField(
                      controller: _finController,
                      label: 'FIN',
                      icon: Icons.fingerprint,
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  Expanded(
                    child: _buildTextField(
                      controller: _bestellnummerController,
                      label: 'Bestellnummer',
                      icon: Icons.receipt_long,
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: _buildTextField(
                      controller: _leasingvertragsnummerController,
                      label: 'Leasingvertragsnummer',
                      icon: Icons.assignment,
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  Expanded(
                    child: _buildTextField(
                      controller: _kostenstelleController,
                      label: 'Kostenstelle',
                      icon: Icons.account_balance,
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: _buildTextField(
                      controller: _typController,
                      label: 'Typ',
                      icon: Icons.category,
                    ),
                  ),
                ],
              ),
              _buildTextField(
                controller: _bemerkungController,
                label: 'Bemerkung',
                icon: Icons.note,
                maxLines: 3,
              ),
            ],
          ),
          SizedBox(height: 16),
          _buildVehicleItemsSection(),
          const SizedBox(height: 16),
          _buildVehicleDamageSection(),
        ],
      ),
    );
  }

  Widget _buildVehicleItemsSection() {
    return _buildSectionCard(
      title: 'vehicle_items'.tr,
      icon: Icons.checklist,
      children: [
        Text(
          'select_available_items'.tr,
          style: TextStyle(
            fontSize: 14,
            color: AppColors.secondaryText,
          ),
        ),
        SizedBox(height: 16),
        Obx(() =>
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: VehicleItem.values.map((item) {
                final isSelected = _selectedItems.contains(item);
                return FilterChip(
                  label: Text(
                    _getVehicleItemText(item),
                    style: TextStyle(
                      fontSize: 12,
                      color: isSelected ? AppColors.whiteText : AppColors.darkGray,
                    ),
                  ),
                  selected: isSelected,
                  onSelected: (selected) {
                    setState(() {
                      if (selected) {
                        _selectedItems.add(item);
                      } else {
                        _selectedItems.remove(item);
                      }
                      _isModified = true;
                    });
                  },
                  selectedColor: AppColors.primaryBlue,
                  checkmarkColor: AppColors.whiteText,
                  backgroundColor: AppColors.lightGray,
                  side: BorderSide(
                    color: isSelected ? AppColors.primaryBlue : AppColors.borderGray,
                  ),
                );
              }).toList(),
            )),
      ],
    );
  }

  Widget _buildVehicleDamageSection() {
    return _buildSectionCard(
      title: 'vehicle_damages'.tr,
      icon: Icons.car_repair_outlined,
      children: [
        Text(
          'select_vehicle_damages'.tr,
          style: TextStyle(
            fontSize: 14,
            color: AppColors.secondaryText,
          ),
        ),
        const SizedBox(height: 16),

        // خريطة السيارة مع الجوانب
        _buildEditVehicleDiagram(),

        const SizedBox(height: 20),

        // قائمة الجوانب المحددة والأضرار
        Obx(() => Column(
          children: VehicleSide.values.map((side) {
            final sideText = _getVehicleSideText(side);
            final sideDamages = _getDamagesForSide(side);
            final isSelected = _selectedSides.contains(side);

            return Column(
              children: [
                // عنوان الجانب مع زر التحديد
                Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    children: [
                      Checkbox(
                        value: isSelected,
                        onChanged: (value) {
                          _toggleVehicleSide(side);
                        },
                        activeColor: AppColors.primaryBlue,
                      ),
                      Expanded(
                        child: Text(
                          sideText,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: isSelected ? AppColors.primaryBlue : AppColors.mediumGray,
                          ),
                        ),
                      ),
                      if (sideDamages.isNotEmpty)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.lightRedBg,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '${sideDamages.length}',
                            style: TextStyle(
                              color: AppColors.errorRed,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),

                // أنواع الأضرار للجانب المحدد
                if (isSelected) ...[
                  Container(
                    margin: const EdgeInsets.only(left: 32, bottom: 16),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.lightBlueBg,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.borderGray),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'damage_types_for'.tr.replaceAll('side', sideText),
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: AppColors.primaryBlue,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          runSpacing: 4,
                          children: DamageType.values.map((damageType) {
                            final damageText = _getDamageTypeText(damageType);
                            final isDamageSelected = _isDamageSelected(side, damageType);

                            return FilterChip(
                              label: Text(
                                damageText,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: isDamageSelected ? AppColors.whiteText : AppColors.darkGray,
                                ),
                              ),
                              selected: isDamageSelected,
                              onSelected: (selected) {
                                _toggleDamage(side, damageType);
                              },
                              selectedColor: AppColors.errorRed,
                              checkmarkColor: AppColors.whiteText,
                              backgroundColor: AppColors.lightGray,
                              side: BorderSide(
                                color: isDamageSelected ? AppColors.errorRed : AppColors.borderGray,
                              ),
                            );
                          }).toList(),
                        ),

                        // حقل وصف الأضرار للجانب
                        if (sideDamages.isNotEmpty) ...[
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: _getDamageDescriptionController(side),
                            decoration: InputDecoration(
                              labelText: 'damage_description'.tr,
                              hintText: 'describe_damages_for'.tr.replaceAll('side', sideText),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide(color: AppColors.borderGray),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide(color: AppColors.borderGray),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide(color: AppColors.primaryBlue, width: 2),
                              ),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            ),
                            maxLines: 2,
                            style: const TextStyle(fontSize: 14, color: AppColors.darkGray),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ],
            );
          }).toList(),
        )),

        // ملخص الأضرار المحددة
        Obx(() {
          final totalDamages = _selectedDamages.length;
          if (totalDamages > 0) {
            return Container(
              margin: const EdgeInsets.only(top: 16),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.lightOrangeBg,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.pendingOrange),
              ),
              child: Row(
                children: [
                  Icon(Icons.warning_amber_rounded, color: AppColors.pendingOrange),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'total_damages_selected'.tr.replaceAll('count', totalDamages.toString()),
                      style: TextStyle(
                        color: AppColors.pendingOrange,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: () => _clearAllDamages(),
                    child: Text(
                      'clear_all'.tr,
                      style: TextStyle(color: AppColors.pendingOrange),
                    ),
                  ),
                ],
              ),
            );
          }
          return const SizedBox.shrink();
        }),
      ],
    );
  }

  Widget _buildEditVehicleDiagram() {
    return Container(
      height: 200,
      child: Stack(
        children: [
          // خلفية السيارة
          Center(
            child: Container(
              width: 120,
              height: 180,
              decoration: BoxDecoration(
                color: AppColors.lightGray,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.borderGray),
              ),
              child: Icon(
                Icons.directions_car,
                size: 80,
                color: AppColors.mediumGray,
              ),
            ),
          ),

          // نقاط الجوانب القابلة للنقر
          Obx(() => Stack(
            children: [
              // الأمام
              Positioned(
                top: 20,
                left: 0,
                right: 0,
                child: _buildEditSideButton(VehicleSide.FRONT, 'top'),
              ),
              // الخلف
              Positioned(
                bottom: 20,
                left: 0,
                right: 0,
                child: _buildEditSideButton(VehicleSide.REAR, 'bottom'),
              ),
              // اليسار
              Positioned(
                top: 0,
                bottom: 0,
                left: 20,
                child: _buildEditSideButton(VehicleSide.LEFT, 'left'),
              ),
              // اليمين
              Positioned(
                top: 0,
                bottom: 0,
                right: 20,
                child: _buildEditSideButton(VehicleSide.RIGHT, 'right'),
              ),
              // الأعلى
              Positioned(
                top: 50,
                left: 0,
                right: 0,
                child: _buildEditSideButton(VehicleSide.TOP, 'center'),
              ),
            ],
          )),
        ],
      ),
    );
  }

  Widget _buildEditSideButton(VehicleSide side, String position) {
    final isSelected = _selectedSides.contains(side);
    final hasDamages = _getDamagesForSide(side).isNotEmpty;

    return Center(
      child: GestureDetector(
        onTap: () => _toggleVehicleSide(side),
        child: Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            color: hasDamages ? AppColors.errorRed :
            isSelected ? AppColors.primaryBlue : AppColors.mediumGray,
            shape: BoxShape.circle,
            border: Border.all(
              color: AppColors.pureWhite,
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.lightShadow,
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Icon(
            hasDamages ? Icons.warning : Icons.add,
            color: AppColors.pureWhite,
            size: 16,
          ),
        ),
      ),
    );
  }

  Widget _buildPickupAddressTab() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        children: [
          _buildAddressCard(
            title: 'pickup_address'.tr,
            icon: Icons.where_to_vote,
            color: AppColors.successGreen,
            streetController: _pickupStreetController,
            houseController: _pickupHouseController,
            zipController: _pickupZipController,
            cityController: _pickupCityController,
            dateController: _pickupDateController,
            companyController: _pickupCompanyController,
            contactNameController: _pickupContactNameController,
            contactPhoneController: _pickupContactPhoneController,
            contactEmailController: _pickupContactEmailController,
            fuelMeterController: _pickupFuelMeterController,
            fuelLevel: _pickupFuelLevel,
          ),
        ],
      ),
    );
  }

  Widget _buildDeliveryAddressTab() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        children: [
          _buildAddressCard(
            title: 'delivery_address'.tr,
            icon: Icons.location_on,
            color: AppColors.primaryBlue,
            streetController: _deliveryStreetController,
            houseController: _deliveryHouseController,
            zipController: _deliveryZipController,
            cityController: _deliveryCityController,
            dateController: _deliveryDateController,
            companyController: _deliveryCompanyController,
            contactNameController: _deliveryContactNameController,
            contactPhoneController: _deliveryContactPhoneController,
            contactEmailController: _deliveryContactEmailController,
            fuelMeterController: _deliveryFuelMeterController,
            fuelLevel: _deliveryFuelLevel,
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
          prefixIcon: Icon(Icons.build_outlined, color: AppColors.mediumGray),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: AppColors.borderGray),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: AppColors.primaryBlue, width: 2),
          ),
          filled: true,
          fillColor: AppColors.lightGray,
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
        items: ServiceType.values.map((ServiceType type) {
          return DropdownMenuItem<ServiceType>(
            value: type,
            child: Text(
                _getServiceTypeText(type),
                style: TextStyle(fontSize: 16, color: AppColors.darkGray)),
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
        style: TextStyle(color: AppColors.darkGray),
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
      shadowColor: AppColors.lightShadow,
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: AppColors.primaryBlue, size: 24),
                SizedBox(width: 8),
                Expanded( // إضافة Expanded هنا
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.darkGray,
                    ),
                    overflow: TextOverflow.ellipsis, // إضافة overflow
                    maxLines: 2, // السماح بسطرين
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
    required TextEditingController dateController,
    required TextEditingController companyController,
    required TextEditingController contactNameController,
    required TextEditingController contactPhoneController,
    required TextEditingController contactEmailController,
    required TextEditingController fuelMeterController,
    required RxInt fuelLevel,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      shadowColor: AppColors.lightShadow,
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
                    color: AppColors.darkGray,
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),

            // Basic address fields
            _buildTextField(
              controller: streetController,
              label: 'street'.tr,
              icon: Icons.edit_road,
            ),
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: _buildTextField(
                    controller: houseController,
                    label: 'house_number'.tr,
                    icon: Icons.home_outlined,
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
                  ),
                ),
              ],
            ),
            _buildTextField(
              controller: cityController,
              label: 'city'.tr,
              icon: Icons.location_city_outlined,
            ),

            // Additional address information section
            const SizedBox(height: 16),
            Text(
              'additional_info'.tr,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: AppColors.primaryBlue,
              ),
            ),
            const SizedBox(height: 8),

            // Date and Company
            Row(
              children: [
                Expanded(
                  child: _buildDateField(
                    controller: dateController,
                    label: 'date'.tr,
                    icon: Icons.date_range,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildTextField(
                    controller: companyController,
                    label: 'company_name'.tr,
                    icon: Icons.business,
                  ),
                ),
              ],
            ),

            // Contact person details
            _buildTextField(
              controller: contactNameController,
              label: 'contact_person_name'.tr,
              icon: Icons.person_outline,
            ),
            Row(
              children: [
                Expanded(
                  child: _buildTextField(
                    controller: contactPhoneController,
                    label: 'contact_person_phone'.tr,
                    icon: Icons.phone_outlined,
                    keyboardType: TextInputType.phone,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildTextField(
                    controller: contactEmailController,
                    label: 'contact_person_email'.tr,
                    icon: Icons.email_outlined,
                    keyboardType: TextInputType.emailAddress,
                  ),
                ),
              ],
            ),

            // Fuel information
            Row(
              children: [
                Expanded(
                  child: _buildFuelLevelSlider(
                    value: fuelLevel,
                    label: 'fuel_level'.tr,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildTextField(
                    controller: fuelMeterController,
                    label: 'fuel_meter'.tr,
                    icon: Icons.speed,
                    keyboardType: TextInputType.number,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDateField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
  }) {
    return Padding(
      padding: EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: AppColors.mediumGray),
          suffixIcon: IconButton(
            icon: Icon(Icons.calendar_today, color: AppColors.mediumGray),
            onPressed: () async {
              final date = await showDatePicker(
                context: Get.context!,
                initialDate: DateTime.now(),
                firstDate: DateTime.now().subtract(Duration(days: 30)),
                lastDate: DateTime.now().add(Duration(days: 365)),
              );
              if (date != null) {
                controller.text = date.toIso8601String().split('T')[0];
                if (!_isModified) {
                  setState(() => _isModified = true);
                }
              }
            },
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: AppColors.borderGray),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: AppColors.primaryBlue, width: 2),
          ),
          filled: true,
          fillColor: AppColors.lightGray,
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
        readOnly: true,
        style: TextStyle(fontSize: 16, color: AppColors.darkGray),
      ),
    );
  }

  Widget _buildFuelLevelSlider({
    required RxInt value,
    required String label,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$label: ${value.value}/8',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: AppColors.mediumGray,
            ),
          ),
          SizedBox(height: 8),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.borderGray),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                Obx(() => Slider(
                  value: value.value.toDouble(),
                  min: 0,
                  max: 8,
                  divisions: 8,
                  label: '${value.value}/8',
                  onChanged: (double newValue) {
                    value.value = newValue.round();
                    if (!_isModified) {
                      setState(() => _isModified = true);
                    }
                  },
                  activeColor: AppColors.primaryBlue,
                  inactiveColor: AppColors.borderGray,
                )),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: List.generate(9, (index) {
                    return Text(
                      '$index',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.secondaryText,
                      ),
                    );
                  }),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    int maxLines = 1,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: AppColors.mediumGray),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: AppColors.borderGray),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: AppColors.primaryBlue, width: 2),
          ),
          filled: true,
          fillColor: AppColors.lightGray,
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
        maxLines: maxLines,
        keyboardType: keyboardType,
        validator: validator,
        style: TextStyle(fontSize: 16, color: AppColors.darkGray),
      ),
    );
  }

  Widget _buildBottomActions() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.pureWhite,
        boxShadow: [
          BoxShadow(
            color: AppColors.lightShadow,
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
              child: OutlinedButton.icon(
                onPressed: () => Get.back(),
                icon: Icon(Icons.cancel_outlined, size: 18, color: AppColors.mediumGray),
                label: Text('cancel'.tr, style: TextStyle(color: AppColors.darkGray)),
                style: AppColors.secondaryButtonStyle,
              ),
            ),
            SizedBox(width: 12),
            Expanded(
              flex: 2,
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
                        valueColor: AlwaysStoppedAnimation<Color>(AppColors.whiteText),
                      ),
                    )
                        : Icon(Icons.save, size: 18),
                    label: Text(_controller.isCreating
                        ? 'saving'.tr
                        : 'save_changes'.tr),
                    style: AppColors.primaryButtonStyle.copyWith(
                      backgroundColor: MaterialStateProperty.resolveWith<Color>(
                            (Set<MaterialState> states) {
                          if (states.contains(MaterialState.disabled)) {
                            return AppColors.mediumGray;
                          }
                          return AppColors.primaryBlue;
                        },
                      ),
                    ),
                  )),
            ),
          ],
        ),
      ),
    );
  }
  // إضافة دالة _getVehicleItemText المفقودة
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
        return item.toString().split('.').last.replaceAll('_', ' ');
    }
  }


// إضافة دالة _getServiceTypeText المفقودة
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
      default:
        return serviceType.toString().split('.').last;
    }
  }



// تحديث دالة dispose لتشمل جميع الحقول الجديدة
  @override
  void dispose() {
    _tabController.dispose();

    // Basic controllers
    _clientController.dispose();
    _clientPhoneController.dispose();
    _clientEmailController.dispose();
    _descriptionController.dispose();
    _commentsController.dispose();
    _vehicleOwnerController.dispose();
    _licensePlateController.dispose();

    // Client address controllers
    _clientAddressStreetController.dispose();
    _clientAddressHouseController.dispose();
    _clientAddressZipController.dispose();
    _clientAddressCityController.dispose();

    // Billing controllers
    _billingNameController.dispose();
    _billingPhoneController.dispose();
    _billingEmailController.dispose();
    _billingAddressStreetController.dispose();
    _billingAddressHouseController.dispose();
    _billingAddressZipController.dispose();
    _billingAddressCityController.dispose();

    // Additional vehicle fields controllers
    _ukzController.dispose();
    _finController.dispose();
    _bestellnummerController.dispose();
    _leasingvertragsnummerController.dispose();
    _kostenstelleController.dispose();
    _bemerkungController.dispose();
    _typController.dispose();

    // Pickup address controllers
    _pickupStreetController.dispose();
    _pickupHouseController.dispose();
    _pickupZipController.dispose();
    _pickupCityController.dispose();
    _pickupDateController.dispose();
    _pickupCompanyController.dispose();
    _pickupContactNameController.dispose();
    _pickupContactPhoneController.dispose();
    _pickupContactEmailController.dispose();
    _pickupFuelMeterController.dispose();

    // Delivery address controllers
    _deliveryStreetController.dispose();
    _deliveryHouseController.dispose();
    _deliveryZipController.dispose();
    _deliveryCityController.dispose();
    _deliveryDateController.dispose();
    _deliveryCompanyController.dispose();
    _deliveryContactNameController.dispose();
    _deliveryContactPhoneController.dispose();
    _deliveryContactEmailController.dispose();
    _deliveryFuelMeterController.dispose();

    _disposeDamageControllers();
    super.dispose();
  }


  // تحديث دالة _submitForm لتشمل الحقول الجديدة
  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) {
      _tabController.animateTo(0);
      return;
    }

    final finalDamages = _getFinalDamagesList();
    print('🔧 عدد الأضرار المُحضرة: ${finalDamages.length}');

    // طباعة تفاصيل الأضرار للتشخيص
    for (int i = 0; i < finalDamages.length; i++) {
      final damage = finalDamages[i];
      print('🔧 ضرر ${i + 1}: ${damage.side} - ${damage.type} - ${damage.description ?? "بدون وصف"}');
    }

    print('starting_save_process'.tr);

    // تحضير بيانات الأضرار بشكل صحيح
    final damagesData = finalDamages.map((damage) => {
      'side': damage.side.toString().split('.').last.toUpperCase(),
      'type': damage.type.toString().split('.').last.toUpperCase(),
      'description': damage.description?.isNotEmpty == true ? damage.description : null,
    }).toList();

    print('🔧 بيانات الأضرار النهائية: $damagesData');

    final orderData = {
      'client': _clientController.text.trim(),
      'clientPhone': _clientPhoneController.text.trim(),
      'clientEmail': _clientEmailController.text.trim(),
      'description': _descriptionController.text.trim(),
      'comments': _commentsController.text.trim(),
      'vehicleOwner': _vehicleOwnerController.text.trim(),
      'licensePlateNumber': _licensePlateController.text.trim(),
      'serviceType': _selectedServiceType
          .toString()
          .split('.')
          .last
          .toUpperCase(),

      // Client address with all fields
      'clientAddress': {
        'street': _clientAddressStreetController.text.trim(),
        'houseNumber': _clientAddressHouseController.text.trim(),
        'zipCode': _clientAddressZipController.text.trim(),
        'city': _clientAddressCityController.text.trim(),
        'country': widget.order.clientAddress?.country ?? 'Deutschland',
      },

      // Billing information
      'isSameBilling': _isSameBilling,
      'billingName': _isSameBilling ? null : _billingNameController.text.trim(),
      'billingPhone': _isSameBilling ? null : _billingPhoneController.text.trim(),
      'billingEmail': _isSameBilling ? null : _billingEmailController.text.trim(),
      'billingAddress': _isSameBilling ? null : {
        'street': _billingAddressStreetController.text.trim(),
        'houseNumber': _billingAddressHouseController.text.trim(),
        'zipCode': _billingAddressZipController.text.trim(),
        'city': _billingAddressCityController.text.trim(),
        'country': widget.order.billingAddress?.country ?? 'Deutschland',
      },

      // Additional vehicle fields
      'ukz': _ukzController.text.trim(),
      'fin': _finController.text.trim(),
      'bestellnummer': _bestellnummerController.text.trim(),
      'leasingvertragsnummer': _leasingvertragsnummerController.text.trim(),
      'kostenstelle': _kostenstelleController.text.trim(),
      'bemerkung': _bemerkungController.text.trim(),
      'typ': _typController.text.trim(),

      // Vehicle items
      'items': _selectedItems.map((item) => item.toString().split('.').last).toList(),

      // Extended pickup address
      'pickupAddress': {
        'street': _pickupStreetController.text.trim(),
        'houseNumber': _pickupHouseController.text.trim(),
        'zipCode': _pickupZipController.text.trim(),
        'city': _pickupCityController.text.trim(),
        'country': widget.order.pickupAddress.country,
        'date': _pickupDateController.text.isNotEmpty ? _pickupDateController.text : null,
        'companyName': _pickupCompanyController.text.trim().isEmpty ? null : _pickupCompanyController.text.trim(),
        'contactPersonName': _pickupContactNameController.text.trim().isEmpty ? null : _pickupContactNameController.text.trim(),
        'contactPersonPhone': _pickupContactPhoneController.text.trim().isEmpty ? null : _pickupContactPhoneController.text.trim(),
        'contactPersonEmail': _pickupContactEmailController.text.trim().isEmpty ? null : _pickupContactEmailController.text.trim(),
        'fuelLevel': _pickupFuelLevel.value,
        'fuelMeter': double.tryParse(_pickupFuelMeterController.text.trim()),
      },

      // Extended delivery address
      'deliveryAddress': {
        'street': _deliveryStreetController.text.trim(),
        'houseNumber': _deliveryHouseController.text.trim(),
        'zipCode': _deliveryZipController.text.trim(),
        'city': _deliveryCityController.text.trim(),
        'country': widget.order.deliveryAddress.country,
        'date': _deliveryDateController.text.isNotEmpty ? _deliveryDateController.text : null,
        'companyName': _deliveryCompanyController.text.trim().isEmpty ? null : _deliveryCompanyController.text.trim(),
        'contactPersonName': _deliveryContactNameController.text.trim().isEmpty ? null : _deliveryContactNameController.text.trim(),
        'contactPersonPhone': _deliveryContactPhoneController.text.trim().isEmpty ? null : _deliveryContactPhoneController.text.trim(),
        'contactPersonEmail': _deliveryContactEmailController.text.trim().isEmpty ? null : _deliveryContactEmailController.text.trim(),
        'fuelLevel': _deliveryFuelLevel.value,
        'fuelMeter': double.tryParse(_deliveryFuelMeterController.text.trim()),
      },

      // ===== إضافة الأضرار بشكل صحيح =====
      'damages': damagesData, // استخدام المتغير المُحضر
    };

    // طباعة البيانات للتأكد من وجود الأضرار
    print("============================ البيانات المُرسلة ============================");
    print('📊 عدد الحقول الكلي: ${orderData.keys.length}');
    print('📊 الحقول الموجودة: ${orderData.keys.join(', ')}');

    if (orderData.containsKey('damages')) {
      print('✅ حقل الأضرار موجود!');
      print('📊 عدد الأضرار: ${(orderData['damages'] as List).length}');
      print('📊 الأضرار: ${orderData['damages']}');
    } else {
      print('❌ حقل الأضرار مفقود!');
    }

    print(jsonEncode(orderData));
    print("=============================================================================");

    bool shouldReturn = true;
    String message = 'changes_saved'.tr;
    Color messageColor = Colors.green;

    try {
      final success = await _controller.updateFullOrder(
        orderId: widget.order.id,
        orderData: orderData,
      ).timeout(
        Duration(seconds: 10),
        onTimeout: () {
          print('request_timeout'.tr);
          return false;
        },
      );

      if (!success) {
        message = 'failed_to_save_changes'.tr;
        messageColor = Colors.orange;
      } else {
        setState(() => _isModified = false);
      }
    } catch (e) {
      print('save_error'.tr.replaceAll('error', e.toString()));
      message = 'error_occurred_while_saving'.tr;
      messageColor = Colors.orange;
    }

    Get.snackbar(
      message.contains('تم') || message.contains('saved') || message.contains('gespeichert') ?
      'success_saved'.tr : 'error_occurred'.tr,
      message,
      backgroundColor: messageColor,
      colorText: Colors.white,
      snackPosition: SnackPosition.TOP,
      duration: const Duration(seconds: 3),
    );

    if (messageColor == Colors.green) {
      Get.back();
    }
  }

}