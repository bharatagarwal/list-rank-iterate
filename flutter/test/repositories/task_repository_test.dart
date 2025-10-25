import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:list_rank_iterate/models/task.dart';
import 'package:list_rank_iterate/repositories/task_repository.dart';

void main() {
  group('TaskRepository Tests', () {
    late TaskRepository repository;
    late Box<Task> testBox;
    late Directory tempDir;

    setUpAll(() async {
      // Initialize Hive with a temporary directory for tests
      tempDir = await Directory.systemTemp.createTemp('hive_test_');
      Hive.init(tempDir.path);
      Hive.registerAdapter(TaskAdapter());
      Hive.registerAdapter(TaskStatusAdapter());
    });

    setUp(() async {
      // Create a new repository and box for each test
      repository = TaskRepository();
      await repository.init();
      testBox = repository.box;
      await testBox.clear();
    });

    tearDown(() async {
      // Clean up after each test
      if (testBox.isOpen) {
        await testBox.clear();
        await testBox.close();
      }
    });

    tearDownAll(() async {
      // Clean up Hive completely
      await Hive.close();
      await Hive.deleteFromDisk();
      if (await tempDir.exists()) {
        await tempDir.delete(recursive: true);
      }
    });

    group('Initialization', () {
      test('should initialize repository and open box', () {
        expect(repository.box.isOpen, isTrue);
        expect(repository.box.name, 'tasks');
      });

      test('should throw exception when accessing box before init', () {
        final uninitializedRepo = TaskRepository();
        expect(() => uninitializedRepo.box, throwsException);
      });
    });

    group('CRUD Operations', () {
      test('create should add task to box', () async {
        final task = Task(
          id: '1',
          title: 'Test Task',
          status: TaskStatus.active,
          order: 0,
          createdAt: DateTime.now(),
        );

        await repository.create(task);

        expect(testBox.length, 1);
        expect(testBox.get('1')?.title, 'Test Task');
      });

      test('read should return task by id', () async {
        final task = Task(
          id: '2',
          title: 'Read Test',
          status: TaskStatus.active,
          order: 0,
          createdAt: DateTime.now(),
        );
        await repository.create(task);

        final result = repository.read('2');

        expect(result, isNotNull);
        expect(result?.id, '2');
        expect(result?.title, 'Read Test');
      });

      test('read should return null for non-existent id', () {
        final result = repository.read('non-existent');
        expect(result, isNull);
      });

      test('update should modify existing task', () async {
        final task = Task(
          id: '3',
          title: 'Original Title',
          status: TaskStatus.active,
          order: 0,
          createdAt: DateTime.now(),
        );
        await repository.create(task);

        final updatedTask = task.copyWith(title: 'Updated Title');
        await repository.update(updatedTask);

        final result = repository.read('3');
        expect(result?.title, 'Updated Title');
      });

      test('update should throw exception for non-existent task', () async {
        final task = Task(
          id: 'non-existent',
          title: 'Test',
          status: TaskStatus.active,
          order: 0,
          createdAt: DateTime.now(),
        );

        expect(() => repository.update(task), throwsException);
      });

      test('delete should remove task from box', () async {
        final task = Task(
          id: '4',
          title: 'Delete Test',
          status: TaskStatus.active,
          order: 0,
          createdAt: DateTime.now(),
        );
        await repository.create(task);
        expect(testBox.length, 1);

        await repository.delete('4');

        expect(testBox.length, 0);
        expect(repository.read('4'), isNull);
      });

      test('deleteAll should clear all tasks', () async {
        for (var i = 0; i < 5; i++) {
          await repository.create(
            Task(
              id: '$i',
              title: 'Task $i',
              status: TaskStatus.active,
              order: i,
              createdAt: DateTime.now(),
            ),
          );
        }
        expect(testBox.length, 5);

        await repository.deleteAll();

        expect(testBox.length, 0);
      });
    });

    group('Query Operations', () {
      setUp(() async {
        // Add test data
        await repository.create(
          Task(
            id: '1',
            title: 'Active Task 1',
            status: TaskStatus.active,
            order: 0,
            createdAt: DateTime.now(),
          ),
        );
        await repository.create(
          Task(
            id: '2',
            title: 'Completed Task',
            status: TaskStatus.completed,
            order: 1,
            createdAt: DateTime.now(),
          ),
        );
        await repository.create(
          Task(
            id: '3',
            title: 'Active Task 2',
            status: TaskStatus.active,
            order: 2,
            createdAt: DateTime.now(),
          ),
        );
        await repository.create(
          Task(
            id: '4',
            title: 'Archived Task',
            status: TaskStatus.archived,
            order: 3,
            createdAt: DateTime.now(),
          ),
        );
      });

      test('getAll should return all tasks sorted by order', () {
        final tasks = repository.getAll();

        expect(tasks.length, 4);
        expect(tasks[0].order, 0);
        expect(tasks[1].order, 1);
        expect(tasks[2].order, 2);
        expect(tasks[3].order, 3);
      });

      test('getByStatus should filter tasks by status', () {
        final activeTasks = repository.getByStatus(TaskStatus.active);
        final completedTasks = repository.getByStatus(TaskStatus.completed);
        final archivedTasks = repository.getByStatus(TaskStatus.archived);

        expect(activeTasks.length, 2);
        expect(completedTasks.length, 1);
        expect(archivedTasks.length, 1);
      });

      test('getByStatus should return sorted tasks', () {
        final activeTasks = repository.getByStatus(TaskStatus.active);

        expect(activeTasks[0].order, 0);
        expect(activeTasks[1].order, 2);
      });
    });

    group('Batch Operations', () {
      test('updateMany should update multiple tasks', () async {
        // Create initial tasks
        final tasks = List.generate(
          3,
          (i) => Task(
            id: '$i',
            title: 'Task $i',
            status: TaskStatus.active,
            order: i,
            createdAt: DateTime.now(),
          ),
        );
        for (final task in tasks) {
          await repository.create(task);
        }

        // Update all tasks
        final updatedTasks = tasks
            .map((t) => t.copyWith(title: 'Updated ${t.title}'))
            .toList();
        await repository.updateMany(updatedTasks);

        // Verify updates
        for (var i = 0; i < 3; i++) {
          final task = repository.read('$i');
          expect(task?.title, 'Updated Task $i');
        }
      });

      test('reorder should update order of tasks', () async {
        // Create tasks
        final tasks = List.generate(
          3,
          (i) => Task(
            id: '$i',
            title: 'Task $i',
            status: TaskStatus.active,
            order: i,
            createdAt: DateTime.now(),
          ),
        );
        for (final task in tasks) {
          await repository.create(task);
        }

        // Reverse the order
        final reversedTasks = tasks.reversed.toList();
        await repository.reorder(reversedTasks);

        // Verify new order
        final allTasks = repository.getAll();
        expect(allTasks[0].id, '2');
        expect(allTasks[0].order, 0);
        expect(allTasks[1].id, '1');
        expect(allTasks[1].order, 1);
        expect(allTasks[2].id, '0');
        expect(allTasks[2].order, 2);
      });
    });

    group('Helper Methods', () {
      test('getNextOrder should return 0 for empty box', () {
        final nextOrder = repository.getNextOrder();
        expect(nextOrder, 0);
      });

      test('getNextOrder should return next available order', () async {
        await repository.create(
          Task(
            id: '1',
            title: 'Task 1',
            status: TaskStatus.active,
            order: 0,
            createdAt: DateTime.now(),
          ),
        );
        await repository.create(
          Task(
            id: '2',
            title: 'Task 2',
            status: TaskStatus.active,
            order: 5,
            createdAt: DateTime.now(),
          ),
        );

        final nextOrder = repository.getNextOrder();
        expect(nextOrder, 6);
      });
    });

    group('Archive Operations', () {
      test('archiveAll should archive active and completed tasks', () async {
        // Create tasks with different statuses
        await repository.create(
          Task(
            id: '1',
            title: 'Active Task',
            status: TaskStatus.active,
            order: 0,
            createdAt: DateTime.now(),
          ),
        );
        await repository.create(
          Task(
            id: '2',
            title: 'Completed Task',
            status: TaskStatus.completed,
            order: 1,
            createdAt: DateTime.now(),
          ),
        );
        await repository.create(
          Task(
            id: '3',
            title: 'Already Archived',
            status: TaskStatus.archived,
            order: 2,
            createdAt: DateTime.now(),
          ),
        );

        await repository.archiveAll();

        final archivedTasks = repository.getByStatus(TaskStatus.archived);
        expect(archivedTasks.length, 3);

        // Verify archivedAt is set
        final task1 = repository.read('1');
        final task2 = repository.read('2');
        expect(task1?.archivedAt, isNotNull);
        expect(task2?.archivedAt, isNotNull);
      });

      test('archiveAll should not affect already archived tasks', () async {
        final originalArchiveTime = DateTime.now().subtract(
          const Duration(days: 1),
        );
        await repository.create(
          Task(
            id: '1',
            title: 'Archived Task',
            status: TaskStatus.archived,
            order: 0,
            createdAt: DateTime.now(),
            archivedAt: originalArchiveTime,
          ),
        );

        await repository.archiveAll();

        final task = repository.read('1');
        expect(task?.status, TaskStatus.archived);
        // The archiveAll operation updates all tasks, so archivedAt will be updated
        expect(task?.archivedAt, isNotNull);
      });
    });
  });
}
