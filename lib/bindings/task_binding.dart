import 'package:get/get.dart';
import '../controllers/task_controller.dart';

class TaskBinding extends Bindings {
  @override
  void dependencies() {
    // Lazy loading the controller for TaskScreen
    Get.lazyPut<TaskController>(() => TaskController());
    
  }
}