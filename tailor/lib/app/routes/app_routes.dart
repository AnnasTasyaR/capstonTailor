part of 'app_pages.dart';

abstract class Routes {
  Routes._();
  static const LOGIN = _Paths.LOGIN;
  static const REGISTER = _Paths.REGISTER;
  static const HOME = _Paths.HOME;
  static const TAILOR_DETAIL = _Paths.TAILOR_DETAIL;
  static const ORDER_FORM = _Paths.ORDER_FORM;
  static const CUSTOMIZE = _Paths.CUSTOMIZE;
  static const ORDERS = _Paths.ORDERS;
  static const TRACKING = _Paths.TRACKING;
  static const PROFILE = _Paths.PROFILE;
  static const DASHBOARD = _Paths.DASHBOARD;
  static const EXPLORE = _Paths.EXPLORE;
  static const FAVOURITE = _Paths.FAVOURITE;
  static const VERIFY_EMAIL = _Paths.VERIFY_EMAIL;
}

abstract class _Paths {
  _Paths._();
  static const LOGIN = '/login';
  static const REGISTER = '/register';
  static const HOME = '/home';
  static const TAILOR_DETAIL = '/tailor-detail';
  static const ORDER_FORM = '/order-form';
  static const CUSTOMIZE = '/customize';
  static const ORDERS = '/orders';
  static const TRACKING = '/tracking';
  static const PROFILE = '/profile';
  static const DASHBOARD = '/dashboard';
  static const EXPLORE = '/explore';
  static const FAVOURITE = '/favourite';
  static const VERIFY_EMAIL = '/verify-email';
}
