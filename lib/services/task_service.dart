import '../models/priority.dart';
import '../models/task.dart';
import '../repositories/repository.dart';
import '../exceptions/task_exceptions.dart';

class TaskService {
  final Repository<Task> _repository;

  TaskService(this._repository);

  Future<List<Task>> getAllTasks() async {
    return await _repository.getAll();
  }

  Future<List<Task>> getAllTasksSortedByPriority() async {
    List<Task> tasks = await _repository.getAll();
    tasks.sort((a, b) => b.priority.index.compareTo(a.priority.index));
    return tasks;
  }

  Future<List<Task>> getAllTasksSortedByDeadline() async {
    List<Task> tasks = await _repository.getAll();
    tasks.sort((a, b) {
      if (a.deadline == null && b.deadline == null) return 0;
      if (a.deadline == null) return 1;
      if (b.deadline == null) return -1;
      return a.deadline!.compareTo(b.deadline!);
    });
    return tasks;
  }

  Future<void> addTask(Task task) async {
    if (task.title.trim().isEmpty) {
      throw InvalidTaskException('Le titre ne peut pas être vide');
    }
    await _repository.add(task);
  }

  Future<void> deleteTask(String id) async {
    List<Task> tasks = await _repository.getAll();
    bool exists = tasks.any((t) => t.id == id);
    if (!exists) {
      throw TaskNotFoundException(id);
    }
    await _repository.delete(id);
  }

  Future<void> toggleTaskStatus(String id) async {
    List<Task> tasks = await _repository.getAll();
    int index = tasks.indexWhere((t) => t.id == id);
    if (index == -1) {
      throw TaskNotFoundException(id);
    }
    tasks[index].isDone = !tasks[index].isDone;
    await _repository.update(tasks[index]);
  }

  Future<List<Task>> getPendingTasks() async {
    List<Task> tasks = await _repository.getAll();
    return tasks.where((t) => !t.isDone).toList();
  }

  Future<List<Task>> getCompletedTasks() async {
    List<Task> tasks = await _repository.getAll();
    return tasks.where((t) => t.isDone).toList();
  }

  Future<List<Task>> getTasksByPriority(Priority priority) async {
    List<Task> tasks = await _repository.getAll();
    return tasks.where((t) => t.priority == priority).toList();
  }

  Future<List<Task>> getOverdueTasks() async {
    List<Task> tasks = await _repository.getAll();
    DateTime now = DateTime.now();
    return tasks
        .where(
          (t) => !t.isDone && t.deadline != null && t.deadline!.isBefore(now),
        )
        .toList();
  }

  Future<double> getCompletionRate() async {
    List<Task> tasks = await _repository.getAll();
    if (tasks.isEmpty) return 0.0;

    int completedCount = tasks.where((t) => t.isDone).length;
    return (completedCount / tasks.length) * 100;
  }
}
