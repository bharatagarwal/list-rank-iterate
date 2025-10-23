import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:list_rank_iterate/models/task.dart';
import 'package:list_rank_iterate/providers/task_provider.dart';
import 'package:list_rank_iterate/screens/task_list_screen.dart';
import 'package:list_rank_iterate/widgets/task_card.dart';
import 'package:moon_design/moon_design.dart';
import 'package:provider/provider.dart';

import '../helpers/fake_task_repository.dart';

Future<void> _pumpTaskList(
  WidgetTester tester, {
  required FakeTaskRepository repository,
}) async {
  await tester.pumpWidget(
    ChangeNotifierProvider<TaskProvider>(
      create: (_) => TaskProvider(repository)..loadTasks(),
      child: MaterialApp(
        theme: ThemeData.light().copyWith(
          useMaterial3: true,
          extensions: <ThemeExtension<dynamic>>[
            MoonTheme(tokens: MoonTokens.light),
          ],
        ),
        home: const TaskListScreen(),
      ),
    ),
  );

  await tester.pump();
  await tester.pump(const Duration(milliseconds: 100));
  await tester.pumpAndSettle();
}

Task _buildTask({
  required String id,
  required String title,
  required TaskStatus status,
  required int order,
  Duration createdOffset = const Duration(minutes: 10),
  Duration? completedOffset,
  Duration? archivedOffset,
}) {
  return Task(
    id: id,
    title: title,
    status: status,
    order: order,
    createdAt: DateTime.now().subtract(createdOffset),
    completedAt: completedOffset == null
        ? null
        : DateTime.now().subtract(completedOffset),
    archivedAt: archivedOffset == null
        ? null
        : DateTime.now().subtract(archivedOffset),
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('TaskListScreen renders active tasks from provider', (
    tester,
  ) async {
    final repository = FakeTaskRepository(
      initialTasks: [
        _buildTask(
          id: 'task-1',
          title: 'Draft UI wireframes',
          status: TaskStatus.active,
          order: 0,
        ),
        _buildTask(
          id: 'task-2',
          title: 'Collect user feedback',
          status: TaskStatus.active,
          order: 1,
        ),
      ],
    );

    await _pumpTaskList(tester, repository: repository);

    expect(find.byType(TaskCard), findsNWidgets(2));
    expect(find.text('Draft UI wireframes'), findsOneWidget);
    expect(find.text('Collect user feedback'), findsOneWidget);
  });

  testWidgets('TaskListScreen shows empty state when no active tasks', (
    tester,
  ) async {
    final repository = FakeTaskRepository(initialTasks: const []);

    await _pumpTaskList(tester, repository: repository);

    expect(find.byKey(const Key('active-empty-state')), findsOneWidget);
  });

  testWidgets('Tapping a task opens inline editor', (tester) async {
    final task = _buildTask(
      id: 'task-3',
      title: 'Write release notes',
      status: TaskStatus.active,
      order: 0,
    );
    final repository = FakeTaskRepository(initialTasks: [task]);

    await _pumpTaskList(tester, repository: repository);

    await tester.tap(find.byKey(ValueKey('task-card-${task.id}')));
    await tester.pumpAndSettle();

    expect(find.byKey(Key('task-title-input-${task.id}')), findsOneWidget);
  });

  testWidgets('Archived navigation opens archived tasks screen', (
    tester,
  ) async {
    final repository = FakeTaskRepository(initialTasks: const []);

    await _pumpTaskList(tester, repository: repository);

    await tester.tap(find.text('Archived'));
    await tester.pumpAndSettle();

    expect(find.text('Archive is clean'), findsOneWidget);
  });

  testWidgets('Archived screen lists archived tasks read-only', (tester) async {
    final archivedTask = _buildTask(
      id: 'archived-1',
      title: 'Launch v1.0',
      status: TaskStatus.archived,
      order: 0,
      archivedOffset: const Duration(hours: 2),
    );
    final repository = FakeTaskRepository(initialTasks: [archivedTask]);

    await _pumpTaskList(tester, repository: repository);

    await tester.tap(find.text('Archived'));
    await tester.pumpAndSettle();

    expect(
      find.byKey(ValueKey('archived-task-${archivedTask.id}')),
      findsOneWidget,
    );
    expect(find.text('Launch v1.0'), findsOneWidget);
    expect(
      find.byKey(Key('task-title-input-${archivedTask.id}')),
      findsNothing,
    );
  });
}
