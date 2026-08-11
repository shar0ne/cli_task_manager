import 'dart:convert';
import 'dart:io';
import '../models/priority.dart';
import '../models/standard_task.dart';
import '../models/task.dart';
import '../models/urgent_task.dart';
import 'repository.dart';
class JsonTaskRepository implements Repository<Task> {
  final File _file;

  JsonTaskRepository(String filePath) : _file = File(filePath);

  @override
  Future<List<Task>> getAll() async {
    if (!await _file.exists()) {
      return [];
    }

    String content = await _file.readAsString();
    if (content.trim().isEmpty) {
      return [];
    }

    List<dynamic> jsonList = jsonDecode(content);
    List<Task> tasks = [];

    for (var map in jsonList) {
      Priority priority = Priority.values.byName(map['priority']);
      DateTime? deadline = map['deadline'] != null
          ? DateTime.parse(map['deadline'])
          : null;

      if (map['type'] == 'urgent') {
        tasks.add(
          UrgentTask(
            id: map['id'],
            title: map['title'],
            deadline: deadline,
            isDone: map['isDone'],
          ),
        );
      } else {
        tasks.add(
          StandardTask(
            id: map['id'],
            title: map['title'],
            priority: priority,
            deadline: deadline,
            isDone: map['isDone'],
          ),
        );
      }
    }

    return tasks;
  }

  // Méthode privée pour réécrire la liste complète dans le fichier JSON
  Future<void> _saveAll(List<Task> tasks) async {
    List<Map<String, dynamic>> jsonList = tasks.map((t) => t.toJson()).toList();
    String content = jsonEncode(jsonList);
    await _file.writeAsString(content);
  }

  @override
  Future<void> add(Task item) async {
    List<Task> tasks = await getAll();
    tasks.add(item);
    await _saveAll(tasks);
  }

  @override
  Future<void> update(Task item) async {
    List<Task> tasks = await getAll();
    int index = tasks.indexWhere((t) => t.id == item.id);
    if (index != -1) {
      tasks[index] = item;
      await _saveAll(tasks);
    }
  }

  @override
  Future<void> delete(String id) async {
    List<Task> tasks = await getAll();
    tasks.removeWhere((t) => t.id == id);
    await _saveAll(tasks);
  }
}
