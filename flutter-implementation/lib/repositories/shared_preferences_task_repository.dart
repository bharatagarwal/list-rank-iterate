import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/task.dart';
import 'base_task_repository.dart';

class SharedPreferencesTaskRepository extends BaseTaskRepository {
  static const String _tasksKey = 'tasks';
  SharedPreferences? _prefs;

  @override
  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  SharedPreferences get _instance {
    if (_prefs == null) {
      throw Exception('SharedPreferences not initialized. Call init() first.');
    }
    return _prefs!;
  }

  List<Task> _getTasksFromPrefs() {
    final tasksJson = _instance.getString(_tasksKey);
    if (tasksJson == null) {
      return [];
    }
    final List<dynamic> decoded = jsonDecode(tasksJson);
    return decoded.map((json) => Task.fromJson(json)).toList();
  }

  Future<void> _saveTasksToPrefs(List<Task> tasks) {
    final List<Map<String, dynamic>> encoded =
        tasks.map((task) => task.toJson()).toList();
    return _instance.setString(_tasksKey, jsonEncode(encoded));
  }

  @override
  Future<void> create(Task task) async {
    final tasks = _getTasksFromPrefs();
    tasks.add(task);
    await _saveTasksToPrefs(tasks);
  }

  @override
  Task? read(String id) {
    try {
      return _getTasksFromPrefs().firstWhere((task) => task.id == id);
    } catch (e) {
      return null;
    }
  }

  @override
  List<Task> getAll() {
    return _getTasksFromPrefs()..sort((a, b) => a.order.compareTo(b.order));
  }

  @override
  List<Task> getByStatus(TaskStatus status) {
    return _getTasksFromPrefs()
        .where((task) => task.status == status)
        .toList()
      ..sort((a, b) => a.order.compareTo(b.order));
  }

  @override
  Future<void> update(Task task) async {
    final tasks = _getTasksFromPrefs();
    final index = tasks.indexWhere((t) => t.id == task.id);
    if (index != -1) {
      tasks[index] = task;
      await _saveTasksToPrefs(tasks);
    } else {
      throw Exception('Task with id ${task.id} not found');
    }
  }

  @override
  Future<void> delete(String id) async {
    final tasks = _getTasksFromPrefs();
    tasks.removeWhere((task) => task.id == id);
    await _saveTasksToPrefs(tasks);
  }

  @override
  Future<void> deleteAll() async {
    await _instance.remove(_tasksKey);
  }

  @override
  Future<void> updateMany(List<Task> tasks) async {
    final allTasks = _getTasksFromPrefs();
    final taskMap = {for (var task in tasks) task.id: task};

    for (var i = 0; i < allTasks.length; i++) {
      if (taskMap.containsKey(allTasks[i].id)) {
        allTasks[i] = taskMap[allTasks[i].id]!;
      }
    }

    await _saveTasksToPrefs(allTasks);
  }

  @override
  int getNextOrder() {
    final tasks = getAll();
    if (tasks.isEmpty) return 0;
    return tasks.map((t) => t.order).reduce((a, b) => a > b ? a : b) + 1;
  }

  @override
  Future<void> reorder(List<Task> tasks) async {
    for (var i = 0; i < tasks.length; i++) {
      tasks[i].order = i;
    }
    await updateMany(tasks);
  }

  @override
  Future<void> archiveAll() async {
    final tasks = _getTasksFromPrefs()
        .where((task) =>
            task.status == TaskStatus.active ||
            task.status == TaskStatus.completed)
        .toList();

    final now = DateTime.now();
    for (var task in tasks) {
      task.status = TaskStatus.archived;
      task.archivedAt = now;
    }

    await updateMany(tasks);
  }

  @override
  Future<void> close() async {
    // No-op for SharedPreferences
  }
}
