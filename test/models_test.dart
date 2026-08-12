import 'package:cli_task_manager/models/priority.dart';
import 'package:cli_task_manager/models/standard_task.dart';
import 'package:cli_task_manager/models/task.dart';
import 'package:cli_task_manager/models/urgent_task.dart';
import 'package:test/test.dart';

void main() {
  group('Task Models & Polymorphism Tests', () {
    test('StandardTask instantiates correctly with assigned priority', () {
      final task = StandardTask(
        id: 'st-1',
        title: 'Lire la documentation Dart',
        priority: Priority.medium,
      );

      expect(task.id, equals('st-1'));
      expect(task.title, equals('Lire la documentation Dart'));
      expect(task.priority, equals(Priority.medium));
      expect(task.typeName, equals('Standard'));
      expect(task.icon, equals('📌'));
      expect(task.isDone, isFalse);
    });

    test('UrgentTask automatically forces high priority', () {
      final task = UrgentTask(
        id: 'ut-1',
        title: 'Corriger le bug critique',
      );

      expect(task.id, equals('ut-1'));
      expect(task.priority, equals(Priority.high));
      expect(task.typeName, equals('Urgente'));
      expect(task.icon, equals('⚡'));
    });

    test('Task toJson and Task.fromJson handle StandardTask correctly', () {
      final original = StandardTask(
        id: 'st-2',
        title: 'Tester la sérialisation',
        priority: Priority.low,
        deadline: DateTime(2026, 12, 31),
        isDone: true,
      );

      final json = original.toJson();
      final restored = Task.fromJson(json);

      expect(restored, isA<StandardTask>());
      expect(restored.id, equals('st-2'));
      expect(restored.title, equals('Tester la sérialisation'));
      expect(restored.priority, equals(Priority.low));
      expect(restored.isDone, isTrue);
      expect(restored.deadline, equals(DateTime(2026, 12, 31)));
    });

    test('Task toJson and Task.fromJson handle UrgentTask correctly', () {
      final original = UrgentTask(
        id: 'ut-2',
        title: 'Déployer en production',
        deadline: DateTime(2026, 9, 1),
      );

      final json = original.toJson();
      final restored = Task.fromJson(json);

      expect(restored, isA<UrgentTask>());
      expect(restored.id, equals('ut-2'));
      expect(restored.priority, equals(Priority.high));
      expect(restored.deadline, equals(DateTime(2026, 9, 1)));
    });

    test('Priority parse converts input strings correctly', () {
      expect(Priority.parse('1'), equals(Priority.low));
      expect(Priority.parse('medium'), equals(Priority.medium));
      expect(Priority.parse('HIGH'), equals(Priority.high));
    });
  });
}
