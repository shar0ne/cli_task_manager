import 'package:test/test.dart';
import 'package:cli_task_manager/services/task_service.dart';
import 'package:cli_task_manager/repositories/repository.dart';
import 'package:cli_task_manager/models/task.dart';
import 'package:cli_task_manager/models/standard_task.dart';
import 'package:cli_task_manager/models/urgent_task.dart';
import 'package:cli_task_manager/models/priority.dart';

class FakeRepository implements Repository<Task> {
  final List<Task> _tasks = [];

  @override
  Future<List<Task>> getAll() async => _tasks;

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
  late FakeRepository repository;
  late TaskService service;

  setUp(() {
    repository = FakeRepository();
    service = TaskService(repository);
  });

  test('addTask ajoute une tâche', () async {
    var task = StandardTask(id: '1', title: 'Test', priority: Priority.medium);
    await service.addTask(task);
    var tasks = await service.getAllTasks();
    expect(tasks.length, 1);
    expect(tasks.first.title, 'Test');
  });

  test('deleteTask supprime une tâche', () async {
    var task = StandardTask(id: '1', title: 'Test', priority: Priority.medium);
    await service.addTask(task);
    await service.deleteTask('1');
    var tasks = await service.getAllTasks();
    expect(tasks.isEmpty, true);
  });

  test('toggleTaskStatus inverse le statut', () async {
    var task = StandardTask(id: '1', title: 'Test', priority: Priority.medium);
    await service.addTask(task);
    await service.toggleTaskStatus('1');
    var tasks = await service.getAllTasks();
    expect(tasks.first.isDone, true);
  });

  test('getPendingTasks retourne les tâches non terminées', () async {
    var t1 = StandardTask(id: '1', title: 'A', priority: Priority.low, isDone: true);
    var t2 = StandardTask(id: '2', title: 'B', priority: Priority.low);
    await service.addTask(t1);
    await service.addTask(t2);
    var pending = await service.getPendingTasks();
    expect(pending.length, 1);
    expect(pending.first.id, '2');
  });

  test('getCompletedTasks retourne les tâches terminées', () async {
    var t1 = StandardTask(id: '1', title: 'A', priority: Priority.low, isDone: true);
    var t2 = StandardTask(id: '2', title: 'B', priority: Priority.low);
    await service.addTask(t1);
    await service.addTask(t2);
    var completed = await service.getCompletedTasks();
    expect(completed.length, 1);
    expect(completed.first.id, '1');
  });

  test('getTasksByPriority filtre correctement', () async {
    var t1 = StandardTask(id: '1', title: 'A', priority: Priority.high);
    var t2 = StandardTask(id: '2', title: 'B', priority: Priority.low);
    await service.addTask(t1);
    await service.addTask(t2);
    var result = await service.getTasksByPriority(Priority.high);
    expect(result.length, 1);
    expect(result.first.id, '1');
  });

  test('getOverdueTasks détecte les tâches en retard', () async {
    var past = DateTime.now().subtract(Duration(days: 1));
    var future = DateTime.now().add(Duration(days: 1));
    var t1 = UrgentTask(id: '1', title: 'A', deadline: past);
    var t2 = UrgentTask(id: '2', title: 'B', deadline: future);
    await service.addTask(t1);
    await service.addTask(t2);
    var overdue = await service.getOverdueTasks();
    expect(overdue.length, 1);
    expect(overdue.first.id, '1');
  });

  test('getCompletionRate calcule le pourcentage correctement', () async {
    var t1 = StandardTask(id: '1', title: 'A', priority: Priority.low, isDone: true);
    var t2 = StandardTask(id: '2', title: 'B', priority: Priority.low);
    await service.addTask(t1);
    await service.addTask(t2);
    var rate = await service.getCompletionRate();
    expect(rate, 50.0);
  });

  test('getCompletionRate retourne 0 si aucune tâche', () async {
    var rate = await service.getCompletionRate();
    expect(rate, 0.0);
  });
}
