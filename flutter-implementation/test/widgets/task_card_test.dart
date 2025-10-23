import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:list_rank_iterate/models/task.dart';
import 'package:list_rank_iterate/widgets/task_card.dart';
import 'package:moon_design/moon_design.dart';

Widget _wrapWithTheme(Widget child) {
  return MaterialApp(
    theme: ThemeData.light().copyWith(
      useMaterial3: true,
      extensions: <ThemeExtension<dynamic>>[
        MoonTheme(tokens: MoonTokens.light),
      ],
    ),
    home: Scaffold(
      body: Padding(padding: const EdgeInsets.all(16), child: child),
    ),
  );
}

Task _buildTask({
  String id = 'task-1',
  String title = 'Write widget tests',
  TaskStatus status = TaskStatus.active,
  int order = 0,
}) {
  return Task(
    id: id,
    title: title,
    status: status,
    order: order,
    createdAt: DateTime.now().subtract(const Duration(minutes: 10)),
    completedAt: status == TaskStatus.completed
        ? DateTime.now().subtract(const Duration(minutes: 5))
        : null,
    archivedAt: status == TaskStatus.archived
        ? DateTime.now().subtract(const Duration(minutes: 2))
        : null,
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('TaskCard displays title and status badge', (tester) async {
    final task = _buildTask();

    await tester.pumpWidget(
      _wrapWithTheme(TaskCard(task: task, isEditable: false)),
    );

    expect(find.text('Write widget tests'), findsOneWidget);
    expect(find.text('Active'), findsOneWidget);
  });

  testWidgets('TaskCard shows editor when in editing mode', (tester) async {
    final task = _buildTask();
    var submittedValue = '';

    await tester.pumpWidget(
      _wrapWithTheme(
        TaskCard(
          task: task,
          isEditable: true,
          isEditing: true,
          onTap: () {},
          onCancel: () {},
          onSubmitted: (value) async {
            submittedValue = value;
          },
        ),
      ),
    );

    final inputFinder = find.byKey(Key('task-title-input-${task.id}'));
    expect(inputFinder, findsOneWidget);

    await tester.enterText(inputFinder, 'Refine widget tests');
    await tester.tap(find.text('Save'));
    await tester.pump();

    expect(submittedValue, 'Refine widget tests');
  });
}
