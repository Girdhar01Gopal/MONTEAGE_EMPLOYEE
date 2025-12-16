import 'package:get/get.dart';
import '../controllers/home_controller.dart'; // Import HomeController

class HomeBinding extends Bindings {
  @override
  void dependencies() {
    // Register the HomeController to be lazily loaded when needed
    Get.lazyPut<HomeController>(() => HomeController());
  }
}
