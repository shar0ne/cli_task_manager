import 'dart:io';
import 'package:cli_task_manager/exceptions/task_exceptions.dart';
import 'package:cli_task_manager/models/priority.dart';
import 'package:cli_task_manager/models/standard_task.dart';
import 'package:cli_task_manager/models/urgent_task.dart';
import 'package:cli_task_manager/repositories/json_task_repository.dart';
import 'package:test/test.dart';

void main() {
  group('JsonTaskRepository Persistence Tests', () {
    late Directory tempDir;
    late String tempFilePath;
    late JsonTaskRepository repository;

    setUp(() async {
      tempDir = await Directory.systemTemp.createTemp('task_mgr_test_');
      tempFilePath = '${tempDir.path}/test_tasks.json';
      repository = JsonTaskRepository(tempFilePath);
    });

    tearDown(() async {
      if (await tempDir.exists()) {
        await tempDir.delete(recursive: true);
      }
    });

    test('getAll returns empty list when file does not exist', () async {
      final tasks = await repository.getAll();
      expect(tasks, isEmpty);
    });

    test('add and getAll persist tasks to JSON file', () async {
      final task1 = StandardTask(
        id: '1',
        title: 'Acheter du pain',
        priority: Priority.low,
      );
      final task2 = UrgentTask(
        id: '2',
        title: 'Appeler le client',
      );

      await repository.add(task1);
      await repository.add(task2);

      // Re-instantiate repository to verify reading from disk
      final newRepositoryInstance = JsonTaskRepository(tempFilePath);
      final storedTasks = await newRepositoryInstance.getAll();

      expect(storedTasks.length, equals(2));
      expect(storedTasks[0].title, equals('Acheter du pain'));
      expect(storedTasks[1], isA<UrgentTask>());
    });

    test('getById returns matching task or null if not found', () async {
      final task = StandardTask(
        id: '100',
        title: 'Faire du sport',
        priority: Priority.medium,
      );

      await repository.add(task);

      final found = await repository.getById('100');
      final notFound = await repository.getById('999');

      expect(found, isNotNull);
      expect(found?.title, equals('Faire du sport'));
      expect(notFound, isNull);
    });

    test('update modifies task data in JSON file', () async {
      final task = StandardTask(
        id: '10',
        title: 'Réviser Dart',
        priority: Priority.low,
      );
      await repository.add(task);

      task.isDone = true;
      task.priority = Priority.high;
      await repository.update(task);

      final updatedTasks = await repository.getAll();
      expect(updatedTasks.first.isDone, isTrue);
      expect(updatedTasks.first.priority, equals(Priority.high));
    });

    test('delete removes task from JSON file', () async {
      final task = StandardTask(
        id: '20',
        title: 'Supprimer moi',
        priority: Priority.medium,
      );
      await repository.add(task);
      await repository.delete('20');

      final tasks = await repository.getAll();
      expect(tasks, isEmpty);
    });

    test('getAll throws StorageException when JSON file is malformed', () async {
      final file = File(tempFilePath);
      await file.writeAsString('{ invalid json format }');

      expect(
        () => repository.getAll(),
        throwsA(isA<StorageException>()),
      );
    });
  });
}
