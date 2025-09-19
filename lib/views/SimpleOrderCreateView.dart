import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/order_controller.dart';
import '../models/new_address.dart';
import '../models/new_order.dart';
import '../utils/AppColors.dart';


class SimpleOrderCreateView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GetBuilder<SimpleOrderCreateController>(
      init: SimpleOrderCreateController(),
      builder: (controller) {
        return Scaffold(
          appBar: AppBar(
            title: Text('create_new_order'.tr,
                style: TextStyle(color: AppColors.whiteText)),
            backgroundColor: AppColors.primaryBlue,
            foregroundColor: AppColors.whiteText,
            elevation: 0,
          ),
          body: Form(
            key: controller.formKey,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // قسم بيانات العميل
                  _buildSectionTitle('client_data'.tr, Icons.person),
                  _buildTextField(
                    controller: controller.clientController,
                    label: 'client_name'.tr,
                    icon: Icons.person,
                    required: true,
                  ),
                  _buildTextField(
                    controller: controller.clientPhoneController,
                    label: 'phone_number'.tr,
                    icon: Icons.phone,
                    keyboardType: TextInputType.phone,
                    required: true,
                  ),
                  _buildTextField(
                    controller: controller.clientEmailController,
                    label: 'email_address'.tr,
                    icon: Icons.email,
                    keyboardType: TextInputType.emailAddress,
                    required: true,
                  ),

                  // قسم عنوان العميل
                  const SizedBox(height: 16),
                  _buildSectionTitle('client_address'.tr, Icons.location_on),
                  Row(
                    children: [
                      Expanded(
                        flex: 3,
                        child: _buildTextField(
                          controller: controller.clientAddressStreetController,
                          label: 'street'.tr,
                          icon: Icons.location_on,
                          required: true,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildTextField(
                          controller: controller.clientAddressHouseNumberController,
                          label: 'house_number'.tr,
                          icon: Icons.home,
                          required: true,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: _buildTextField(
                          controller: controller.clientAddressZipCodeController,
                          label: 'postal_code'.tr,
                          icon: Icons.mail,
                          required: true,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        flex: 2,
                        child: _buildTextField(
                          controller: controller.clientAddressCityController,
                          label: 'city'.tr,
                          icon: Icons.location_city,
                          required: true,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // قسم صاحب الفاتورة
                  _buildSectionTitle('billing_info'.tr, Icons.receipt),
                  Obx(() => CheckboxListTile(
                    value: controller.isSameBilling.value,
                    onChanged: (value) {
                      controller.isSameBilling.value = value ?? true;
                    },
                    title: Text('same_as_client'.tr,
                        style: TextStyle(color: AppColors.darkGray)),
                    subtitle: Text('billing_same_client_desc'.tr,
                        style: TextStyle(color: AppColors.secondaryText)),
                    controlAffinity: ListTileControlAffinity.leading,
                    activeColor: AppColors.primaryBlue,
                  )),

                  // حقول صاحب الفاتورة
                  Obx(() => !controller.isSameBilling.value ? Column(
                    children: [
                      const SizedBox(height: 16),
                      _buildTextField(
                        controller: controller.billingNameController,
                        label: 'billing_name'.tr,
                        icon: Icons.person_outline,
                        required: true,
                      ),
                      _buildTextField(
                        controller: controller.billingPhoneController,
                        label: 'billing_phone'.tr,
                        icon: Icons.phone_outlined,
                        keyboardType: TextInputType.phone,
                        required: true,
                      ),
                      _buildTextField(
                        controller: controller.billingEmailController,
                        label: 'billing_email'.tr,
                        icon: Icons.email_outlined,
                        keyboardType: TextInputType.emailAddress,
                        required: true,
                      ),

                      // عنوان صاحب الفاتورة
                      const SizedBox(height: 8),
                      Text(
                        'billing_address'.tr,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: AppColors.primaryBlue,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            flex: 3,
                            child: _buildTextField(
                              controller: controller.billingAddressStreetController,
                              label: 'street'.tr,
                              icon: Icons.location_on_outlined,
                              required: true,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _buildTextField(
                              controller: controller.billingAddressHouseNumberController,
                              label: 'house_number'.tr,
                              icon: Icons.home_outlined,
                              required: true,
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: _buildTextField(
                              controller: controller.billingAddressZipCodeController,
                              label: 'postal_code'.tr,
                              icon: Icons.mail_outline,
                              required: true,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            flex: 2,
                            child: _buildTextField(
                              controller: controller.billingAddressCityController,
                              label: 'city'.tr,
                              icon: Icons.location_city_outlined,
                              required: true,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ) : const SizedBox()),
                  const SizedBox(height: 24),

                  // قسم بيانات المركبة الأساسية
                  _buildBasicVehicleData(controller),

                  // قسم بيانات المركبة الإضافية (الحقول الجديدة)
                  _buildAdditionalVehicleFields(controller),

                  const SizedBox(height: 16),
                  _buildTextField(
                    controller: controller.descriptionController,
                    label: 'service_description'.tr,
                    icon: Icons.description,
                    maxLines: 2,
                    required: false,
                  ),

                  _buildServiceTypeDropdown(controller),
                  const SizedBox(height: 24),

                  // قسم الأغراض الجديد
                  _buildVehicleItemsSection(controller),
                  const SizedBox(height: 24),

                  // قسم الأضرار
                  _buildVehicleDamageSection(controller),
                  const SizedBox(height: 24),

                  // قسم عنوان الاستلام المحدث
                  _buildExtendedPickupAddress(controller),
                  const SizedBox(height: 24),

                  // قسم عنوان التسليم المحدث
                  _buildExtendedDeliveryAddress(controller),
                  const SizedBox(height: 32),

                  // زر الإنشاء
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: Obx(() => ElevatedButton(
                      onPressed: controller.isCreating.value ? null : controller.createOrder,
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
                      child: controller.isCreating.value
                          ? const CircularProgressIndicator(color: Colors.white, strokeWidth: 2)
                          : Text(
                        'create_order_btn'.tr,
                        style: AppColors.buttonTextStyle.copyWith(color: AppColors.whiteText),
                      ),
                    )),
                  ),
                  const SizedBox(height: 16),

                  // ملاحظة هامة
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.lightBlueBg,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.borderGray),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.info_outline, color: AppColors.primaryBlue),
                            const SizedBox(width: 8),
                            Text(
                              'important_note'.tr,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: AppColors.primaryBlue,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'order_creation_note'.tr,
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
          ),
        );
      },
    );
  }

  Widget _buildVehicleDamageSection(SimpleOrderCreateController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('vehicle_damages'.tr, Icons.report_problem),
        Container(
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'select_vehicle_damages'.tr,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade600,
                ),
              ),
              SizedBox(height: 16),

              // خريطة السيارة مع الجوانب
              _buildVehicleDiagram(controller),

              SizedBox(height: 20),

              // قائمة الجوانب المحددة والأضرار
              Obx(() => Column(
                children: VehicleSide.values.map((side) {
                  final sideText = controller.getVehicleSideText(side);
                  final sideDamages = controller.getDamagesForSide(side);
                  final isSelected = controller.selectedSides.contains(side);

                  return Column(
                    children: [
                      // عنوان الجانب مع زر التحديد
                      Container(
                        margin: EdgeInsets.only(bottom: 8),
                        child: Row(
                          children: [
                            Checkbox(
                              value: isSelected,
                              onChanged: (value) {
                                controller.toggleVehicleSide(side);
                              },
                              activeColor: Colors.blue.shade600,
                            ),
                            Expanded(
                              child: Text(
                                sideText,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  color: isSelected ? Colors.blue.shade800 : Colors.grey.shade600,
                                ),
                              ),
                            ),
                            if (sideDamages.isNotEmpty)
                              Container(
                                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.red.shade100,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  '${sideDamages.length}',
                                  style: TextStyle(
                                    color: Colors.red.shade800,
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
                          margin: EdgeInsets.only(left: 32, bottom: 16),
                          padding: EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.blue.shade50,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.blue.shade200),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'damage_types_for'.tr.replaceAll('side', sideText),
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.blue.shade800,
                                ),
                              ),
                              SizedBox(height: 8),
                              Wrap(
                                spacing: 8,
                                runSpacing: 4,
                                children: DamageType.values.map((damageType) {
                                  final damageText = controller.getDamageTypeText(damageType);
                                  final isDamageSelected = controller.isDamageSelected(side, damageType);

                                  return FilterChip(
                                    label: Text(
                                      damageText,
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: isDamageSelected ? Colors.white : Colors.black87,
                                      ),
                                    ),
                                    selected: isDamageSelected,
                                    onSelected: (selected) {
                                      controller.toggleDamage(side, damageType);
                                    },
                                    selectedColor: Colors.red.shade600,
                                    checkmarkColor: Colors.white,
                                    backgroundColor: Colors.grey.shade100,
                                    side: BorderSide(
                                      color: isDamageSelected ? Colors.red.shade600 : Colors.grey.shade300,
                                    ),
                                  );
                                }).toList(),
                              ),

                              // حقل وصف الأضرار للجانب
                              if (sideDamages.isNotEmpty) ...[
                                SizedBox(height: 12),
                                TextFormField(
                                  controller: controller.getDamageDescriptionController(side),
                                  decoration: InputDecoration(
                                    labelText: 'damage_description'.tr,
                                    hintText: 'describe_damages_for'.tr.replaceAll('side', sideText),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                  ),
                                  maxLines: 2,
                                  style: TextStyle(fontSize: 14),
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
                final totalDamages = controller.selectedDamages.length;
                if (totalDamages > 0) {
                  return Container(
                    margin: EdgeInsets.only(top: 16),
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.orange.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.orange.shade200),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.warning_amber_rounded, color: Colors.orange.shade600),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'total_damages_selected'.tr.replaceAll('count', totalDamages.toString()),
                            style: TextStyle(
                              color: Colors.orange.shade800,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        TextButton(
                          onPressed: () => controller.clearAllDamages(),
                          child: Text(
                            'clear_all'.tr,
                            style: TextStyle(color: Colors.orange.shade800),
                          ),
                        ),
                      ],
                    ),
                  );
                }
                return SizedBox.shrink();
              }),
            ],
          ),
        ),
      ],
    );
  }
  Widget _buildVehicleItemsSection(SimpleOrderCreateController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('vehicle_items'.tr, Icons.checklist),
        Container(
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.borderGray),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              Text(
                'select_available_items'.tr,
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.secondaryText,
                ),
              ),
              SizedBox(height: 16),
              Obx(() => Wrap(
                spacing: 8,
                runSpacing: 8,
                children: VehicleItem.values.map((item) {
                  final isSelected = controller.selectedItems.contains(item);
                  return FilterChip(
                    label: Text(
                      controller.getVehicleItemText(item),
                      style: TextStyle(
                        fontSize: 12,
                        color: isSelected ? Colors.white : AppColors.darkGray,
                      ),
                    ),
                    selected: isSelected,
                    onSelected: (selected) {
                      controller.toggleItem(item);
                    },
                    selectedColor: AppColors.primaryBlue,
                    checkmarkColor: Colors.white,
                    backgroundColor: AppColors.lightGray,
                    side: BorderSide(
                      color: isSelected ? AppColors.primaryBlue : AppColors.borderGray,
                    ),
                  );
                }).toList(),
              )),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildExtendedPickupAddress(SimpleOrderCreateController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('pickup_address'.tr, Icons.location_on),

        // العنوان الأساسي
        Row(
          children: [
            Expanded(
              flex: 3,
              child: _buildTextField(
                controller: controller.pickupStreetController,
                label: 'street'.tr,
                icon: Icons.location_on,
                required: true,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildTextField(
                controller: controller.pickupHouseNumberController,
                label: 'house_number'.tr,
                icon: Icons.home,
                required: true,
              ),
            ),
          ],
        ),
        Row(
          children: [
            Expanded(
              child: _buildTextField(
                controller: controller.pickupZipCodeController,
                label: 'postal_code'.tr,
                icon: Icons.mail,
                required: true,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              flex: 2,
              child: _buildTextField(
                controller: controller.pickupCityController,
                label: 'city'.tr,
                icon: Icons.location_city,
                required: true,
              ),
            ),
          ],
        ),

        // الحقول الإضافية
        const SizedBox(height: 16),
        Text(
          'additional_pickup_info'.tr,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: AppColors.primaryBlue,
          ),
        ),
        const SizedBox(height: 8),

        // التاريخ واسم الشركة
        Row(
          children: [
            Expanded(
              child: _buildDateField(
                controller: controller.pickupDateController,
                label: 'pickup_date'.tr,
                icon: Icons.date_range,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildTextField(
                controller: controller.pickupCompanyNameController,
                label: 'company_name'.tr,
                icon: Icons.business,
              ),
            ),
          ],
        ),

        // بيانات الموظف
        _buildTextField(
          controller: controller.pickupContactPersonNameController,
          label: 'contact_person_name'.tr,
          icon: Icons.person_outline,
        ),
        Row(
          children: [
            Expanded(
              child: _buildTextField(
                controller: controller.pickupContactPersonPhoneController,
                label: 'contact_person_phone'.tr,
                icon: Icons.phone_outlined,
                keyboardType: TextInputType.phone,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildTextField(
                controller: controller.pickupContactPersonEmailController,
                label: 'contact_person_email'.tr,
                icon: Icons.email_outlined,
                keyboardType: TextInputType.emailAddress,
              ),
            ),
          ],
        ),

        // مستوى الوقود وعداد الوقود
        Row(
          children: [
            Expanded(
              child: _buildFuelLevelSlider(
                value: controller.pickupFuelLevel,
                label: 'fuel_level'.tr,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildTextField(
                controller: controller.pickupFuelMeterController,
                label: 'fuel_meter'.tr,
                icon: Icons.speed,
                keyboardType: TextInputType.number,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildBasicVehicleData(SimpleOrderCreateController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('vehicle_data'.tr, Icons.directions_car),
        _buildTextField(
          controller: controller.vehicleOwnerController,
          label: 'vehicle_owner'.tr,
          icon: Icons.person_outline,
          required: true,
        ),
        _buildTextField(
          controller: controller.licensePlateController,
          label: 'license_plate'.tr,
          icon: Icons.confirmation_number,
          required: true,
        ),
      ],
    );
  }

  Widget _buildExtendedDeliveryAddress(SimpleOrderCreateController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('delivery_address'.tr, Icons.local_shipping),

        // العنوان الأساسي
        Row(
          children: [
            Expanded(
              flex: 3,
              child: _buildTextField(
                controller: controller.deliveryStreetController,
                label: 'street'.tr,
                icon: Icons.location_on,
                required: true,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildTextField(
                controller: controller.deliveryHouseNumberController,
                label: 'house_number'.tr,
                icon: Icons.home,
                required: true,
              ),
            ),
          ],
        ),
        Row(
          children: [
            Expanded(
              child: _buildTextField(
                controller: controller.deliveryZipCodeController,
                label: 'postal_code'.tr,
                icon: Icons.mail,
                required: true,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              flex: 2,
              child: _buildTextField(
                controller: controller.deliveryCityController,
                label: 'city'.tr,
                icon: Icons.location_city,
                required: true,
              ),
            ),
          ],
        ),

        // الحقول الإضافية
        const SizedBox(height: 16),
        Text(
          'additional_delivery_info'.tr,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: AppColors.primaryBlue,
          ),
        ),
        const SizedBox(height: 8),

        // التاريخ واسم الشركة
        Row(
          children: [
            Expanded(
              child: _buildDateField(
                controller: controller.deliveryDateController,
                label: 'delivery_date'.tr,
                icon: Icons.date_range,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildTextField(
                controller: controller.deliveryCompanyNameController,
                label: 'company_name'.tr,
                icon: Icons.business,
              ),
            ),
          ],
        ),

        // بيانات الموظف
        _buildTextField(
          controller: controller.deliveryContactPersonNameController,
          label: 'contact_person_name'.tr,
          icon: Icons.person_outline,
        ),
        Row(
          children: [
            Expanded(
              child: _buildTextField(
                controller: controller.deliveryContactPersonPhoneController,
                label: 'contact_person_phone'.tr,
                icon: Icons.phone_outlined,
                keyboardType: TextInputType.phone,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildTextField(
                controller: controller.deliveryContactPersonEmailController,
                label: 'contact_person_email'.tr,
                icon: Icons.email_outlined,
                keyboardType: TextInputType.emailAddress,
              ),
            ),
          ],
        ),

        // مستوى الوقود وعداد الوقود
        Row(
          children: [
            Expanded(
              child: _buildFuelLevelSlider(
                value: controller.deliveryFuelLevel,
                label: 'fuel_level'.tr,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildTextField(
                controller: controller.deliveryFuelMeterController,
                label: 'fuel_meter'.tr,
                icon: Icons.speed,
                keyboardType: TextInputType.number,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDateField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
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
              }
            },
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: AppColors.borderGray),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: AppColors.borderGray),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: AppColors.primaryBlue, width: 2),
          ),
        ),
        style: TextStyle(color: AppColors.darkGray),
        readOnly: true,
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

  Widget _buildAdditionalVehicleFields(SimpleOrderCreateController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        _buildSectionTitle('additional_vehicle_info'.tr, Icons.info_outline),

        // صف أول: ÜKZ و FIN
        Row(
          children: [
            Expanded(
              child: _buildTextField(
                controller: controller.ukzController,
                label: 'ÜKZ',
                icon: Icons.confirmation_number_outlined,
                required: false,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildTextField(
                controller: controller.finController,
                label: 'FIN',
                icon: Icons.fingerprint,
                required: false,
              ),
            ),
          ],
        ),

        // صف ثاني: Bestellnummer و Leasingvertragsnummer
        Row(
          children: [
            Expanded(
              child: _buildTextField(
                controller: controller.bestellnummerController,
                label: 'Bestellnummer',
                icon: Icons.receipt_long,
                required: false,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildTextField(
                controller: controller.leasingvertragsnummerController,
                label: 'Leasingvertragsnummer',
                icon: Icons.assignment,
                required: false,
              ),
            ),
          ],
        ),

        // صف ثالث: Kostenstelle و Typ
        Row(
          children: [
            Expanded(
              child: _buildTextField(
                controller: controller.kostenstelleController,
                label: 'Kostenstelle',
                icon: Icons.account_balance,
                required: false,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildTextField(
                controller: controller.typController,
                label: 'Typ',
                icon: Icons.category,
                required: false,
              ),
            ),
          ],
        ),

        // Bemerkung - حقل كامل العرض
        _buildTextField(
          controller: controller.bemerkungController,
          label: 'Bemerkung',
          icon: Icons.note,
          maxLines: 3,
          required: false,
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Icon(icon, color: AppColors.primaryBlue),
          const SizedBox(width: 8),
          Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.primaryBlue,
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
    bool required = false,
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: required ? '$label *' : label,
          prefixIcon: Icon(icon, color: AppColors.mediumGray),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: AppColors.borderGray),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: AppColors.borderGray),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: AppColors.primaryBlue, width: 2),
          ),
        ),
        maxLines: maxLines,
        keyboardType: keyboardType,
        style: TextStyle(color: AppColors.darkGray),
        validator: required
            ? (value) {
          if (value == null || value.isEmpty) {
            return 'field_required'.tr;
          }
          if (keyboardType == TextInputType.emailAddress) {
            if (!GetUtils.isEmail(value)) {
              return 'email_invalid'.tr;
            }
          }
          return null;
        }
            : null,
      ),
    );
  }

  Widget _buildServiceTypeDropdown(SimpleOrderCreateController controller) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Obx(() => DropdownButtonFormField<ServiceType>(
        value: controller.selectedServiceType.value,
        decoration: InputDecoration(
          labelText: '${'service_type'.tr} *',
          prefixIcon: Icon(Icons.build, color: AppColors.mediumGray),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: AppColors.borderGray),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: AppColors.borderGray),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: AppColors.primaryBlue, width: 2),
          ),
        ),
        items: ServiceType.values.map((ServiceType type) {
          return DropdownMenuItem<ServiceType>(
            value: type,
            child: Text(
              controller.getServiceTypeText(type),
              style: TextStyle(color: AppColors.darkGray),
            ),
          );
        }).toList(),
        onChanged: (ServiceType? value) {
          if (value != null) {
            controller.selectedServiceType.value = value;
          }
        },
        style: TextStyle(color: AppColors.darkGray),
        validator: (value) {
          if (value == null) {
            return 'service_type_required'.tr;
          }
          return null;
        },
      )),
    );
  }

  Widget _buildVehicleDiagram(SimpleOrderCreateController controller) {
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
                child: _buildSideButton(controller, VehicleSide.FRONT, 'top'),
              ),
              // الخلف
              Positioned(
                bottom: 20,
                left: 0,
                right: 0,
                child: _buildSideButton(controller, VehicleSide.REAR, 'bottom'),
              ),
              // اليسار
              Positioned(
                top: 0,
                bottom: 0,
                left: 20,
                child: _buildSideButton(controller, VehicleSide.LEFT, 'left'),
              ),
              // اليمين
              Positioned(
                top: 0,
                bottom: 0,
                right: 20,
                child: _buildSideButton(controller, VehicleSide.RIGHT, 'right'),
              ),
              // الأعلى
              Positioned(
                top: 50,
                left: 0,
                right: 0,
                child: _buildSideButton(controller, VehicleSide.TOP, 'center'),
              ),
            ],
          )),
        ],
      ),
    );
  }

  Widget _buildSideButton(SimpleOrderCreateController controller, VehicleSide side, String position) {
    final isSelected = controller.selectedSides.contains(side);
    final hasDamages = controller.getDamagesForSide(side).isNotEmpty;

    return Center(
      child: GestureDetector(
        onTap: () => controller.toggleVehicleSide(side),
        child: Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            color: hasDamages ? AppColors.errorRed :
            isSelected ? AppColors.primaryBlue : AppColors.mediumGray,
            shape: BoxShape.circle,
            border: Border.all(
              color: Colors.white,
              width: 2,
            ),
            boxShadow: const [
              BoxShadow(
                color: AppColors.lightShadow,
                blurRadius: 4,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Icon(
            hasDamages ? Icons.warning : Icons.add,
            color: Colors.white,
            size: 16,
          ),
        ),
      ),
    );
  }
}

class SimpleOrderCreateController extends GetxController {
  final NewOrderController orderController = Get.find<NewOrderController>();
  final formKey = GlobalKey<FormState>();

  // Text Controllers - بيانات العميل
  final clientController = TextEditingController();
  final clientPhoneController = TextEditingController();
  final clientEmailController = TextEditingController();

  final clientAddressStreetController = TextEditingController();
  final clientAddressHouseNumberController = TextEditingController();
  final clientAddressZipCodeController = TextEditingController();
  final clientAddressCityController = TextEditingController();

  // Text Controllers - بيانات صاحب الفاتورة
  final billingNameController = TextEditingController();
  final billingPhoneController = TextEditingController();
  final billingEmailController = TextEditingController();
  final billingAddressStreetController = TextEditingController();
  final billingAddressHouseNumberController = TextEditingController();
  final billingAddressZipCodeController = TextEditingController();
  final billingAddressCityController = TextEditingController();

  // بيانات السيارة
  final vehicleOwnerController = TextEditingController();
  final licensePlateController = TextEditingController();
  final descriptionController = TextEditingController();

  final ukzController = TextEditingController();
  final finController = TextEditingController();
  final bestellnummerController = TextEditingController();
  final leasingvertragsnummerController = TextEditingController();
  final kostenstelleController = TextEditingController();
  final bemerkungController = TextEditingController();
  final typController = TextEditingController();

  final pickupStreetController = TextEditingController();
  final pickupHouseNumberController = TextEditingController();
  final pickupZipCodeController = TextEditingController();
  final pickupCityController = TextEditingController();

  final deliveryStreetController = TextEditingController();
  final deliveryHouseNumberController = TextEditingController();
  final deliveryZipCodeController = TextEditingController();
  final deliveryCityController = TextEditingController();

  // كونترولرز جديدة لعنوان الاستلام
  final pickupDateController = TextEditingController();
  final pickupCompanyNameController = TextEditingController();
  final pickupContactPersonNameController = TextEditingController();
  final pickupContactPersonPhoneController = TextEditingController();
  final pickupContactPersonEmailController = TextEditingController();
  final pickupFuelMeterController = TextEditingController();

  // كونترولرز جديدة لعنوان التسليم
  final deliveryDateController = TextEditingController();
  final deliveryCompanyNameController = TextEditingController();
  final deliveryContactPersonNameController = TextEditingController();
  final deliveryContactPersonPhoneController = TextEditingController();
  final deliveryContactPersonEmailController = TextEditingController();
  final deliveryFuelMeterController = TextEditingController();

  // Observables للوقود
  RxInt pickupFuelLevel = 0.obs;
  RxInt deliveryFuelLevel = 0.obs;

  // Observable للأغراض المحددة
  RxList<VehicleItem> selectedItems = <VehicleItem>[].obs;

  // Observables
  Rx<ServiceType> selectedServiceType = ServiceType.TRANSPORT.obs;
  RxBool isCreating = false.obs;
  RxBool isSameBilling = true.obs;

  // Observables للأضرار
  RxList<VehicleSide> selectedSides = <VehicleSide>[].obs;
  RxList<VehicleDamage> selectedDamages = <VehicleDamage>[].obs;

  // خريطة لحفظ أوصاف الأضرار لكل جانب
  final Map<VehicleSide, TextEditingController> _damageDescriptionControllers = {};


  @override
  void onClose() {
    // Dispose all controllers
    _disposeControllers();
    super.onClose();
  }

  void _disposeControllers() {
    // Client controllers
    clientController.dispose();
    clientPhoneController.dispose();
    clientEmailController.dispose();
    clientAddressStreetController.dispose();
    clientAddressHouseNumberController.dispose();
    clientAddressZipCodeController.dispose();
    clientAddressCityController.dispose();

    // Billing controllers
    billingNameController.dispose();
    billingPhoneController.dispose();
    billingEmailController.dispose();
    billingAddressStreetController.dispose();
    billingAddressHouseNumberController.dispose();
    billingAddressZipCodeController.dispose();
    billingAddressCityController.dispose();

    // Vehicle controllers
    vehicleOwnerController.dispose();
    licensePlateController.dispose();
    descriptionController.dispose();
    ukzController.dispose();
    finController.dispose();
    bestellnummerController.dispose();
    leasingvertragsnummerController.dispose();
    kostenstelleController.dispose();
    bemerkungController.dispose();
    typController.dispose();

    // Address controllers
    pickupStreetController.dispose();
    pickupHouseNumberController.dispose();
    pickupZipCodeController.dispose();
    pickupCityController.dispose();
    deliveryStreetController.dispose();
    deliveryHouseNumberController.dispose();
    deliveryZipCodeController.dispose();
    deliveryCityController.dispose();

    // Extended address controllers
    pickupDateController.dispose();
    pickupCompanyNameController.dispose();
    pickupContactPersonNameController.dispose();
    pickupContactPersonPhoneController.dispose();
    pickupContactPersonEmailController.dispose();
    pickupFuelMeterController.dispose();
    deliveryDateController.dispose();
    deliveryCompanyNameController.dispose();
    deliveryContactPersonNameController.dispose();
    deliveryContactPersonPhoneController.dispose();
    deliveryContactPersonEmailController.dispose();
    deliveryFuelMeterController.dispose();

    _damageDescriptionControllers.values.forEach((controller) => controller.dispose());
    _damageDescriptionControllers.clear();
  }

  // تحديث دالة إنشاء الطلبية
  Future<void> createOrder() async {
    if (!formKey.currentState!.validate()) {
      return;
    }

    isCreating.value = true;

    final damages = getFinalDamagesList();

    try {
      final orderId = await orderController.createBasicOrder(
        client: clientController.text.trim(),
        clientPhone: clientPhoneController.text.trim(),
        clientEmail: clientEmailController.text.trim(),
        clientAddress: NewAddress(
          street: clientAddressStreetController.text.trim(),
          houseNumber: clientAddressHouseNumberController.text.trim(),
          zipCode: clientAddressZipCodeController.text.trim(),
          city: clientAddressCityController.text.trim(),
        ),
        description: descriptionController.text.trim(),
        vehicleOwner: vehicleOwnerController.text.trim(),
        licensePlateNumber: licensePlateController.text.trim(),

        // الحقول الإضافية للسيارة
        ukz: ukzController.text.trim(),
        fin: finController.text.trim(),
        bestellnummer: bestellnummerController.text.trim(),
        leasingvertragsnummer: leasingvertragsnummerController.text.trim(),
        kostenstelle: kostenstelleController.text.trim(),
        bemerkung: bemerkungController.text.trim(),
        typ: typController.text.trim(),

        // عنوان الاستلام مع الحقول الجديدة
        pickupAddress: NewAddress(
          street: pickupStreetController.text.trim(),
          houseNumber: pickupHouseNumberController.text.trim(),
          zipCode: pickupZipCodeController.text.trim(),
          city: pickupCityController.text.trim(),
          date: pickupDateController.text.isNotEmpty
              ? DateTime.tryParse(pickupDateController.text)
              : null,
          companyName: pickupCompanyNameController.text.trim().isEmpty
              ? null
              : pickupCompanyNameController.text.trim(),
          contactPersonName: pickupContactPersonNameController.text.trim().isEmpty
              ? null
              : pickupContactPersonNameController.text.trim(),
          contactPersonPhone: pickupContactPersonPhoneController.text.trim().isEmpty
              ? null
              : pickupContactPersonPhoneController.text.trim(),
          contactPersonEmail: pickupContactPersonEmailController.text.trim().isEmpty
              ? null
              : pickupContactPersonEmailController.text.trim(),
          fuelLevel: pickupFuelLevel.value,
          fuelMeter: double.tryParse(pickupFuelMeterController.text.trim()),
        ),

        // عنوان التسليم مع الحقول الجديدة
        deliveryAddress: NewAddress(
          street: deliveryStreetController.text.trim(),
          houseNumber: deliveryHouseNumberController.text.trim(),
          zipCode: deliveryZipCodeController.text.trim(),
          city: deliveryCityController.text.trim(),
          date: deliveryDateController.text.isNotEmpty
              ? DateTime.tryParse(deliveryDateController.text)
              : null,
          companyName: deliveryCompanyNameController.text.trim().isEmpty
              ? null
              : deliveryCompanyNameController.text.trim(),
          contactPersonName: deliveryContactPersonNameController.text.trim().isEmpty
              ? null
              : deliveryContactPersonNameController.text.trim(),
          contactPersonPhone: deliveryContactPersonPhoneController.text.trim().isEmpty
              ? null
              : deliveryContactPersonPhoneController.text.trim(),
          contactPersonEmail: deliveryContactPersonEmailController.text.trim().isEmpty
              ? null
              : deliveryContactPersonEmailController.text.trim(),
          fuelLevel: deliveryFuelLevel.value,
          fuelMeter: double.tryParse(deliveryFuelMeterController.text.trim()),
        ),

        serviceType: selectedServiceType.value,

        // بيانات صاحب الفاتورة
        isSameBilling: isSameBilling.value,
        billingName: isSameBilling.value ? null : billingNameController.text.trim(),
        billingPhone: isSameBilling.value ? null : billingPhoneController.text.trim(),
        billingEmail: isSameBilling.value ? null : billingEmailController.text.trim(),
        billingAddress: isSameBilling.value ? null : NewAddress(
          street: billingAddressStreetController.text.trim(),
          houseNumber: billingAddressHouseNumberController.text.trim(),
          zipCode: billingAddressZipCodeController.text.trim(),
          city: billingAddressCityController.text.trim(),
        ),

        // الأغراض المحددة
        items: selectedItems.toList(),
        damages: damages,


      );

      if (orderId != null) {
        Get.offNamed('/dashboard');
      }
    } catch (e) {
      print('خطأ في إنشاء الطلبية: $e');
      Get.snackbar(
        'خطأ',
        'فشل في إنشاء الطلبية: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isCreating.value = false;
    }
  }

  // دالة للحصول على نص نوع الخدمة
  String getServiceTypeText(ServiceType type) {
    return orderController.getServiceTypeText(type);
  }

  // دالة لتبديل اختيار الغرض
  void toggleItem(VehicleItem item) {
    try {
      if (selectedItems.contains(item)) {
        selectedItems.remove(item);
      } else {
        selectedItems.add(item);
      }
      print('تم تبديل الغرض: ${_getItemName(item)}, المحددة حالياً: ${selectedItems.length}');
    } catch (e) {
      print('خطأ في تبديل الغرض: $e');
    }
  }

  // دالة للحصول على نص الغرض - مُصححة
  String getVehicleItemText(VehicleItem item) {
    return _getItemName(item);
  }

  // دالة مساعدة للحصول على اسم الغرض
  String _getItemName(VehicleItem item) {
    switch (item) {
      case VehicleItem.PARTITION_NET:
        return 'PARTITION_NET'.tr;
      case VehicleItem.WINTER_TIRES:
        return 'WINTER_TIRES'.tr;
      case VehicleItem.HUBCAPS:
        return 'HUBCAPS'.tr;
      case VehicleItem.REAR_PARCEL_SHELF:
        return 'REAR_PARCEL_SHELF'.tr;
      case VehicleItem.NAVIGATION_SYSTEM:
        return 'NAVIGATION_SYSTEM'.tr;
      case VehicleItem.TRUNK_ROLL_COVER:
        return 'TRUNK_ROLL_COVER'.tr;
      case VehicleItem.SAFETY_VEST:
        return 'SAFETY_VEST'.tr;
      case VehicleItem.VEHICLE_KEYS:
        return 'VEHICLE_KEYS'.tr;
      case VehicleItem.WARNING_TRIANGLE:
        return 'WARNING_TRIANGLE'.tr;
      case VehicleItem.RADIO:
        return 'RADIO'.tr;
      case VehicleItem.ALLOY_WHEELS:
        return 'ALLOY_WHEELS'.tr;
      case VehicleItem.SUMMER_TIRES:
        return 'SUMMER_TIRES'.tr;
      case VehicleItem.OPERATING_MANUAL:
        return 'OPERATING_MANUAL'.tr;
      case VehicleItem.REGISTRATION_DOCUMENT:
        return 'REGISTRATION_DOCUMENT'.tr;
      case VehicleItem.COMPRESSOR_REPAIR_KIT:
        return 'COMPRESSOR_REPAIR_KIT'.tr;
      case VehicleItem.TOOLS_JACK:
        return 'TOOLS_JACK'.tr;
      case VehicleItem.SECOND_SET_OF_TIRES:
        return 'SECOND_SET_OF_TIRES'.tr;
      case VehicleItem.EMERGENCY_WHEEL:
        return 'EMERGENCY_WHEEL'.tr;
      case VehicleItem.ANTENNA:
        return 'ANTENNA'.tr;
      case VehicleItem.FUEL_CARD:
        return 'FUEL_CARD'.tr;
      case VehicleItem.FIRST_AID_KIT:
        return 'FIRST_AID_KIT'.tr;
      case VehicleItem.SPARE_TIRE:
        return 'SPARE_TIRE'.tr;
      case VehicleItem.SERVICE_BOOK:
        return 'SERVICE_BOOK'.tr;
      default:
        return item.toString().split('.').last.replaceAll('_', ' ').tr;
    }
  }


  // دالة للتحقق من الأغراض المحددة
  bool isItemSelected(VehicleItem item) {
    return selectedItems.contains(item);
  }

  // دالة لمسح جميع الأغراض
  void clearAllItems() {
    selectedItems.clear();
  }

  // دالة لتحديد جميع الأغراض
  void selectAllItems() {
    selectedItems.assignAll(VehicleItem.values);
  }

  // دالة للحصول على controller الوصف لجانب معين
  TextEditingController getDamageDescriptionController(VehicleSide side) {
    if (!_damageDescriptionControllers.containsKey(side)) {
      _damageDescriptionControllers[side] = TextEditingController();
    }
    return _damageDescriptionControllers[side]!;
  }

// دالة لتبديل تحديد جانب السيارة
  void toggleVehicleSide(VehicleSide side) {
    if (selectedSides.contains(side)) {
      selectedSides.remove(side);
      // إزالة جميع الأضرار المرتبطة بهذا الجانب
      selectedDamages.removeWhere((damage) => damage.side == side);
    } else {
      selectedSides.add(side);
    }
  }

// دالة لتبديل تحديد ضرر معين
  void toggleDamage(VehicleSide side, DamageType damageType) {
    final damage = VehicleDamage(side: side, type: damageType);

    if (isDamageSelected(side, damageType)) {
      selectedDamages.removeWhere((d) => d.side == side && d.type == damageType);
    } else {
      selectedDamages.add(damage);
      // التأكد من أن الجانب محدد
      if (!selectedSides.contains(side)) {
        selectedSides.add(side);
      }
    }
  }

// دالة للتحقق من تحديد ضرر معين
  bool isDamageSelected(VehicleSide side, DamageType damageType) {
    return selectedDamages.any((damage) => damage.side == side && damage.type == damageType);
  }

// دالة للحصول على الأضرار المحددة لجانب معين
  List<VehicleDamage> getDamagesForSide(VehicleSide side) {
    return selectedDamages.where((damage) => damage.side == side).toList();
  }

// دالة لمسح جميع الأضرار
  void clearAllDamages() {
    selectedDamages.clear();
    selectedSides.clear();
    // مسح جميع أوصاف الأضرار
    _damageDescriptionControllers.values.forEach((controller) => controller.clear());
  }

// دالة للحصول على نص جانب السيارة
  String getVehicleSideText(VehicleSide side) {
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
      default:
        return side.toString().split('.').last;
    }
  }

// دالة للحصول على نص نوع الضرر
  String getDamageTypeText(DamageType damageType) {
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
      default:
        return damageType.toString().split('.').last;
    }
  }

// دالة لإعداد الأضرار النهائية مع الأوصاف
  List<VehicleDamage> getFinalDamagesList() {
    final List<VehicleDamage> finalDamages = [];

    for (final damage in selectedDamages) {
      final controller = _damageDescriptionControllers[damage.side];
      final description = controller?.text.trim();

      finalDamages.add(VehicleDamage(
        side: damage.side,
        type: damage.type,
        description: description?.isNotEmpty == true ? description : null,
      ));
    }

    return finalDamages;
  }

}