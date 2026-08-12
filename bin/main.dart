import 'dart:io';

import 'package:cli_task_manager/repositories/json_task_repository.dart';
import 'package:cli_task_manager/services/task_service.dart';
import 'package:cli_task_manager/cli/menu.dart';

void main() async {
  Directory('data').createSync(recursive: true);
  final repository = JsonTaskRepository('data/tasks.json');
  final taskService = TaskService(repository);
  final menu = Menu(taskService);
  await menu.start();
}
