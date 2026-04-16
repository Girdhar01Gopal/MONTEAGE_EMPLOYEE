import 'package:get/get.dart';
import '../controllers/task_received_controller.dart'; // Make sure you have this controller

class TaskReceivedBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<TaskReceivedController>(
      () => TaskReceivedController(),
    );
  }
}