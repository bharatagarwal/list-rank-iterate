import 'dart:math';

import 'package:hive/hive.dart';
import 'package:list_rank_iterate/models/task.dart';
import 'package:list_rank_iterate/repositories/task_repository.dart';

class FakeTaskRepository extends TaskRepository {
  FakeTaskRepository({Iterable<Task> initialTasks = const []}) {
    for (final task in initialTasks) {
      _store[task.id] = task;
    }
  }

  final Map<String, Task> _store = {};

  @override
  Future<void> init() async {}

  @override
  Box<Task> get box =>
      throw UnimplementedError('Fake repository does not expose a Hive box.');

  @override
  Future<void> create(Task task) async {
    _store[task.id] = task;
  }

  @override
  Task? read(String id) => _store[id];

  @override
  List<Task> getAll() {
    final tasks = _store.values.toList();
    tasks.sort((a, b) => a.order.compareTo(b.order));
    return tasks;
  }

  @override
  List<Task> getByStatus(TaskStatus status) {
    return getAll().where((task) => task.status == status).toList();
  }

  @override
  Future<void> update(Task task) async {
    if (_store.containsKey(task.id)) {
      _store[task.id] = task;
      return;
    }
    throw Exception('Task with id ${task.id} not found');
  }

  @override
  Future<void> delete(String id) async {
    _store.remove(id);
  }

  @override
  Future<void> deleteAll() async {
    _store.clear();
  }

  @override
  Future<void> updateMany(List<Task> tasks) async {
    for (final task in tasks) {
      _store[task.id] = task;
    }
  }

  @override
  int getNextOrder() {
    if (_store.isEmpty) {
      return 0;
    }

    final highestOrder = _store.values.map((task) => task.order).reduce(max);
    return highestOrder + 1;
  }

  @override
  Future<void> reorder(List<Task> tasks) async {
    final updated = <Task>[];
    for (var index = 0; index < tasks.length; index++) {
      updated.add(tasks[index].copyWith(order: index));
    }
    await updateMany(updated);
  }

  @override
  Future<void> archiveAll() async {
    final now = DateTime.now();
    final updates = <Task>[];

    for (final task in _store.values) {
      if (task.status == TaskStatus.active ||
          task.status == TaskStatus.completed) {
        updates.add(
          task.copyWith(status: TaskStatus.archived, archivedAt: now),
        );
      }
    }

    await updateMany(updates);
  }

  @override
  Future<void> close() async {}
}
