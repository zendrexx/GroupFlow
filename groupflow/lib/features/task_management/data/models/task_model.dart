import 'package:groupflow/features/task_management/domain/entities/task.dart';

class TaskModel extends Task {
  const TaskModel({
    required super.taskId,
    required super.projectId,
    required super.title,
    required super.description,
    super.assignedTo,
    required super.createdBy,
    required super.priority,
    required super.status,
    super.dueDate,
    required super.createdAt,
    required super.updatedAt,
    super.completedAt,
  });

  factory TaskModel.fromJson(Map<String, dynamic> json) {
    return TaskModel(
      taskId: json['task_id'] as String,
      projectId: json['project_id'] as String,
      title: json['title'] as String,
      description: json['description'] as String? ?? '',
      assignedTo: json['assigned_to'] as String?,
      createdBy: json['created_by'] as String,
      priority: _parsePriority(json['priority'] as String),
      status: _parseStatus(json['status'] as String),
      dueDate: json['due_date'] != null
          ? DateTime.parse(json['due_date'] as String)
          : null,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      completedAt: json['completed_at'] != null
          ? DateTime.parse(json['completed_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toInsertJson({
    required String projectId,
    required String title,
    required String description,
    required String createdBy,
    required TaskPriority priority,
    String? assignedTo,
    DateTime? dueDate,
  }) {
    return {
      'project_id': projectId,
      'title': title,
      'description': description,
      'created_by': createdBy,
      'assigned_to': assignedTo,
      'priority': priority.name,
      'status': TaskStatus.todo.name,
      'due_date': dueDate?.toIso8601String(),
    };
  }

  Map<String, dynamic> toUpdateJson({
    String? title,
    String? description,
    String? assignedTo,
    TaskPriority? priority,
    TaskStatus? status,
    DateTime? dueDate,
    DateTime? completedAt,
  }) {
    final map = <String, dynamic>{
      'updated_at': DateTime.now().toIso8601String(),
    };
    if (title != null) map['title'] = title;
    if (description != null) map['description'] = description;
    if (assignedTo != null) map['assigned_to'] = assignedTo;
    if (priority != null) map['priority'] = priority.name;
    if (status != null) map['status'] = status.name;
    if (dueDate != null) map['due_date'] = dueDate.toIso8601String();
    if (completedAt != null) {
      map['completed_at'] = completedAt.toIso8601String();
    }
    return map;
  }

  static TaskPriority _parsePriority(String value) {
    return TaskPriority.values.firstWhere(
      (e) => e.name == value,
      orElse: () => TaskPriority.medium,
    );
  }

  static TaskStatus _parseStatus(String value) {
    return TaskStatus.values.firstWhere(
      (e) => e.name == value,
      orElse: () => TaskStatus.todo,
    );
  }
}
