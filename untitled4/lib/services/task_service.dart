import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/task_model.dart';

class TaskService {
  static Future<List<Task>> loadTasks() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? tasksString = prefs.getString('tasks');
    if (tasksString != null) {
      List<dynamic> jsonData = jsonDecode(tasksString);
      return jsonData.map((task) => Task.fromJson(task)).toList();
    }
    return [];
  }

  static Future<void> saveTasks(List<Task> tasks) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<Map<String, dynamic>> jsonTasks = tasks.map((task) => task.toJson()).toList();
    prefs.setString('tasks', jsonEncode(jsonTasks));
  }
}
