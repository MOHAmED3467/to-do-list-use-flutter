import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'add_task_screen.dart';          // استيراد شاشة إضافة المهمة
import 'completed_tasks_screen.dart';  // استيراد شاشة المهام المكتملة
import 'pending_tasks_screen.dart';    // استيراد شاشة المهام المعلقة
import '../models/task_model.dart';
import '../services/task_service.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Task> tasks = [];
  TextEditingController _searchController = TextEditingController(); // للتحكم في شريط البحث

  @override
  void initState() {
    super.initState();
    loadTasks(); // تحميل المهام عند بداية تشغيل الشاشة
  }

  // تحميل المهام من SharedPreferences
  void loadTasks() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? tasksString = prefs.getString('tasks');
      if (tasksString != null) {
        List<dynamic> jsonData = jsonDecode(tasksString);
        tasks = jsonData.map((task) => Task.fromJson(task)).toList();
      }
    } catch (e) {
      print('Error loading tasks: $e');
    }
  }


  // فرز المهام حسب الأولوية
  void sortTasksByPriority() {
    tasks.sort((a, b) {
      if (a.priority == 'High') return -1;
      if (b.priority == 'High') return 1;
      if (a.priority == 'Medium') return -1;
      return 1;
    });
  }

  // فلترة المهام حسب النص المدخل في البحث
  void filterTasks(String query) {
    final filteredTasks = tasks.where((task) {
      return task.title.toLowerCase().contains(query.toLowerCase());
    }).toList();
    setState(() {
      tasks = filteredTasks;
    });
  }

  // التبديل بين المهام المكتملة وغير المكتملة
  void toggleTaskCompletion(int index) {
    setState(() {
      tasks[index].completed = !tasks[index].completed;
      updateTasks();
    });
  }

  // حذف مهمة من القائمة
  void deleteTask(int index) {
    setState(() {
      tasks.removeAt(index);
      updateTasks();
    });
  }

  // تحديث المهام في SharedPreferences
  void updateTasks() async {
    await TaskService.saveTasks(tasks);
    setState(() {});
  }

  // التنقل إلى صفحة المهام المكتملة
  void navigateToCompletedTasks() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => CompletedTasksScreen(tasks: tasks)),
    );
  }

  // التنقل إلى صفحة المهام المعلقة
  void navigateToPendingTasks() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => PendingTasksScreen(tasks: tasks)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('To-Do List')),
      body: Column(
        children: [
          // شريط البحث
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'Search Tasks',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: (query) {
                filterTasks(query);  // تنفيذ الفلترة أثناء الكتابة
              },
            ),
          ),
          // أزرار التنقل بين المهام المكتملة والمعلقة
          Row(
            mainAxisAlignment: MainAxisAlignment.center,  // وضع الأزرار في المنتصف
            children: [
              ElevatedButton(
                onPressed: navigateToCompletedTasks,
                child: Text('View Completed Tasks'),
              ),
              SizedBox(width: 10), // المسافة بين الأزرار
              ElevatedButton(
                onPressed: navigateToPendingTasks,
                child: Text('View Pending Tasks'),
              ),
            ],
          ),
          // عرض المهام في ListView
          Expanded(
            child: tasks.isEmpty
                ? Center(child: Text('No tasks available.'))
                : ListView.builder(
              itemCount: tasks.length,
              itemBuilder: (context, index) {
                return Card(
                  child: ListTile(
                    title: Text(
                      tasks[index].title,
                      style: TextStyle(
                        decoration: tasks[index].completed
                            ? TextDecoration.lineThrough
                            : null,
                      ),
                    ),
                    leading: Checkbox(
                      value: tasks[index].completed,
                      onChanged: (value) => toggleTaskCompletion(index),
                    ),
                    trailing: IconButton(
                      icon: Icon(Icons.delete, color: Colors.red),
                      onPressed: () => deleteTask(index),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final newTask = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AddTaskScreen()),
          );

          if (newTask != null) {
            setState(() {
              tasks.add(newTask);
              updateTasks();
            });
          }
        },
        child: Icon(Icons.add),
      ),
    );
  }
}
