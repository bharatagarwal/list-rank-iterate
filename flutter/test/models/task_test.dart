import 'package:flutter_test/flutter_test.dart';
import 'package:list_rank_iterate/models/task.dart';

void main() {
  group('Task Model Tests', () {
    late Task testTask;
    late DateTime testDate;

    setUp(() {
      testDate = DateTime(2025, 10, 23, 12);
      testTask = Task(
        id: '123',
        title: 'Test Task',
        status: TaskStatus.active,
        order: 0,
        createdAt: testDate,
      );
    });

    group('toJson', () {
      test('should convert task to JSON correctly with all fields', () {
        final completedDate = DateTime(2025, 10, 23, 13);
        final archivedDate = DateTime(2025, 10, 23, 14);

        final task = Task(
          id: '456',
          title: 'Complete Task',
          status: TaskStatus.completed,
          order: 1,
          createdAt: testDate,
          completedAt: completedDate,
          archivedAt: archivedDate,
        );

        final json = task.toJson();

        expect(json['id'], '456');
        expect(json['title'], 'Complete Task');
        expect(json['status'], 'completed');
        expect(json['order'], 1);
        expect(json['createdAt'], testDate.toIso8601String());
        expect(json['completedAt'], completedDate.toIso8601String());
        expect(json['archivedAt'], archivedDate.toIso8601String());
      });

      test('should handle null optional fields correctly', () {
        final json = testTask.toJson();

        expect(json['id'], '123');
        expect(json['title'], 'Test Task');
        expect(json['status'], 'active');
        expect(json['order'], 0);
        expect(json['createdAt'], testDate.toIso8601String());
        expect(json['completedAt'], isNull);
        expect(json['archivedAt'], isNull);
      });

      test('should convert all TaskStatus values correctly', () {
        final activeTask = testTask.copyWith(status: TaskStatus.active);
        expect(activeTask.toJson()['status'], 'active');

        final completedTask = testTask.copyWith(status: TaskStatus.completed);
        expect(completedTask.toJson()['status'], 'completed');

        final archivedTask = testTask.copyWith(status: TaskStatus.archived);
        expect(archivedTask.toJson()['status'], 'archived');
      });
    });

    group('fromJson', () {
      test('should create task from JSON with all fields', () {
        final json = {
          'id': '789',
          'title': 'JSON Task',
          'status': 'completed',
          'order': 2,
          'createdAt': '2025-10-23T12:00:00.000',
          'completedAt': '2025-10-23T13:00:00.000',
          'archivedAt': '2025-10-23T14:00:00.000',
        };

        final task = Task.fromJson(json);

        expect(task.id, '789');
        expect(task.title, 'JSON Task');
        expect(task.status, TaskStatus.completed);
        expect(task.order, 2);
        expect(task.createdAt, DateTime.parse('2025-10-23T12:00:00.000'));
        expect(task.completedAt, DateTime.parse('2025-10-23T13:00:00.000'));
        expect(task.archivedAt, DateTime.parse('2025-10-23T14:00:00.000'));
      });

      test('should handle null optional fields correctly', () {
        final json = {
          'id': '101',
          'title': 'Minimal Task',
          'status': 'active',
          'order': 0,
          'createdAt': '2025-10-23T12:00:00.000',
          'completedAt': null,
          'archivedAt': null,
        };

        final task = Task.fromJson(json);

        expect(task.id, '101');
        expect(task.title, 'Minimal Task');
        expect(task.status, TaskStatus.active);
        expect(task.order, 0);
        expect(task.completedAt, isNull);
        expect(task.archivedAt, isNull);
      });

      test('should parse all TaskStatus values correctly', () {
        final activeJson = {...testTask.toJson(), 'status': 'active'};
        expect(Task.fromJson(activeJson).status, TaskStatus.active);

        final completedJson = {...testTask.toJson(), 'status': 'completed'};
        expect(Task.fromJson(completedJson).status, TaskStatus.completed);

        final archivedJson = {...testTask.toJson(), 'status': 'archived'};
        expect(Task.fromJson(archivedJson).status, TaskStatus.archived);
      });
    });

    group('JSON roundtrip', () {
      test('should preserve all data through toJson and fromJson', () {
        final completedDate = DateTime(2025, 10, 23, 13);
        final originalTask = Task(
          id: 'roundtrip',
          title: 'Roundtrip Task',
          status: TaskStatus.completed,
          order: 5,
          createdAt: testDate,
          completedAt: completedDate,
        );

        final json = originalTask.toJson();
        final restoredTask = Task.fromJson(json);

        expect(restoredTask.id, originalTask.id);
        expect(restoredTask.title, originalTask.title);
        expect(restoredTask.status, originalTask.status);
        expect(restoredTask.order, originalTask.order);
        expect(restoredTask.createdAt, originalTask.createdAt);
        expect(restoredTask.completedAt, originalTask.completedAt);
        expect(restoredTask.archivedAt, originalTask.archivedAt);
      });
    });

    group('copyWith', () {
      test('should create new task with updated fields', () {
        final updatedTask = testTask.copyWith(
          title: 'Updated Title',
          status: TaskStatus.completed,
        );

        expect(updatedTask.id, testTask.id);
        expect(updatedTask.title, 'Updated Title');
        expect(updatedTask.status, TaskStatus.completed);
        expect(updatedTask.order, testTask.order);
      });

      test('should preserve original values when no changes provided', () {
        final copiedTask = testTask.copyWith();

        expect(copiedTask.id, testTask.id);
        expect(copiedTask.title, testTask.title);
        expect(copiedTask.status, testTask.status);
        expect(copiedTask.order, testTask.order);
      });
    });
  });
}
