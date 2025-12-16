import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../infrastructure/routes/admin_routes.dart';

class AdminSplashController extends GetxController {
  final box = GetStorage();

  @override
  void onInit() {
    super.onInit();

    Future.delayed(const Duration(seconds: 2), () {
      bool isLoggedIn = box.read('isLoggedIn') ?? false;

      if (isLoggedIn) {
       // Get.offAllNamed(AdminRoutes.WELCOME);
      } else {
        Get.offAllNamed(AdminRoutes.LOGIN);
      }
    });
  }
}


