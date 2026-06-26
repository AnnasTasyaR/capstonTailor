import 'package:get/get.dart';
import '../controllers/tailor_detail_controller.dart';

class TailorDetailBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<TailorDetailController>(() => TailorDetailController());
  }
}
