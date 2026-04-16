import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../infrastructure/routes/admin_routes.dart';

class TaskReceivedController extends GetxController {
  final box = GetStorage(); 

  
  var tasksReceived = <Task>[].obs;

  
  void addTask(Task task) {
    tasksReceived.add(task);
  }

  
  void removeTask(int taskId) {
    tasksReceived.removeWhere((task) => task.id == taskId);
  }

  
  void updateTaskStatus(int taskId, String newStatus) {
    var task = tasksReceived.firstWhere((task) => task.id == taskId);
    task.status = newStatus;
    tasksReceived.refresh(); 
  }
}

class Task {
  final int id;
  final String name;
  final String description;
  String status;

  Task({
    required this.id,
    required this.name,
    required this.description,
    required this.status,
  });
}