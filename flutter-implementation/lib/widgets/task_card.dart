import 'dart:async';

import 'package:flutter/material.dart';
import 'package:moon_design/moon_design.dart';

import '../models/task.dart';

class TaskCard extends StatefulWidget {
  final Task task;
  final bool isEditing;
  final Future<void> Function(String)? onSubmitted;
  final VoidCallback? onTap;
  final VoidCallback? onCancel;
  final bool isEditable;

  const TaskCard({
    super.key,
    required this.task,
    this.isEditing = false,
    this.onSubmitted,
    this.onTap,
    this.onCancel,
    this.isEditable = true,
  }) : assert(
         (!isEditable && !isEditing) ||
         (isEditable && onSubmitted != null && onTap != null && onCancel != null),
         'TaskCard with isEditable=true requires onTap, onSubmitted, and onCancel callbacks. '
         'Also, isEditing cannot be true when isEditable is false.',
       );

  @override
  State<TaskCard> createState() => _TaskCardState();
}

class _TaskCardState extends State<TaskCard> {
  late final TextEditingController _controller;
  final FocusNode _focusNode = FocusNode();
  String? _errorText;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.task.title);

    if (widget.isEditing && widget.isEditable) {
      scheduleMicrotask(_requestFocus);
    }
  }

  @override
  void didUpdateWidget(covariant TaskCard oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.task.title != oldWidget.task.title &&
        _controller.text != widget.task.title) {
      _controller.text = widget.task.title;
    }

    if (widget.isEditing && !oldWidget.isEditing && widget.isEditable) {
      _controller.selection = TextSelection.collapsed(
        offset: widget.task.title.length,
      );
      scheduleMicrotask(_requestFocus);
    } else if (!widget.isEditing && oldWidget.isEditing) {
      if (_focusNode.hasFocus) {
        _focusNode.unfocus();
      }
      _errorText = null;
    }
  }

  void _requestFocus() {
    if (!mounted) return;
    _focusNode.requestFocus();
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit(String rawValue) async {
    final trimmed = rawValue.trim();

    if (trimmed.isEmpty) {
      setState(() {
        _errorText = 'Title cannot be empty';
      });
      return;
    }

    if (trimmed == widget.task.title) {
      widget.onCancel?.call();
      return;
    }

    setState(() => _errorText = null);

    await widget.onSubmitted?.call(trimmed);
    _focusNode.unfocus();
  }

  @override
  Widget build(BuildContext context) {
    final tokens = context.moonTheme?.tokens ?? MoonTokens.light;
    final colors = tokens.colors;
    final typography = tokens.typography;

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 200),
      switchInCurve: tokens.transitions.defaultTransitionCurve,
      switchOutCurve: tokens.transitions.defaultTransitionCurve,
      child: widget.isEditing && widget.isEditable
          ? _buildEditingState(tokens, colors, typography)
          : _buildDisplayState(tokens, colors, typography),
    );
  }

  Widget _buildEditingState(
    MoonTokens tokens,
    MoonColors colors,
    MoonTypography typography,
  ) {
    return Container(
      key: ValueKey('task-card-edit-${widget.task.id}'),
      padding: EdgeInsets.all(tokens.sizes.x2s),
      decoration: BoxDecoration(
        color: colors.goku,
        borderRadius: tokens.borders.interactiveMd,
        border: Border.all(
          color: colors.piccolo.withOpacity(0.4),
          width: tokens.borders.activeBorderWidth,
        ),
        boxShadow: [
          BoxShadow(
            color: colors.piccolo.withOpacity(context.isDarkMode ? 0.32 : 0.12),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: MoonTag(
              backgroundColor: _statusBackgroundColor(colors),
              label: Text(
                _statusLabel(),
                style: typography.body.text12.copyWith(
                  color: _statusAccentColor(colors),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          SizedBox(height: tokens.sizes.x3s),
          MoonTextInput(
            key: Key('task-title-input-${widget.task.id}'),
            controller: _controller,
            focusNode: _focusNode,
            textCapitalization: TextCapitalization.sentences,
            hintText: 'Update task title',
            errorText: _errorText,
            onSubmitted: _handleSubmit,
          ),
          SizedBox(height: tokens.sizes.x3s),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              MoonTextButton(
                label: const Text('Cancel'),
                onTap: () {
                  _controller.text = widget.task.title;
                  setState(() => _errorText = null);
                  _focusNode.unfocus();
                  widget.onCancel?.call();
                },
              ),
              SizedBox(width: tokens.sizes.x3s),
              MoonFilledButton(
                label: const Text('Save'),
                onTap: () => _handleSubmit(_controller.text),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDisplayState(
    MoonTokens tokens,
    MoonColors colors,
    MoonTypography typography,
  ) {
    final statusAccent = _statusAccentColor(colors);

    return MoonMenuItem(
      key: ValueKey('task-card-display-${widget.task.id}'),
      onTap: widget.isEditable ? widget.onTap : null,
      backgroundColor: colors.goku,
      borderRadius: tokens.borders.surfaceSm,
      leading: Icon(
        MoonIcons.text_bullets_list_24_light,
        color: statusAccent,
        size: tokens.sizes.sm,
      ),
      label: Text(
        widget.task.title,
        style: typography.heading.text16.copyWith(color: colors.bulma),
      ),
      content: Padding(
        padding: EdgeInsets.only(top: tokens.sizes.x4s),
        child: Row(
          children: [
            MoonTag(
              backgroundColor: _statusBackgroundColor(colors),
              label: Text(
                _statusLabel(),
                style: typography.body.text10.copyWith(
                  color: statusAccent,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            SizedBox(width: tokens.sizes.x4s),
            Expanded(
              child: Text(
                _secondaryLabel(),
                style: typography.body.text12.copyWith(color: colors.trunks),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
      trailing: widget.isEditable
          ? Icon(
              MoonIcons.generic_edit_24_light,
              color: colors.trunks,
              size: tokens.sizes.sm,
            )
          : null,
    );
  }

  String _statusLabel() {
    switch (widget.task.status) {
      case TaskStatus.active:
        return 'Active';
      case TaskStatus.completed:
        return 'Completed';
      case TaskStatus.archived:
        return 'Archived';
    }
  }

  String _secondaryLabel() {
    switch (widget.task.status) {
      case TaskStatus.active:
        return 'Added ${_formatRelativeTime(widget.task.createdAt)}';
      case TaskStatus.completed:
        final completedAt = widget.task.completedAt ?? widget.task.createdAt;
        return 'Completed ${_formatRelativeTime(completedAt)}';
      case TaskStatus.archived:
        final archivedAt =
            widget.task.archivedAt ??
            widget.task.completedAt ??
            widget.task.createdAt;
        return 'Archived ${_formatRelativeTime(archivedAt)}';
    }
  }

  Color _statusAccentColor(MoonColors colors) {
    switch (widget.task.status) {
      case TaskStatus.active:
        return colors.piccolo;
      case TaskStatus.completed:
        return colors.roshi;
      case TaskStatus.archived:
        return colors.trunks;
    }
  }

  Color _statusBackgroundColor(MoonColors colors) {
    switch (widget.task.status) {
      case TaskStatus.active:
        return colors.whis10;
      case TaskStatus.completed:
        return colors.roshi10;
      case TaskStatus.archived:
        return colors.heles;
    }
  }

  String _formatRelativeTime(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inDays >= 7) {
      final date = timestamp.toLocal();
      return '${_twoDigits(date.day)} ${_monthLabel(date.month)}';
    }

    if (difference.inDays >= 1) {
      final days = difference.inDays;
      return '$days day${days == 1 ? '' : 's'} ago';
    }

    if (difference.inHours >= 1) {
      final hours = difference.inHours;
      return '$hours h ago';
    }

    if (difference.inMinutes >= 1) {
      final minutes = difference.inMinutes;
      return '$minutes min ago';
    }

    return 'Just now';
  }

  String _twoDigits(int value) => value.toString().padLeft(2, '0');

  String _monthLabel(int month) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return months[month - 1];
  }
}
