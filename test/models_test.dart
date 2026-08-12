import 'package:cli_task_manager/models/priority.dart';
import 'package:cli_task_manager/models/standard_task.dart';
import 'package:cli_task_manager/models/urgent_task.dart';
import 'package:test/test.dart';

void main() {
  group('Task Models & Inheritance Tests', () {
    test('StandardTask instantiates correctly with assigned priority', () {
      final task = StandardTask(
        id: 'st-1',
        title: 'Lire la documentation Dart',
        priority: Priority.medium,
      );

      expect(task.id, equals('st-1'));
      expect(task.title, equals('Lire la documentation Dart'));
      expect(task.priority, equals(Priority.medium));
      expect(task.isDone, isFalse);
    });

    test('UrgentTask automatically forces high priority', () {
      final task = UrgentTask(
        id: 'ut-1',
        title: 'Corriger le bug critique',
      );

      expect(task.id, equals('ut-1'));
      expect(task.priority, equals(Priority.high));
    });

    test('StandardTask toJson outputs correct structure', () {
      final task = StandardTask(
        id: 'st-2',
        title: 'Tester la sérialisation',
        priority: Priority.low,
        deadline: DateTime(2026, 12, 31),
        isDone: true,
      );

      final json = task.toJson();

      expect(json['type'], equals('standard'));
      expect(json['id'], equals('st-2'));
      expect(json['title'], equals('Tester la sérialisation'));
      expect(json['priority'], equals('low'));
      expect(json['isDone'], isTrue);
      expect(json['deadline'], equals('2026-12-31T00:00:00.000'));
    });

    test('UrgentTask toJson outputs correct structure', () {
      final task = UrgentTask(
        id: 'ut-2',
        title: 'Déployer en production',
        deadline: DateTime(2026, 9, 1),
      );

      final json = task.toJson();

      expect(json['type'], equals('urgent'));
      expect(json['id'], equals('ut-2'));
      expect(json['priority'], equals('high'));
      expect(json['deadline'], equals('2026-09-01T00:00:00.000'));
    });
  });
}
