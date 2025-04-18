class Task {
  String title;
  bool completed;
  String createdAt;
  String priority; // إضافة حقل الأولوية

  Task({required this.title, this.completed = false, required this.createdAt, this.priority = 'Medium'});

  // تحويل كائن Task إلى Map لحفظه في Shared Preferences
  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'completed': completed,
      'created_at': createdAt,
      'priority': priority, // إضافة الأولوية هنا
    };
  }

  // تحويل Map إلى كائن Task عند استرجاع البيانات
  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      title: json['title'],
      completed: json['completed'],
      createdAt: json['created_at'],
      priority: json['priority'] ?? 'Medium', // التعامل مع الحقل الجديد
    );
  }
}
