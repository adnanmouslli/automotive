import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_instance/src/bindings_interface.dart';

import '../controllers/auth_controller.dart';
import '../controllers/order_controller.dart';

class InitialBindings extends Bindings {
  @override
  void dependencies() {
    // Initialize AuthController immediately and permanently
    Get.put(AuthController(), permanent: true);

    // Initialize OrderController immediately
    // Get.put(NewOrderController(), permanent: true);
  }
}