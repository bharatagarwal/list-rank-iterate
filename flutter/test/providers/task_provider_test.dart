import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:list_rank_iterate/models/task.dart';
import 'package:list_rank_iterate/providers/task_provider.dart';
import 'package:list_rank_iterate/repositories/task_repository.dart';

void main() {
  group('TaskProvider Tests', () {
    late TaskProvider provider;
    late TaskRepository repository;
    late Directory tempDir;

    setUpAll(() async {
      // Initialize Hive for tests
      tempDir = await Directory.systemTemp.createTemp('hive_provider_test_');
      Hive.init(tempDir.path);
      Hive.registerAdapter(TaskAdapter());
      Hive.registerAdapter(TaskStatusAdapter());
    });

    setUp(() async {
      // Create new repository and provider for each test
      repository = TaskRepository();
      await repository.init();
      await repository.deleteAll();
      provider = TaskProvider(repository);
    });

    tearDown(() async {
      await repository.deleteAll();
      await repository.close();
    });

    tearDownAll(() async {
      await Hive.close();
      await Hive.deleteFromDisk();
      if (await tempDir.exists()) {
        await tempDir.delete(recursive: true);
      }
    });

    group('Initialization', () {
      test('should start with empty task list', () {
        expect(provider.tasks, isEmpty);
        expect(provider.isLoading, isFalse);
      });

      test('loadTasks should populate tasks from repository', () async {
        // Add tasks to repository
        await repository.create(
          Task(
            id: '1',
            title: 'Test Task',
            status: TaskStatus.active,
            order: 0,
            createdAt: DateTime.now(),
          ),
        );

        await provider.loadTasks();

        expect(provider.tasks.length, 1);
        expect(provider.tasks[0].title, 'Test Task');
      });

      test('loadTasks should set loading state', () async {
        final loadingStates = <bool>[];
        provider.addListener(() {
          loadingStates.add(provider.isLoading);
        });

        await provider.loadTasks();

        expect(loadingStates, contains(true));
        expect(provider.isLoading, isFalse);
      });
    });

    group('Task Filtering', () {
      setUp(() async {
        // Add tasks with different statuses
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
        await provider.loadTasks();
      });

      test('activeTasks should return only active tasks', () {
        final activeTasks = provider.activeTasks;
        expect(activeTasks.length, 2);
        expect(activeTasks.every((t) => t.status == TaskStatus.active), isTrue);
      });

      test('completedTasks should return only completed tasks', () {
        final completedTasks = provider.completedTasks;
        expect(completedTasks.length, 1);
        expect(
          completedTasks.every((t) => t.status == TaskStatus.completed),
          isTrue,
        );
      });

      test('archivedTasks should return only archived tasks', () {
        final archivedTasks = provider.archivedTasks;
        expect(archivedTasks.length, 1);
        expect(
          archivedTasks.every((t) => t.status == TaskStatus.archived),
          isTrue,
        );
      });

      test('filtered tasks should be sorted by order', () {
        final activeTasks = provider.activeTasks;
        expect(activeTasks[0].order, lessThan(activeTasks[1].order));
      });
    });

    group('Task Management', () {
      test('addTask should create and add new task', () async {
        var notifyCount = 0;
        provider.addListener(() => notifyCount++);

        await provider.addTask('New Task');

        expect(provider.tasks.length, 1);
        expect(provider.tasks[0].title, 'New Task');
        expect(provider.tasks[0].status, TaskStatus.active);
        expect(notifyCount, greaterThan(0));
      });

      test('addTask should persist to repository', () async {
        await provider.addTask('Persisted Task');

        final tasksInRepo = repository.getAll();
        expect(tasksInRepo.length, 1);
        expect(tasksInRepo[0].title, 'Persisted Task');
      });

      test('updateTask should modify existing task', () async {
        await provider.addTask('Original Title');
        final task = provider.tasks[0];

        var notifyCount = 0;
        provider.addListener(() => notifyCount++);

        final updatedTask = task.copyWith(title: 'Updated Title');
        await provider.updateTask(updatedTask);

        expect(provider.tasks[0].title, 'Updated Title');
        expect(notifyCount, greaterThan(0));
      });

      test('deleteTask should remove task', () async {
        await provider.addTask('Task to Delete');
        final taskId = provider.tasks[0].id;

        var notifyCount = 0;
        provider.addListener(() => notifyCount++);

        await provider.deleteTask(taskId);

        expect(provider.tasks, isEmpty);
        expect(notifyCount, greaterThan(0));
      });

      test('deleteTask should persist to repository', () async {
        await provider.addTask('Task to Delete');
        final taskId = provider.tasks[0].id;

        await provider.deleteTask(taskId);

        expect(repository.getAll(), isEmpty);
      });
    });

    group('Task Status Changes', () {
      setUp(() async {
        await provider.addTask('Test Task');
      });

      test('completeTask should update status to completed', () async {
        final taskId = provider.tasks[0].id;

        await provider.completeTask(taskId);

        final task = provider.tasks.firstWhere((t) => t.id == taskId);
        expect(task.status, TaskStatus.completed);
        expect(task.completedAt, isNotNull);
      });

      test('archiveTask should update status to archived', () async {
        final taskId = provider.tasks[0].id;

        await provider.archiveTask(taskId);

        final task = provider.tasks.firstWhere((t) => t.id == taskId);
        expect(task.status, TaskStatus.archived);
        expect(task.archivedAt, isNotNull);
      });

      test('status changes should persist to repository', () async {
        final taskId = provider.tasks[0].id;

        await provider.completeTask(taskId);

        final taskInRepo = repository.read(taskId);
        expect(taskInRepo?.status, TaskStatus.completed);
      });
    });

    group('Task Reordering', () {
      test('reorderTasks should update task order', () async {
        // Create tasks directly in repository with unique IDs
        await repository.create(
          Task(
            id: 'task1',
            title: 'Task 1',
            status: TaskStatus.active,
            order: 0,
            createdAt: DateTime.now(),
          ),
        );
        await repository.create(
          Task(
            id: 'task2',
            title: 'Task 2',
            status: TaskStatus.active,
            order: 1,
            createdAt: DateTime.now(),
          ),
        );
        await repository.create(
          Task(
            id: 'task3',
            title: 'Task 3',
            status: TaskStatus.active,
            order: 2,
            createdAt: DateTime.now(),
          ),
        );
        await provider.loadTasks();

        final tasks = List<Task>.from(provider.tasks);
        final reordered = [tasks[2], tasks[0], tasks[1]];

        await provider.reorderTasks(reordered);

        expect(provider.tasks[0].title, 'Task 3');
        expect(provider.tasks[1].title, 'Task 1');
        expect(provider.tasks[2].title, 'Task 2');
      });

      test('reorderTasks should persist to repository', () async {
        await repository.create(
          Task(
            id: 'task1',
            title: 'Task 1',
            status: TaskStatus.active,
            order: 0,
            createdAt: DateTime.now(),
          ),
        );
        await repository.create(
          Task(
            id: 'task2',
            title: 'Task 2',
            status: TaskStatus.active,
            order: 1,
            createdAt: DateTime.now(),
          ),
        );
        await repository.create(
          Task(
            id: 'task3',
            title: 'Task 3',
            status: TaskStatus.active,
            order: 2,
            createdAt: DateTime.now(),
          ),
        );
        await provider.loadTasks();

        final tasks = List<Task>.from(provider.tasks);
        final reordered = [tasks[2], tasks[0], tasks[1]];

        await provider.reorderTasks(reordered);

        final repoTasks = repository.getAll();
        expect(repoTasks[0].order, 0);
        expect(repoTasks[1].order, 1);
        expect(repoTasks[2].order, 2);
      });

      test('reorderTasks should notify listeners', () async {
        await repository.create(
          Task(
            id: 'task1',
            title: 'Task 1',
            status: TaskStatus.active,
            order: 0,
            createdAt: DateTime.now(),
          ),
        );
        await repository.create(
          Task(
            id: 'task2',
            title: 'Task 2',
            status: TaskStatus.active,
            order: 1,
            createdAt: DateTime.now(),
          ),
        );
        await repository.create(
          Task(
            id: 'task3',
            title: 'Task 3',
            status: TaskStatus.active,
            order: 2,
            createdAt: DateTime.now(),
          ),
        );
        await provider.loadTasks();

        final tasks = List<Task>.from(provider.tasks);
        final reordered = [tasks[2], tasks[0], tasks[1]];

        var notifyCount = 0;
        provider.addListener(() => notifyCount++);

        await provider.reorderTasks(reordered);

        expect(notifyCount, greaterThan(0));
      });
    });

    group('Bulk Operations', () {
      test(
        'archiveAllTasks should archive all active and completed tasks',
        () async {
          await repository.create(
            Task(
              id: 'active1',
              title: 'Active Task',
              status: TaskStatus.active,
              order: 0,
              createdAt: DateTime.now(),
            ),
          );
          await repository.create(
            Task(
              id: 'completed1',
              title: 'Completed Task',
              status: TaskStatus.completed,
              order: 1,
              createdAt: DateTime.now(),
              completedAt: DateTime.now(),
            ),
          );
          await provider.loadTasks();

          await provider.archiveAllTasks();

          expect(provider.archivedTasks.length, 2);
          expect(provider.activeTasks, isEmpty);
          expect(provider.completedTasks, isEmpty);
        },
      );

      test('archiveAllTasks should persist to repository', () async {
        await repository.create(
          Task(
            id: 'active1',
            title: 'Active Task',
            status: TaskStatus.active,
            order: 0,
            createdAt: DateTime.now(),
          ),
        );
        await repository.create(
          Task(
            id: 'completed1',
            title: 'Completed Task',
            status: TaskStatus.completed,
            order: 1,
            createdAt: DateTime.now(),
            completedAt: DateTime.now(),
          ),
        );
        await provider.loadTasks();

        await provider.archiveAllTasks();

        final archivedInRepo = repository.getByStatus(TaskStatus.archived);
        expect(archivedInRepo.length, 2);
      });

      test('archiveAllTasks should notify listeners', () async {
        await repository.create(
          Task(
            id: 'active1',
            title: 'Active Task',
            status: TaskStatus.active,
            order: 0,
            createdAt: DateTime.now(),
          ),
        );
        await repository.create(
          Task(
            id: 'completed1',
            title: 'Completed Task',
            status: TaskStatus.completed,
            order: 1,
            createdAt: DateTime.now(),
            completedAt: DateTime.now(),
          ),
        );
        await provider.loadTasks();

        var notifyCount = 0;
        provider.addListener(() => notifyCount++);

        await provider.archiveAllTasks();

        expect(notifyCount, greaterThan(0));
      });

      test('clearAllTasks should remove all tasks', () async {
        await provider.addTask('Task 1');
        await provider.addTask('Task 2');

        await provider.clearAllTasks();

        expect(provider.tasks, isEmpty);
        expect(repository.getAll(), isEmpty);
      });
    });

    group('Change Notifications', () {
      test('should notify listeners on addTask', () async {
        var notified = false;
        provider.addListener(() => notified = true);

        await provider.addTask('Test');

        expect(notified, isTrue);
      });

      test('should notify listeners on updateTask', () async {
        await provider.addTask('Test');
        final task = provider.tasks[0];

        var notified = false;
        provider.addListener(() => notified = true);

        await provider.updateTask(task.copyWith(title: 'Updated'));

        expect(notified, isTrue);
      });

      test('should notify listeners on deleteTask', () async {
        await provider.addTask('Test');
        final taskId = provider.tasks[0].id;

        var notified = false;
        provider.addListener(() => notified = true);

        await provider.deleteTask(taskId);

        expect(notified, isTrue);
      });

      test('should notify listeners on loadTasks', () async {
        await repository.create(
          Task(
            id: '1',
            title: 'Test',
            status: TaskStatus.active,
            order: 0,
            createdAt: DateTime.now(),
          ),
        );

        var notifyCount = 0;
        provider.addListener(() => notifyCount++);

        await provider.loadTasks();

        expect(notifyCount, greaterThan(0));
      });
    });
  });
}
