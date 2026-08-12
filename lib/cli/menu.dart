import 'dart:io';

import '../exceptions/task_exceptions.dart';
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
      print('4. Marquer / Démarquer une tâche (Terminée)');
      print('5. Supprimer une tâche');
      print('6. Statistiques & Filtres');
      print('7. Quitter');
      print('-----------------------------------------');
      stdout.write('Votre choix (1-7) : ');

      String? choice = stdin.readLineSync();

      try {
        switch (choice?.trim()) {
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
            print('⚠️ Choix invalide. Veuillez saisir un nombre entre 1 et 7.');
        }
      } on TaskManagerException catch (e) {
        print('⚠️ Erreur : $e');
      } catch (e) {
        print('❌ Une erreur inattendue est survenue : $e');
      }
    }
  }

  Future<void> _showAllTasks() async {
    print('\nTrier par : 1. Priorité  2. Date limite  3. Ordre par défaut');
    stdout.write('Choix (1-3) [défaut = 3] : ');
    String? sortChoice = stdin.readLineSync()?.trim();

    var tasks = sortChoice == '1'
        ? await _service.getAllTasksSortedByPriority()
        : sortChoice == '2'
            ? await _service.getAllTasksSortedByDeadline()
            : await _service.getAllTasks();

    if (tasks.isEmpty) {
      print('\nAucune tâche enregistrée pour le moment.');
      return;
    }

    print('\n--- 📋 LISTE DES TÂCHES (${tasks.length}) ---');
    for (var task in tasks) {
      String status = task.isDone ? '[X]' : '[ ]';
      String deadlineStr = task.deadline != null
          ? ' (Échéance: ${task.deadline.toString().split(' ')[0]})'
          : '';
      print(
        '$status ${task.icon} [ID: ${task.id}] ${task.title} | Priorité: ${task.priority.label} (${task.priority.name.toUpperCase()})$deadlineStr',
      );
    }
  }

  Future<void> _addStandardTask() async {
    stdout.write('\nTitre de la tâche : ');
    String? title = stdin.readLineSync();
    if (title == null || title.trim().isEmpty) {
      print('⚠️ Le titre ne peut pas être vide.');
      return;
    }

    print('Priorité : 1. Basse (low)  2. Moyenne (medium)  3. Haute (high)');
    stdout.write('Choix (1-3) [défaut = 2] : ');
    String? pChoice = stdin.readLineSync()?.trim();
    Priority priority = Priority.medium;
    if (pChoice == '1') priority = Priority.low;
    if (pChoice == '3') priority = Priority.high;

    stdout.write('Date limite (AAAA-MM-JJ, optionnel) : ');
    String? dateStr = stdin.readLineSync()?.trim();
    DateTime? deadline;
    if (dateStr != null && dateStr.isNotEmpty) {
      deadline = DateTime.tryParse(dateStr);
      if (deadline == null) {
        print('⚠️ Format de date invalide (ex: 2026-12-31). Tâche créée sans date limite.');
      }
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
    String? dateStr = stdin.readLineSync()?.trim();
    DateTime? deadline;
    if (dateStr != null && dateStr.isNotEmpty) {
      deadline = DateTime.tryParse(dateStr);
      if (deadline == null) {
        print('⚠️ Format de date invalide. Tâche urgente créée sans date limite.');
      }
    }

    String id = DateTime.now().millisecondsSinceEpoch.toString().substring(7);
    var task = UrgentTask(
      id: id,
      title: title.trim(),
      deadline: deadline,
    );

    await _service.addTask(task);
    print('⚡ Tâche urgente créée (Priorité HAUTE automatique) ! (ID: $id)');
  }

  Future<void> _toggleTask() async {
    stdout.write('\nEntrez l\'ID de la tâche à modifier : ');
    String? id = stdin.readLineSync()?.trim();
    if (id == null || id.isEmpty) {
      print('⚠️ L\'ID ne peut pas être vide.');
      return;
    }

    await _service.toggleTaskStatus(id);
    print('🔄 Statut de la tâche mis à jour !');
  }

  Future<void> _deleteTask() async {
    stdout.write('\nEntrez l\'ID de la tâche à supprimer : ');
    String? id = stdin.readLineSync()?.trim();
    if (id == null || id.isEmpty) {
      print('⚠️ L\'ID ne peut pas être vide.');
      return;
    }

    await _service.deleteTask(id);
    print('🗑️ Tâche supprimée avec succès !');
  }

  Future<void> _showStatsAndFilters() async {
    double rate = await _service.getCompletionRate();
    var pending = await _service.getPendingTasks();
    var completed = await _service.getCompletedTasks();
    var overdue = await _service.getOverdueTasks();

    print('\n--- 📊 STATISTIQUES & FILTRES ---');
    print('Taux d\'avancement  : ${rate.toStringAsFixed(1)}%');
    print('Tâches terminées   : ${completed.length}');
    print('Tâches en attente  : ${pending.length}');
    print('Tâches en retard   : ${overdue.length}');
  }
}

