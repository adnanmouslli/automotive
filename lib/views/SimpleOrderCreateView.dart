import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/order_controller.dart';
import '../models/new_order.dart';

class SimpleOrderCreateView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GetBuilder<SimpleOrderCreateController>(
      init: SimpleOrderCreateController(),
      builder: (controller) {
        return Scaffold(
          appBar: AppBar(
            title: Text('create_new_order'.tr),
            backgroundColor: Colors.blue.shade600,
            foregroundColor: Colors.white,
          ),
          body: Form(
            key: controller.formKey,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
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
                  const SizedBox(height: 24),

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
                  _buildTextField(
                    controller: controller.descriptionController,
                    label: 'service_description'.tr,
                    icon: Icons.description,
                    maxLines: 2,
                    required: false,
                  ),
                  const SizedBox(height: 16),

                  _buildServiceTypeDropdown(controller),
                  const SizedBox(height: 24),

                  _buildSectionTitle('pickup_address'.tr, Icons.location_on),
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
                  const SizedBox(height: 24),

                  _buildSectionTitle('delivery_address'.tr, Icons.local_shipping),
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
                  const SizedBox(height: 32),

                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: Obx(() => ElevatedButton(
                      onPressed: controller.isCreating.value ? null : controller.createOrder,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green.shade600,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: controller.isCreating.value
                          ? const CircularProgressIndicator(color: Colors.white, strokeWidth: 2)
                          : Text(
                        'create_order_btn'.tr,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    )),
                  ),
                  const SizedBox(height: 16),

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
                            Icon(Icons.info_outline, color: Colors.blue.shade600),
                            const SizedBox(width: 8),
                            Text(
                              'important_note'.tr,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.blue.shade800,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'order_creation_note'.tr,
                          style: TextStyle(
                            color: Colors.blue.shade700,
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

  Widget _buildSectionTitle(String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Icon(icon, color: Colors.blue.shade600),
          const SizedBox(width: 8),
          Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.blue.shade800,
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
          prefixIcon: Icon(icon),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.blue.shade600, width: 2),
          ),
        ),
        maxLines: maxLines,
        keyboardType: keyboardType,
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
          prefixIcon: const Icon(Icons.build),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.blue.shade600, width: 2),
          ),
        ),
        items: ServiceType.values.map((ServiceType type) {
          return DropdownMenuItem<ServiceType>(
            value: type,
            child: Text(controller.getServiceTypeText(type)),
          );
        }).toList(),
        onChanged: (ServiceType? value) {
          if (value != null) {
            controller.selectedServiceType.value = value;
          }
        },
        validator: (value) {
          if (value == null) {
            return 'service_type_required'.tr;
          }
          return null;
        },
      )),
    );
  }
}

class SimpleOrderCreateController extends GetxController {
  final NewOrderController orderController = Get.find<NewOrderController>();
  final formKey = GlobalKey<FormState>();

  // Text Controllers
  final clientController = TextEditingController();
  final clientPhoneController = TextEditingController();
  final clientEmailController = TextEditingController();
  final vehicleOwnerController = TextEditingController();
  final licensePlateController = TextEditingController();
  final descriptionController = TextEditingController();

  final pickupStreetController = TextEditingController();
  final pickupHouseNumberController = TextEditingController();
  final pickupZipCodeController = TextEditingController();
  final pickupCityController = TextEditingController();

  final deliveryStreetController = TextEditingController();
  final deliveryHouseNumberController = TextEditingController();
  final deliveryZipCodeController = TextEditingController();
  final deliveryCityController = TextEditingController();

  // Observables
  Rx<ServiceType> selectedServiceType = ServiceType.TRANSPORT.obs;
  RxBool isCreating = false.obs;

  @override
  void onClose() {
    // Dispose controllers
    clientController.dispose();
    clientPhoneController.dispose();
    clientEmailController.dispose();
    vehicleOwnerController.dispose();
    licensePlateController.dispose();
    descriptionController.dispose();
    pickupStreetController.dispose();
    pickupHouseNumberController.dispose();
    pickupZipCodeController.dispose();
    pickupCityController.dispose();
    deliveryStreetController.dispose();
    deliveryHouseNumberController.dispose();
    deliveryZipCodeController.dispose();
    deliveryCityController.dispose();
    super.onClose();
  }

  Future<void> createOrder() async {
    if (!formKey.currentState!.validate()) {
      return;
    }

    isCreating.value = true;

    try {
      final orderId = await orderController.createBasicOrder(
        client: clientController.text.trim(),
        clientPhone: clientPhoneController.text.trim(),
        clientEmail: clientEmailController.text.trim(),
        description: descriptionController.text.trim(),
        vehicleOwner: vehicleOwnerController.text.trim(),
        licensePlateNumber: licensePlateController.text.trim(),
        pickupStreet: pickupStreetController.text.trim(),
        pickupHouseNumber: pickupHouseNumberController.text.trim(),
        pickupZipCode: pickupZipCodeController.text.trim(),
        pickupCity: pickupCityController.text.trim(),
        deliveryStreet: deliveryStreetController.text.trim(),
        deliveryHouseNumber: deliveryHouseNumberController.text.trim(),
        deliveryZipCode: deliveryZipCodeController.text.trim(),
        deliveryCity: deliveryCityController.text.trim(),
        serviceType: selectedServiceType.value,
      );

      if (orderId != null) {
        Get.offNamed('/dashboard');
      }
    } finally {
      isCreating.value = false;
    }
  }

  String getServiceTypeText(ServiceType type) {
    return orderController.getServiceTypeText(type);
  }
}