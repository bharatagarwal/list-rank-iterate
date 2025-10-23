import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:moon_design/moon_design.dart';
import 'package:provider/provider.dart';
import 'models/task.dart';
import 'providers/task_provider.dart';
import 'repositories/base_task_repository.dart';
import 'repositories/task_repository.dart';
import 'repositories/shared_preferences_task_repository.dart';
import 'screens/task_list_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Conditionally choose the repository based on the platform
  // Web (WASM): Use SharedPreferences with localStorage
  // Mobile/Desktop: Use Hive with file system
  final dynamic taskRepository =
      kIsWeb ? SharedPreferencesTaskRepository() : TaskRepository();

  // Initialize platform-specific dependencies if not on web
  if (!kIsWeb) {
    await Hive.initFlutter();
    Hive.registerAdapter(TaskAdapter());
    Hive.registerAdapter(TaskStatusAdapter());
  }

  // Initialize the chosen repository
  await taskRepository.init();

  runApp(MyApp(taskRepository: taskRepository));
}

class MyApp extends StatelessWidget {
  final BaseTaskRepository taskRepository;

  const MyApp({super.key, required this.taskRepository});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => TaskProvider(taskRepository)..loadTasks(),
      child: MaterialApp(
        title: 'List, Rank, Iterate',
        theme: _buildLightTheme(),
        darkTheme: _buildDarkTheme(),
        themeMode: ThemeMode.system,
        home: const TaskListScreen(),
      ),
    );
  }

  ThemeData _buildLightTheme() {
    final base = ThemeData(
      brightness: Brightness.light,
      useMaterial3: true,
    );

    return base.copyWith(
      scaffoldBackgroundColor: MoonTokens.light.colors.gohan,
      appBarTheme: AppBarTheme(
        backgroundColor: MoonTokens.light.colors.goku,
        foregroundColor: MoonTokens.light.colors.bulma,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        titleTextStyle: MoonTokens.light.typography.heading.text20.copyWith(
          color: MoonTokens.light.colors.bulma,
        ),
      ),
      colorScheme: base.colorScheme.copyWith(
        primary: MoonTokens.light.colors.piccolo,
        secondary: MoonTokens.light.colors.hit,
      ),
      extensions: <ThemeExtension<dynamic>>[
        MoonTheme(tokens: MoonTokens.light),
      ],
    );
  }

  ThemeData _buildDarkTheme() {
    final base = ThemeData(
      brightness: Brightness.dark,
      useMaterial3: true,
    );

    return base.copyWith(
      scaffoldBackgroundColor: MoonTokens.dark.colors.gohan,
      appBarTheme: AppBarTheme(
        backgroundColor: MoonTokens.dark.colors.goku,
        foregroundColor: MoonTokens.dark.colors.bulma,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        titleTextStyle: MoonTokens.dark.typography.heading.text20.copyWith(
          color: MoonTokens.dark.colors.bulma,
        ),
      ),
      colorScheme: base.colorScheme.copyWith(
        primary: MoonTokens.dark.colors.piccolo,
        secondary: MoonTokens.dark.colors.hit,
      ),
      extensions: <ThemeExtension<dynamic>>[
        MoonTheme(tokens: MoonTokens.dark),
      ],
    );
  }
}
