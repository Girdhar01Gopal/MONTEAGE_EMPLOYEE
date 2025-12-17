import 'package:get/get.dart';
import '../controllers/FaceRegisterController.dart';

class FaceRegisterBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<FaceRegisterController>(() => FaceRegisterController());
  }
}
