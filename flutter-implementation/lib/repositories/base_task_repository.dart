import '../models/task.dart';

/// Abstract base class for task repositories
/// Allows platform-specific implementations (Hive for mobile, SharedPreferences for web)
abstract class BaseTaskRepository {
  Future<void> init();

  Future<void> create(Task task);

  Task? read(String id);

  List<Task> getAll();

  List<Task> getByStatus(TaskStatus status);

  Future<void> update(Task task);

  Future<void> delete(String id);

  Future<void> deleteAll();

  Future<void> updateMany(List<Task> tasks);

  int getNextOrder();

  Future<void> reorder(List<Task> tasks);

  Future<void> archiveAll();

  Future<void> close();
}
