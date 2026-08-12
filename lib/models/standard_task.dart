import 'task.dart';

class StandardTask extends Task {
  StandardTask({
    required super.id,
    required super.title,
    required super.priority,
    super.deadline,
    super.isDone,
  });

  @override
  String get typeName => 'Standard';

  @override
  String get icon => '📌';

  @override
  Map<String, dynamic> toJson() {
    return {
      'type': 'standard',
      'id': id,
      'title': title,
      'priority': priority.name,
      'deadline': deadline?.toIso8601String(),
      'isDone': isDone,
    };
  }
}

