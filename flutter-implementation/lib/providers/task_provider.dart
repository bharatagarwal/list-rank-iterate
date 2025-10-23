import 'package:flutter/foundation.dart';
import '../models/task.dart';
import '../repositories/base_task_repository.dart';

class TaskProvider extends ChangeNotifier {
  final BaseTaskRepository _repository;
  List<Task> _tasks = [];
  bool _isLoading = false;

  TaskProvider(this._repository);

  List<Task> get tasks => _tasks;
  bool get isLoading => _isLoading;

  List<Task> get activeTasks =>
      _tasks.where((task) => task.status == TaskStatus.active).toList();

  List<Task> get completedTasks =>
      _tasks.where((task) => task.status == TaskStatus.completed).toList();

  List<Task> get archivedTasks =>
      _tasks.where((task) => task.status == TaskStatus.archived).toList();

  Future<void> loadTasks() async {
    _isLoading = true;
    notifyListeners();

    _tasks = _repository.getAll();

    _isLoading = false;
    notifyListeners();
  }

  Future<void> addTask(String title) async {
    final task = Task(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      status: TaskStatus.active,
      order: _repository.getNextOrder(),
      createdAt: DateTime.now(),
    );

    await _repository.create(task);
    _tasks.add(task);
    notifyListeners();
  }

  Future<void> updateTask(Task task) async {
    await _repository.update(task);
    final index = _tasks.indexWhere((t) => t.id == task.id);
    if (index != -1) {
      _tasks[index] = task;
      notifyListeners();
    }
  }

  Future<void> deleteTask(String id) async {
    await _repository.delete(id);
    _tasks.removeWhere((task) => task.id == id);
    notifyListeners();
  }

  Future<void> completeTask(String id) async {
    final task = _tasks.firstWhere((t) => t.id == id);
    final updatedTask = task.copyWith(
      status: TaskStatus.completed,
      completedAt: DateTime.now(),
    );
    await updateTask(updatedTask);
  }

  Future<void> archiveTask(String id) async {
    final task = _tasks.firstWhere((t) => t.id == id);
    final updatedTask = task.copyWith(
      status: TaskStatus.archived,
      archivedAt: DateTime.now(),
    );
    await updateTask(updatedTask);
  }

  Future<void> reorderTasks(List<Task> reorderedTasks) async {
    await _repository.reorder(reorderedTasks);
    _tasks = _repository.getAll();
    notifyListeners();
  }

  Future<void> archiveAllTasks() async {
    await _repository.archiveAll();
    _tasks = _repository.getAll();
    notifyListeners();
  }

  Future<void> clearAllTasks() async {
    await _repository.deleteAll();
    _tasks.clear();
    notifyListeners();
  }
}
