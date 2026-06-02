enum TaskPriority { low, medium, high }

enum TaskStatus { todo, doing, done }

extension TaskPriorityX on TaskPriority {
  String get label => name[0].toUpperCase() + name.substring(1);
}

extension TaskStatusX on TaskStatus {
  String get label {
    if (this == TaskStatus.doing) return 'In Progress';
    return name[0].toUpperCase() + name.substring(1);
  }
}

class Task {
  final String taskId;
  final String projectId;
  final String title;
  final String description;
  final String? assignedTo;
  final String createdBy;
  final TaskPriority priority;
  final TaskStatus status;
  final DateTime? dueDate;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? completedAt;

  const Task({
    required this.taskId,
    required this.projectId,
    required this.title,
    required this.description,
    this.assignedTo,
    required this.createdBy,
    required this.priority,
    required this.status,
    this.dueDate,
    required this.createdAt,
    required this.updatedAt,
    this.completedAt,
  });

  bool get isOverdue =>
      dueDate != null &&
      dueDate!.isBefore(DateTime.now()) &&
      status != TaskStatus.done;

  bool get isDueTomorrow {
    if (dueDate == null) return false;
    final now = DateTime.now();
    final tomorrow = DateTime(now.year, now.month, now.day + 1);
    final due = DateTime(dueDate!.year, dueDate!.month, dueDate!.day);
    return due == tomorrow;
  }

  Task copyWith({
    String? title,
    String? description,
    String? assignedTo,
    TaskPriority? priority,
    TaskStatus? status,
    DateTime? dueDate,
    DateTime? completedAt,
  }) {
    return Task(
      taskId: taskId,
      projectId: projectId,
      title: title ?? this.title,
      description: description ?? this.description,
      assignedTo: assignedTo ?? this.assignedTo,
      createdBy: createdBy,
      priority: priority ?? this.priority,
      status: status ?? this.status,
      dueDate: dueDate ?? this.dueDate,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
      completedAt: completedAt ?? this.completedAt,
    );
  }
}
