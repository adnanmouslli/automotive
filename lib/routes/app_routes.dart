part of 'app_pages.dart';

abstract class Routes {
  Routes._();
  static const LOGIN = _Paths.LOGIN;
  static const DASHBOARD = _Paths.DASHBOARD;
  static const ORDER_FORM = _Paths.ORDER_FORM;

  static const EDIT_ORDER = '/edit-order'; // Add this line


}

abstract class _Paths {
  _Paths._();
  static const LOGIN = '/login';
  static const DASHBOARD = '/dashboard';
  static const ORDER_FORM = '/order-form';
}
