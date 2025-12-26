// controllers/admin_splash_controller.dart
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:monteage_employee/infrastructure/utils/pref_const.dart';
import 'package:monteage_employee/infrastructure/utils/pref_manager.dart';
import '../infrastructure/routes/admin_routes.dart';

class AdminSplashController extends GetxController {
  final box = GetStorage();

  @override
  void onInit() {
    super.onInit();

    Future.delayed(const Duration(seconds: 4), () async{
      var isLoggedIn = await PrefManager().readValue(key: PrefConst.isLoggedIn) == 0;

      if (isLoggedIn) {
        Get.offAllNamed(AdminRoutes.HOME);
      } else {
        Get.offAllNamed(AdminRoutes.LOGIN);
      }
    });
  }
}


