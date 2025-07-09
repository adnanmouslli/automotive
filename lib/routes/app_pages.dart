import 'package:automotive/controllers/order_view_details.dart';
import 'package:automotive/views/ExpensesPage.dart';
import 'package:automotive/views/SignaturePage.dart';
import 'package:get/get.dart';
import '../models/new_order.dart';
import '../views/EditOrderView.dart';
import '../views/OrderDetailsView.dart';
import '../views/SimpleOrderCreateView.dart';
import '../views/login_view.dart';
import '../views/dashboard_view.dart';

part 'app_routes.dart';

class AppPages {
  AppPages._();

  static const INITIAL = Routes.LOGIN;

  static final routes = [
    GetPage(
      name: _Paths.LOGIN,
      page: () =>  LoginView(),
    ),
    GetPage(
      name: _Paths.DASHBOARD,
      page: () =>  DashboardView(),
    ),
    GetPage(
      name: '/create-order',
      page: () => SimpleOrderCreateView(),
    ),
    // GetPage(
    //   name: '/order-details',
    //   page: () => OrderDetailsView(),
    // ),


    GetPage(
      name: '/order-details',
      page: () => OrderDetailsView(),
      // binding: BindingsBuilder(() {
      //   Get.lazyPut(() => OrderDetailsController());
      // }),
      transition: Transition.rightToLeft,
    ),
    
    // Signature Page
    GetPage(
      name: '/signature',
      page: () => SignaturePage(),
      transition: Transition.downToUp,
    ),
    
    // Expenses Page
    GetPage(
      name: '/expenses',
      page: () => ExpensesPage(),
      transition: Transition.rightToLeft,
    ),

    GetPage(
      name: Routes.EDIT_ORDER,
      page: () {
        final order = Get.arguments as NewOrder;
        return EditOrderView(order: order);
      },
      transition: Transition.rightToLeft,
    ),

  ];
}