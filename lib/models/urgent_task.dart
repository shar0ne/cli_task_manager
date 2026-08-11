import 'priority.dart';
import 'task.dart';
class UrgentTask extends Task {
	UrgentTask({
  required String id,
  required String title,
  DateTime? deadline,
  bool isDone = false,
}) : super(id: id, title: title, priority: Priority.high, deadline: deadline, isDone: isDone);
@override Map<String, dynamic> toJson() { return {'type': 'urgent', 'id': id,
    'title': title,
    'priority': priority.name,
    'deadline': deadline?.toIso8601String(),
    'isDone': isDone,};}
}
