import 'package:path/path.dart' as p;
import 'dart:io';

import '../lib/repositories/json_task_repository.dart';
import '../lib/services/task_service.dart';
import '../lib/cli/menu.dart';

void main() async {
Directory('data').createSync(recursive: true);
final repository = JsonTaskRepository('data/tasks.json');
final taskService = TaskService(repository);
final menu = Menu(taskService);
await menu.start();
}
