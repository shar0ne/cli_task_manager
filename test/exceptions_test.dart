import 'package:test/test.dart';
import 'package:cli_task_manager/services/task_service.dart';
import 'package:cli_task_manager/repositories/repository.dart';
import 'package:cli_task_manager/models/task.dart';
import 'package:cli_task_manager/models/standard_task.dart';
import 'package:cli_task_manager/models/priority.dart';
import 'package:cli_task_manager/exceptions/task_exceptions.dart';

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

  test('deleteTask lève TaskNotFoundException si ID inconnu', () async {
    expect(() => service.deleteTask('999'), throwsA(isA<TaskNotFoundException>()));
  });

  test('toggleTaskStatus lève TaskNotFoundException si ID inconnu', () async {
    expect(() => service.toggleTaskStatus('999'), throwsA(isA<TaskNotFoundException>()));
  });

  test('addTask lève InvalidTaskException si titre vide', () async {
    var task = StandardTask(id: '1', title: '', priority: Priority.low);
    expect(() => service.addTask(task), throwsA(isA<InvalidTaskException>()));
  });

  test('getAllTasksSortedByPriority trie du plus haut au plus bas', () async {
    var low = StandardTask(id: '1', title: 'A', priority: Priority.low);
    var high = StandardTask(id: '2', title: 'B', priority: Priority.high);
    await service.addTask(low);
    await service.addTask(high);
    var sorted = await service.getAllTasksSortedByPriority();
    expect(sorted.first.id, '2');
  });
}
