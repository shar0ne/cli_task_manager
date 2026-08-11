import 'task.dart';
import 'priority.dart';
class StandardTask extends Task {
	StandardTask({
		required String id,

		required String title,

		required Priority priority,

		DateTime? deadline,

		bool isDone = false,
}):super(id: id, title: title, priority: priority, deadline: deadline, isDone: isDone);
@override
Map<String, dynamic> toJson() { 
	return{
	'type': 'standard',

	'id': id,

	'title': title,

	'priority': priority.name, 

	'deadline': deadline?.toIso8601String(), 

	'isDone': isDone,
};
}
}
