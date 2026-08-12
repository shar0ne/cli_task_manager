abstract class TaskManagerException implements Exception {
  final String message;
  const TaskManagerException(this.message);

  @override
  String toString() => message;
}

class TaskNotFoundException extends TaskManagerException {
  final String id;
  TaskNotFoundException(this.id)
      : super('Aucune tâche trouvée avec l\'ID "$id".');
}

class InvalidTaskException extends TaskManagerException {
  InvalidTaskException(super.message);
}

class StorageException extends TaskManagerException {
  StorageException(super.message);
}

