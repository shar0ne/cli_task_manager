import 'package:cli_task_manager/models/priority.dart';
import 'package:cli_task_manager/models/standard_task.dart';
import 'package:cli_task_manager/models/task.dart';
import 'package:cli_task_manager/models/urgent_task.dart';
import 'package:cli_task_manager/repositories/repository.dart';
import 'package:cli_task_manager/services/task_service.dart';
import 'package:test/test.dart';

class FakeRepository implements Repository<Task> {
  final List<Task> _tasks = [];

  @override
  Future<List<Task>> getAll() async => List.unmodifiable(_tasks);

  @override
  Future<void> add(Task item) async {
    _tasks.add(item);
  }

  @override
  Future<void> update(Task item) async {
    int index = _tasks.indexWhere((t) => t.id == item.id);
    if (index != -1) {
      _tasks[index] = item;
    }
  }

  @override
  Future<void> delete(String id) async {
    _tasks.removeWhere((t) => t.id == id);
  }
}

void main() {
  group('TaskService Unit Tests', () {
    late FakeRepository repository;
    late TaskService service;

    setUp(() {
      repository = FakeRepository();
      service = TaskService(repository);
    });

    test('addTask ajoute une tâche avec succès', () async {
      var task = StandardTask(id: '1', title: 'Test Task', priority: Priority.medium);
      await service.addTask(task);
      var tasks = await service.getAllTasks();
      expect(tasks.length, 1);
      expect(tasks.first.title, 'Test Task');
    });

    test('deleteTask supprime une tâche existante', () async {
      var task = StandardTask(id: '1', title: 'Test Task', priority: Priority.medium);
      await service.addTask(task);
      await service.deleteTask('1');
      var tasks = await service.getAllTasks();
      expect(tasks.isEmpty, true);
    });

    test('markTaskAsDone et markTaskAsUndone mettent à jour le statut', () async {
      var task = StandardTask(id: '1', title: 'Test Task', priority: Priority.medium);
      await service.addTask(task);

      await service.markTaskAsDone('1');
      var tasksAfterDone = await service.getAllTasks();
      expect(tasksAfterDone.first.isDone, isTrue);

      await service.markTaskAsUndone('1');
      var tasksAfterUndone = await service.getAllTasks();
      expect(tasksAfterUndone.first.isDone, isFalse);
    });

    test('toggleTaskStatus inverse le statut de la tâche', () async {
      var task = StandardTask(id: '1', title: 'Test Task', priority: Priority.medium);
      await service.addTask(task);

      await service.toggleTaskStatus('1');
      expect((await service.getAllTasks()).first.isDone, isTrue);

      await service.toggleTaskStatus('1');
      expect((await service.getAllTasks()).first.isDone, isFalse);
    });

    test('getAllTasksSortedByPriority trie du plus haut au plus bas', () async {
      var low = StandardTask(id: '1', title: 'Low Priority', priority: Priority.low);
      var high = StandardTask(id: '2', title: 'High Priority', priority: Priority.high);
      var medium = StandardTask(id: '3', title: 'Medium Priority', priority: Priority.medium);

      await service.addTask(low);
      await service.addTask(high);
      await service.addTask(medium);

      var sorted = await service.getAllTasksSortedByPriority();
      expect(sorted.map((t) => t.priority), equals([Priority.high, Priority.medium, Priority.low]));
    });

    test('getAllTasksSortedByDeadline trie les tâches par date d\'échéance', () async {
      var t1 = StandardTask(id: '1', title: 'Later', priority: Priority.low, deadline: DateTime(2026, 12, 1));
      var t2 = StandardTask(id: '2', title: 'Sooner', priority: Priority.low, deadline: DateTime(2026, 6, 1));
      var t3 = StandardTask(id: '3', title: 'No Deadline', priority: Priority.low);

      await service.addTask(t1);
      await service.addTask(t2);
      await service.addTask(t3);

      var sorted = await service.getAllTasksSortedByDeadline();
      expect(sorted[0].id, equals('2'));
      expect(sorted[1].id, equals('1'));
      expect(sorted[2].id, equals('3'));
    });

    test('getPendingTasks et getCompletedTasks filtrent selon isDone', () async {
      var t1 = StandardTask(id: '1', title: 'Pending', priority: Priority.low, isDone: false);
      var t2 = StandardTask(id: '2', title: 'Completed', priority: Priority.low, isDone: true);

      await service.addTask(t1);
      await service.addTask(t2);

      var pending = await service.getPendingTasks();
      var completed = await service.getCompletedTasks();

      expect(pending.length, equals(1));
      expect(pending.first.id, equals('1'));
      expect(completed.length, equals(1));
      expect(completed.first.id, equals('2'));
    });

    test('getTasksByPriority filtre par niveau de priorité', () async {
      var t1 = StandardTask(id: '1', title: 'Task High', priority: Priority.high);
      var t2 = StandardTask(id: '2', title: 'Task Low', priority: Priority.low);

      await service.addTask(t1);
      await service.addTask(t2);

      var result = await service.getTasksByPriority(Priority.high);
      expect(result.length, equals(1));
      expect(result.first.id, equals('1'));
    });

    test('getOverdueTasks détecte les tâches non terminées en retard', () async {
      var past = DateTime.now().subtract(const Duration(days: 2));
      var future = DateTime.now().add(const Duration(days: 2));

      var t1 = UrgentTask(id: '1', title: 'Late Task', deadline: past);
      var t2 = UrgentTask(id: '2', title: 'Future Task', deadline: future);
      var t3 = UrgentTask(id: '3', title: 'Completed Late Task', deadline: past, isDone: true);

      await service.addTask(t1);
      await service.addTask(t2);
      await service.addTask(t3);

      var overdue = await service.getOverdueTasks();
      expect(overdue.length, equals(1));
      expect(overdue.first.id, equals('1'));
    });

    test('getCompletionRate calcule le pourcentage exact de complétion', () async {
      expect(await service.getCompletionRate(), equals(0.0));

      var t1 = StandardTask(id: '1', title: 'A', priority: Priority.low, isDone: true);
      var t2 = StandardTask(id: '2', title: 'B', priority: Priority.low, isDone: false);
      await service.addTask(t1);
      await service.addTask(t2);

      expect(await service.getCompletionRate(), equals(50.0));
    });
  });
}
