import 'priority.dart';
import 'task.dart';

class UrgentTask extends Task {
  UrgentTask({
    required super.id,
    required super.title,
    super.deadline,
    super.isDone,
  }) : super(priority: Priority.high);

  @override
  Map<String, dynamic> toJson() {
    return {
      'type': 'urgent',
      'id': id,
      'title': title,
      'priority': priority.name,
      'deadline': deadline?.toIso8601String(),
      'isDone': isDone,
    };
  }
}
