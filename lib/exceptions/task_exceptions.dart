class TaskNotFoundException implements Exception {
  final String id;
  TaskNotFoundException(this.id);

  @override
  String toString() => 'TaskNotFoundException: aucune tâche trouvée avec l\'ID $id';
}

class InvalidTaskException implements Exception {
  final String message;
  InvalidTaskException(this.message);

  @override
  String toString() => 'InvalidTaskException: $message';
}
