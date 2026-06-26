import 'package:get/get.dart';

import '../modules/auth/login/bindings/login_binding.dart';
import '../modules/auth/login/views/login_view.dart';
import '../modules/auth/register/bindings/register_binding.dart';
import '../modules/auth/register/views/register_view.dart';
import '../modules/home/bindings/home_binding.dart';
import '../modules/home/views/home_view.dart';
import '../modules/tailor_detail/bindings/tailor_detail_binding.dart';
import '../modules/tailor_detail/views/tailor_detail_view.dart';
import '../modules/order/bindings/order_binding.dart';
import '../modules/order/views/order_form_view.dart';
import '../modules/order/bindings/customize_binding.dart';
import '../modules/order/views/customize_view.dart';
import '../modules/orders/bindings/orders_binding.dart';
import '../modules/orders/views/orders_view.dart';
import '../modules/tracking/bindings/tracking_binding.dart';
import '../modules/tracking/views/tracking_view.dart';
import '../modules/profile/bindings/profile_binding.dart';
import '../modules/profile/views/profile_view.dart';
import '../modules/dashboard/bindings/dashboard_binding.dart';
import '../modules/dashboard/views/dashboard_view.dart';
import '../modules/explore/views/explore_view.dart';
import '../modules/explore/controllers/explore_controller.dart';
import '../modules/favourite/views/favourite_view.dart';
import '../modules/favourite/controllers/favourite_controller.dart';
import '../modules/auth/verify_email/views/verify_email_view.dart';
import '../modules/auth/verify_email/controllers/verify_email_controller.dart';

part 'app_routes.dart';

class AppPages {
  AppPages._();

  static const INITIAL = Routes.DASHBOARD;

  static final routes = [
    GetPage(
      name: _Paths.LOGIN,
      page: () => const LoginView(),
      binding: LoginBinding(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: _Paths.REGISTER,
      page: () => const RegisterView(),
      binding: RegisterBinding(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: _Paths.HOME,
      page: () => const HomeView(),
      binding: HomeBinding(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: _Paths.TAILOR_DETAIL,
      page: () => const TailorDetailView(),
      binding: TailorDetailBinding(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: _Paths.ORDER_FORM,
      page: () => const OrderFormView(),
      binding: OrderBinding(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: _Paths.CUSTOMIZE,
      page: () => const CustomizeView(),
      binding: CustomizeBinding(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: _Paths.ORDERS,
      page: () => const OrdersView(),
      binding: OrdersBinding(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: _Paths.TRACKING,
      page: () => const TrackingView(),
      binding: TrackingBinding(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: _Paths.PROFILE,
      page: () => const ProfileView(),
      binding: ProfileBinding(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: _Paths.DASHBOARD,
      page: () => const DashboardView(),
      binding: DashboardBinding(),
    ),
    GetPage(
      name: _Paths.EXPLORE,
      page: () => const ExploreView(),
      binding: BindingsBuilder(() => Get.lazyPut(() => ExploreController())),
    ),
    GetPage(
      name: _Paths.FAVOURITE,
      page: () => const FavouriteView(),
      binding: BindingsBuilder(() => Get.lazyPut(() => FavouriteController())),
    ),
    GetPage(
      name: _Paths.VERIFY_EMAIL,
      page: () => const VerifyEmailView(),
      binding: BindingsBuilder(() => Get.lazyPut(() => VerifyEmailController())),
      transition: Transition.fadeIn,
    ),
  ];
}
