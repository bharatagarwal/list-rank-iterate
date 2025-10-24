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

    final result = await showMoonModalBottomSheet<String>(
      context: context,
      isExpanded: true,
      builder: (sheetContext) {
        return _TaskComposerModal(
          tokens: tokens,
          colors: colors,
          typography: typography,
        );
      },
    );

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

class _TaskComposerModal extends StatefulWidget {
  final MoonTokens tokens;
  final MoonColors colors;
  final MoonTypography typography;

  const _TaskComposerModal({
    required this.tokens,
    required this.colors,
    required this.typography,
  });

  @override
  State<_TaskComposerModal> createState() => _TaskComposerModalState();
}

class _TaskComposerModalState extends State<_TaskComposerModal> {
  late final TextEditingController _controller;
  late final FocusNode _focusNode;
  String? _errorText;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
    _focusNode = FocusNode();
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _handleSubmit(BuildContext context) {
    final trimmed = _controller.text.trim();
    if (trimmed.isEmpty) {
      setState(() {
        _errorText = 'Please enter a task title';
      });
      return;
    }
    Navigator.of(context).pop(trimmed);
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Padding(
        padding: EdgeInsets.only(
          left: widget.tokens.sizes.xs,
          right: widget.tokens.sizes.xs,
          top: widget.tokens.sizes.xs,
          bottom: MediaQuery.of(context).viewInsets.bottom + widget.tokens.sizes.xs,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: MoonTag(
                backgroundColor: widget.colors.whis10,
                label: Text(
                  'New task',
                  style: widget.typography.body.text12.copyWith(
                    color: widget.colors.piccolo,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            SizedBox(height: widget.tokens.sizes.x2s),
            Text(
              'What do you want to capture?',
              style: widget.typography.heading.text20.copyWith(
                color: widget.colors.bulma,
              ),
            ),
            SizedBox(height: widget.tokens.sizes.x3s),
            MoonTextInput(
              key: const Key('add-task-input'),
              controller: _controller,
              focusNode: _focusNode,
              textInputSize: MoonTextInputSize.md,
              hintText: 'Type a task title',
              errorText: _errorText,
              onSubmitted: (_) => _handleSubmit(context),
            ),
            SizedBox(height: widget.tokens.sizes.x3s),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                MoonTextButton(
                  label: const Text('Cancel'),
                  onTap: () => Navigator.of(context).pop(),
                ),
                SizedBox(width: widget.tokens.sizes.x3s),
                MoonFilledButton(
                  label: const Text('Add task'),
                  onTap: () => _handleSubmit(context),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
