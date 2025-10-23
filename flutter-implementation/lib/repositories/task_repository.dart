import 'package:hive/hive.dart';
import '../models/task.dart';

class TaskRepository {
  static const String _boxName = 'tasks';
  Box<Task>? _box;

  Future<void> init() async {
    _box = await Hive.openBox<Task>(_boxName);
  }

  Box<Task> get box {
    if (_box == null || !_box!.isOpen) {
      throw Exception('TaskRepository not initialized. Call init() first.');
    }
    return _box!;
  }

  Future<void> create(Task task) async {
    await box.put(task.id, task);
  }

  Task? read(String id) {
    return box.get(id);
  }

  List<Task> getAll() {
    return box.values.toList()..sort((a, b) => a.order.compareTo(b.order));
  }

  List<Task> getByStatus(TaskStatus status) {
    return box.values
        .where((task) => task.status == status)
        .toList()
      ..sort((a, b) => a.order.compareTo(b.order));
  }

  Future<void> update(Task task) async {
    if (box.containsKey(task.id)) {
      await box.put(task.id, task);
    } else {
      throw Exception('Task with id ${task.id} not found');
    }
  }

  Future<void> delete(String id) async {
    await box.delete(id);
  }

  Future<void> deleteAll() async {
    await box.clear();
  }

  Future<void> updateMany(List<Task> tasks) async {
    final taskMap = {for (var task in tasks) task.id: task};
    await box.putAll(taskMap);
  }

  int getNextOrder() {
    final tasks = getAll();
    if (tasks.isEmpty) return 0;
    return tasks.map((t) => t.order).reduce((a, b) => a > b ? a : b) + 1;
  }

  Future<void> reorder(List<Task> tasks) async {
    for (var i = 0; i < tasks.length; i++) {
      tasks[i].order = i;
    }
    await updateMany(tasks);
  }

  Future<void> archiveAll() async {
    final tasks = box.values.where((task) =>
      task.status == TaskStatus.active || task.status == TaskStatus.completed
    ).toList();

    final now = DateTime.now();
    for (var task in tasks) {
      task.status = TaskStatus.archived;
      task.archivedAt = now;
    }

    await updateMany(tasks);
  }

  Future<void> close() async {
    await box.close();
  }
}
