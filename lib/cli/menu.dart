import 'dart:io';

import '../models/priority.dart';
import '../models/standard_task.dart';
import '../models/urgent_task.dart';
import '../services/task_service.dart';

class Menu {
  final TaskService _service;

  Menu(this._service);
Future<void> start() async {
    bool running = true;

    while (running) {
      print('\n=========================================');
      print('      📌 GESTIONNAIRE DE TÂCHES CLI      ');
      print('=========================================');
      print('1. Voir toutes les tâches');
      print('2. Ajouter une tâche standard');
      print('3. Ajouter une tâche urgente ⚡');
      print('4. Marquer/Démaquer une tâche comme terminée');
      print('5. Supprimer une tâche');
      print('6. Voir les tâches par filtre / statistiques');
      print('7. Quitter');
      print('-----------------------------------------');
      stdout.write('Votre choix (1-7) : ');

      String? choice = stdin.readLineSync();

      switch (choice) {
        case '1':
          await _showAllTasks();
          break;
        case '2':
          await _addStandardTask();
          break;
        case '3':
          await _addUrgentTask();
          break;
        case '4':
          await _toggleTask();
          break;
        case '5':
          await _deleteTask();
          break;
        case '6':
          await _showStatsAndFilters();
          break;
        case '7':
          running = false;
          print('\nAu revoir ! 👋');
          break;
        default:
          print('⚠️ Choix invalide. Veuillez réessayer.');
      }
    }
  }
Future<void> _showAllTasks() async {
    var tasks = await _service.getAllTasks();
    if (tasks.isEmpty) {
      print('\nAucune tâche enregistrée.');
      return;
    }

    print('\n--- 📋 LISTE DES TÂCHES ---');
    for (var task in tasks) {
      String status = task.isDone ? '[X]' : '[ ]';
      String type = task is UrgentTask ? '⚡' : '📌';
      String deadlineStr = task.deadline != null
          ? ' (Échéance: ${task.deadline.toString().split(' ')[0]})'
          : '';
      print('$status $type [ID: ${task.id}] ${task.title} | Priorité: ${task.priority.name.toUpperCase()}$deadlineStr');
    }
  }
Future<void> _addStandardTask() async {
    stdout.write('\nTitre de la tâche : ');
    String? title = stdin.readLineSync();
    if (title == null || title.trim().isEmpty) {
      print('⚠️ Le titre ne peut pas être vide.');
      return;
    }

    print('Priorité : 1. Low  2. Medium  3. High');
    stdout.write('Choix (1-3) [défaut = 2] : ');
    String? pChoice = stdin.readLineSync();
    Priority priority = Priority.medium;
    if (pChoice == '1') priority = Priority.low;
    if (pChoice == '3') priority = Priority.high;

    stdout.write('Date limite (AAAA-MM-JJ, optionnel) : ');
    String? dateStr = stdin.readLineSync();
    DateTime? deadline;
    if (dateStr != null && dateStr.trim().isNotEmpty) {
      deadline = DateTime.tryParse(dateStr.trim());
    }

    String id = DateTime.now().millisecondsSinceEpoch.toString().substring(7);
    var task = StandardTask(
      id: id,
      title: title.trim(),
      priority: priority,
      deadline: deadline,
    );

    await _service.addTask(task);
    print('✅ Tâche standard créée avec succès ! (ID: $id)');
  }
Future<void> _addUrgentTask() async {
    stdout.write('\nTitre de la tâche urgente : ');
    String? title = stdin.readLineSync();
    if (title == null || title.trim().isEmpty) {
      print('⚠️ Le titre ne peut pas être vide.');
      return;
    }

    stdout.write('Date limite (AAAA-MM-JJ, optionnel) : ');
    String? dateStr = stdin.readLineSync();
    DateTime? deadline;
    if (dateStr != null && dateStr.trim().isNotEmpty) {
      deadline = DateTime.tryParse(dateStr.trim());
    }

    String id = DateTime.now().millisecondsSinceEpoch.toString().substring(7);
    var task = UrgentTask(
      id: id,
      title: title.trim(),
      deadline: deadline,
    );

    await _service.addTask(task);
    print('⚡ Tâche urgente créée (Priorité HIGH automatique) ! (ID: $id)');
  }
Future<void> _toggleTask() async {
    stdout.write('\nEntrez l\'ID de la tâche à modifier : ');
    String? id = stdin.readLineSync();
    if (id != null && id.isNotEmpty) {
      await _service.toggleTaskStatus(id.trim());
      print('🔄 Statut de la tâche mis à jour !');
    }
  }
Future<void> _deleteTask() async {
    stdout.write('\nEntrez l\'ID de la tâche à supprimer : ');
    String? id = stdin.readLineSync();
    if (id != null && id.isNotEmpty) {
      await _service.deleteTask(id.trim());
      print('🗑️ Tâche supprimée !');
    }
  }
Future<void> _showStatsAndFilters() async {
    double rate = await _service.getCompletionRate();
    var pending = await _service.getPendingTasks();
    var overdue = await _service.getOverdueTasks();

    print('\n--- 📊 STATISTIQUES & FILTRES ---');
    print('Taux d\'avancement : ${rate.toStringAsFixed(1)}%');
    print('Tâches en attente : ${pending.length}');
    print('Tâches en retard  : ${overdue.length}');
  }
}
