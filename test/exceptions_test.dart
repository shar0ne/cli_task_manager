import 'package:cli_task_manager/exceptions/task_exceptions.dart';
import 'package:cli_task_manager/models/priority.dart';
import 'package:cli_task_manager/models/standard_task.dart';
import 'package:cli_task_manager/models/task.dart';
import 'package:cli_task_manager/repositories/repository.dart';
import 'package:cli_task_manager/services/task_service.dart';
import 'package:test/test.dart';

class FakeRepository implements Repository<Task> {
  final List<Task> _tasks = [];

  @override
  Future<List<Task>> getAll() async => List.unmodifiable(_tasks);

  @override
  Future<Task?> getById(String id) async {
    for (var t in _tasks) {
      if (t.id == id) return t;
    }
    return null;
  }

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
  group('Custom Exceptions Unit Tests', () {
    late FakeRepository repository;
    late TaskService service;

    setUp(() {
      repository = FakeRepository();
      service = TaskService(repository);
    });

    test('deleteTask lève TaskNotFoundException si l\'ID est inconnu', () async {
      expect(
        () => service.deleteTask('non-existent-id'),
        throwsA(isA<TaskNotFoundException>()),
      );
    });

    test('toggleTaskStatus lève TaskNotFoundException si l\'ID est inconnu', () async {
      expect(
        () => service.toggleTaskStatus('non-existent-id'),
        throwsA(isA<TaskNotFoundException>()),
      );
    });

    test('getTaskById lève TaskNotFoundException si l\'ID est inconnu', () async {
      expect(
        () => service.getTaskById('non-existent-id'),
        throwsA(isA<TaskNotFoundException>()),
      );
    });

    test('addTask lève InvalidTaskException si le titre est vide ou composé uniquement d\'espaces', () async {
      var emptyTask = StandardTask(id: '1', title: '', priority: Priority.low);
      var whitespaceTask = StandardTask(id: '2', title: '   ', priority: Priority.low);

      expect(
        () => service.addTask(emptyTask),
        throwsA(isA<InvalidTaskException>()),
      );

      expect(
        () => service.addTask(whitespaceTask),
        throwsA(isA<InvalidTaskException>()),
      );
    });

    test('Les exceptions personnalisées héritent de TaskManagerException', () {
      final notFoundEx = TaskNotFoundException('123');
      final invalidEx = InvalidTaskException('Champ requis');
      final storageEx = StorageException('Fichier inaccessible');

      expect(notFoundEx, isA<TaskManagerException>());
      expect(invalidEx, isA<TaskManagerException>());
      expect(storageEx, isA<TaskManagerException>());
      expect(notFoundEx, isA<Exception>());
    });
  });
}
