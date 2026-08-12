import 'dart:convert';
import 'dart:io';
import '../exceptions/task_exceptions.dart';
import '../models/task.dart';
import 'repository.dart';

class JsonTaskRepository implements Repository<Task> {
  final File _file;

  JsonTaskRepository(String filePath) : _file = File(filePath);

  @override
  Future<List<Task>> getAll() async {
    try {
      if (!await _file.exists()) {
        return [];
      }

      String content = await _file.readAsString();
      if (content.trim().isEmpty) {
        return [];
      }

      List<dynamic> jsonList = jsonDecode(content);
      return jsonList
          .map((map) => Task.fromJson(map as Map<String, dynamic>))
          .toList();
    } catch (e) {
      if (e is FormatException) {
        throw StorageException(
          'Fichier JSON corrompu ou format invalide : ${e.message}',
        );
      }
      if (e is StorageException) rethrow;
      throw StorageException('Erreur lors de la lecture des données : $e');
    }
  }

  @override
  Future<Task?> getById(String id) async {
    List<Task> tasks = await getAll();
    for (var task in tasks) {
      if (task.id == id) return task;
    }
    return null;
  }

  Future<void> _saveAll(List<Task> tasks) async {
    try {
      if (!await _file.parent.exists()) {
        await _file.parent.create(recursive: true);
      }
      List<Map<String, dynamic>> jsonList = tasks.map((t) => t.toJson()).toList();
      String content = const JsonEncoder.withIndent('  ').convert(jsonList);
      await _file.writeAsString(content);
    } catch (e) {
      if (e is StorageException) rethrow;
      throw StorageException(
        'Erreur lors de la sauvegarde des données : $e',
      );
    }
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

