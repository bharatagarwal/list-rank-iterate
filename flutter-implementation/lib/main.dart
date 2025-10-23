import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:moon_design/moon_design.dart';
import 'package:provider/provider.dart';
import 'models/task.dart';
import 'providers/task_provider.dart';
import 'repositories/task_repository.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Hive
  await Hive.initFlutter();

  // Register Hive adapters
  Hive.registerAdapter(TaskAdapter());
  Hive.registerAdapter(TaskStatusAdapter());

  // Initialize repository
  final taskRepository = TaskRepository();
  await taskRepository.init();

  runApp(MyApp(taskRepository: taskRepository));
}

class MyApp extends StatelessWidget {
  final TaskRepository taskRepository;

  const MyApp({super.key, required this.taskRepository});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => TaskProvider(taskRepository)..loadTasks(),
      child: MaterialApp(
        title: 'List, Rank, Iterate',
        theme: ThemeData.light().copyWith(
          extensions: <ThemeExtension<dynamic>>[
            MoonTheme(
              tokens: MoonTokens.light,
            ),
          ],
        ),
        darkTheme: ThemeData.dark().copyWith(
          extensions: <ThemeExtension<dynamic>>[
            MoonTheme(
              tokens: MoonTokens.dark,
            ),
          ],
        ),
        themeMode: ThemeMode.system,
        home: const MyHomePage(),
      ),
    );
  }
}

class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('List, Rank, Iterate'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Phase 1: Foundation Complete',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            const Text(
              'Data layer with unit tests ready.',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 32),
            Consumer<TaskProvider>(
              builder: (context, taskProvider, child) {
                return Column(
                  children: [
                    Text(
                      'Total Tasks: ${taskProvider.tasks.length}',
                      style: const TextStyle(fontSize: 18),
                    ),
                    Text(
                      'Active: ${taskProvider.activeTasks.length}',
                      style: const TextStyle(fontSize: 18),
                    ),
                    Text(
                      'Completed: ${taskProvider.completedTasks.length}',
                      style: const TextStyle(fontSize: 18),
                    ),
                    Text(
                      'Archived: ${taskProvider.archivedTasks.length}',
                      style: const TextStyle(fontSize: 18),
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final provider = context.read<TaskProvider>();
          await provider.addTask('Test task ${DateTime.now().millisecondsSinceEpoch}');
        },
        tooltip: 'Add Test Task',
        child: const Icon(Icons.add),
      ),
    );
  }
}
