import 'package:flutter/material.dart';
import 'package:moon_design/moon_design.dart';
import 'package:provider/provider.dart';

import '../providers/task_provider.dart';
import '../widgets/task_card.dart';
import '../widgets/task_list_empty_state.dart';

class ArchivedTasksScreen extends StatelessWidget {
  const ArchivedTasksScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final tokens = context.moonTheme?.tokens ?? MoonTokens.light;
    final colors = tokens.colors;
    final typography = tokens.typography;

    return Scaffold(
      backgroundColor: colors.gohan,
      appBar: AppBar(
        title: Text(
          'Archived tasks',
          style: typography.heading.text20.copyWith(color: colors.bulma),
        ),
      ),
      body: SafeArea(
        child: Consumer<TaskProvider>(
          builder: (context, provider, child) {
            final archivedTasks = provider.archivedTasks;

            if (archivedTasks.isEmpty) {
              return ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: EdgeInsets.symmetric(
                  horizontal: tokens.sizes.xs,
                  vertical: tokens.sizes.xs,
                ),
                children: [
                  SizedBox(height: tokens.sizes.lg),
                  TaskListEmptyState(
                    key: const Key('archive-empty-state'),
                    icon: MoonIcons.files_folder_open_24_light,
                    title: 'Archive is clean',
                    description:
                        'Completed or archived tasks will show up here for reference.',
                  ),
                ],
              );
            }

            return ListView.separated(
              padding: EdgeInsets.symmetric(
                horizontal: tokens.sizes.xs,
                vertical: tokens.sizes.xs,
              ),
              itemBuilder: (context, index) {
                final task = archivedTasks[index];
                return TaskCard(
                  key: ValueKey('archived-task-${task.id}'),
                  task: task,
                  isEditable: false,
                );
              },
              separatorBuilder: (context, index) =>
                  SizedBox(height: tokens.sizes.x3s),
              itemCount: archivedTasks.length,
            );
          },
        ),
      ),
    );
  }
}
