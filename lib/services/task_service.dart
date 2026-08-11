import '../models/priority.dart';
import '../models/task.dart';
import '../repositories/repository.dart';

class TaskService {
  final Repository<Task> _repository;

  TaskService(this._repository);

  Future<List<Task>> getAllTasks() async {
    return await _repository.getAll();
  }

  Future<void> addTask(Task task) async {
    await _repository.add(task);
  }

  Future<void> deleteTask(String id) async {
    await _repository.delete(id);
  }

  Future<void> toggleTaskStatus(String id) async {
    List<Task> tasks = await _repository.getAll();
    int index = tasks.indexWhere((t) => t.id == id);
    if (index != -1) {
      tasks[index].isDone = !tasks[index].isDone;
      await _repository.update(tasks[index]);
    }
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
        .where((t) =>
            !t.isDone && t.deadline != null && t.deadline!.isBefore(now))
        .toList();
  }

 
  Future<double> getCompletionRate() async {
    List<Task> tasks = await _repository.getAll();
    if (tasks.isEmpty) return 0.0;
    
    int completedCount = tasks.where((t) => t.isDone).length;
    return (completedCount / tasks.length) * 100;
  }
}
