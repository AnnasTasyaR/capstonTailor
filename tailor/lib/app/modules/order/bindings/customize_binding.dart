import 'package:get/get.dart';
import '../controllers/customize_controller.dart';

class CustomizeBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<CustomizeController>(
      () => CustomizeController(),
    );
  }
}
