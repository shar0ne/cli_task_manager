import 'priority.dart';
import 'standard_task.dart';
import 'urgent_task.dart';

abstract class Task {
  String id;
  String title;
  Priority priority;
  DateTime? deadline;
  bool isDone;

  Task({
    required this.id,
    required this.title,
    required this.priority,
    this.deadline,
    this.isDone = false,
  });

  String get typeName;
  String get icon;

  Map<String, dynamic> toJson();

  factory Task.fromJson(Map<String, dynamic> json) {
    final type = json['type'] as String?;
    final id = json['id'] as String;
    final title = json['title'] as String;
    final isDone = json['isDone'] as bool? ?? false;
    final deadlineStr = json['deadline'] as String?;
    final deadline = deadlineStr != null ? DateTime.parse(deadlineStr) : null;
    final priorityStr = json['priority'] as String? ?? 'medium';
    final priority = Priority.values.firstWhere(
      (p) => p.name == priorityStr,
      orElse: () => Priority.medium,
    );

    if (type == 'urgent') {
      return UrgentTask(
        id: id,
        title: title,
        deadline: deadline,
        isDone: isDone,
      );
    }

    return StandardTask(
      id: id,
      title: title,
      priority: priority,
      deadline: deadline,
      isDone: isDone,
    );
  }
}

