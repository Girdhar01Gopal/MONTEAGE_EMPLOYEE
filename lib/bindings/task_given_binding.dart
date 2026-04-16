import 'package:get/get.dart';
import '../controllers/task_given_controller.dart'; // Make sure you have this controller

class TaskGivenBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<TaskGivenController>(
      () => TaskGivenController(),
    );
  }
}