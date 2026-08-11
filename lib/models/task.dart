import 'priority.dart';
abstract class Task {
	String id;
	String title;
	Priority priority;
	DateTime? deadline;
	bool isDone;
Task ({
	required this.id,
	required this.title,
	required this.priority,
	this.deadline,
	this.isDone = false,
});
Map<String, dynamic> toJson();
}
