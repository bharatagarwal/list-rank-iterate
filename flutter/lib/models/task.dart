// ignore_for_file: public_member_api_docs

import 'package:hive/hive.dart';

part 'task.g.dart';

@HiveType(typeId: 0)
enum TaskStatus {
  @HiveField(0)
  active,
  @HiveField(1)
  completed,
  @HiveField(2)
  archived,
}

@HiveType(typeId: 1)
class Task extends HiveObject {

  Task({
    required this.id,
    required this.title,
    required this.status,
    required this.order,
    required this.createdAt,
    this.completedAt,
    this.archivedAt,
  });

  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      id: json['id'] as String,
      title: json['title'] as String,
      status: TaskStatus.values.firstWhere((e) => e.name == json['status']),
      order: json['order'] as int,
      createdAt: DateTime.parse(json['createdAt'] as String),
      completedAt: json['completedAt'] != null
          ? DateTime.parse(json['completedAt'] as String)
          : null,
      archivedAt: json['archivedAt'] != null
          ? DateTime.parse(json['archivedAt'] as String)
          : null,
    );
  }
  @HiveField(0)
  String id;

  @HiveField(1)
  String title;

  @HiveField(2)
  TaskStatus status;

  @HiveField(3)
  int order;

  @HiveField(4)
  DateTime createdAt;

  @HiveField(5)
  DateTime? completedAt;

  @HiveField(6)
  DateTime? archivedAt;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'status': status.name,
      'order': order,
      'createdAt': createdAt.toIso8601String(),
      'completedAt': completedAt?.toIso8601String(),
      'archivedAt': archivedAt?.toIso8601String(),
    };
  }

  Task copyWith({
    String? id,
    String? title,
    TaskStatus? status,
    int? order,
    DateTime? createdAt,
    DateTime? completedAt,
    DateTime? archivedAt,
  }) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      status: status ?? this.status,
      order: order ?? this.order,
      createdAt: createdAt ?? this.createdAt,
      completedAt: completedAt ?? this.completedAt,
      archivedAt: archivedAt ?? this.archivedAt,
    );
  }
}
