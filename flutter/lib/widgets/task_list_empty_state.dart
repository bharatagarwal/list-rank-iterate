import 'package:flutter/material.dart';
import 'package:moon_design/moon_design.dart';

class TaskListEmptyState extends StatelessWidget {
  const TaskListEmptyState({
    required this.icon,
    required this.title,
    required this.description,
    super.key,
  });
  final IconData icon;
  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    final tokens = context.moonTheme?.tokens ?? MoonTokens.light;
    final colors = tokens.colors;
    final typography = tokens.typography;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: tokens.sizes.xs),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: EdgeInsets.all(tokens.sizes.x4s),
            decoration: BoxDecoration(
              color: colors.whis10,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: tokens.sizes.lg, color: colors.piccolo),
          ),
          SizedBox(height: tokens.sizes.xs),
          Text(
            title,
            style: typography.heading.text18.copyWith(color: colors.bulma),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: tokens.sizes.x4s),
          Text(
            description,
            style: typography.body.text14.copyWith(color: colors.trunks),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
