import 'package:get/get.dart';
import '../controllers/face_id_login_controller.dart';

class FaceIdLoginBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<FaceIdLoginController>(() => FaceIdLoginController());
  }
}