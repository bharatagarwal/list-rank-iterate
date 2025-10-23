import 'dart:async';

import 'package:flutter/material.dart';
import 'package:moon_design/moon_design.dart';
import 'package:provider/provider.dart';

import '../models/task.dart';
import '../providers/task_provider.dart';
import '../widgets/task_card.dart';
import '../widgets/task_list_empty_state.dart';
import 'archived_tasks_screen.dart';

class TaskListScreen extends StatefulWidget {
  const TaskListScreen({super.key});

  @override
  State<TaskListScreen> createState() => _TaskListScreenState();
}

class _TaskListScreenState extends State<TaskListScreen> {
  String? _editingTaskId;

  Future<void> _openTaskComposer() async {
    final tokens = context.moonTheme?.tokens ?? MoonTokens.light;
    final colors = tokens.colors;
    final typography = tokens.typography;

    final controller = TextEditingController();
    final focusNode = FocusNode();
    String? errorText;

    final result = await showMoonModalBottomSheet<String>(
      context: context,
      isExpanded: true,
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (modalContext, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                left: tokens.sizes.xs,
                right: tokens.sizes.xs,
                top: tokens.sizes.xs,
                bottom:
                    MediaQuery.of(modalContext).viewInsets.bottom +
                    tokens.sizes.xs,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: MoonTag(
                      backgroundColor: colors.whis10,
                      label: Text(
                        'New task',
                        style: typography.body.text12.copyWith(
                          color: colors.piccolo,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: tokens.sizes.x2s),
                  Text(
                    'What do you want to capture?',
                    style: typography.heading.text20.copyWith(
                      color: colors.bulma,
                    ),
                  ),
                  SizedBox(height: tokens.sizes.x3s),
                  MoonTextInput(
                    key: const Key('add-task-input'),
                    controller: controller,
                    focusNode: focusNode,
                    textInputSize: MoonTextInputSize.md,
                    hintText: 'Type a task title',
                    errorText: errorText,
                    onSubmitted: (value) {
                      final trimmed = value.trim();
                      if (trimmed.isEmpty) {
                        setModalState(() {
                          errorText = 'Please enter a task title';
                        });
                        return;
                      }
                      Navigator.of(modalContext).pop(trimmed);
                    },
                  ),
                  SizedBox(height: tokens.sizes.x3s),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      MoonTextButton(
                        label: const Text('Cancel'),
                        onTap: () => Navigator.of(modalContext).pop(),
                      ),
                      SizedBox(width: tokens.sizes.x3s),
                      MoonFilledButton(
                        label: const Text('Add task'),
                        onTap: () {
                          final trimmed = controller.text.trim();
                          if (trimmed.isEmpty) {
                            setModalState(() {
                              errorText = 'Please enter a task title';
                            });
                            return;
                          }
                          Navigator.of(modalContext).pop(trimmed);
                        },
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );

    focusNode.dispose();
    controller.dispose();

    if (!mounted) return;

    final trimmed = result?.trim() ?? '';
    if (trimmed.isEmpty) return;

    await context.read<TaskProvider>().addTask(trimmed);
  }

  Future<void> _handleTaskRename(Task task, String updatedTitle) async {
    final provider = context.read<TaskProvider>();
    await provider.updateTask(task.copyWith(title: updatedTitle));
    if (mounted) {
      setState(() {
        _editingTaskId = null;
      });
    }
  }

  void _cancelEditing() {
    setState(() {
      _editingTaskId = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final tokens = context.moonTheme?.tokens ?? MoonTokens.light;
    final colors = tokens.colors;
    final typography = tokens.typography;

    return Scaffold(
      backgroundColor: colors.gohan,
      appBar: AppBar(
        title: Text(
          'Today\'s tasks',
          style: typography.heading.text20.copyWith(color: colors.bulma),
        ),
        actions: [
          Padding(
            padding: EdgeInsets.only(right: tokens.sizes.x2s),
            child: MoonTextButton(
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => const ArchivedTasksScreen(),
                  ),
                );
              },
              label: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    MoonIcons.files_folder_open_24_light,
                    size: tokens.sizes.sm,
                    color: colors.trunks,
                  ),
                  SizedBox(width: tokens.sizes.x4s),
                  const Text('Archived'),
                ],
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Consumer<TaskProvider>(
          builder: (context, provider, child) {
            if (provider.isLoading) {
              return const Center(child: MoonCircularLoader());
            }

            final activeTasks = provider.activeTasks;

            return RefreshIndicator(
              color: colors.piccolo,
              backgroundColor: colors.goku,
              displacement: tokens.sizes.lg,
              onRefresh: _openTaskComposer,
              child: activeTasks.isEmpty
                  ? ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: EdgeInsets.symmetric(
                        horizontal: tokens.sizes.xs,
                        vertical: tokens.sizes.xs,
                      ),
                      children: [
                        SizedBox(height: tokens.sizes.lg),
                        TaskListEmptyState(
                          key: const Key('active-empty-state'),
                          icon: MoonIcons.text_bullets_list_24_light,
                          title: 'No active tasks yet',
                          description:
                              'Pull down to add your first task and start building momentum.',
                        ),
                      ],
                    )
                  : ListView.separated(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: EdgeInsets.symmetric(
                        horizontal: tokens.sizes.xs,
                        vertical: tokens.sizes.xs,
                      ),
                      itemBuilder: (context, index) {
                        final task = activeTasks[index];
                        return TaskCard(
                          key: ValueKey('task-card-${task.id}'),
                          task: task,
                          isEditing: _editingTaskId == task.id,
                          onTap: () {
                            if (!mounted) return;
                            setState(() => _editingTaskId = task.id);
                          },
                          onCancel: _cancelEditing,
                          onSubmitted: (value) =>
                              _handleTaskRename(task, value),
                        );
                      },
                      separatorBuilder: (context, index) =>
                          SizedBox(height: tokens.sizes.x3s),
                      itemCount: activeTasks.length,
                    ),
            );
          },
        ),
      ),
    );
  }
}
