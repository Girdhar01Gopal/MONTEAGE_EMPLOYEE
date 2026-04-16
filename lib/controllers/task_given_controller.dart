import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class TaskGivenController extends GetxController {
  final box = GetStorage();

  
  var tasksGiven = <Task>[].obs;

  @override
  void onInit() {
    super.onInit();
    
  }

  
  void addTask(Task task) {
    tasksGiven.add(task); 
  }

  
  void removeTask(int taskId) {
    tasksGiven.removeWhere((task) => task.id == taskId); 
  }

  
  void markTaskCompleted(int taskId) {
    var task = tasksGiven.firstWhere((task) => task.id == taskId);
    task.status = 'Completed'; // Mark the task as completed
    tasksGiven.refresh(); // Refresh the list to update the UI
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